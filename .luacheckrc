codes = true
color = true

std = "max"

include_files = { 
    "lualib/*",
    "service/*",
}

exclude_files = {
    "lualib/xml/*",
    "lualib/ws/*",
    "lualib/bash.lua",
}

ignore = {
    "i",
    "k",
    "v",
    "bash",
    "SERVICE_NAME",
    "self",
}
