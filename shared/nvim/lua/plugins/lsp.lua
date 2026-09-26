return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false,
      },
      inlay_hints = {
        enabled = false,
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- Go
        "gopls",
        -- Python
        "pyright",
        -- JavaScript / TypeScript
        "typescript-language-server",
        -- Lua
        "lua-language-server",
        -- Bash / shell
        "bash-language-server",
        -- HTML / CSS
        "html-lsp",
        "css-lsp",
        -- config / terminal formats
        "yaml-language-server",
        "json-lsp",
        "taplo",
        "marksman",
        "docker-language-server",
      },
    },
  },
}
