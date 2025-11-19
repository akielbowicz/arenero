# Nushell Environment Configuration

# Directories
$env.HOME = $env.HOME? | default '/data/data/com.termux/files/home'
$env.XDG_CONFIG_HOME = $"($env.HOME)/.config"
$env.XDG_DATA_HOME = $"($env.HOME)/.local/share"
$env.XDG_CACHE_HOME = $"($env.HOME)/.cache"

# Path
$env.PATH = (
    $env.PATH
    | split row (char esep)
    | prepend $"($env.HOME)/.local/bin"
    | prepend $"($env.HOME)/.cargo/bin"
    | prepend $"/data/data/com.termux/files/usr/bin"
    | uniq
)

# Default editor
$env.EDITOR = "helix"
$env.VISUAL = "helix"

# Less configuration
$env.LESS = "-R"
$env.LESSHISTFILE = "-"

# Bat (cat replacement) theme
$env.BAT_THEME = "ansi"

# Ripgrep configuration
$env.RIPGREP_CONFIG_PATH = $"($env.XDG_CONFIG_HOME)/ripgrep/config"

# FZF configuration - high contrast for monochromacy
$env.FZF_DEFAULT_OPTS = "--color=bw --layout=reverse --border --info=inline"

# Zoxide
$env._ZO_DATA_DIR = $"($env.XDG_DATA_HOME)/zoxide"

# Starship cache
$env.STARSHIP_CACHE = $"($env.XDG_CACHE_HOME)/starship"
