#!/data/data/com.termux/files/usr/bin/bash
# Termux Development Environment Setup Script
# Optimized for monochromacy with high-contrast themes

set -e

echo "╔════════════════════════════════════════════════════╗"
echo "║  Termux Development Environment Setup             ║"
echo "║  High-contrast configuration for monochromacy     ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""

# Step 1: Install packages
echo "[1/9] Installing core packages..."
pkg install -y nushell zoxide yazi starship ripgrep bat helix zk carapace nodejs fzf

# Step 2: Install npm packages
echo "[2/9] Installing npm global packages..."
npm install -g @anthropic-ai/claude-code

# Step 3: Create directory structure
echo "[3/9] Creating directory structure..."
mkdir -p ~/.config/{nushell,yazi,bat,ripgrep,helix/themes,babashka}
mkdir -p ~/notes/{daily,.zk/templates}

# Step 4: Configure Nushell
echo "[4/9] Configuring Nushell..."
cat > ~/.config/nushell/config.nu << 'EOF'
# Nushell Configuration - High-contrast for monochromacy
$env.EDITOR = "helix"
$env.VISUAL = "helix"

let high_contrast_theme = {
    separator: white
    header: { fg: white attr: b }
    bool: { fg: white attr: b }
    int: white
    string: white
    hints: dark_gray
    search_result: { fg: black bg: white }
}

$env.config = {
    show_banner: false
    color_config: $high_contrast_theme
    edit_mode: vi
    shell_integration: {
        osc2: true
        osc7: true
        osc8: true
        osc9_9: false
        osc133: true
        osc633: true
        reset_application_mode: true
    }
    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "fuzzy"
        external: {
            enable: true
            max_results: 100
            completer: {|spans|
                carapace $spans.0 nushell ...$spans | from json | get completions
            }
        }
    }
}

# Zoxide
def --env __zoxide_z [...rest: string] {
    let arg0 = ($rest | append '~').0
    let path = if (($rest | length) <= 1) and ($arg0 == '-' or ($arg0 | path expand | path type) == dir) {
        $arg0
    } else {
        (zoxide query --exclude $env.PWD -- ...$rest | str trim -r -c "\n")
    }
    cd $path
}

alias z = __zoxide_z
alias bbk = LD_PRELOAD='' bb

# Carapace completions
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'

alias cat = bat
alias grep = rg

# Git aliases - optimized for two-thumb Colemak DH on phone
alias gn = git status              # 'n' center-right, quick status check
alias ge = git add .               # 'e' easy right thumb, add current dir
alias gt = git commit              # 't' center-left, commit
alias gh = git push                # 'h' center-right, push (home/hub)
alias gd = git diff                # 'd' center-left, diff
alias gr = git pull                # 'r' left thumb, pull (retrieve)
alias gi = git commit -m           # 'i' right thumb, commit inline message

# Starship
$env.STARSHIP_SHELL = "nu"
$env.STARSHIP_SESSION_KEY = (random chars -l 16)

def create_left_prompt [] {
    starship prompt --cmd-duration $env.CMD_DURATION_MS --status $env.LAST_EXIT_CODE
}

def create_right_prompt [] {
    starship prompt --right --cmd-duration $env.CMD_DURATION_MS --status $env.LAST_EXIT_CODE
}

$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = { || create_right_prompt }
$env.PROMPT_INDICATOR = ""
$env.PROMPT_INDICATOR_VI_INSERT = ": "
$env.PROMPT_INDICATOR_VI_NORMAL = "> "
$env.PROMPT_MULTILINE_INDICATOR = "::: "

# Update zoxide on cd
$env.config = ($env.config | upsert hooks {
    env_change: {
        PWD: [{|before, after| zoxide add -- $after }]
    }
})
EOF

# Step 5: Environment config
echo "[5/9] Configuring environment..."
cat > ~/.config/nushell/env.nu << 'EOF'
$env.BAT_THEME = "ansi"
$env.FZF_DEFAULT_OPTS = "--color=bw --layout=reverse --border --info=inline --prompt='> ' --pointer='▶' --marker='✓'"
$env.RIPGREP_CONFIG_PATH = "~/.config/ripgrep/config"
$env.EDITOR = "helix"
EOF

# Step 6: Tool configs
echo "[6/9] Configuring tools..."

# Git
cat > ~/.gitconfig << 'EOF'
[color]
	ui = true
	status = always

[color "status"]
	added = bold white
	changed = bold white reverse
	untracked = white
	branch = bold white
	nobranch = bold white reverse

[color "diff"]
	meta = bold white
	frag = bold white
	old = white reverse
	new = bold white
	commit = bold white

