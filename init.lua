-- Required for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Tabs and spaces
vim.opt.tabstop = 4
vim.opt.softtabstop = 0
vim.opt.shiftwidth = 4
vim.opt.smarttab = true
vim.opt.expandtab = true

-- Show line number
vim.opt.number = true

-- Highlight all search pattern matches
vim.opt.hlsearch = true

-- Highlight cursorline
vim.opt.cursorline = true

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
        use {'zbirenbaum/copilot.lua',
            requires = {
                'zbirenbaum/copilot-cmp'
            }
        }
    end
)

-------------------------------------------------------------------------------
-- Colors
-------------------------------------------------------------------------------
vim.opt.termguicolors = true
vim.g['codedark_conservative'] = 1
vim.cmd [[ colorscheme codedark ]]

-------------------------------------------------------------------------------
-- Config for vim-airline
-------------------------------------------------------------------------------
vim.g['airline_powerline_fonts'] = 1

-------------------------------------------------------------------------------
-- Config for indent-blankline
-------------------------------------------------------------------------------
vim.opt.list = true
vim.opt.listchars:append "space:·"
vim.opt.listchars:append "eol:║"

require("ibl").setup( {
    indent = {
        highlight = { "Whitespace", "CursorColumn" },
        char = "|",
        tab_char = "~"
    },
    whitespace = {
        highlight = { "Whitespace", "CursorColumn" },
        remove_blankline_trail = false
    },
    scope = {
        enabled = false
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
    PATH = "prepend",
    ensure_installed = {
        "clangd",
        "jsonls",
        "bashls",
        "marksman",
        "pyright",
        "yamlls",
        "autotools_ls",
        "hdl_checker",
    },
} )

-------------------------------------------------------------------------------
-- Copilot
-------------------------------------------------------------------------------
require("copilot").setup( {
    suggestion = {
        enabled = false,
    },
    panel = {
        enabled = false,
    },
} )

require("copilot_cmp").setup()

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
--        ["<Tab>"] = cmp.mapping(
--            function(fallback)
--                if cmp.visible() then
--                    cmp.select_next_item()
--                elseif luasnip.expandable() then
--                    luasnip.expand()
--                elseif luasnip.expand_or_jumpable() then
--                    luasnip.expand_or_jump()
--                elseif check_backspace() then
--                    fallback()
--                else
--                    fallback()
--                end
--            end, { "i", "s", }
--        ),
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
        { name = 'copilot' },
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
local lspconfig = require("lspconfig")

lspconfig['clangd'].setup {
    capabilities = capabilities
}
lspconfig['jsonls'].setup {
    capabilities = capabilities
}
lspconfig['bashls'].setup {
    capabilities = capabilities
}
lspconfig['marksman'].setup {
    capabilities = capabilities
}
lspconfig['pyright'].setup {
    capabilities = capabilities
}
lspconfig['yamlls'].setup {
    capabilities = capabilities
}
lspconfig['autotools_ls'].setup {
    capabilities = capabilities
}

lspconfig['hdl_checker'].setup {
    capabilities = capabilities
}

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

-----------------------------------------------------------------------------
-- Key mapping
-------------------------------------------------------------------------------
vim.api.nvim_set_keymap("n", "<C-f>", ":NvimTreeFocus<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-d>", ":q!<cr>", { noremap = true })
