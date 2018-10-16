local skynet = require "skynet"
local class = require "class"
local util = require "util"

local M = class("timer_t")
function M:ctor()
    self._top = nil
    self._cancel = nil
end

function M:destroy()
    if self._cancel then
        self._cancel()
    end
    self._top = nil
    self._cancel = nil
end

function M:cancelable_timeout(delta, func)
    if delta <= 0 then
        func()
        return
    end
    local function cb()
        if func then
            func()
        end
    end
    local function cancel()
        func = nil
    end
    skynet.timeout(delta*100//1, cb)
    return cancel
end

function M:start()
    assert(self._top)
    self._cancel = self:cancelable_timeout(self._top.ti - skynet.time(), function()
        util.try(function()
            self._top.cb()
        end)
        self:next()
    end)
end

function M:cancel()
    self._cancel()
end

function M:next()
    --print("next")
    self._top = self._top.next
    if self._top then
        self:start()
    end
    --self:dump()
end

function M:timeout(expire, cb)
    assert(type(expire) == "number")
    assert(type(cb) == "function")
    
    local node = {
        ti = skynet.time() + expire/100,
        cb = cb,
    }

    if not self._top then
        self._top = node 
        self:start()
    else
        if node.ti < self._top.ti then
            node.next = self._top
            self._top = node
            self:cancel()
            self:start()
        else
            local cur = self._top
            local prev
            while cur do 
                if prev and prev.ti <= node.ti and cur.ti > node.ti then
                    if prev then
                        prev.next = node
                    end
                    node.next = cur
                    return
                end
                prev = cur
                cur = cur.next
            end
            prev.next = node
        end
    end
end

function M:dump()
    local str = ""
    local cur = self._top
    while cur do
        str = str .. "," .. cur.ti
        cur = cur.next
    end
    --print("timer:"..str)
end

return M
