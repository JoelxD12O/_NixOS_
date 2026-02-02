return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    -- En las versiones nuevas usamos 'opts' en lugar de llamar a un módulo que ya no existe
    opts = {
        highlight = { enable = true },
        indent = { enable = true },
        autotag = { enable = true },
        ensure_installed = {
            "lua",
            "tsx",
            "typescript",
            "php",
            "nix",
            "vim",
            "vimdoc",
            "markdown",
            "markdown_inline",
            "regex",
            "bash",
        },
        auto_install = false,
    },
}
