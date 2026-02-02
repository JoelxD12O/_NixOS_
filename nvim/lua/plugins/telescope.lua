return {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local telescope = require("telescope")
        local builtin = require("telescope.builtin")

        -- ESENCIAL: Agregar el setup aunque esté vacío
        telescope.setup({
            defaults = {
                file_ignore_patterns = { "node_modules", ".git/" },
                hidden = true,
                --                preview = {
                --                  treesitter = false, -- Esto evita que llame a 'ft_to_lang'
                --            }
            }
        })


        vim.keymap.set("n", "<C-f>", builtin.find_files, { desc = "Telescope find files" })
        vim.keymap.set("n", "<C-g>", builtin.live_grep, { desc = "Telescope live grep" })
        vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
        vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
    end,
}
