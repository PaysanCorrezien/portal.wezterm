# 🌀 WezTerm Portal Plugin

A dynamic workspace teleportation system for WezTerm that creates persistent, customizable portals to your different workflow environments. Jump between specialized workspaces with a single keystroke, and return exactly where you left off.
Go inside and out of your workspaces with ease, and enjoy the benefits of a seamless, efficient workflow. 🚀

## 🌟 Features

- 🎯 Instant workspace switching with memory
- 🔄 Automatic workspace state preservation
- 🚀 Custom environment configuration per workspace
- 🏃 Launch-or-resume workflow functionality
- 🎮 Configurable command execution on portal entry

## 🚀 Installation

```lua
local wez = require('wezterm')
local portal = wez.plugin.require("https://github.com/PaysanCorrezien/portal.wezterm")
```

## 💡 Usage Examples

### 📝 Notes Portal

```lua
{
  key = "N",
  mods = "LEADER",
  action = portal.teleport({
    name = "Notes",
    action = {
      args = {
        "zsh", "-c",
        "source ~/.zshrc && nvim -c \"lua require('telescope.builtin').find_files({cwd = '/home/dylan/Documents/Notes/', file_ignore_patterns = {'^%.git/'}, find_command = {'rg', '--files', '--type', 'md'}})\"",
      },
      cwd = "/home/dylan/Documents/Notes/",
      env = { EDITOR = "nvim" },
    },
  }),
}
```

Opens Neovim Telescope file finder pre-configured for `.md` files.

### ⚙️ NixOS Configuration Portal

```lua
{
  key = "n",
  mods = "LEADER",
  action = portal.teleport({
    name = "NixOS",
    action = {
      args = {
        "zsh", "-c",
        "source ~/.zshrc && nvim -c \"lua require('telescope.builtin').find_files({cwd = '/home/dylan/.config/nix/', file_ignore_patterns = {'^%.git/'}})\"",
      },
      cwd = "/home/dylan/.config/nix/",
    },
  }),
}
```

Quick access to NixOS configuration files with immediate Telescope search capability.

### 🎵 Music Player Portal

```lua
{
  key = ".",
  mods = "LEADER",
  action = portal.teleport({
    name = "Music",
    action = {
      args = { "termusic" },
      cwd = "/home/dylan/Musique/",
    },
  }),
}
```

Launches a dedicated music workspace with termusic player.

## 🤝 Contributing

Contributions are welcome! Please note:

- This project is maintained as time permits
- Focus on meaningful improvements that don't add unnecessary complexity

## 📄 License

This project follows the MIT License conventions. Feel free to use, modify, and distribute as per MIT License terms.
