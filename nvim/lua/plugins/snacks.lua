return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      hidden = true, -- Ne pas afficher le picker dans la liste des fenêtres
      ignored = true,
      sources = {
        files = {
          hidden = true, -- Ne pas afficher les fichiers cachés dans le picker
          ignored = true, -- Ne pas afficher les fichiers ignorés (ex: .gitignore) dans le picker
        },
      },
    },
  },
}
