vim.opt.runtimepath:append(vim.fn.expand("~/.config/nvim"))

if vim.g.vscode then
  -- VSCode Neovim extension - only load mappings and options
  require("vscode-nvim/mappings")
  require("vscode-nvim/options")
else
  -- Bootstrap Lazy.nvim (from template)
  local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

  if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
    local result = vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({ { ("Error cloning lazy.nvim:\n%s\n"):format(result), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
      vim.fn.getchar()
      vim.cmd.quit()
    end
  end

  vim.opt.rtp:prepend(lazypath)

  -- validate that lazy is available
  if not pcall(require, "lazy") then
    vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
    vim.fn.getchar()
    vim.cmd.quit()
  end

  -- Load your Lazy setup and any post-setup polish
  require "lazy_setup"
  require "polish"
end
