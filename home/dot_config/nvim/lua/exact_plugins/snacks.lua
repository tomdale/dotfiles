return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true, -- show dotfiles by default (toggle with `H`)
            ignored = true, -- show gitignored files by default (toggle with `I`)
          },
        },
      },
      terminal = {
        bo = {
          filetype = "snacks_terminal",
        },
        wo = {},
        stack = true, -- when enabled, multiple split windows with the same position will be stacked together (useful for terminals)
        keys = {
          q = "hide",
          gf = function(self)
            local f = vim.fn.findfile(vim.fn.expand("<cfile>"), "**")
            if f == "" then
              Snacks.notify.warn("No file under cursor")
            else
              self:hide()
              vim.schedule(function()
                vim.cmd("e " .. f)
              end)
            end
          end,
          term_normal = {
            "<esc>",
            function(self)
              self.esc_timer = self.esc_timer or (vim.uv or vim.loop).new_timer()
              if self.esc_timer:is_active() then
                -- Key repeat detected (user is holding) - exit terminal mode
                self.esc_timer:stop()
                vim.cmd("stopinsert")
                return ""  -- Don't send escape to terminal
              else
                -- First escape press - wait to see if it's a tap or hold
                self.esc_timer:start(500, 0, vim.schedule_wrap(function()
                  -- Timer fired without key repeat - user tapped quickly
                  -- Send escape to the terminal
                  local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
                  vim.api.nvim_feedkeys(esc, "t", false)
                end))
                return ""  -- Suppress escape for now
              end
            end,
            mode = "t",
            expr = true,
            desc = "Hold escape to enter normal mode",
          },
        },
      },
    },
  },
}
