#!/usr/bin/env nu
# Claude Code status line - High-contrast monochrome theme
# Optimized for complete color blindness (monochromacy)
# Written in Nushell

# ANSI codes for high-contrast monochrome display
let BOLD = "\u{1b}[1m"
let REVERSE = "\u{1b}[7m"
let RESET = "\u{1b}[0m"

# Get current directory (shorten if too long)
let pwd_short = (
    $env.PWD
    | str replace $env.HOME "~"
    | if ($in | str length) > 40 {
        $"...($in | str substring (($in | str length) - 37)..)"
    } else {
        $in
    }
)

# Get git branch if in a git repo
let git_info = (
    try {
        let branch = (git branch --show-current | str trim)
        let has_changes = (
            (git diff --quiet; $env.LAST_EXIT_CODE != 0) or
            (git diff --cached --quiet; $env.LAST_EXIT_CODE != 0)
        )
        let status_mark = if $has_changes { "*" } else { "" }
        $" [($branch)($status_mark)]"
    } catch {
        ""
    }
)

# Get current time
let time = (date now | format date "%H:%M")

# Build status line with high contrast
# Format: [PWD] [git:branch*] [TIME]
print $"($BOLD)($REVERSE) ($pwd_short)($git_info) ($RESET) ($BOLD)($time)($RESET)"
