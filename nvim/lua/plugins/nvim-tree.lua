return {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("nvim-tree").setup({
            sort_by = "case_sensitive",
            view = {
                width = 30,
                side = "left",
                preserve_window_proportions = true,
            },
            renderer = {
                root_folder_label = false,
                highlight_git = true,
                highlight_opened_files = "all",
                indent_markers = {
                    enable = true,
                    icons = { corner = "└", edge = "│", item = "│", none = " " },
                },
            },

            filters = {
                dotfiles = false,
                custom = { ".git", "node_modules", ".cache" },
            },
            git = {
                enable = true,
                ignore = true,
                timeout = 200,
            },
            diagnostics = {
                enable = true,
                show_on_dirs = true,
                icons = { hint = "", info = "", warning = "", error = "" },
            },
            update_focused_file = {
                enable = true,
                update_root = false,
                ignore_list = {},
            },
            actions = {
                open_file = {
                    quit_on_open = true,
                    resize_window = true,
                    window_picker = { enable = false },
                },
            },
            log = { enable = false },
        })
    end,
}