[color "branch"]
	current = bold white
	local = white
	remote = white
	upstream = bold white

[color "interactive"]
	prompt = bold white
	header = bold white
	help = white
	error = bold white reverse

[core]
	pager = less -R

[diff]
	tool = difftastic

[merge]
	conflictstyle = diff3

[pull]
	rebase = false

[init]
	defaultBranch = main
EOF

echo "  ⚠ Note: Configure git user details with:"
echo "    git config --global user.name 'Your Name'"
echo "    git config --global user.email 'your.email@example.com'"

# Bat
cat > ~/.config/bat/config << 'EOF'
--theme="ansi"
--style="numbers,grid"
--tabs=4
--wrap=auto
EOF

# Ripgrep
cat > ~/.config/ripgrep/config << 'EOF'
--follow
--hidden
--glob=!.git/*
--glob=!node_modules/*
--smart-case
--line-number
--column
EOF

# Starship
cat > ~/.config/starship.toml << 'EOF'
format = """[┌─](bold white)$username$hostname$directory$git_branch$git_status
[└─>](bold white) """

[character]
success_symbol = "[▶](bold white)"
error_symbol = "[✗](bold white)"

[username]
style_user = "bold white"
format = "[$user]($style) "
show_always = true

[directory]
style = "bold white"
format = "[$path]($style) "
truncation_length = 3

[git_branch]
symbol = "GIT:"
style = "bold white"
format = "[$symbol$branch]($style) "

[git_status]
style = "bold white"
format = "([$all_status]($style) )"
EOF

# Step 7: Yazi
echo "[7/9] Configuring Yazi..."
cat > ~/.config/yazi/yazi.toml << 'EOF'
[manager]
show_hidden = false

[opener]
edit = [{ run = 'helix "$@"', block = true }]

[tool]
editor = "helix"
pager = "bat"
EOF

# Step 8: Helix
echo "[8/9] Configuring Helix..."
cat > ~/.config/helix/config.toml << 'EOF'
theme = "monochrome"

[editor]
line-number = "relative"
auto-save = true
color-modes = true

[editor.cursor-shape]
insert = "bar"
normal = "block"

[keys.normal]
C-s = ":w"
EOF

# Helix theme (minimal version)
cat > ~/.config/helix/themes/monochrome.toml << 'EOF'
"ui.background" = { fg = "white", bg = "black" }
"ui.text" = "white"
"ui.cursor" = { fg = "black", bg = "white" }
"ui.selection" = { fg = "black", bg = "white" }
"ui.linenr" = "gray"
"ui.statusline" = { fg = "black", bg = "white" }
"comment" = { fg = "gray" }
"keyword" = { fg = "white", modifiers = ["bold"] }
"function" = { fg = "white", modifiers = ["bold"] }

[palette]
black = "#000000"
gray = "#808080"
white = "#FFFFFF"
EOF

# Step 9: Initialize zk
echo "[9/9] Initializing zk notebook..."
cd ~/notes
if [ ! -f .zk/config.toml ]; then
    zk init --no-input
fi

# Configure zk
sed -i 's/#editor = "vim"/editor = "helix"/' ~/.notes/.zk/config.toml 2>/dev/null || true
sed -i 's/#pager = "less -FIRX"/pager = "bat"/' ~/.notes/.zk/config.toml 2>/dev/null || true

# Babashka config
echo "[EXTRA] Configuring Babashka..."
cat > ~/.config/babashka/bb.edn << 'EOF'
{:paths ["." "src"]
 :deps {}
 :tasks
 {:requires ([babashka.fs :as fs])
  hello {:doc "Print hello" :task (println "Hello from Babashka!")}}}
EOF

echo ""
echo "✓ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Run 'nu' to start Nushell"
echo "  2. Babashka: use 'bbk' alias (LD_PRELOAD='' bb)"
echo "  3. GitHub CLI: 'gh auth login' (if needed)"
echo "  4. Notes: 'cd ~/notes && zk today'"
echo ""
echo "Installed tools:"
echo "  - Nushell (shell)"
echo "  - Zoxide (smart cd)"
echo "  - Yazi (file manager)"
echo "  - Starship (prompt)"
echo "  - Ripgrep (search)"
echo "  - Bat (cat with highlighting)"
echo "  - Helix (editor)"
echo "  - Zk (notes)"
echo "  - Carapace (completions)"
echo "  - GitHub CLI (gh)"
echo "  - Node.js & npm"
echo "  - Claude Code (claude)"
echo "  - Babashka (already installed)"
echo "  - Fzf (fuzzy finder)"
echo ""
