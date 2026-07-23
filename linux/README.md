# config-files — Linux (Ubuntu 26.04)

Configuration for the **native Ubuntu 26.04** machine.

- [`nvim/`](nvim/) — Neovim configuration (see below)
- [`.bashrc`](.bashrc) — Bash configuration
- [`.ripgreprc`](.ripgreprc) — global ripgrep config (loaded via `RIPGREP_CONFIG_PATH`, set in
  `.bashrc`); hides `*worktrees/` and `*.pnpm-store/` dirs from all `rg` searches, even with
  `--no-ignore`
- [`.config/git/ignore`](.config/git/ignore) — global gitignore (same dirs, plus local Claude
  settings)
- [`.config/fd/ignore`](.config/fd/ignore) — ignore file for `fd`
- [`gnome/`](gnome/) — GNOME desktop settings, dumped from `dconf` (see below)
- [`terminator/`](terminator/) — Terminator terminal emulator config (see below)

---

## Neovim Config

[kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)-based config:

- Colorscheme is **disabled** so Neovim inherits the terminal's own colors
  (`termguicolors` is off). gruvbox-material is installed but not loaded — see the
  comments in `nvim/init.lua` to switch back.
- **neo-tree** file explorer is enabled (toggle with `\`).
- The **mouse is disabled** (`vim.opt.mouse = ''`) so terminal click-drag selection works normally.
- Plugin versions are pinned via `nvim/lazy-lock.json`, resolved against Neovim 0.11.6.
- **nvim-treesitter is pinned to its `master` branch.** The plugin's default branch is now
  `main`, a rewrite that removes the `nvim-treesitter.configs` module this config sets up —
  without the pin, startup fails with `module 'nvim-treesitter.configs' not found`. Upstream
  kickstart pins `master` for the same reason. Dropping the pin means porting that plugin
  block to the new API.

### Prerequisites

| Tool | Why | Notes |
|------|-----|-------|
| Neovim **0.11.x** | the editor | `apt install neovim` on 26.04 |
| `git` | plugin manager clones repos | |
| `gcc` / `make` | compiling treesitter parsers & telescope-fzf-native | `build-essential` |
| `ripgrep` (`rg`) | Telescope live-grep (`<leader>sg`) | |
| `fd` | Telescope find-files (`<leader>sf`) | Ubuntu packages it as `fd-find` (binary `fdfind`) |
| `wl-clipboard` | system clipboard under Wayland | use `xclip` instead on an X11 session |

### 1. Install the packages

```sh
sudo apt-get update && sudo apt-get install -y \
    neovim ripgrep fd-find wl-clipboard build-essential git unzip
nvim --version   # should report NVIM v0.11.x

# expose fd-find under the name `fd` that Telescope expects
mkdir -p ~/.local/bin && ln -sf "$(command -v fdfind)" ~/.local/bin/fd
# make sure ~/.local/bin is on your PATH (Ubuntu's default .profile already does this)
```

### 2. Install the config

```sh
# back up any existing config first
[ -e ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.bak

mkdir -p ~/.config
cp -r nvim ~/.config/nvim
```

### 3. Install the plugins

```sh
# clones every plugin at the exact version recorded in lazy-lock.json
nvim --headless "+Lazy! restore" +qa
```

Open `nvim` — on first use of a file, treesitter will compile that language's parser once.

### 4. Shell and search tool config

```sh
cp .bashrc ~/.bashrc
cp .ripgreprc ~/.ripgreprc
mkdir -p ~/.config/fd ~/.config/git
cp .config/fd/ignore ~/.config/fd/ignore
cp .config/git/ignore ~/.config/git/ignore
```

### Handy keybindings (leader = `Space`)

| Keys | Action |
|------|--------|
| `\` | toggle the **neo-tree** file explorer |
| `<leader>sf` | **search files** by name (find_files / `fd`) |
| `<leader>sg` | **search by grep** across files (live_grep / `ripgrep`, respects `.gitignore`) |
| `<leader>sw` | search the word under the cursor |
| `<leader>sh` | search help |
| `<leader>sk` | search keymaps |
| `<leader><leader>` | switch between open buffers |

Telescope searches relative to Neovim's current working directory (`:pwd`) — launch `nvim`
from the directory you want to search, or `:cd` there first.

---

## GNOME Config

GNOME stores its settings in a binary `dconf` database, not plain files, so
[`gnome/gnome-settings.dconf`](gnome/gnome-settings.dconf) is a text dump of the `/org/gnome/`
subtree produced with `dconf dump`. It captures the desktop appearance and behavior worth
carrying between machines:

- **Interface** — `brown` accent color, hot corners off, `Ubuntu Sans` / `Ubuntu Sans Mono`
  fonts, `Yaru` cursor theme
- **Shell** — favorite (dock) apps, enabled extensions (`ding`, `ubuntu-dock`,
  `tiling-assistant`), dock pinned to the bottom, `performance` power profile
- **Custom keybinding** — <kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>T</kbd> launches `terminator`
  (under `settings-daemon/plugins/media-keys`)
- **Tiling / mutter** — GNOME edge-tiling disabled in favor of the `tiling-assistant`
  extension
- **Nautilus, power, background, screensaver** and other everyday preferences

The dump is deliberately **scrubbed of personal and machine-specific data** — the
`evolution-data-server` calendar cache, window geometry, saved file-chooser paths, and
night-light GPS coordinates are all excluded, so it's safe to commit and reapply anywhere.

### Prerequisites

`dconf` ships with GNOME; nothing extra to install. The extensions referenced above
(`tiling-assistant`, `ubuntu-dock`, `ding`) come with Ubuntu's GNOME session. Terminator must
be installed for the custom keybinding to do anything (see the next section).

### Apply the settings

```sh
# back up your current GNOME settings first, so you can roll back
dconf dump /org/gnome/ > ~/gnome-settings.backup.dconf

# load this repo's settings into the /org/gnome/ subtree
dconf load /org/gnome/ < gnome/gnome-settings.dconf
```

Changes apply immediately for most keys; log out and back in if the dock, extensions, or
fonts don't fully refresh.

To roll back: `dconf load /org/gnome/ < ~/gnome-settings.backup.dconf`.

### Re-dump after changing settings

When you tweak GNOME and want to capture it, re-run the same scrubbed dump so personal data
never lands in the repo:

```sh
dconf dump /org/gnome/ \
  | awk 'BEGIN{for(s in a);split("evolution-data-server evolution-data-server/calendar control-center nautilus/window-state portal/filechooser/com.google.Chrome settings-daemon/plugins/color",k," ");for(i in k)skip[k[i]]=1}
         /^\[/{sect=substr($0,2,length($0)-2);drop=(sect in skip)}
         drop{next}
         /^window-size=|^window-state=|^night-light-last-coordinates=/{next}
         {print}' \
  > gnome/gnome-settings.dconf
```

---

## Terminator Config

[`terminator/config`](terminator/config) is the [Terminator](https://gnome-terminator.org/)
terminal-emulator config. Highlights:

- White background / black foreground default profile
- Splits: <kbd>Alt</kbd>+<kbd>_</kbd> horizontal, <kbd>Alt</kbd>+<kbd>+</kbd> vertical
- Tabs: <kbd>Ctrl</kbd>+<kbd>Tab</kbd> next, <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Tab</kbd>
  previous
- Never prompt before closing; tabs not detachable

Pair it with the GNOME custom keybinding above to launch Terminator with
<kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>T</kbd>.

### Prerequisites

```sh
sudo apt-get update && sudo apt-get install -y terminator
```

### Install the config

```sh
# back up any existing config first
[ -e ~/.config/terminator/config ] && mv ~/.config/terminator/config ~/.config/terminator/config.bak

mkdir -p ~/.config/terminator
cp terminator/config ~/.config/terminator/config
```

Terminator reads the file on next launch — no reload command needed.
