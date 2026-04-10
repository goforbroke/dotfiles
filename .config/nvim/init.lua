-- 行番号を表示
vim.opt.number = true

-- シンタックスハイライトを有効化
-- (Neovimではデフォルトで有効ですが、明示的に指定する場合)
vim.cmd('syntax on')

-- スマートインデントの設定
vim.opt.smartindent = true

-- (補足) タブの幅なども設定しておくとより快適です
vim.opt.tabstop = 2      -- 画面上のタブ幅
vim.opt.shiftwidth = 2   -- 自動インデント時の幅
vim.opt.expandtab = true -- タブをスペースに変換
