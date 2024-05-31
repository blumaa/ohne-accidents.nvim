local M = {}

---@class OhneAccidentsConfig
---@field welcomeOnStartup? boolean Choose whether to display the welcome message on startup.
---@field multiLine? boolean Choose wether the message should be displayed in a single line or multiple lines.
---@field api? "echo" | "notify" Choose whether to use `echo` or `vim.notify` to display the message.
M.config = {
    welcomeOnStartup = true,
    multiLine = true,
    api = "echo",
}

function M.setConfig(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts)
end

function M.notify(message)
    if M.config.api == "echo" then
        vim.api.nvim_echo({ { message, "Title" } }, true, {})
    end

    if M.config.api == "notify" then
        vim.api.nvim_notify(message, vim.log.levels.INFO, { title = " Ohne Accidents" })
    end

    if M.config.api ~= "echo" and M.config.api ~= "notify" then
        error("Invalid notifyApi option")
    end
end

-- Calculates the time since last modification of any config file
local function timeSinceLastChange()
    local config_dir = vim.fn.stdpath("config")
    local files = vim.fn.split(vim.fn.glob(config_dir .. "/**/*.lua"), "\n")

    local last_modified = 0
    local current_time = os.time()

    for _, file in pairs(files) do
        local modified_time = vim.fn.getftime(file)
        last_modified = modified_time > last_modified and modified_time or last_modified
    end

    local diff_seconds = os.difftime(current_time, last_modified)
    local days = vim.fn.floor(diff_seconds / 86400)
    local hours = vim.fn.floor((diff_seconds % 86400) / 3600)
    local minutes = vim.fn.floor((diff_seconds % 3600) / 60)
    local seconds = vim.fn.floor(diff_seconds % 60)

    return days, hours, minutes, seconds
end

function M.welcomeOnStartup()
    if not M.config.welcomeOnStartup then
        return
    end

    local days = timeSinceLastChange()

    if M.config.multiLine then
        local message = string.format(
            "╔════╗\n║ %2d ║ Days Without Editing the Configuration\n╚════╝",
            days
        )
        M.notify(message)
    else
        local message = string.format("%2d Days Without Editing the Configuration", days)

        M.notify(message)
    end
end

function M.displayDetailedMessage()
    local days, hours, minutes, seconds = timeSinceLastChange()

    if M.config.multiLine then
        local message = string.format(
            "╔════╗\n║ %2d ║ Days\n║ %2d ║ Hours\n║ %2d ║ Minutes\n║ %2d ║ Seconds\n╚════╝ Without Editing the Configuration",
            days,
            hours,
            minutes,
            seconds
        )

        M.notify(message)
    else
        local message = string.format(
            "%2d Days, %2d Hours, %2d Minutes, %2d Seconds Without Editing the Configuration.",
            days,
            hours,
            minutes,
            seconds
        )

        M.notify(message)
    end
end

function M.setup(opts)
    if opts then
        M.setConfig(opts)
    end

    M.welcomeOnStartup()

    vim.api.nvim_command('command! OhneAccidents lua require("ohne-accidents").displayDetailedMessage()')
end

return M
