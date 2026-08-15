return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      for _, parser in pairs(require("nvim-treesitter.parsers")) do
        local info = parser.install_info
        if info and info.url and info.url:match("^https://github%.com/") then
          info.url = "https://ghfast.top/" .. info.url
        end
      end
      return opts
    end,
  },
}
