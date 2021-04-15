-- Copyright 2021 Mitchell. See LICENSE.

--[[ This comment is for LuaDoc.
---
-- Format/reformat paragraph and code.
--
-- Install this module by copying it into your *~/.textadept/modules/* directory or Textadept's
-- *modules/* directory, and then putting the following in your *~/.textadept/init.lua*:
--
--     require('fmt')
--
-- There will be an "Edit > Reformat" menu. You can also assign a keybinding:
--
--     keys['ctrl+alt+j'] = require('fmt').paragraph
--
-- @field fmt_line_length (number)
--   The maximum number of characters to allow on a line when reformatting paragraphs. The
--   default value is 100.
-- @field on_save (bool)
--   Whether or not to invoke a code formatter on save. The default value is `true`.
module('fmt')]]
local M = {}

-- Localizations.
local _L = _L
if not rawget(_L, 'Reformat') then
  -- Menu.
  _L['Reformat'] = 'Reformat'
  _L['Code'] = '_Code'
  _L['Paragraph'] = '_Paragraph'
end

-- Helper function that returns whether or not the given config file exists in the current or
-- a parent directory of the current buffer's filename.
local function has_config_file(filename)
  if not buffer.filename then return false end
  local dir = buffer.filename:match('^(.+)[/\\]')
  while dir do
    if lfs.attributes(dir .. '/' .. filename) then return true end
    dir = dir:match('^(.+)[/\\]')
  end
  return false
end

---
-- Map of lexer languages to string code formatter commands or functions that return such commands.
-- @class table
-- @name commands
M.commands = {
  lua = function() return has_config_file('.lua-format') and 'lua-format' or nil end,
  cpp = function() return has_config_file('.clang-format') and 'clang-format -style=file' or nil end
}
M.commands.ansi_c = M.commands.cpp

---
-- Header lines to ignore when reformatting paragraphs.
-- These can be LuaDoc or Doxygen headers for example.
-- @class table
-- @name fmt_ignore_header_lines
M.fmt_ignore_header_lines = {'---', '/**'}

---
-- Footer lines to ignore when reformatting paragraphs.
-- These can be Doxygen footers for example.
-- @class table
-- @name fmt_ignore_footer_lines
M.fmt_ignore_footer_lines = {'*/'}

M.on_save = true
M.fmt_line_length = 100

---
-- Reformats using a code formatter for the current buffer's lexer language either the selected
-- text or the current paragraph, according to the rules of `textadept.editing.filter_through()`.
-- @see commands
-- @name code
function M.code()
  local command = M.commands[buffer:get_lexer()]
  if type(command) == 'function' then command = command() end
  if not command then return end
  local current_dir = lfs.currentdir()
  local dir = (buffer.filename or ''):match('^(.+)[/\\]') or io.get_project_root()
  if dir and dir ~= current_dir then lfs.chdir(dir) end
  textadept.editing.filter_through(command)
  if dir and dir ~= current_dir then lfs.chdir(current_dir) end -- restore
end
events.connect(events.FILE_BEFORE_SAVE, function(filename) if M.on_save then M.code() end end)

---
-- Reformats using the Unix `fmt` tool either the selected text or the current paragraph,
-- according to the rules of `textadept.editing.filter_through()`.
-- For styled text, paragraphs are either blocks of same-styled lines (e.g. code comments),
-- or lines surrounded by blank lines.
-- If the first line matches any of the lines in `fmt_ignore_header_lines`, it is not reformatted.
-- If the last line matches any of the lines in `fmt_ignore_footer_lines`, it is not reformatted.
-- @see fmt_ignore_header_lines
-- @see fmt_ignore_footer_lines
-- @see fmt_line_length
-- @name reformat
function M.paragraph()
  if buffer.selection_empty then
    local s = buffer:line_from_position(buffer.current_pos)
    local style = buffer.style_at[buffer.line_indent_position[s]]
    local e = s + 1
    for i = s - 1, 1, -1 do
      if buffer.style_at[buffer.line_indent_position[i]] ~= style then break end
      s = s - 1
    end
    local line = buffer:get_line(s)
    for _, header in ipairs(M.fmt_ignore_header_lines) do
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
    for _, footer in ipairs(M.fmt_ignore_footer_lines) do
      if line:find('^%s*' .. footer:gsub('%p', '%%%0')) then
        e = e - 1
        break
      end
    end
    buffer:set_sel(buffer:position_from_line(s), buffer:position_from_line(e))
  end
  local prefix = buffer:get_line(buffer:line_from_position(buffer.selection_start)):match(
    '^%s*(%p*)')
  local cmd = 'fmt -w ' .. M.fmt_line_length .. ' -c'
  if prefix ~= '' then cmd = string.format('%s -p "%s"', cmd, prefix) end
  textadept.editing.filter_through(cmd)
end

-- LuaFormatter off
-- Add menu entry.
local m_edit = textadept.menu.menubar[_L['Edit']]
table.insert(m_edit, #m_edit - 1, {
  title = _L['Reformat'],
  {_L['Code'], M.code},
  {_L['Paragraph'], M.paragraph}
})
-- LuaFormatter on

return M
