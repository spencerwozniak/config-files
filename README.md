# config-files

Personal configuration files, split by the machine they target. The two trees are
deliberately kept close to each other — same Neovim config, same shell setup, same
search-tool ignore rules — and differ only where the platform forces them to.

| Directory | Machine | Neovim |
|-----------|---------|--------|
| [`wsl/`](wsl/) | **WSL2**, Ubuntu 20.04 (glibc 2.31) under Windows | 0.10.2, plugins pinned |
| [`linux/`](linux/) | **Native Linux**, Ubuntu 26.04 | 0.11.6 from apt |

Each directory has its own README with the full install steps for that machine:
[`wsl/README.md`](wsl/README.md) · [`linux/README.md`](linux/README.md).

## What's in each

Both trees contain:

- `nvim/` — Neovim config, based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim).
  Colorscheme disabled so Neovim inherits the terminal's colors, mouse disabled, neo-tree
  file explorer on `\`.
- `.bashrc` — Bash configuration: prompt, AWS MFA helpers, PATH setup for nvm / pnpm / cargo /
  gcloud.
- `.ripgreprc` — global ripgrep config (loaded via `RIPGREP_CONFIG_PATH`), hides `*worktrees/`
  and `*.pnpm-store/` from all `rg` searches.
- `.config/fd/ignore` — the same ignore list for `fd`.
- `.config/git/ignore` — global gitignore (same dirs, plus local Claude settings).

Only `wsl/` has:

- `settings.json` — Windows Terminal configuration. There is no equivalent on the native
  Linux box, which uses its own terminal emulator's config.

## How they differ

The three real differences, all downstream of the platform:

1. **Neovim version.** Ubuntu 20.04's glibc 2.31 caps WSL at Neovim ~0.10.2, so `wsl/` pins a
   0.10-era kickstart snapshot and its plugin versions in `lazy-lock.json` — there, use
   `:Lazy restore`, never `:Lazy sync`. Ubuntu 26.04 ships 0.11.6, so `linux/` tracks current
   plugin versions with its own lockfile and can be updated normally. The one plugin that
   still needs a pin there is nvim-treesitter, held to its `master` branch because the newer
   `main` branch drops the module this config uses.
2. **Clipboard.** `wsl/` routes the system clipboard through Windows with an explicit
   `vim.g.clipboard` provider (`clip.exe` to copy, `powershell.exe Get-Clipboard` to paste).
   `linux/` drops that block entirely and lets Neovim autodetect `wl-copy`/`wl-paste`
   (Wayland) or `xclip`/`xsel` (X11), so `wl-clipboard` must be installed.
3. **`fd` invocation.** Ubuntu 20.04 ships fd 7.x, which has no global ignore file, so
   `wsl/.bashrc` aliases `fd` to pass `--ignore-file` explicitly. fd on 26.04 reads
   `~/.config/fd/ignore` by itself, so `linux/.bashrc` has no alias — just the `fdfind` →
   `fd` symlink that Telescope expects.

Everything else — keybindings, options, plugin list, shell functions — is intended to stay in
sync between the two.
