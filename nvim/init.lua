require "core"

local custom_init_path = vim.api.nvim_get_runtime_file("lua/custom/init.lua", false)[1]

if custom_init_path then
  dofile(custom_init_path)
end

require("core.utils").load_mappings()

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

-- bootstrap lazy.nvim!
if not vim.loop.fs_stat(lazypath) then
  require("core.bootstrap").gen_chadrc_template()
  require("core.bootstrap").lazy(lazypath)
end

dofile(vim.g.base46_cache .. "defaults")
vim.opt.rtp:prepend(lazypath)
require "plugins"

-- Relative number lines
vim.wo.relativenumber = true

-- Changing colors
vim.cmd [[

  augroup ilikecursorline
    autocmd VimEnter * :highlight CursorLine guibg=#282a2e
  augroup END

  augroup selection
    autocmd VimEnter * :highlight Visual guibg=#453f5c
  augroup END

  augroup selection
    autocmd VimEnter * :highlight Search guibg=yellow guifg=black
  augroup END

  augroup comments
    autocmd VimEnter * :highlight Comment guifg=#696969
  augroup END

  augroup tabbar
    autocmd VimEnter * :highlight St_InsertMode guifg = black guibg = #e8385b
    autocmd VimEnter * :highlight St_InsertModeSep guifg = #e8385b 

    autocmd VimEnter * :highlight St_NormalMode guifg = black guibg = #C0D0D8
    autocmd VimEnter * :highlight St_NormalModeSep guifg =  #C0D0D8

    autocmd VimEnter * :highlight St_OtherMode guifg = black guibg = #48e085
    autocmd VimEnter * :highlight St_OtherModeSep guifg = #48e085

    autocmd VimEnter * :highlight St_ReplaceMode guifg = black guibg = yellow
    autocmd VimEnter * :highlight St_ReplaceModeSep guifg = yellow

    autocmd VimEnter * :highlight St_VisualMode guifg = black guibg = #4634eb
    autocmd VimEnter * :highlight St_VisualModeSep guifg = #4634eb
  augroup END

]]

