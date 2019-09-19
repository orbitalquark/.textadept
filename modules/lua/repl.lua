-- Copyright 2014-2019 Mitchell mitchell.att.foicica.com. See LICENSE.

---
-- A special environment for a Lua REPL.
-- It has an `__index` metafield for accessing Textadept's global environment.
-- @class table
-- @name env
local env = setmetatable({
  print = function(...)
    buffer:add_text('--> ')
    local args = table.pack(...)
    for i = 1, args.n do
    buffer:add_text(tostring(args[i]))
    if i < args.n then buffer:add_text('\t') end
    end
    buffer:new_line()
  end
}, {__index = _G})

---
-- Lua command history.
-- It has a numeric `pos` field that indicates where in the history the user
-- currently is.
-- @class table
-- @name history
local history = {pos = 0}

-- Evaluates as Lua code the current line or the text on the currently selected
-- lines.
-- If the current line has a syntax error, it is ignored and treated as a line
-- continuation.
local function evaluate_repl()
  local s, e = buffer.selection_start, buffer.selection_end
  local code, last_line
  if s ~= e then -- use selected lines as code
    local i, j = buffer:line_from_position(s), buffer:line_from_position(e)
    if i < j then
      s = buffer:position_from_line(i)
      if buffer.column[e] > 0 then e = buffer:position_from_line(j + 1) end
    end
    code = buffer:text_range(s, e)
    last_line = buffer:line_from_position(e)
  else -- use line as input
    code = buffer:get_cur_line()
    last_line = buffer:line_from_position(buffer.current_pos)
  end

  local f, result = load('return '..code, 'repl', 't', env)
  if not f then f, result = load(code, 'repl', 't', env) end
  if not f and s == e then return false end -- multi-line chunk; propagate key
  buffer:goto_pos(buffer.line_end_position[last_line])
  buffer:new_line()
  if f then f, result = pcall(f) end
  if result then
    buffer:add_text('--> ')
    if type(result) == 'table' then
      -- Pretty-print tables like ui.command_entry does.
      local items = {}
      for k, v in pairs(result) do
        items[#items + 1] = tostring(k)..' = '..tostring(v)
      end
      table.sort(items)
      result = '{'..table.concat(items, ', ')..'}'
      if buffer.edge_column > 0 and #result > buffer.edge_column then
        local indent = string.rep(' ', buffer.tab_width)
        result = '{\n'..indent..table.concat(items, ',\n'..indent)..'\n}'
      end
    end
    buffer:add_text(tostring(result):gsub('(\r?\n)', '%1--> '))
    buffer:new_line()
  end
  history[#history + 1] = code
  history.pos = #history + 1
  buffer:set_save_point()
end

-- Cycle backward through command history, taking into account commands with
-- multiple lines.
local function cycle_history_prev()
  if history.pos >= 1 then
    for _ in (history[history.pos] or ''):gmatch('\n') do
      buffer:line_delete()
      buffer:delete_back()
    end
    buffer:line_delete()
    history.pos = math.max(history.pos - 1, 1)
    buffer:add_text(history[history.pos])
  end
end

-- Cycle forward through command history, taking into account commands with
-- multiple lines.
local function cycle_history_next()
  if history.pos < #history then
    for _ in (history[history.pos] or ''):gmatch('\n') do
      buffer:line_delete()
      buffer:delete_back()
    end
    buffer:line_delete()
    history.pos = math.min(history.pos + 1, #history)
    buffer:add_text(history[history.pos])
  end
end

-- Add REPL to Tools menu.
table.insert(textadept.menu.menubar[_L['_Tools']], {''})
table.insert(textadept.menu.menubar[_L['_Tools']], {'Lua REPL', function()
  buffer.new()._type = '[Lua REPL]'
  buffer:set_lexer('lua')
  buffer:add_text('-- Lua REPL')
  buffer:new_line()
  buffer:set_save_point()
  if not keys.lua['\n'] then
    -- Evaluate REPL on newline.
    keys.lua['\n'] = function()
      if buffer._type ~= '[Lua REPL]' then return false end -- propagate
      return evaluate_repl()
    end
    keys.lua.cup = function()
      if buffer._type ~= '[Lua REPL]' then return false end -- propagate
      cycle_history_prev()
    end
    keys.lua.cdown = function()
      if buffer._type ~= '[Lua REPL]' then return false end -- propagate
      cycle_history_next()
    end
    keys.lua.cp = function()
      if buffer._type ~= '[Lua REPL]' then return false end -- propagate
      cycle_history_prev()
    end
    keys.lua.cn = function()
      if buffer._type ~= '[Lua REPL]' then return false end -- propagate
      cycle_history_next()
    end
  end
end})
