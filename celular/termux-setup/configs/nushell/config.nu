# Nushell Configuration
# Optimized for monochromacy with high contrast

# Environment
$env.EDITOR = "helix"
$env.VISUAL = "helix"

# High-contrast theme for monochromacy
# Uses brightness differences and styles instead of colors
let high_contrast_theme = {
    separator: white
    leading_trailing_space_bg: { attr: r }
    header: { fg: white attr: b }
    empty: white
    bool: { fg: white attr: b }
    int: white
    filesize: white
    duration: white
    date: { fg: white attr: b }
    range: white
    float: white
    string: white
    nothing: white
    binary: white
    cellpath: white
    row_index: { fg: white attr: b }
    record: white
    list: white
    block: white
    hints: dark_gray
    search_result: { fg: black bg: white }

    shape_and: { fg: white attr: b }
    shape_binary: { fg: white attr: b }
    shape_block: white
    shape_bool: { fg: white attr: b }
    shape_closure: white
    shape_custom: { fg: white attr: b }
    shape_datetime: { fg: white attr: b }
    shape_directory: { fg: white attr: b }
    shape_external: white
    shape_externalarg: white
    shape_filepath: { fg: white attr: u }
    shape_flag: { fg: white attr: b }
    shape_float: white
    shape_garbage: { fg: white bg: red attr: b }
    shape_globpattern: white
    shape_int: white
    shape_internalcall: { fg: white attr: b }
    shape_list: white
    shape_literal: { fg: white attr: b }
    shape_match_pattern: white
    shape_matching_brackets: { attr: u }
    shape_nothing: white
    shape_operator: { fg: white attr: b }
    shape_or: { fg: white attr: b }
    shape_pipe: { fg: white attr: b }
    shape_range: white
    shape_record: white
    shape_redirection: { fg: white attr: b }
    shape_signature: { fg: white attr: b }
    shape_string: white
    shape_string_interpolation: white
    shape_table: white
    shape_variable: white
    shape_vardecl: { fg: white attr: b }
}

$env.config = {
    show_banner: false

    color_config: $high_contrast_theme

    use_grid_icons: true
    footer_mode: 25

    float_precision: 2

    filesize: {
        metric: false
        format: "auto"
    }

    cursor_shape: {
        emacs: line
        vi_insert: line
        vi_normal: block
    }

    edit_mode: vi

    shell_integration: true

    history: {
        max_size: 100000
        sync_on_enter: true
        file_format: "sqlite"
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
                carapace $spans.0 nushell ...$spans
                | from json
                | get completions
            }
        }
    }

    keybindings: [
        {
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: completion_menu }
                    { send: menunext }
                ]
            }
        }
    ]
}

# Zoxide integration
def --env __zoxide_z [...rest: string] {
    let arg0 = ($rest | append '~').0
    let path = if (($rest | length) <= 1) and ($arg0 == '-' or ($arg0 | path expand | path type) == dir) {
        $arg0
    } else {
        (zoxide query --exclude $env.PWD -- ...$rest | str trim -r -c "\n")
    }
    cd $path
}

def --env __zoxide_zi  [...rest: string] {
    cd $"(zoxide query -i -- ...$rest | str trim -r -c "\n")"
}

alias z = __zoxide_z
alias zi = __zoxide_zi

# Starship prompt
$env.STARSHIP_SHELL = "nu"
$env.STARSHIP_SESSION_KEY = (random chars -l 16)

def create_left_prompt [] {
    starship prompt --cmd-duration $env.CMD_DURATION_MS --status $env.LAST_EXIT_CODE --jobs (ps | where pid == $env.PPID | get 0 | get children | length)
}

def create_right_prompt [] {
    starship prompt --right --cmd-duration $env.CMD_DURATION_MS --status $env.LAST_EXIT_CODE --jobs (ps | where pid == $env.PPID | get 0 | get children | length)
}

$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = { || create_right_prompt }
$env.PROMPT_INDICATOR = ""
$env.PROMPT_INDICATOR_VI_INSERT = ": "
$env.PROMPT_INDICATOR_VI_NORMAL = "> "
$env.PROMPT_MULTILINE_INDICATOR = "::: "

# Aliases
alias ls = ls --color=always
alias ll = ls -la
alias la = ls -a
alias l = ls -l

# Babashka alias (from bash history)
alias bbk = LD_PRELOAD='' bb

# Carapace completions
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional

# Modern CLI tools
alias cat = bat
alias find = fd
alias grep = rg

# Git aliases - optimized for two-thumb Colemak DH on phone
# Center/easy reach: d h t n s r e i
alias gs = git status              # status
alias ga = git add                 # add
alias gd = git diff                # diff
alias gc = git commit              # commit
alias gp = git push                # push
alias gl = git log --oneline --graph

# Two-thumb optimized (alternating hands, easy reach)
alias gn = git status              # 'n' center-right, quick status check
alias ge = git add .               # 'e' easy right thumb, add current dir
alias gt = git commit              # 't' center-left, commit
alias gh = git push                # 'h' center-right, push (home/hub)
alias gd = git diff                # 'd' center-left, diff
alias gr = git pull                # 'r' left thumb, pull (retrieve)
alias gi = git commit -m           # 'i' right thumb, commit inline message
alias gds = git diff --staged      # diff staged
alias gaa = git add --all          # add all files
alias gcm = git commit -m          # commit with message
alias gca = git commit --amend     # commit amend
alias gco = git checkout           # checkout
alias gb = git branch              # branch
alias gm = git merge               # merge
alias gst = git stash              # stash
alias gcl = git clone              # clone

# Quick navigation
alias .. = cd ..
alias ... = cd ../..
alias .... = cd ../../..

# Helper functions
def mkcd [name: string] {
    mkdir $name
    cd $name
}

# Update zoxide database on directory change
$env.config = ($env.config | upsert hooks {
    env_change: {
        PWD: [
            {|before, after|
                zoxide add -- $after
            }
        ]
    }
})
