local wezterm = require("wezterm")
local act = wezterm.action

---@class Config
local M = {}

-- Plugin configuration
M.config = {
	debug = false,
	namespace = "plugins.portal",
}

-- Helper function for logging
local function log(message, force)
	if M.config.debug or force then
		wezterm.log_info(string.format("[%s] %s", M.config.namespace, message))
	end
end

-- Initialize the plugin state
local function init_plugin_state()
	wezterm.GLOBAL.plugins = wezterm.GLOBAL.plugins or {}
	local plugin_state = wezterm.GLOBAL.plugins[M.config.namespace]
		or {
			initialized = false,
			workspace_cache = {},
		}
	wezterm.GLOBAL.plugins[M.config.namespace] = plugin_state
	return plugin_state
end

-- Enable/disable debug logging
function M.set_debug(enabled)
	M.config.debug = enabled
	log(string.format("Debug logging %s", enabled and "enabled" or "disabled"), true)
end

-- Function to create spawn configuration safely
local function create_spawn_config(config)
	local spawn_config = {
		label = config.name,
		args = config.action.args or {},
		cwd = config.action.cwd,
	}

	-- Handle environment variables correctly
	if config.action.env then
		spawn_config.set_environment_variables = config.action.env
	end

	return spawn_config
end

-- Function to teleport between workspaces
function M.teleport(config)
	return wezterm.action_callback(function(window, pane)
		local plugin_state = init_plugin_state()
		local current_workspace = window:active_workspace()
		log(string.format("Current workspace: %s", current_workspace))

		if current_workspace == config.name then
			-- We're in the target session, switch back to the cached workspace
			local last_workspace = plugin_state.workspace_cache[config.name]
			log(string.format("Attempting to switch back. Last workspace: %s", last_workspace or "nil"))

			if last_workspace then
				log("Switching back to last workspace")
				window:perform_action(act.SwitchToWorkspace({ name = last_workspace }), pane)
			else
				log("No last workspace, switching to default workspace")
				window:perform_action(act.SwitchToWorkspace({ name = "default" }), pane)
			end
		else
			-- We're not in the target session, switch to it
			log(string.format("Switching to target session: %s", config.name))
			-- Save current workspace before switching
			plugin_state.workspace_cache[config.name] = current_workspace

			-- Check if workspace exists
			local workspace_exists = false
			local workspace_names = wezterm.mux.get_workspace_names()
			for _, name in ipairs(workspace_names) do
				if name == config.name then
					workspace_exists = true
					break
				end
			end

			if workspace_exists then
				log("Workspace exists, switching to it")
				window:perform_action(act.SwitchToWorkspace({ name = config.name }), pane)
			else
				log("Creating new workspace")
				local spawn_config = create_spawn_config(config)

				-- Log spawn configuration details
				log(
					string.format(
						"Spawn config - Label: %s, CWD: %s",
						spawn_config.label,
						spawn_config.cwd or "default"
					)
				)

				if spawn_config.args and #spawn_config.args > 0 then
					log(string.format("Command args: %s", table.concat(spawn_config.args, " ")))
				end

				-- Create and switch to the new workspace
				window:perform_action(
					act.SwitchToWorkspace({
						name = config.name,
						spawn = spawn_config,
					}),
					pane
				)

				-- Handle post-spawn commands if specified
				if config.action.post_spawn then
					for _, cmd in ipairs(config.action.post_spawn) do
						window:perform_action(act.SendString(cmd), pane)
						window:perform_action(act.SendKey({ key = "Enter" }), pane)
					end
				end
			end
		end
	end)
end

return M
