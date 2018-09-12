-- Copyright 2007-2018 Mitchell mitchell.att.foicica.com. See LICENSE.

--[[ This comment is for LuaDoc.
---
-- Utilize Ctags with Textadept.
--
-- There are four ways to tell Textadept about *tags* files:
--
--   1. Place a *tags* file in current file's directory. This file will be used
--      in a tag search from any file in that directory.
--   2. Place a *tags* file in a project's root directory. This file will be
--      used in a tag search from any of that project's source files.
--   3. Add a *tags* file or list of *tags* files to the `_M.ctags` table for a
--      project root key. This file(s) will be used in a tag search from any of
--      that project's source files.
--      For example: `_M.ctags['/path/to/project'] = '/path/to/tags'`.
--   4. Add a *tags* file to the `_M.ctags` table. This file will be used in any
--      tag search.
--      For example: `_M.ctags[#_M.ctags + 1] = '/path/to/tags'`.
--   5. As a last resort, if no *tags* files were found, or if there is no match
--      for a given symbol, a temporary *tags* file is generated for the current
--      file and used.
--
-- Textadept will use any and all *tags* files based on the above rules.
-- @field _G.textadept.editing.autocompleters.ctag (function)
--   Autocompleter function for ctags. (Names only; not context-sensitive).
-- @field ctags (string)
--    Path to the ctags executable.
--    The default value is `ctags`.
module('_M.ctags')]]

local M = {}

M.ctags = 'ctags'

