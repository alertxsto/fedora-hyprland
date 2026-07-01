return {
  {
    "xiyaowong/transparent.nvim",
    lazy = false,
    priority = 999,
    opts = {
      extra_groups = {
        "NormalFloat",
        "NvimTreeNormal",
        "NeoTreeNormal",
        "NeoTreeNormalNC",
        "NeoTreeEndOfBuffer",
      },
    },
  },
  {
    "neanias/everforest-nvim",
    priority = 1000,
    opts = {
      background = "hard",
      transparent_background_level = 2,
      italics = true,
      disable_italic_comments = false,
      on_highlights = function(hl, palette)
        hl.Normal = { fg = palette.fg, bg = "NONE" }
        hl.NormalFloat = { fg = palette.fg, bg = "NONE" }
        hl.NeoTreeNormal = { fg = palette.fg, bg = "NONE" }
      end,
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      transparent_background = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  { "ellisonleao/gruvbox.nvim", opts = { transparent_mode = true } },
  { "shaunsingh/nord.nvim" },
  { "Mofiqul/dracula.nvim" },
  { "marko-cerovac/material.nvim" },
  { "craftzdog/solarized-osaka.nvim", opts = { transparent = true } },
  { "rose-pine/neovim", name = "rose-pine", opts = { disable_background = true } },
}
