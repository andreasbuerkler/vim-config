-- Required for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Tabs and spaces
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

-- Show line number
vim.opt.number = true

-- Highlight all search pattern matches
vim.opt.hlsearch = true

-- Highlight cursorline
vim.opt.cursorline = true

-------------------------------------------------------------------------------
-- Colors
-------------------------------------------------------------------------------
vim.opt.termguicolors = true
--vim.cmd [[ airline_theme codedark ]]
vim.g['codedark_conservative'] = 1
vim.cmd [[ colorscheme codedark ]]

-------------------------------------------------------------------------------
-- Plugins
-------------------------------------------------------------------------------

-- Install packer
local install_path = vim.fn.stdpath('data') .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
end

require('packer').startup(
    function(use)
        use 'wbthomason/packer.nvim'
        use 'lukas-reineke/indent-blankline.nvim'
        use 'tomasiser/vim-code-dark'
        use 'nvim-treesitter/nvim-treesitter'
        use {'nvim-tree/nvim-tree.lua',
            requires = {
                'nvim-tree/nvim-web-devicons',
            }
        }
        use 'vim-airline/vim-airline'
        use 'williamboman/mason.nvim'
        use 'williamboman/mason-lspconfig.nvim'
        use 'neovim/nvim-lspconfig'
        use 'hrsh7th/nvim-cmp'
        use 'hrsh7th/cmp-nvim-lsp'
        use 'hrsh7th/vim-vsnip'
        use 'hrsh7th/cmp-buffer'
        use 'hrsh7th/cmp-path'
        use 'hrsh7th/cmp-cmdline'
    end
)

-------------------------------------------------------------------------------
-- Config for indent-blankline
-------------------------------------------------------------------------------
vim.opt.list = true
vim.opt.listchars:append "space:·"
vim.opt.listchars:append "eol:║"

vim.cmd [[highlight IndentBlanklineIndent1 guifg=#444444 gui=nocombine]]

require("indent_blankline").setup( {
    show_end_of_line = true,
    space_char_blankline = " ",
    char_highlight_list = {
        "IndentBlanklineIndent1",
    },
    space_char_highlight_list = {
        "IndentBlanklineIndent1",
    },
} )

-------------------------------------------------------------------------------
-- Config for nvim-treesitter
-------------------------------------------------------------------------------
vim.cmd [[ syntax enable ]]

require'nvim-treesitter.configs'.setup( {
    ensure_installed = {
        "c",
        "cpp",
        "diff",
        "json",
        "markdown",
        "lua",
        "python",
        "yaml"
    },
    sync_install = false,
    highlight = {
        enable = true,
    },
} )

-------------------------------------------------------------------------------
-- Config for nvim-tree
-------------------------------------------------------------------------------
require("nvim-tree").setup( {
    actions = {
        open_file = {
            quit_on_open = true
        }
    }
} )

-------------------------------------------------------------------------------
-- Language server
-------------------------------------------------------------------------------
require("mason").setup()
require("mason-lspconfig").setup( {
    ensure_installed = {
--        "clangd",
        "jsonls",
        "bashls",
        "marksman",
--        "sumneko_lua",
        "pyright",
        "yamlls"
    },
} )

-------------------------------------------------------------------------------
-- Autocomplete
-------------------------------------------------------------------------------
local cmp = require'cmp'

cmp.setup( {
    snippet = {
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert( {
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<C-d>'] = cmp.mapping.abort(),
        ['<Up>'] = cmp.mapping.select_prev_item(select_opts),
        ['<Down>'] = cmp.mapping.select_next_item(select_opts),
        ["<Tab>"] = cmp.mapping(
            function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip.expandable() then
                    luasnip.expand()
                elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                elseif check_backspace() then
                    fallback()
                else
                    fallback()
                end
            end, { "i", "s", }
        ),
        ["<S-Tab>"] = cmp.mapping(
            function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, { "i", "s", }
        ),
    } ),
    sources = cmp.config.sources( {
        { name = 'nvim_lsp' },
        { name = 'vsnip' },
        { name = 'buffer' },
        { name = 'path' },
    } ),
    window = {
        completion = {
            border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
        },
        documentation = {
            border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
        },
    },
} )

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline( { '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
} )

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources( {
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    } )
} )

local capabilities = require('cmp_nvim_lsp').default_capabilities()

require("lspconfig").jsonls.setup( {
    capabilities = capabilities
} )
require("lspconfig").bashls.setup( {
    capabilities = capabilities
} )
require("lspconfig").marksman.setup( {
    capabilities = capabilities
} )
require("lspconfig").pyright.setup( {
    capabilities = capabilities
} )
require("lspconfig").yamlls.setup( {
    capabilities = capabilities
} )

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function()
    local bufmap = function(mode, lhs, rhs)
      local opts = {buffer = true}
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Displays hover information about the symbol under the cursor
    bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')

    -- Jump to the definition
    bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')

    -- Jump to declaration
    bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')

    -- Lists all the implementations for the symbol under the cursor
    bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')

    -- Jumps to the definition of the type symbol
    bufmap('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')

    -- Lists all the references 
    bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')

    -- Renames all references to the symbol under the cursor
    bufmap('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')

  end
})

-------------------------------------------------------------------------------
-- Key mapping
-------------------------------------------------------------------------------
vim.api.nvim_set_keymap("n", "<C-f>", ":NvimTreeFocus<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-d>", ":q!<cr>", { noremap = true })
