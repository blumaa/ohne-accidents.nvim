-- ohne-accidents.lua

local M = {}

-- Function to calculate the number of days since last modification of any config file
local function daysSinceLastChange()
    local config_dir = vim.fn.expand("~/.config/nvim")
    local files = vim.fn.split(vim.fn.glob(config_dir .. "/**/*.lua"), "\n")

    local last_modified = 0
    local current_time = os.time()

    for _, file in pairs(files) do
        local modified_time = vim.fn.getftime(file)
        last_modified = modified_time > last_modified and modified_time or last_modified
    end

    return vim.fn.floor(os.difftime(current_time, last_modified) / 86400)
end

-- Function to display the message on the welcome screen
function M.displayWelcomeMessage()
    local days_without_change = daysSinceLastChange()
    local message = string.format("╔════╗\n║ %2d ║ Days Without Editing the Configuration\n╚════╝", days_without_change)
    vim.api.nvim_echo({{message, "Title"}}, true, {})
end

-- Initialization function
function M.setup()
    M.displayWelcomeMessage()
end

return M

