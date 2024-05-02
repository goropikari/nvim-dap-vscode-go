vim.g.mapleader = ","
vim.g.maplocalleader = ","
vim.o.shell = "bash"
vim.o.exrc = true -- current directory の .nvim.lua を読み込む

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
require("lazy").setup(
  {
    "ellisonleao/gruvbox.nvim",
    {
      -- Highlight, edit, and navigate code
      "nvim-treesitter/nvim-treesitter",
      dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
      },
      build = ":TSUpdate",
    },

    {
      -- Detect tabstop and shiftwidth automatically
      "tpope/vim-sleuth",
    },

    {
      -- Set lualine as statusline
      "nvim-lualine/lualine.nvim",
    },

    {
      -- Add indentation guides even on blank lines
      "lukas-reineke/indent-blankline.nvim",
      -- See `:help ibl`
      main = "ibl",
      opts = {},
    },

    -- sidebar file explorer
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      -- cmd = 'Neotree',
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
        -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
      },
      keys = {
        {
          "<c-e>", -- Ctrl-e で neo-tree の表示切り替え
          function()
            require("neo-tree.command").execute({ toggle = true })
          end,
          desc = "Explorer NeoTree",
        },
      },
      deactivate = function()
        vim.cmd([[Neotree close]])
      end,
      init = function()
        if vim.fn.argc(-1) == 1 then
          local stat = vim.loop.fs_stat(vim.fn.argv(0))
          if stat and stat.type == "directory" then
            require("neo-tree")
          end
        end
      end,
      config = function()
        require("neo-tree").setup({
          sources = { "filesystem", "buffers", "git_status", "document_symbols" },
          open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
          hijack_netrw_behavior = "disabled",
          filesystem = {
            bind_to_cwd = false,
            follow_current_file = { enabled = true },
            use_libuv_file_watcher = true,
            filtered_items = {
              hide_dotfiles = false,
            },
          },
          window = {
            position = "float",
            mappings = {
              ["<space>"] = "none",
              ["Y"] = function(state)
                local node = state.tree:get_node()
                local path = node:get_id()
                vim.fn.setreg("+", path, "c")
              end,
            },
          },
          default_component_configs = {
            indent = {
              with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
              expander_collapsed = "",
              expander_expanded = "",
              expander_highlight = "NeoTreeExpander",
            },
          },
        })
      end,
    },

    {
      -- Highly experimental plugin that completely replaces the UI for messages, cmdline and the popupmenu.
      -- command が pop up window で表示される
      "folke/noice.nvim",
      event = "VeryLazy",
      opts = {
        -- add any options here
      },
      dependencies = {
        -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
        "MunifTanjim/nui.nvim",
        -- OPTIONAL:
        --   `nvim-notify` is only needed, if you want to use the notification view.
        --   If not available, we use `mini` as the fallback
        -- "rcarriga/nvim-notify",
      },
    },

    {
      -- vim.ui.input を cursor で選択できるようにする
      "stevearc/dressing.nvim",
      opts = {},
    },

    -- buffer を tab で表示する
    {
      "romgrk/barbar.nvim",
      dependencies = {
        "lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
        "nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
      },
      init = function()
        vim.g.barbar_auto_setup = false
      end,
      opts = {
        animation = false,
      },
      version = "^1.0.0", -- optional: only update when a new 1.x version is released
    },

    -- cursor 下と同じ文字列に下線を引く'
    {
      "xiyaowong/nvim-cursorword",
    },

    {
      -- Ctrl-t でターミナルを出す
      "akinsho/toggleterm.nvim",
      version = "*",
      -- config = true,
      opts = {
        open_mapping = [[<c-\>]],
      },
    },

    {
      -- cursor 下と同じ文字のものをハイライトする
      "RRethy/vim-illuminate",
      opts = {
        delay = 200,
        large_file_cutoff = 2000,
        large_file_overrides = {
          providers = { "lsp", "treesitter", "regex" },
        },
      },
      config = function(_, opts)
        require("illuminate").configure(opts)
      end,
    },

    -- Fuzzy Finder (files, lsp, etc)
    {
      "nvim-telescope/telescope.nvim",
      branch = "0.1.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        -- Fuzzy Finder Algorithm which requires local dependencies to be built.
        -- Only load if `make` is available. Make sure you have the system
        -- requirements installed.
        {
          "nvim-telescope/telescope-fzf-native.nvim",
          -- NOTE: If you are having trouble with this installation,
          --       refer to the README for telescope-fzf-native for more instructions.
          build = "make",
          cond = function()
            return vim.fn.executable("make") == 1
          end,
        },
      },
    },

    {
      "goropikari/chowcho.nvim",
      -- dir = '~/workspace/github/chowcho.nvim',
      branch = "fix",
      dependencies = {
        "nvim-tree/nvim-web-devicons",
      },
    },

    -- Useful plugin to show you pending keybinds.
    {
      "folke/which-key.nvim",
      opts = {},
    },

    {
      -- ssh, docker 内で copy したものをホストの clipboard に入れる
      "ojroques/nvim-osc52",
    },

    {
      -- splitting/joining blocks of code like arrays, hashes, statements, objects, dictionaries, etc.
      "Wansmer/treesj",
      -- keys = { '<leader>m' },
      dependencies = { "nvim-treesitter/nvim-treesitter" },
      keys = {
        {
          "<leader>m",
          function()
            require("treesj").toggle()
          end,
          desc = "split/join collections",
        },
      },
      opts = {
        max_join_length = 1000,
      },
    },

    -- Add/delete/change surrounding pairs
    {
      "kylechui/nvim-surround",
      version = "*", -- Use for stability; omit to use `main` branch for the latest features
      event = "VeryLazy",
      config = function()
        require("nvim-surround").setup({
          keymaps = {
            -- default keymap を無効化
            insert = false,
            insert_line = false,
            normal = false,
            normal_cur = false,
            normal_line = false,
            normal_cur_line = false,
            visual = false,
            visual_line = false,
            delete = false,
            change = false,
            change_line = false,
          },
        })
      end,
    },

    {
      "junegunn/vim-easy-align",
    },

    {
      -- :FixWhitespace で末端空白を消す
      "bronson/vim-trailing-whitespace",
    },

    -- Ctrl-/ でコメント
    {
      "numToStr/Comment.nvim",
      opts = {
        mappings = false,
      },
    },

    {
      -- Autocompletion
      "hrsh7th/nvim-cmp",
      dependencies = {
        -- Snippet Engine & its associated nvim-cmp source
        {
          "L3MON4D3/LuaSnip",
          build = (function()
            -- Build Step is needed for regex support in snippets
            -- This step is not supported in many windows environments
            -- Remove the below condition to re-enable on windows
            if vim.fn.has("win32") == 1 then
              return
            end
            return "make install_jsregexp"
          end)(),
        },
        "saadparwaiz1/cmp_luasnip",

        -- Adds LSP completion capabilities
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-path",

        -- Adds a number of user-friendly snippets
        "rafamadriz/friendly-snippets",
      },
    },

    {
      -- Git related plugins
      "tpope/vim-fugitive",
    },

    {
      -- Adds git related signs to the gutter, as well as utilities for managing changes
      "lewis6991/gitsigns.nvim",
      dependencies = {
        "petertriho/nvim-scrollbar",
      },
      config = function()
        require("gitsigns").setup()
        require("scrollbar.handlers.gitsigns").setup()
      end,
    },

    {
      -- LSP Configuration & Plugins
      "neovim/nvim-lspconfig",
      dependencies = {
        -- Automatically install LSPs to stdpath for neovim
        { "williamboman/mason.nvim", config = true },
        "williamboman/mason-lspconfig.nvim",

        -- Useful status updates for LSP
        -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
        { "j-hui/fidget.nvim", opts = {} },

        -- Additional lua configuration, makes nvim stuff amazing!
        "folke/neodev.nvim",
      },
    },

    {
      "neoclide/jsonc.vim",
    },

    -- markdown
    -- :MarkdownPreview で browser で markdown が表示される
    {
      "iamcco/markdown-preview.nvim",
      cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
      ft = { "markdown" },
      build = function()
        vim.fn["mkdp#util#install"]()
      end,
    },

    {
      "mfussenegger/nvim-dap",
      dependencies = {
        "rcarriga/nvim-dap-ui", -- Creates a beautiful debugger UI
        "theHamsta/nvim-dap-virtual-text", -- code 中に変数の値を表示する
        "nvim-telescope/telescope-dap.nvim",
        "nvim-neotest/nvim-nio",

        {
          dir = "/workspaces/nvim-dap-vscode-go",
        },
      },
    },

    {
      "nvim-neotest/neotest",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",

        {
          url = "https://github.com/wwnbb/neotest-go",
          branch = "feat/dap-support",
        },
      },
    },
  },

  -- options
  {
    checker = {
      -- automatically check for plugin updates
      enabled = true,
      concurrency = nil, ---@type number? set to 1 to check for updates very slowly
      notify = false, -- get a notification when new updates are found
      frequency = 3600, -- check for updates every hour
      check_pinned = false, -- check for pinned packages that can't be updated
    },
    change_detection = {
      -- automatically check for config file changes and reload the ui
      enabled = true,
      notify = false, -- get a notification when changes are found
    },
    performance = {
      rtp = {
        disabled_plugins = {
          "netrw",
          "netrwPlugin",
          "netrwSettings",
          "gzip",
          -- "matchit",
          -- "matchparen",
          "netrwPlugin",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin", -- "netrwFileHandlers",
        },
      },
    },
  }
)

require("custom.plugins")
