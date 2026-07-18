vim.g.mapleader = " "
vim.g.maplocleader = "\\"
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.swapfile = false
vim.opt.winborder = "rounded"
-- Style
vim.cmd("colorscheme default")
-- Transparent background
vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE' })
-- vim.api.nvim_set_hl(0, 'StatusLine', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'StatusLineNC', { bg = 'NONE' })

-- Plugins
local gh = function(x) return 'https://github.com/' .. x end
vim.pack.add({
  gh('neovim/nvim-lspconfig')
})

-- LSP
vim.lsp.enable('lua_ls')
vim.lsp.enable('kotlin_lsp')
vim.lsp.enable('yamlls')
vim.lsp.enable('gh_actions_ls')
vim.lsp.enable('jsonls')
vim.lsp.enable('ts_ls')
-- vim.lsp.enable('texlab')
-- vim.lsp.enable('terraformls')

-- Diagnostics
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)

-- Completion and formatting
vim.o.autocomplete = true
vim.opt.completeopt = { 'menuone', 'noselect' }
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end

    -- Auto-format ("lint") on save.
    if not client:supports_method('textDocument/willSaveWaitUntil')
        and client:supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
        buffer = ev.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = ev.buf, id = client.id, timeout_ms = 1000 })
        end,
      })
    end
  end,
})
vim.opt.complete:append('o')
