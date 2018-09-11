-- Copyright 2014 Mitchell mitchell.att.foicica.com. See Textadept's LICENSE.

-- A special environment for a Lua REPL.
-- It has an `__index` metafield for accessing Textadept's global environment.
local env

-- Creates a Lua REPL in a new buffer.
local function new_repl()
  buffer.new()._type = '[Lua REPL]'
  buffer:set_lexer('lua')
  buffer:add_text('-- Lua REPL')
  buffer:new_line()
  buffer:set_save_point()
  env = setmetatable({
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
end

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

  local f, result = load('return '..code, "repl", 't', env)
  if not f and s == e then return false end -- multi-line chunk; propagate key
  buffer:goto_pos(buffer.line_end_position[last_line])
  buffer:new_line()
  if f then f, result = pcall(f) end
  if result then
    buffer:add_text('--> ')
    buffer:add_text(tostring(result):gsub('(\r?\n)', '%1--> '))
    buffer:new_line()
  end
  buffer:set_save_point()
end

-- Add REPL to Tools menu.
table.insert(textadept.menu.menubar[_L['_Tools']], {''})
table.insert(textadept.menu.menubar[_L['_Tools']], {'Lua REPL', new_repl})
textadept.menu.menubar = nil -- re-hide

-- Evaluate REPL on newline.
keys.lua['\n'] = function()
  if buffer._type ~= '[Lua REPL]' then return false end -- propagate
  evaluate_repl()
end
