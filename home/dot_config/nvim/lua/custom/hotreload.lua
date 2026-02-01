-- Hot reload files changed on disk
-- Based on: https://github.com/richardgill/nix/blob/bdd30a0/modules/home-manager/dot-files/nvim/lua/custom/hotreload.lua
local M = {}

local timer = nil

local function should_check()
  local mode = vim.api.nvim_get_mode().mode
  return not (
    mode:match("[cR!s]") -- Skip: command-line, replace, ex, select modes
    or vim.fn.getcmdwintype() ~= "" -- Skip: command-line window is open
  )
end

local function check_time()
  if should_check() then
    vim.cmd("checktime")
  end
end

local defaults = {
  poll_interval = 3000, -- milliseconds, set to 0 to disable polling
}

M.setup = function(opts)
  opts = vim.tbl_deep_extend("force", defaults, opts or {})

  vim.o.autoread = true

  -- Event-based checking
  vim.api.nvim_create_autocmd({ "FocusGained", "TermLeave", "BufEnter", "WinEnter", "CursorHold", "CursorHoldI" }, {
    group = vim.api.nvim_create_augroup("hotreload", { clear = true }),
    callback = check_time,
  })

  vim.api.nvim_create_autocmd("FileChangedShellPost", {
    group = vim.api.nvim_create_augroup("hotreload_notify", { clear = true }),
    callback = function()
      vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
    end,
  })

  -- Timer-based polling
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end

  if opts.poll_interval > 0 then
    timer = vim.uv.new_timer()
    timer:start(
      opts.poll_interval,
      opts.poll_interval,
      vim.schedule_wrap(check_time)
    )
  end
end

return M
