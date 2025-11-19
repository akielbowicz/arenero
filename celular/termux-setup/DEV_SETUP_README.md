# Termux Development Environment Setup

High-contrast configuration optimized for monochromacy (complete color blindness).

## Quick Start

Run the setup script:

```bash
bash ~/setup_termux_dev.sh
```

Then start Nushell:

```bash
nu
```

## Installed Tools

### Shell & Navigation
- **Nushell** - Modern shell with structured data
- **Zoxide** - Smart directory jumping (use `z dirname`)
- **Starship** - Fast, customizable prompt

### File Management
- **Yazi** - Terminal file manager (run with `yazi`)
- **Fzf** - Fuzzy finder for files, commands, and more
- **Bat** - Better `cat` with syntax highlighting
- **Ripgrep** - Fast search tool (aliased as `grep`)
- **fd** - Better `find` command

### Development
- **Node.js & npm** - JavaScript runtime and package manager
- **Helix** - Modern modal editor (run with `hx` or `helix`)
- **GitHub CLI** - Manage GitHub from terminal (`gh`)
- **Claude Code** - AI-powered coding assistant (`claude`)
- **Babashka** - Fast Clojure scripting (use `bbk` alias)
- **Carapace** - Multi-shell completion engine (auto-enabled in Nushell)

### Note-Taking
- **Zk** - Plain text note-taking with linking

## Key Aliases & Commands

### Nushell Aliases & Features
- `z <dir>` - Jump to directory (zoxide)
- `cat` → `bat` - Syntax-highlighted file viewing
- `grep` → `rg` - Fast searching
- `bbk` - Run babashka (handles LD_PRELOAD issue)
- **Tab completion** - Enhanced by Carapace for 600+ commands (git, npm, docker, etc.)

### Git Aliases (Two-Thumb Colemak DH Optimized)
Quick workflow using center/easy keys:
- `gn` - git status (right thumb, center key)
- `ge` - git add . (right thumb, easy reach)
- `gt` - git commit (left thumb, center key)
- `gh` - git push (right thumb, center key)
- `gd` - git diff (left thumb, center key)
- `gr` - git pull (left thumb)
- `gi` - git commit -m (right thumb)

**See**: `~/dev/borradores/celular/GIT_ALIASES_COLEMAK.md` for complete documentation

### Zk Note Commands
- `zk today` - Open/create today's daily note
- `zk list` - List all notes
- `zk recent` - Show recent notes
- `zk edit --interactive` - Interactively select notes

## Configuration Files

All configurations use high-contrast themes with:
- Black and white color scheme
- Bold, underline, and dim for emphasis
- No reliance on color hues
- Maximum brightness contrast

### Locations
```
~/.config/
├── nushell/
│   ├── config.nu      # Shell configuration
│   └── env.nu         # Environment variables
├── helix/
│   ├── config.toml    # Editor settings
│   └── themes/
│       └── monochrome.toml  # High-contrast theme
├── yazi/
│   ├── yazi.toml      # File manager config
│   └── theme.toml     # High-contrast theme
├── bat/
│   └── config         # Syntax highlighter config
├── ripgrep/
│   └── config         # Search tool config
├── fzf/
│   └── fzf.conf       # Fuzzy finder config reference
├── starship.toml      # Prompt configuration
└── babashka/
    └── bb.edn         # Babashka tasks

~/notes/
├── .zk/
│   ├── config.toml    # Zk configuration
│   └── templates/     # Note templates
└── daily/             # Daily notes
```

## Special Considerations

### Node.js & npm
Install Node.js (includes npm) via Termux package manager:
```bash
pkg install nodejs
```

Verify installation:
```bash
node --version   # Should show v24.9.0 or newer
npm --version    # Should show 11.6.0 or newer
```

After npm is installed, you can install global packages like Claude Code:
```bash
npm install -g @anthropic-ai/claude-code
```

### Babashka on Termux
Babashka requires LD_PRELOAD to be empty on Termux. Use the `bbk` alias:
```bash
bbk your-script.clj
```

