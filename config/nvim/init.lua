-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Auto-detect theme from wallpaper
local function get_theme_from_wallpaper()
  local handle = io.popen("swww query 2>/dev/null | grep -oP '(?<=image: ).*' | head -n1")
  local wallpaper = handle:read("*a"):gsub("\n", "")
  handle:close()
  
  if wallpaper:match("Everforest") then
    return "everforest"
  elseif wallpaper:match("Catppuccin") then
    return "catppuccin-macchiato"
  elseif wallpaper:match("Gruvbox") then
    return "gruvbox"
  elseif wallpaper:match("Nord") then
    return "nord"
  elseif wallpaper:match("Dracula") then
    return "dracula"
  elseif wallpaper:match("Material") then
    return "material"
  elseif wallpaper:match("Osaka") then
    return "solarized-osaka"
  elseif wallpaper:match("Rose%-Pine") then
    return "rose-pine"
  end
  return "everforest"
end

-- Force transparency on all backgrounds
local function set_transparency()
  vim.cmd([[
    hi Normal guibg=NONE ctermbg=NONE
    hi NormalNC guibg=NONE ctermbg=NONE
    hi NormalFloat guibg=NONE ctermbg=NONE
    hi FloatBorder guibg=NONE ctermbg=NONE
    hi SignColumn guibg=NONE ctermbg=NONE
    hi EndOfBuffer guibg=NONE ctermbg=NONE
    hi NeoTreeNormal guibg=NONE ctermbg=NONE
    hi NeoTreeNormalNC guibg=NONE ctermbg=NONE
    hi NeoTreeEndOfBuffer guibg=NONE ctermbg=NONE
    hi LineNr guibg=NONE ctermbg=NONE
    hi CursorLineNr guibg=NONE ctermbg=NONE
    hi StatusLine guibg=NONE ctermbg=NONE
    hi StatusLineNC guibg=NONE ctermbg=NONE
    hi TabLine guibg=NONE ctermbg=NONE
    hi TabLineFill guibg=NONE ctermbg=NONE
    hi TabLineSel guibg=NONE ctermbg=NONE
    hi VertSplit guibg=NONE ctermbg=NONE
    hi WinSeparator guibg=NONE ctermbg=NONE
    hi Pmenu guibg=NONE ctermbg=NONE
    hi PmenuSel guibg=NONE ctermbg=NONE
    hi PmenuSbar guibg=NONE ctermbg=NONE
    hi PmenuThumb guibg=NONE ctermbg=NONE
    hi Visual guibg=#4a555b
  ]])
end

-- Set colorscheme and transparency
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.cmd.colorscheme(get_theme_from_wallpaper())
    vim.defer_fn(set_transparency, 100)
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", { callback = set_transparency })

-- Watch wallpaper changes (realtime sync)
local last_wallpaper = ""
local timer = vim.loop.new_timer()
timer:start(0, 2000, vim.schedule_wrap(function()
  local handle = io.popen("swww query 2>/dev/null | grep -oP '(?<=image: ).*' | head -n1")
  local current_wallpaper = handle:read("*a"):gsub("\n", "")
  handle:close()
  
  if current_wallpaper ~= last_wallpaper and current_wallpaper ~= "" then
    last_wallpaper = current_wallpaper
    local theme = get_theme_from_wallpaper()
    vim.cmd.colorscheme(theme)
    vim.defer_fn(set_transparency, 50)
  end
end))
