# Claude Code Configuration

High-contrast configuration for Claude Code optimized for monochromacy.

## Files

- `settings.json` - Claude Code settings with custom status line
- `statusline.nu` - Nushell-based status line script with high-contrast ANSI codes

## Installation

The setup script will copy these files to `~/.claude/`:

```bash
cp configs/claude/settings.json ~/.claude/settings.json
cp configs/claude/statusline.nu ~/.claude/statusline.nu
chmod +x ~/.claude/statusline.nu
```

## Status Line

The status line displays:
- Current directory (shortened if > 40 chars)
- Git branch and modification indicator (*)
- Current time

Uses bold and reverse video (inverted colors) for high contrast visibility.

## Theme Configuration

**Important**: Claude Code does not control terminal colors. For high-contrast monochrome theme:

1. **Terminal colors** are controlled by Termux itself
2. Termux uses system black/white with `use-black-ui = true` in `~/.termux/termux.properties`
3. The status line uses ANSI codes (bold, reverse) for additional contrast

## Settings Explained

- `alwaysThinkingEnabled: false` - Cleaner output without constant thinking indicators
- `statusLine` - Custom status line with high-contrast formatting
  - Uses Nushell script for consistency with your shell environment
  - Displays essential info: path, git status, time
  - High-contrast formatting with bold and reverse video

## Customization

Edit `statusline.nu` to customize what information is shown. The script uses:
- `\u{1b}[1m` - Bold text
- `\u{1b}[7m` - Reverse video (inverted fg/bg)
- `\u{1b}[0m` - Reset formatting

## Termux Configuration

For optimal high-contrast in Termux, ensure `~/.termux/termux.properties` has:
```
use-black-ui = true
terminal-cursor-style = block
```

After changing termux.properties, run:
```bash
termux-reload-settings
```
