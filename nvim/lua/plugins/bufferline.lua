return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },

  config = function()
    local ok, bufferline = pcall(require, "bufferline")
    if not ok then return end

    bufferline.setup({
      options = {
        numbers = "none",
        diagnostics = "nvim_lsp",
        show_buffer_close_icons = true,
        show_close_icon = false,
        color_icons = true,
        always_show_bufferline = true,
        indicator = { style = "underline" },
        offsets = {
          {
            filetype = "NvimTree",
            text = "📁  Explorer",
            highlight = "Directory",
            separator = true,
          },
        },
      },

   })

    -- 🎹 Keymaps minimalistas y universales
    vim.keymap.set("n", "<S-l>", ":BufferLineCycleNext<CR>", { desc = "Siguiente buffer" })
    vim.keymap.set("n", "<S-h>", ":BufferLineCyclePrev<CR>", { desc = "Buffer anterior" })
    --vim.keymap.set("n", "<C-q>", ":bdelete<CR>", { desc = "Cerrar buffer actual" })
    vim.keymap.set("n", "<A-l>", ":BufferLineMoveNext<CR>", { desc = "Mover buffer →" })
    vim.keymap.set("n", "<A-h>", ":BufferLineMovePrev<CR>", { desc = "Mover buffer ←" })
  end,
}

