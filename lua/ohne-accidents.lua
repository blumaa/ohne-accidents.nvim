local M = {}

---@class OhneAccidentsConfig
---@field welcomeOnStartup? boolean Choose whether to display the welcome message on startup.
---@field multiLine? boolean Choose wether the message should be displayed in a single line or multiple lines.
---@field api? "echo" | "notify" Choose whether to use `echo` or `vim.notify` to display the message.
---@field useLastCommit? boolean Use the date of the last commit as the indicator for the time of last changes.
M.config = {
    welcomeOnStartup = true,
    multiLine = true,
    api = "echo",
    useLastCommit = false,
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

-- Get the last commit date in Unix timestamp format
local function getLastCommitDate()
    local handle = io.popen("git -C " .. vim.fn.stdpath("config") .. " log -1 --format=%ct")
    if not handle then
        return 0
    else
        local result = handle:read("*a")
        handle:close()
        return tonumber(result)
    end
end

-- Calculates the time since the last modification or the last commit date
local function timeSinceLastChange()
    local last_modified = 0

    if M.config.useLastCommit then
        last_modified = getLastCommitDate()
    else
        local config_dir = vim.fn.stdpath("config")
        local files = vim.fn.split(vim.fn.glob(config_dir .. "/**/*.lua"), "\n")

        for _, file in pairs(files) do
            local modified_time = vim.fn.getftime(file)
            last_modified = modified_time > last_modified and modified_time or last_modified
        end
    end

    local current_time = os.time()
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
    local message_template = M.config.useLastCommit and "Days Since Last Commit"
        or "Days Without Editing the Configuration"

    if M.config.multiLine then
        local message = string.format("╔════╗\n║ %2d ║ %s\n╚════╝", days, message_template)
        M.notify(message)
    else
        local message = string.format("%2d %s", days, message_template)

        M.notify(message)
    end
end

function M.displayDetailedMessage()
    local days, hours, minutes, seconds = timeSinceLastChange()
    local message_template = M.config.useLastCommit and "Since Last Commit" or "Without Editing the Configuration"

    if M.config.multiLine then
        local message = string.format(
            "╔════╗\n║ %2d ║ Days\n║ %2d ║ Hours\n║ %2d ║ Minutes\n║ %2d ║ Seconds\n╚════╝ %s",
            days,
            hours,
            minutes,
            seconds,
            message_template
        )

        M.notify(message)
    else
        local message = string.format(
            "%2d Days, %2d Hours, %2d Minutes, %2d Seconds %s.",
            days,
            hours,
            minutes,
            seconds,
            message_template
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
