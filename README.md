# config-files

Personal configuration files.

- [`nvim/`](nvim/) — Neovim configuration (see below)
- [`.bashrc`](.bashrc) — Bash configuration
- [`settings.json`](settings.json) — Windows Terminal configuration

---

## Neovim Config

This configuration is based on **[kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)**
(a single-file, well-documented starter config), with a few local changes:

- Colorscheme is **disabled** so Neovim inherits the terminal's own colors
  (`termguicolors` is off). gruvbox-material is installed but not loaded — see the
  comments in `nvim/init.lua` to switch back.
- **neo-tree** file explorer is enabled (toggle with `\`).
- Plugin versions are **pinned** via `nvim/lazy-lock.json` (see the compatibility note below).

### ⚠️ Important: Neovim version

This config is pinned to a **Neovim 0.10.x-era** snapshot of kickstart (upstream commit
`8d1ef97`) because the host runs **Ubuntu 20.04 / glibc 2.31**, which can only run Neovim up
to **~v0.10.2**. The latest Neovim needs glibc ≥ 2.34, and current kickstart needs Neovim
0.11+/0.12 (`vim.pack`, `vim.lsp.config`). **Do not** upgrade Neovim past 0.10.x or run
`:Lazy sync`/`:Lazy update` unless the OS/glibc is upgraded first — newer plugin versions
drop 0.10 support and will break the config. Use `:Lazy restore` to install/repair plugins
at the pinned versions instead.

### Prerequisites

| Tool | Why | Notes |
|------|-----|-------|
| Neovim **0.10.x** | the editor | install steps below |
| `git` | plugin manager clones repos | |
| `gcc` / `make` | compiling treesitter parsers & telescope-fzf-native | |
| `ripgrep` (`rg`) | Telescope live-grep (`<leader>sg`) | |
| `fd` | Telescope find-files (`<leader>sf`) | Ubuntu packages it as `fd-find` (binary `fdfind`) |

### 1. Install Neovim 0.10.2 (glibc-2.31 compatible build)

The latest release won't run on Ubuntu 20.04. Use the last build made for ubuntu-20.04:

```sh
curl -fLO https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
sudo mv /opt/nvim-linux64 /opt/nvim
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
nvim --version   # should report NVIM v0.10.2
```

> On a newer distro (glibc ≥ 2.34) you can skip this and just install the latest Neovim —
> but then you should track upstream kickstart rather than this pinned config.

### 2. Install the search tools

```sh
sudo apt-get update && sudo apt-get install -y ripgrep fd-find
# expose fd-find under the name `fd` that Telescope expects
mkdir -p ~/.local/bin && ln -sf "$(command -v fdfind)" ~/.local/bin/fd
# make sure ~/.local/bin is on your PATH (Ubuntu's default .profile already does this)
```

If `apt` doesn't have `ripgrep` (older releases), grab the static binary instead:

```sh
curl -fLO https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz
tar xzf ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz
install -m755 ripgrep-14.1.1-*/rg ~/.local/bin/rg
```

### 3. Install the config

```sh
# back up any existing config first
[ -e ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.bak

mkdir -p ~/.config
cp -r nvim ~/.config/nvim
```

### 4. Install the pinned plugins

```sh
# clones every plugin at the exact version recorded in lazy-lock.json
nvim --headless "+Lazy! restore" +qa
```

Open `nvim` — on first use of a file, treesitter will compile that language's parser once.

> Use `:Lazy restore` (honors `lazy-lock.json`), **never** `:Lazy sync`/`:Lazy update`,
> which would re-pull plugin versions that require Neovim 0.11+.

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
