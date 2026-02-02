return {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        dashboard.section.header.val = {

            "███╗   ██╗██╗   ██╗██╗███╗   ███╗",
            "████╗  ██║██║   ██║██║████╗ ████║",
            "██╔██╗ ██║██║   ██║██║██╔████╔██║",
            "██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
            "██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
            "╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
        }

        dashboard.section.buttons.val = {
            dashboard.button("e", "  Nuevo archivo", ":ene <BAR> startinsert <CR>"),
            dashboard.button("c", "  Abrir ~/.config/", ":e ~/.config/<CR>"),
            dashboard.button("n", "N  Abrir ~/.config/nvim/", ":e ~/.config/nvim/<CR>"),
            dashboard.button("h", "  Abrir ~/.config/hypr/", ":e ~/.config/hypr/<CR>"),
            dashboard.button("w", "  Abrir ~/.config/waybar/", ":e ~/.config/waybar/<CR>"),
            dashboard.button("z", "MAMAWBO  Abrir configuration.nix", ":e ~/.config/nix/<CR>"),
            dashboard.button("q", "  Salir", ":qa<CR>"),
        }

        dashboard.section.footer.val = "Configurado por gpt"
        dashboard.opts.opts.noautocmd = true
        alpha.setup(dashboard.opts)
    end,
}
