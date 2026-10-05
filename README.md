# Neovim config

A small, modular Neovim setup built on Neovim 0.12's built-in plugin manager (`vim.pack`).
It started from [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim).

| Area | Plugin |
| --- | --- |
| Colorscheme | [catppuccin](https://github.com/catppuccin/nvim) (mocha) |
| Fuzzy finder, floating terminal, file explorer, lazygit, notifications, dashboard | [snacks.nvim](https://github.com/folke/snacks.nvim) |
| Statusline / buffer tabs | lualine, bufferline |
| Keymap hints | which-key |
| LSP | native `vim.lsp` + nvim-lspconfig + Mason |
| Java | [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls) (+ debug and JUnit test bundles, Lombok) |
| Completion / snippets | blink.cmp, LuaSnip, friendly-snippets |
| Syntax | nvim-treesitter (`main` branch), treesitter-context |
| Formatting | conform.nvim (format on save, LSP fallback) |
| Debugging | nvim-dap, nvim-dap-view, nvim-dap-virtual-text |
| Git | gitsigns, lazygit (via snacks) |
| Editing | mini.ai, mini.surround, mini.pairs, mini.splitjoin, flash, guess-indent |
| Diagnostics list | trouble.nvim, todo-comments |

## Requirements

- **Neovim 0.12+**
- `git`, `curl`, `tar`, `unzip`, `make`, a C compiler
- [`tree-sitter` CLI](https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md) 0.26.1+, installed with your package manager, not npm (nvim-treesitter compiles parsers with it, see below)
- [`ripgrep`](https://github.com/BurntSushi/ripgrep) and [`fd`](https://github.com/sharkdp/fd) for the picker
- A [Nerd Font](https://www.nerdfonts.com) set as your terminal font (otherwise set `vim.g.have_nerd_font = false` in `init.lua`)
- Java: a **JDK 21+** (to run jdtls; projects can target older versions) and `python3`
- Optional: [`lazygit`](https://github.com/jesseduffield/lazygit), `npm` (for the JSON/YAML/Bash language servers), a clipboard tool (`wl-clipboard` / `xclip`)

## Install

```sh
mv ~/.config/nvim ~/.config/nvim.bak   # back up any existing config
git clone https://github.com/janne6565/dotfiles ~/.config/nvim
nvim
```

On first start Neovim asks you to confirm installing the plugins. Mason then installs the language servers, formatters and Java tooling in the background (`:Mason` shows progress). Treesitter parsers are compiled the first time too. Restart once everything is done.

### Installing the tree-sitter CLI

| System | Command |
| --- | --- |
| macOS | `brew install tree-sitter-cli` |
| Arch | `sudo pacman -S tree-sitter-cli` |
| Fedora | `sudo dnf install tree-sitter-cli` |
| Any (with Rust) | `cargo install --locked tree-sitter-cli` |
| Any | download the binary for your platform from the [tree-sitter releases](https://github.com/tree-sitter/tree-sitter/releases) and put it on your `PATH` |

Debian/Ubuntu packages are usually too old; use cargo or the release binary there. Check with `tree-sitter --version`.
Without the CLI, Neovim still starts and shows one warning, but only its bundled parsers (Lua, Vimscript, Markdown, C) highlight.

## Layout

```
init.lua               entry point, loads everything below in order
lua/config/            options, keymaps, autocmds, vim.pack build hooks
lua/plugins/           one file per area (snacks, ui, lsp, java, ...)
nvim-pack-lock.json    pinned plugin versions, commit this
lua/local.lua          optional machine-local overrides (git-ignored)
```

To add a plugin, call `vim.pack.add { gh 'owner/repo' }` in a file under `lua/plugins/`, then `require` it from `init.lua`.

## Keymaps

`<leader>` is **Space**. Press it and wait: which-key lists everything.

| Keys | Action |
| --- | --- |
| `<leader><space>` | Smart file finder |
| `<leader>ff` / `fr` / `fb` / `fc` | Files / recent / buffers / config files |
| `<leader>/` or `<leader>sg` | Live grep |
| `<leader>sw` | Grep word under cursor / selection |
| `<leader>sh`, `sk`, `sd`, `sr` | Help, keymaps, diagnostics, resume last search |
| `<leader>e` | File explorer |
| `<C-/>` or `<leader>tt` | Toggle floating terminal (`<leader>tb` for a bottom split) |
| `<leader>gg` | Lazygit |
| `<leader>w` + `h/j/k/l` or `<C-h/j/k/l>` | Move between windows (`<leader>w` works like `<C-w>`: `s`/`v` split, `q` close, `=` equalize) |
| `<S-h>` / `<S-l>`, `<leader>bd` | Previous / next buffer, delete buffer |
| `s` / `S` | Flash jump / treesitter select |
| `gsa` / `gsd` / `gsr` | Add / delete / replace surrounding |
| `gd`, `grr`, `gri`, `grt`, `K` | Definition, references, implementation, type definition, hover |
| `<leader>ca` / `<leader>cr` / `<leader>cf` | Code action / rename / format |
| `<leader>xx` | Diagnostics list (Trouble) |
| `]h` / `[h`, `<leader>h…` | Next / previous git hunk, hunk actions |
| `<F5>`, `<F10>`, `<F11>`, `<F12>` | Debug: continue, step over, step into, step out |
| `<leader>db`, `<leader>du` | Toggle breakpoint, toggle debug view |
| `<leader>t…` | Toggles (format on save, inlay hints, wrap, spelling, ...) |
| `<leader>pu` | Update plugins |

### Java (`<leader>j…`, in Java buffers)

| Keys | Action |
| --- | --- |
| `<leader>jo` | Organize imports |
| `<leader>jv` / `jc` / `jm` | Extract variable / constant / method (`jm` in visual mode) |
| `<leader>jt` / `jT` | Run nearest test method / test class (JUnit) |
| `<leader>jp` | Jump between test and implementation |
| `<leader>ju` | Reload project config after editing `pom.xml` / `build.gradle` |
| `<F5>` | Debug: pick a `main` class to launch |

Extra JDKs (for example Java 17 and 21 side by side) can be registered under `runtimes` in `lua/plugins/java.lua`.

## Maintenance

- `:lua vim.pack.update()` (`<leader>pu`) fetches updates and opens a review buffer. `:write` applies them, `:quit` cancels. Then commit `nvim-pack-lock.json`.
- `:checkhealth` for troubleshooting, `:Mason` for tool versions.
- If jdtls acts up on a project, `<leader>jw` wipes its workspace data.
