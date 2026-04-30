-- ============================================================================
--  ~/.config/nvim/init.lua — kickstart-style, single-file config.
--
--  Sections:
--    1. Leader + options
--    2. Autocmds + ex commands
--    3. Core keymaps (no plugins required)
--    4. lazy.nvim bootstrap
--    5. Plugin specs (everything inline)
-- ============================================================================

-- ---------- 1. Leader + options --------------------------------------------
vim.g.mapleader = '\\'
vim.g.maplocalleader = '\\'

local opt = vim.opt
opt.autoindent = true
opt.autoread = true
opt.backspace = 'indent,eol,start'
opt.clipboard = 'unnamedplus'
opt.cmdheight = 1
opt.completeopt = 'menu,menuone,noselect'
opt.cursorline = false
opt.expandtab = true
opt.exrc = true
opt.foldlevelstart = 20
opt.foldmethod = 'syntax'
opt.hidden = true
opt.hlsearch = true
opt.ignorecase = true
opt.incsearch = true
opt.laststatus = 3                -- global statusline
opt.lazyredraw = true
opt.mouse = 'a'
opt.number = true
opt.pumheight = 10
opt.ruler = true
opt.scrolloff = 4
opt.secure = true
opt.shiftwidth = 4
opt.showmatch = true
opt.showmode = false              -- lualine handles this
opt.signcolumn = 'yes'
opt.smartcase = true
opt.softtabstop = 4
opt.splitbelow = true
opt.splitright = true
opt.tabstop = 4
opt.termguicolors = true          -- 24-bit colors; gruvbox.nvim values match Ghostty's palette
opt.textwidth = 120
opt.timeoutlen = 500
opt.ttimeoutlen = 50
opt.undofile = true
opt.updatetime = 250
opt.writebackup = false
opt.swapfile = false

-- ---------- 2. Autocmds + ex commands --------------------------------------
local aug = vim.api.nvim_create_augroup('init', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
  group = aug, callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = aug,
  pattern = { 'c', 'cpp', 'vim', 'xml', 'html', 'xhtml', 'javascript',
              'javascriptreact', 'typescript', 'typescriptreact' },
  callback = function()
    vim.opt_local.foldmethod = 'syntax'
    vim.cmd('normal! zR')
  end,
})

vim.api.nvim_create_autocmd('BufEnter', {
  group = aug, command = ':syntax sync minlines=2000',
})

