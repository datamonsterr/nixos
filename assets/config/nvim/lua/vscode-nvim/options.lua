local set = vim.opt
-- In VSCode, prefer the extension's clipboard provider for reliable sync
-- See: https://github.com/vscode-neovim/vscode-neovim#api (g:vscode_clipboard)
pcall(function()
	vim.g.clipboard = vim.g.vscode_clipboard
end)
set.ignorecase = true
set.smartcase = true
set.hidden = true
set.showmode = false
set.backup = false
set.writebackup = false
set.updatetime = 300
set.timeoutlen = 300
set.incsearch = true
set.undofile = true
set.writebackup = false
set.clipboard = "unnamedplus"