-- Searches all available tags files tag *tag* and returns a table of tags
-- found.
-- All Ctags in tags files must be sorted.
-- @param tag Tag to find.
-- @return table of tags found with each entry being a table that contains the
--   4 ctags fields
local function find_tags(tag)
  -- TODO: binary search?
  local tags = {}
  local patt = '^('..tag..'%S*)\t([^\t]+)\t(.-);"\t?(.*)$'
  -- Determine the tag files to search in.
  local tag_files = {}
  local tag_file = ((buffer.filename or ''):match('^.+[/\\]') or
                    lfs.currentdir()..'/')..'tags' -- current directory's tags
  if lfs.attributes(tag_file) then tag_files[#tag_files + 1] = tag_file end
  if buffer.filename then
    local root = io.get_project_root(buffer.filename)
    if root then
      tag_file = root..'/tags' -- project's tags
      if lfs.attributes(tag_file) then tag_files[#tag_files + 1] = tag_file end
      tag_file = M[root] -- project's specified tags
      if type(tag_file) == 'string' then
        tag_files[#tag_files + 1] = tag_file
      elseif type(tag_file) == 'table' then
        for i = 1, #tag_file do tag_files[#tag_files + 1] = tag_file[i] end
      end
    end
  end
  for i = 1, #M do tag_files[#tag_files + 1] = M[i] end -- global tags
  -- Search all tags files for matches.
  local tmpfile
  ::retry::
  for i = 1, #tag_files do
    local dir, found = tag_files[i]:match('^.+[/\\]'), false
    local f = io.open(tag_files[i])
    if not f then goto continue end
    for line in f:lines() do
      local tag, file, ex_cmd, ext_fields = line:match(patt)
      if tag then
        if not file:find('^%a?:?[/\\]') then file = dir..file end
        if ex_cmd:find('^/') then ex_cmd = ex_cmd:match('^/^?(.-)$?/$') end
        tags[#tags + 1] = {tag, file, ex_cmd, ext_fields}
        found = true
      elseif found then
        break -- tags are sorted, so no more matches exist in this file
      end
    end
    f:close()
    ::continue::
  end
  if #tags == 0 and buffer.filename and not tmpfile then
    -- If no matches were found, try the current file.
    tmpfile = os.tmpname()
    if WIN32 then tmpfile = os.getenv("TEMP")..tmpfile end
    local cmd = string.format('%s -o "%s" "%s"', M.ctags, tmpfile,
                              buffer.filename)
    spawn(cmd):wait()
    tag_files = {tmpfile}
    goto retry
  end
  if tmpfile then os.remove(tmpfile) end
  return tags
end

-- List of jump positions comprising a jump history.
-- Has a `pos` field that points to the current jump position.
-- @class table
-- @name jump_list
local jump_list = {pos = 0}
---
-- Jumps to the source of string *tag* or the source of the word under the
-- caret.
-- Prompts the user when multiple sources are found. If *tag* is `nil`, jumps to
-- the previous or next position in the jump history, depending on boolean
-- *prev*.
-- @param tag The tag to jump to the source of.
-- @param prev Optional flag indicating whether to go to the previous position
--   in the jump history or the next one. Only applicable when *tag* is `nil` or
--   `false`.
-- @see tags
-- @name goto_tag
function M.goto_tag(tag, prev)
  if not tag and prev == nil then
    local s = buffer:word_start_position(buffer.current_pos, true)
    local e = buffer:word_end_position(buffer.current_pos, true)
    tag = buffer:text_range(s, e)
  elseif not tag then
    -- Navigate within the jump history.
    if prev and jump_list.pos <= 1 then return end
    if not prev and jump_list.pos == #jump_list then return end
    jump_list.pos = jump_list.pos + (prev and -1 or 1)
    io.open_file(jump_list[jump_list.pos][1])
    buffer:goto_pos(jump_list[jump_list.pos][2])
    return
  end
  -- Search for potential tags to jump to.
  local tags = find_tags(tag)
  if #tags == 0 then return end
  -- Prompt the user to select a tag from multiple candidates or automatically
  -- pick the only one.
  if #tags > 1 then
    local items = {}
    for i = 1, #tags do
      items[#items + 1] = tags[i][1]
      items[#items + 1] = tags[i][2]:match('[^/\\]+$') -- filename only
      items[#items + 1] = tags[i][3]:match('^%s*(.+)$') -- strip indentation
      items[#items + 1] = tags[i][4]:match('^%a?%s*(.*)$') -- ignore kind
    end
    local button, i = ui.dialogs.filteredlist{
      title = _L['Go To'],
      columns = {_L['Name'], _L['File'], _L['Line:'], 'Extra Information'},
      items = items, search_column = 2, width = CURSES and ui.size[1] - 2 or nil
    }
    if button < 1 then return end
    tag = tags[i]
  else
    tag = tags[1]
  end
  -- Store the current position in the jump history if applicable, clearing any
  -- jump history positions beyond the current one.
  if jump_list.pos < #jump_list then
    for i = jump_list.pos + 1, #jump_list do jump_list[i] = nil end
  end
  if jump_list.pos == 0 or jump_list[#jump_list][1] ~= buffer.filename or
     jump_list[#jump_list][2] ~= buffer.current_pos then
    jump_list[#jump_list + 1] = {buffer.filename, buffer.current_pos}
  end
  -- Jump to the tag.
  io.open_file(tag[2])
  if not tonumber(tag[3]) then
    for i = 0, buffer.line_count - 1 do
      if buffer:get_line(i):find(tag[3], 1, true) then
        textadept.editing.goto_line(i)
        break
      end
    end
  else
    textadept.editing.goto_line(tonumber(tag[3]) - 1)
  end
  -- Store the new position in the jump history.
  jump_list[#jump_list + 1] = {buffer.filename, buffer.current_pos}
  jump_list.pos = #jump_list
end

-- Autocompleter function for ctags.
-- Does not remove duplicates.
textadept.editing.autocompleters.ctag = function()
  local completions = {}
  local s = buffer:word_start_position(buffer.current_pos, true)
  local e = buffer:word_end_position(buffer.current_pos, true)
  local tags = find_tags(buffer:text_range(s, e))
  for i = 1, #tags do completions[#completions + 1] = tags[i][1] end
  return e - s, completions
end

-- Add menu entries.
local m_search = textadept.menu.menubar[_L['_Search']]
m_search[#m_search + 1] = {''} -- separator
m_search[#m_search + 1] = {
  title = '_Ctags',
  {'_Goto Ctag', M.goto_tag},
  {'G_oto Ctag...', function()
    local button, name = ui.dialogs.standard_inputbox{title = 'Goto Tag'}
    if button == 1 then _M.ctags.goto_tag(name) end
  end},
  {''},
  {'Jump _Back', function() M.goto_tag(nil, true) end},
  {'Jump _Forward', function() M.goto_tag(nil, false) end},
  {''},
  {'_Autocomplete Tag', function() textadept.editing.autocomplete('ctag') end}
}

return M
