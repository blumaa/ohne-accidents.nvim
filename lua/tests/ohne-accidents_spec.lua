-- ohne-accidents_spec.lua

-- Get the directory of the current script
local script_dir = debug.getinfo(1, "S").source:match("@(.*/)")
-- Add the parent directory to package.path
package.path = package.path .. ";" .. script_dir .. "../?.lua"
-- Now require the module by name
local ohne_accidents = require("ohne-accidents")

describe("ohne-accidents", function()
    before_each(function()
        ohne_accidents.setConfig({ welcomeOnStartup = false })
    end)

    local mock_vim = {
        fn = {
            expand = function()
                return "/home/user/.config/nvim"
            end,
            split = function()
                return { "file1.lua", "file2.lua" }
            end,
            glob = function()
                return "file1.lua\nfile2.lua"
            end,
            getftime = function()
                return 1628000000
            end, -- Mocked file modification time
            floor = function(x)
                return math.floor(x)
            end,
            stdpath = function()
                return "/home/user/.config/nvim"
            end, -- Mocked stdpath function
        },
        api = {
            nvim_echo = function() end,
        },
    }

    -- Mock os.time to return the same value as getftime
    local original_os_time = os.time
    os.time = function()
        return 1628000000
    end

    setup(function()
        _G.vim = mock_vim
    end)

    teardown(function()
        os.time = original_os_time
    end)

    it("displays welcome message", function()
        -- Set the welcomeOnStartup configuration option to true
        ohne_accidents.setConfig({ welcomeOnStartup = true })

        local spy = require("luassert.spy")
        local nvim_echo_spy = spy.on(vim.api, "nvim_echo")

        ohne_accidents.welcomeOnStartup()

        assert.spy(nvim_echo_spy).was.called_with(
            { { "╔════╗\n║  0 ║ Days Without Editing the Configuration\n╚════╝", "Title" } },
            true,
            {}
        )
    end)

    it("displays welcome message with 33 days", function()
        -- Adjust os.time to return a value that is 33 days later than getftime
        os.time = function()
            return 1628000000 + 33 * 86400
        end

        -- Set the welcomeOnStartup configuration option to true
        ohne_accidents.setConfig({ welcomeOnStartup = true })

        local spy = require("luassert.spy")
        local nvim_echo_spy = spy.on(vim.api, "nvim_echo")

        ohne_accidents.welcomeOnStartup()

        assert.spy(nvim_echo_spy).was.called_with(
            { { "╔════╗\n║ 33 ║ Days Without Editing the Configuration\n╚════╝", "Title" } },
            true,
            {}
        )
    end)

    it("displays detailed message", function()
        -- Adjust os.time to return a value that is 33 days, 7 hours, 46 minutes, and 40 seconds later than getftime
        os.time = function()
            return 1628000000 + 33 * 86400 + 7 * 3600 + 46 * 60 + 40
        end

        local spy = require("luassert.spy")
        local nvim_echo_spy = spy.on(vim.api, "nvim_echo")

        ohne_accidents.displayDetailedMessage()

        assert.spy(nvim_echo_spy).was.called_with(
            {
                {
                    "╔════╗\n║ 33 ║ Days\n║  7 ║ Hours\n║ 46 ║ Minutes\n║ 40 ║ Seconds\n╚════╝ Without Editing the Configuration",
                    "Title",
                },
            },
            true,
            {}
        )
    end)

    it("displays welcome message on startup", function()
        -- Reset os.time to return the same value as getftime
        os.time = function()
            return 1628000000
        end

        -- Set the welcomeOnStartup configuration option to true
        ohne_accidents.setConfig({ welcomeOnStartup = true })

        local spy = require("luassert.spy")
        local nvim_echo_spy = spy.on(vim.api, "nvim_echo")

        ohne_accidents.welcomeOnStartup()

        assert.spy(nvim_echo_spy).was.called_with(
            { { "╔════╗\n║  0 ║ Days Without Editing the Configuration\n╚════╝", "Title" } },
            true,
            {}
        )
    end)

    it("welcomeOnStartup is false by default", function()
        assert.is_false(ohne_accidents.config.welcomeOnStartup)
    end)
end)
