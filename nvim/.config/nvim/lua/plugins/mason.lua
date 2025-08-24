return {
  {
    "mason-org/mason-lspconfig.nvim",
    version = "^1.0.0",
  },
  {
    "mason-org/mason.nvim",
    -- Mason 2.0 conatins braking changes, currently sticking with 1.*
    version = "^1.0.0",
    opts = {
      ensure_installed = {
        "csharpier",
        "netcoredbg",
        "roslyn",
      },
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
    },
  },
}