-- :Q :W and TEOL/CLEAN cleanups (carried over from existing vimrc)
vim.api.nvim_create_user_command('Q', 'q<bang>', { bang = true })
vim.api.nvim_create_user_command('W', 'w<bang>', { bang = true })
vim.api.nvim_create_user_command('TEOL', [[%s/\s\+$//e]], {})
vim.api.nvim_create_user_command('CLEAN', function()
  vim.cmd('retab')
  vim.cmd('TEOL')
end, {})

-- ---------- 3. Core keymaps -------------------------------------------------
local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

-- Toggle fold with <Space>
map('n', '<Space>', 'za', 'Toggle fold')

-- Move lines up/down with Alt-j/k (works on Mac + Linux when Alt is set
-- to send escape sequences instead of compose-key — Ghostty does this).
map('n', '<A-j>', ':m +1<cr>',  'Move line down')
map('n', '<A-k>', ':m -2<cr>',  'Move line up')
map('v', '<A-j>', ":m '>+1<cr>gv=gv", 'Move selection down')
map('v', '<A-k>', ":m '<-2<cr>gv=gv", 'Move selection up')

-- Window/buffer management
map('n', '<leader>q',  ':close<cr>',          'Close window')
map('n', '<leader>Q',  ':close!<cr>',         'Close window (force)')
map('n', '<leader>d',  ':bp|bd #<cr>',        'Delete buffer (keep window)')
map('n', '<leader>D',  ':bp!|bd! #<cr>',      'Delete buffer (force)')
map('n', '<leader>da', ':%bdelete<cr>',       'Delete all buffers')
map('n', '<leader>DA', ':%bdelete!<cr>',      'Delete all buffers (force)')

-- Resize splits — exact bindings carried over from the work vimrc.
map('n', '<leader>=',  function()
  vim.cmd('vertical resize ' .. math.floor(vim.fn.winwidth(0) * 3 / 2))
end, 'Grow split')
map('n', '<leader>-',  function()
  vim.cmd('vertical resize ' .. math.floor(vim.fn.winwidth(0) * 2 / 3))
end, 'Shrink split')
map('n', '<leader>|',  '<C-w>=', 'Equalize splits')
map('n', '<C-\\>',     ':vsp<cr>', 'Vertical split')
-- Horizontal split: bind both forms — legacy terminals send Ctrl-/ as 0x1F
-- (which vim sees as <C-_>); modern terminals (Ghostty / kitty / CSI-u) send <C-/>.
map('n', '<C-_>',      ':sp<cr>',  'Horizontal split')
map('n', '<C-/>',      ':sp<cr>',  'Horizontal split')

-- Diagnostics — match existing <leader>e / <leader>E convention.
map('n', '<leader>e', function() vim.diagnostic.jump({ count = 1 })  end, 'Next diagnostic')
map('n', '<leader>E', function() vim.diagnostic.jump({ count = -1 }) end, 'Prev diagnostic')

-- ---------- 4. lazy.nvim bootstrap -----------------------------------------
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ---------- 5. Plugins ------------------------------------------------------
require('lazy').setup({

  -- ----- Colorscheme: Nord (nordic.nvim — polished treesitter coverage)
  {
    'AlexvZyl/nordic.nvim',
    priority = 1000,
    config = function()
      require('nordic').setup({
        transparent = { bg = true },     -- inherit Ghostty's bg
        bold_keywords = false,
        italic_comments = true,
        bright_border = false,
        reduced_blue = true,             -- slightly warmer Nord (improves contrast vs vanilla Nord)
        swap_backgrounds = false,
        telescope = { style = 'classic' },
      })
      require('nordic').load()
    end,
  },

  -- ----- Statusline -----------------------------------------------------
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'auto',          -- catppuccin doesn't ship a lualine theme module;
                                 -- 'auto' derives it from the active colorscheme.
        component_separators = '|',
        section_separators = '',
        globalstatus = true,
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
    },
  },

  -- ----- Treesitter (syntax) -------------------------------------------
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {
        'bash', 'css', 'diff', 'dockerfile', 'fish', 'gitcommit', 'go',
        'html', 'javascript', 'json', 'jsonc', 'lua', 'markdown',
        'markdown_inline', 'python', 'regex', 'ruby', 'rust', 'toml',
        'tsx', 'typescript', 'vim', 'vimdoc', 'yaml',
      },
      auto_install = true,
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      indent = { enable = true },
    },
  },

  -- ----- Telescope (fuzzy finder) ---------------------------------------
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make',
        cond = function() return vim.fn.executable('make') == 1 end },
    },
    config = function()
      local t = require('telescope')
      local actions = require('telescope.actions')
      t.setup({
        defaults = {
          path_display = { 'truncate' },
          layout_config = { horizontal = { preview_width = 0.55 } },
          mappings = {
            i = {
              -- Single-press <Esc> closes (skip telescope's normal-mode layer).
              ['<esc>'] = actions.close,
              -- Preview scroll — same chord style as the fzf opts.
              ['<C-A-k>'] = actions.preview_scrolling_up,
              ['<C-A-j>'] = actions.preview_scrolling_down,
              ['<A-Up>']   = actions.preview_scrolling_up,
              ['<A-Down>'] = actions.preview_scrolling_down,
            },
            n = {
              ['<C-A-k>'] = actions.preview_scrolling_up,
              ['<C-A-j>'] = actions.preview_scrolling_down,
              ['<A-Up>']   = actions.preview_scrolling_up,
              ['<A-Down>'] = actions.preview_scrolling_down,
            },
          },
        },
      })
      pcall(t.load_extension, 'fzf')

      local b = require('telescope.builtin')
      -- Match the exact <leader> bindings from the existing vimrc.
      map('n', '<leader>s', b.live_grep,    'Grep')
      map('n', '<leader>S', b.current_buffer_fuzzy_find, 'Lines (current buffer)')
      map('n', '<leader>t', b.find_files,   'Find files')
      map('n', '<leader>T', b.buffers,      'Buffers')
      map('n', '<leader>c', b.git_commits,  'Git commits')
      map('n', '<leader>g', b.git_status,   'Git status (changed files)')
    end,
  },

  -- ----- Smart pane navigation (vim-tmux-navigator successor) ----------
  {
    'mrjones2014/smart-splits.nvim',
    lazy = false,
    config = function()
      local ss = require('smart-splits')
      ss.setup({})
      map('n', '<C-h>', ss.move_cursor_left,  'Move to left split/pane')
      map('n', '<C-j>', ss.move_cursor_down,  'Move to bottom split/pane')
      map('n', '<C-k>', ss.move_cursor_up,    'Move to top split/pane')
      map('n', '<C-l>', ss.move_cursor_right, 'Move to right split/pane')
    end,
  },

  -- ----- Mason — installs LSP servers, formatters, linters --------------
  {
    'mason-org/mason.nvim',
    cmd = { 'Mason', 'MasonInstall', 'MasonUpdate' },
    opts = {},
  },

  -- ----- LSP -------------------------------------------------------------
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'mason-org/mason.nvim',
      'mason-org/mason-lspconfig.nvim',
      'saghen/blink.cmp',
    },
    config = function()
      -- Servers we want; mason-lspconfig will auto-install.
      local servers = {
        ts_ls = {},                 -- TypeScript / JavaScript
        eslint = {},                -- JS/TS linting
        basedpyright = {},          -- Python (faster fork of pyright)
        lua_ls = {                  -- For editing this config
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
              diagnostics = { globals = { 'vim' } },
            },
          },
        },
      }

      require('mason-lspconfig').setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = true,
      })

      local capabilities = require('blink.cmp').get_lsp_capabilities()
      for name, cfg in pairs(servers) do
        cfg.capabilities = capabilities
        vim.lsp.config(name, cfg)
        vim.lsp.enable(name)
      end

      -- LSP keymaps — applied on attach so they only exist where LSP runs.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(ev)
          local opts = function(desc) return { buffer = ev.buf, silent = true, desc = desc } end

          -- Direct-jump (no picker): gd / gy / gi / gr
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition,      opts('Definition'))
          vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, opts('Type definition'))
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation,  opts('Implementation'))
          vim.keymap.set('n', 'gr', vim.lsp.buf.references,      opts('References'))

          -- Telescope-picker variants: <leader>g{d,y,i,r}
          local b = require('telescope.builtin')
          vim.keymap.set('n', '<leader>gd', b.lsp_definitions,      opts('Definitions (picker)'))
          vim.keymap.set('n', '<leader>gy', b.lsp_type_definitions, opts('Type defs (picker)'))
          vim.keymap.set('n', '<leader>gi', b.lsp_implementations,  opts('Implementations (picker)'))
          vim.keymap.set('n', '<leader>gr', b.lsp_references,       opts('References (picker)'))

          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts('Hover docs'))
          vim.keymap.set('n', '<leader>n', vim.lsp.buf.rename, opts('Rename'))

          -- Filter out disabled actions (some servers — ts_ls especially —
          -- return them and they clutter the picker).
          local code_action = function()
            vim.lsp.buf.code_action({
              filter = function(a) return a.disabled == nil end,
            })
          end
          vim.keymap.set({ 'n', 'x' }, '<leader>a', code_action, opts('Code action'))
        end,
      })
    end,
  },

  -- ----- Completion (blink.cmp) -----------------------------------------
  {
    'saghen/blink.cmp',
    version = '*',
    dependencies = { 'rafamadriz/friendly-snippets' },
    opts = {
      keymap = { preset = 'default' },        -- <C-space> open, <C-y> accept, <C-n>/<C-p> nav
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      signature = { enabled = true },
    },
  },

  -- ----- Formatting (replaces :CocCommand prettier.formatFile) ----------
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    cmd = 'ConformInfo',
    opts = {
      formatters_by_ft = {
        javascript      = { 'prettierd', 'prettier', stop_after_first = true },
        javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        typescript      = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        json            = { 'prettierd', 'prettier', stop_after_first = true },
        jsonc           = { 'prettierd', 'prettier', stop_after_first = true },
        yaml            = { 'prettierd', 'prettier', stop_after_first = true },
        markdown        = { 'prettierd', 'prettier', stop_after_first = true },
        html            = { 'prettierd', 'prettier', stop_after_first = true },
        css             = { 'prettierd', 'prettier', stop_after_first = true },
        python          = { 'ruff_format', 'black', stop_after_first = true },
        lua             = { 'stylua' },
      },
    },
    init = function()
      map('n', '<leader>f', function()
        require('conform').format({ async = true, lsp_format = 'fallback' })
      end, 'Format buffer')
    end,
  },

  -- ----- Git ------------------------------------------------------------
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(buf)
        local gs = require('gitsigns')
        local function gmap(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
        end
        gmap('n', '<leader>b',  gs.blame_line,   'Git blame line')
        gmap('n', ']c',         gs.next_hunk,    'Next hunk')
        gmap('n', '[c',         gs.prev_hunk,    'Prev hunk')
        gmap('n', '<leader>hp', gs.preview_hunk, 'Preview hunk')
        -- gitsigns 1.0+: stage_hunk toggles staged/unstaged on the current hunk.
        gmap('n', '<leader>hs', gs.stage_hunk,   'Stage / unstage hunk')
        gmap('n', '<leader>hr', gs.reset_hunk,   'Reset hunk (discard changes)')
      end,
    },
  },

  -- :Git command (fugitive)
  { 'tpope/vim-fugitive', cmd = { 'Git', 'G' } },

  -- ----- Editing helpers ------------------------------------------------
  { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },
  { 'kylechui/nvim-surround', version = '*', event = 'VeryLazy', opts = {} },
  { 'numToStr/Comment.nvim',  event = 'VeryLazy', opts = {} },

  -- LSP progress in corner
  { 'j-hui/fidget.nvim', event = 'LspAttach', opts = {} },

}, {
  -- lazy.nvim global options
  install = { colorscheme = { 'gruvbox' } },
  ui = { border = 'rounded' },
  change_detection = { notify = false },
})