### Helix Editor
- Theme: `monochrome` (high-contrast)
- Line numbers: relative
- Vi-mode keybindings
- Auto-save enabled

### Nushell
- Vi editing mode
- Zoxide integration for smart `cd`
- Starship prompt
- Modern tool aliases

### GitHub CLI
Authenticate with:
```bash
gh auth login
```

### Claude Code
Launch Claude Code for AI-assisted development:
```bash
claude              # Start interactive session
claude -c           # Continue previous conversation
claude --help       # Show available options
```

Installed via npm:
```bash
npm install -g @anthropic-ai/claude-code
```

## Usage Examples

### Navigate with Zoxide
```bash
z projects      # Jump to ~/projects or similar
z documents     # Jump to ~/Documents
zi              # Interactive directory picker
```

### File Management with Yazi
```bash
yazi            # Launch file manager
# Use arrow keys to navigate
# Enter to open with helix
# q to quit
```

### Note-Taking with Zk
```bash
cd ~/notes
zk new --title "My Note"  # Create new note
zk today                   # Today's daily note
zk list --interactive      # Browse notes
zk edit --interactive      # Edit notes
```

### Searching with Ripgrep
```bash
rg "search term"          # Search current directory
rg "pattern" ~/projects   # Search specific directory
rg -i "case insensitive"  # Case-insensitive search
```

### Fuzzy Finding with Fzf
```bash
fzf                       # Interactive fuzzy finder
vim $(fzf)               # Open selected file in editor
cd $(find . -type d | fzf)  # Navigate to directory
fzf --preview 'bat {}'   # Preview files with bat
fzf --multi              # Multi-selection mode
```

**Fzf Integration Examples:**
```bash
# Find and edit file
hx $(fzf)

# Search in file contents and open
rg "pattern" -l | fzf --preview 'bat {}' | xargs hx

# Process selection
ps aux | fzf | awk '{print $2}'
```

### Editing with Helix
```bash
hx file.txt              # Open file
# Normal mode: hjkl for movement
# Insert mode: i
# Save: :w
# Quit: :q
# Save & quit: :wq
```

## Monochromacy Optimizations

All tools are configured with:

1. **ANSI theme** (bat) - Uses only black/white/gray
2. **Monochrome theme** (helix) - No color hues, only brightness
3. **Bold/underline/dim** - For visual hierarchy
4. **High contrast** - Maximum brightness differences
5. **Clear symbols** - Text-based indicators instead of colors

## Customization

To modify themes, edit:
- Nushell: `~/.config/nushell/config.nu` (theme section)
- Helix: `~/.config/helix/themes/monochrome.toml`
- Starship: `~/.config/starship.toml`
- Yazi: `~/.config/yazi/theme.toml`

## Troubleshooting

### Nushell not starting
Ensure installation completed:
```bash
pkg install -y nushell
```

### Babashka errors
Always use the `bbk` alias, not `bb` directly:
```bash
bbk script.clj
```

### Zoxide not working
Initialize the database:
```bash
cd ~
cd ~/projects  # Visit directories to build database
```

## Backup & Restore

Backup your configuration:
```bash
tar -czf termux-config-backup.tar.gz ~/.config ~/notes
```

Restore:
```bash
tar -xzf termux-config-backup.tar.gz -C ~
```

## Updates

Update all packages:
```bash
pkg upgrade
```

Update Termux tools:
```bash
pkg upgrade nushell zoxide yazi starship ripgrep bat helix zk
```

Update npm packages (like Claude Code):
```bash
npm update -g @anthropic-ai/claude-code
```

## Additional Resources

- Helix: https://helix-editor.com/
- Nushell: https://nushell.sh/
- Claude Code: https://github.com/anthropics/claude-code
- Zk: https://github.com/zk-org/zk
- Yazi: https://yazi-rs.github.io/
- Starship: https://starship.rs/

---

**Note**: This setup is optimized for phone screens with monochromacy enabled.
All configurations prioritize contrast and clarity over color.
