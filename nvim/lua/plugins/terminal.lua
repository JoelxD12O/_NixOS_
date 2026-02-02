return {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
        local term_height = math.floor(vim.o.lines * 0.3)
        local term_width = math.floor(vim.o.columns * 0.8)

        require("toggleterm").setup({
            size = 200,
            open_mapping = [[<C-ñ>]],
            hide_numbers = true,
            shade_terminals = true,
            shading_factor = 2,
            start_in_insert = true,
            insert_mappings = true,
            direction = "float",
            float_opts = {
                border = "curved",
                width = term_width,
                height = term_height,
                winblend = 10,
                highlights = {
                    border = "FloatBorder",
                    background = "Normal",
                },
            },
        })

        -- Colores estilo Tokyonight
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1a1b26" })
        vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#7aa2f7", bg = "#1a1b26" })

        vim.keymap.set("n", "<C-|>", ":ToggleTerm<CR>", { desc = "Toggle terminal" })
    end,
}
