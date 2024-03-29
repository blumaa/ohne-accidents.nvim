-- ohne-accidents.lua

local M = {}

M.config = {
  welcomeOnStartup = true
}

-- Function to set configuration options
function M.setConfig(opts)
  for k, v in pairs(opts) do
    if M.config[k] ~= nil then
      M.config[k] = v
    end
  end
end

-- Function to calculate the time since last modification of any config file
local function timeSinceLastChange()
  -- local config_dir = vim.fn.expand("~/.config/nvim")
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

-- Function to display the message on the welcome screen
function M.welcomeOnStartup()
  if not M.config.welcomeOnStartup then
    return
  end

  local days = timeSinceLastChange()
  local message = string.format("╔════╗\n║ %2d ║ Days Without Editing the Configuration\n╚════╝", days)
  vim.api.nvim_echo({ { message, "Title" } }, true, {})
end

-- Function to display the detailed message
function M.displayDetailedMessage()
  local days, hours, minutes, seconds = timeSinceLastChange()
  local message = string.format(
    "╔════╗\n║ %2d ║ Days\n║ %2d ║ Hours\n║ %2d ║ Minutes\n║ %2d ║ Seconds\n╚════╝ Without Editing the Configuration",
    days,
    hours, minutes, seconds)
  vim.api.nvim_echo({ { message, "Title" } }, true, {})
end

function M.handleCommand(arg)
  if arg == 'status' then
    M.displayDetailedMessage()
  end
end

-- Initialization function
function M.setup(opts)
  if opts then
    M.setConfig(opts)
  end

  M.welcomeOnStartup()

  vim.api.nvim_command('command! OhneAccidents lua require("ohne-accidents").displayDetailedMessage()')
end

return M
