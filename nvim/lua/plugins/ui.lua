-- Personnalisation de l'interface pour correspondre à notre thème Tokyo Night
return {
  -- ─── Thème principal ──────────────────────────────────────────────
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",           -- Variante la plus sombre
      transparent = true,        -- Fond transparent (pour voir le blur WezTerm)
      terminal_colors = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },

  -- ─── Barre de statut ──────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = "tokyonight",
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "lazy", "alpha" } },
      },
    },
  },

  -- ─── Neo-tree : toujours afficher les fichiers cachés ────────────
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,       -- Affiche les fichiers cachés (grisés)
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    },
  },

  -- ─── Cmdline en bas (désactive le popup central de noice) ─────────
  {
    "folke/noice.nvim",
    opts = {
      cmdline = {
        view = "cmdline", -- Utilise la cmdline classique en bas au lieu du popup centré
      },
    },
  },
}
