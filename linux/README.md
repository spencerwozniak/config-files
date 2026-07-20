# config-files — Linux (Ubuntu 26.04)

Configuration for the **native Ubuntu 26.04** machine. For the older WSL2 / Ubuntu 20.04
setup see [`../wsl/`](../wsl/); the [root README](../README.md) explains how the two differ.

- [`nvim/`](nvim/) — Neovim configuration (see below)
- [`.bashrc`](.bashrc) — Bash configuration
- [`.ripgreprc`](.ripgreprc) — global ripgrep config (loaded via `RIPGREP_CONFIG_PATH`, set in
  `.bashrc`); hides `*worktrees/` and `*.pnpm-store/` dirs from all `rg` searches, even with
  `--no-ignore`
- [`.config/git/ignore`](.config/git/ignore) — global gitignore (same dirs, plus local Claude
  settings)
- [`.config/fd/ignore`](.config/fd/ignore) — ignore file for `fd`; unlike the WSL config this
  is read automatically, no alias needed

There's no Windows Terminal `settings.json` here — that file only applies to the WSL box.

---

## Neovim Config

Same [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)-based config as the WSL
setup, with the same local changes:

- Colorscheme is **disabled** so Neovim inherits the terminal's own colors
  (`termguicolors` is off). gruvbox-material is installed but not loaded — see the
  comments in `nvim/init.lua` to switch back.
- **neo-tree** file explorer is enabled (toggle with `\`).
- The **mouse is disabled** (`vim.opt.mouse = ''`) so terminal click-drag selection works normally.
- **Clipboard is the native system clipboard.** The WSL config's `vim.g.clipboard` block
  (`clip.exe` / `powershell.exe`) is removed here; Neovim autodetects `wl-copy`/`wl-paste`
  under Wayland or `xclip`/`xsel` under X11, and `unnamedplus` shares the system clipboard.
  Verify with `:checkhealth provider` if yank/paste doesn't reach other apps.
- Plugin versions are pinned via `nvim/lazy-lock.json`, resolved against Neovim 0.11.6.
- **nvim-treesitter is pinned to its `master` branch.** The plugin's default branch is now
  `main`, a rewrite that removes the `nvim-treesitter.configs` module this config sets up —
  without the pin, startup fails with `module 'nvim-treesitter.configs' not found`. Upstream
  kickstart pins `master` for the same reason. Dropping the pin means porting that plugin
  block to the new API.

Unlike the WSL config — which is frozen at a 0.10-era snapshot by glibc 2.31 — this one runs
a current Neovim, so `:Lazy update` is safe. Commit the regenerated `lazy-lock.json`
afterwards to keep the pin honest.

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

Everything is in the 26.04 archive — no third-party build needed, unlike the WSL setup:

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
