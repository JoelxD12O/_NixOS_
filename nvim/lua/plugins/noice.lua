return {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
        -- Aquí puedes añadir tu configuración personalizada
        lsp = {
            -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = true,
            },
        },
        presets = {
            bottom_search = true,         -- usa una línea de búsqueda en la parte inferior
            command_palette = true,       -- agrupa la línea de comandos y el menú emergente
            long_message_to_split = true, -- envía mensajes largos a un split
            inc_rename = false,           -- activa la interfaz para inc-rename.nvim
            lsp_doc_border = false,       -- añade un borde a las ventanas flotantes de documentación
        },
    },
    dependencies = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
    }
}
