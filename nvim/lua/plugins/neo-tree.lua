return {
  "nvim-neo-tree/neo-tree.nvim",
  lazy = true,
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,        -- Affiche les fichiers cachés (grisés)
        hide_dotfiles = false,
        hide_gitignored = false,
      },
    },
  },
}
