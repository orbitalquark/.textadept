-- Copyright 2021 Mitchell. See LICENSE.

--[[ This comment is for LuaDoc.
---
-- Reformat paragraph/text using the Unix `fmt` tool.
--
-- Install this module by copying it into your *~/.textadept/modules/* directory or Textadept's
-- *modules/* directory, and then putting the following in your *~/.textadept/init.lua*:
--
--     require('fmt')
--
-- There will be an "Edit > Reformat Paragraph" menu item. You can also assign a keybinding:
--
--     keys['ctrl+alt+j'] = require('fmt').reformat
--
-- @field line_length The maximum number of characters to allow on a line. The default value is 100.
module('fmt')]]
local M = {}

---
-- Header lines to ignore when reformatting text.
-- These can be LuaDoc or Doxygen headers for example.
-- @class table
-- @name ignore_header_lines
M.ignore_header_lines = {'---', '/**'}

---
-- Footer lines to ignore when reformatting text.
-- These can be Doxygen footers for example.
-- @class table
-- @name ignore_header_lines
M.ignore_footer_lines = {'*/'}

M.line_length = 100

---
-- Reformats using the Unix `fmt` tool either the selected text or the current paragraph,
-- according to the rules of `textadept.editing.filter_through()`.
-- For styled text, paragraphs are either blocks of same-styled lines (e.g. code comments),
-- or lines surrounded by blank lines.
-- If the first line matches any of the lines in `ignore_header_lines`, it is not reformatted.
-- If the last line matches any of the lines in `ignore_footer_lines`, it is not reformatted.
-- @see ignore_header_lines
-- @see ignore_footer_lines
-- @see line_length
-- @name reformat
function M.reformat()
  if buffer.selection_empty then
    local s = buffer:line_from_position(buffer.current_pos)
    local style = buffer.style_at[buffer.line_indent_position[s]]
    local e = s + 1
    for i = s - 1, 1, -1 do
      if buffer.style_at[buffer.line_indent_position[i]] ~= style then break end
      s = s - 1
    end
    local line = buffer:get_line(s)
    for _, header in ipairs(M.ignore_header_lines) do
      if line:find('^%s*' .. header:gsub('%p', '%%%0')) then
        s = s + 1
        break
      end
    end
    for i = e, buffer.line_count do
      if buffer.style_at[buffer.line_indent_position[i]] ~= style then break end
      e = e + 1
    end
    line = buffer:get_line(e - 1)
    for _, footer in ipairs(M.ignore_footer_lines) do
      if line:find('^%s*' .. footer:gsub('%p', '%%%0')) then
        e = e - 1
        break
      end
    end
    buffer:set_sel(buffer:position_from_line(s), buffer:position_from_line(e))
  end
  local prefix = buffer:get_line(buffer:line_from_position(buffer.selection_start)):match(
    '^%s*(%p*)')
  local cmd = 'fmt -w ' .. M.line_length .. ' -c'
  if prefix ~= '' then cmd = string.format('%s -p "%s"', cmd, prefix) end
  textadept.editing.filter_through(cmd)
end

-- Add menu entry.
local m_edit = textadept.menu.menubar[_L['Edit']]
table.insert(m_edit, #m_edit - 1, {'Reformat', M.reformat})

return M
