-- Copyright 2007-2019 Mitchell mitchell.att.foicica.com. See LICENSE.

--[[ This comment is for LuaDoc.
---
-- Manages and defines key commands in Textadept.
module('textadept.keys')]]

-- c:         ~~   ~            ~ \ ^
-- ca: a cdefg~~jk m o qrstuv  yz~\]^_
-- a:  aA  cC  eE      iIjJkKlL   N O PqQ R StT   V  xXyYzZ_`~~~~~%^&*()-=+[]{}\ ;       / \b~

local keys, GUI = keys, not CURSES

-- File.
-- TODO: buffer.new
keys.cr = require('open_file_interactive')
-- TODO: io.open_recent_file
-- TODO: io.reload_file
keys.cw = io.save_file
-- TODO: io.save_file_as
-- TODO: io.save_all_files
keys.cx = io.close_buffer
-- TODO: io.close_all_buffers
-- TODO: textadept.session.load
-- TODO: textadept.session.save
keys.cq = quit

-- Edit.
local m_edit = textadept.menu.menubar[_L['_Edit']]
keys.cu = buffer.undo
keys[GUI and 'au' or 'mu'] = buffer.redo
keys.ck = function()
  if buffer.selection_empty then buffer:line_end_extend() end
  if not buffer.selection_empty then
    buffer:cut()
    buffer:cancel() -- cancel selection mode
  else
    buffer:clear()
  end
end
keys[GUI and 'ak' or 'mk'] = buffer.copy
keys.cy = textadept.editing.paste_reindent
keys[GUI and 'aD' or 'mD'] = buffer.line_duplicate
-- buffer.clear is 'del'
-- TODO: m_edit[_L['D_elete Word']][2]
-- TODO: buffer.select_all
keys[GUI and 'am' or 'mm'] = m_edit[_L['_Match Brace']][2]
-- m_edit[_L['Complete _Word']][2] is '\t'
keys[GUI and 'caw' or 'cmw'] = textadept.editing.highlight_word
keys[GUI and 'c/' or 'c_'] = textadept.editing.block_comment
keys.ct = textadept.editing.transpose_chars
keys.cj = textadept.editing.join_lines
keys[GUI and 'a|' or 'm|'] = m_edit[_L['_Filter Through']][2]
-- Select.
local m_sel = m_edit[_L['_Select']]
keys[GUI and 'aM' or 'mM'] = m_sel[_L['Select between _Matching Delimiters']][2]
-- TODO: m_sel[_L['Select between _XML Tags']][2]
-- TODO: m_sel[_L['Select in XML _Tag']][2]
keys[GUI and 'aw' or 'mw'] = textadept.editing.select_word
-- TODO: textadept.editing.select_line
-- TODO: textadept.editing.select_paragraph
-- Selection.
m_sel = m_edit[_L['Selectio_n']]
-- TODO: buffer.upper_case
-- TODO: buffer.lower_case
-- TODO: m_sel[_L['Enclose as _XML Tags']][2]
-- TODO: m_sel[_L['Enclose as Single XML _Tag']][2]
-- TODO: m_sel[_L['Enclose in Single _Quotes']][2]
-- TODO: m_sel[_L['Enclose in _Double Quotes']][2]
-- TODO: m_sel[_L['Enclose in _Parentheses']][2]
-- TODO: m_sel[_L['Enclose in _Brackets']][2]
-- TODO: m_sel[_L['Enclose in B_races']][2]
-- TODO: buffer.move_selected_lines_up
-- TODO: buffer.move_selected_lines_down

-- Search.
local m_search = textadept.menu.menubar[_L['_Search']]
keys[GUI and 'as' or 'ms'] = m_search[_L['_Find']][2]
-- TODO: ui.find.find_next
-- TODO: ui.find.find_prev
-- TODO: ui.find.replace
-- TODO: ui.find.replace_all
-- Find Next is an when find pane is focused in GUI.
-- Find Prev is ap when find pane is focused in GUI.
-- Replace is ar when find pane is focused in GUI.
-- Replace All is aa when find pane is focused in GUI.
-- Find in Files is ai when find pane is focused in GUI.
keys.cs = function()
  ui.find.in_files = false
  ui.find.find_incremental()
end
keys[not CURSES and 'aS' or 'mS'] = m_search[_L['Find in Fi_les']][2]
-- TODO: m_search[_L['Goto Nex_t File Found']][2]
-- TODO: m_search[_L['Goto Previou_s File Found']][2]
keys.cg = textadept.editing.goto_line

-- Tools.
local m_tools = textadept.menu.menubar[_L['_Tools']]
keys[GUI and 'a:' or 'm:'] = m_tools[_L['Command _Entry']][2]
keys.cc = m_tools[_L['Select Co_mmand']][2]
-- TODO: textadept.run.run
-- TODO: textadept.run.compile
-- TODO: m_tools[_L['Set _Arguments...']][2]
-- TODO: textadept.run.build
-- TODO: textadept.run.stop
-- TODO: m_tools[_L['_Next Error']][2]
-- TODO: m_tools[_L['_Previous Error']][2]
-- Bookmarks.
local m_bookmark = m_tools[_L['_Bookmark']]
keys["a'"] = textadept.bookmarks.toggle
-- TODO: textadept.bookmarks.clear
-- TODO: m_bookmark[_L['_Next Bookmark']][2]
-- TODO: m_bookmark[_L['_Previous Bookmark']][2]
keys['a"'] = textadept.bookmarks.goto_mark
-- Macros.
keys.f9 = textadept.macros.start_recording
keys[GUI and 'sf9' or 'f10'] = textadept.macros.stop_recording
keys[GUI and 'af9' or 'f12'] = textadept.macros.play
-- Quick Open.
local m_quickopen = m_tools[_L['Quick _Open']]
keys[GUI and 'aU' or 'mU'] = m_quickopen[_L['Quickly Open _User Home']][2]
keys[GUI and 'aH' or 'mH'] = m_quickopen[_L['Quickly Open _Textadept Home']][2]
keys[GUI and 'ar' or 'mr'] = io.quick_open
-- Snippets.
keys['\t'] = function()
  if buffer:auto_c_active() then buffer:line_down() return end -- scroll
  if textadept.snippets._insert() ~= false then return true end
  if buffer.selection_empty then
    if textadept.editing.autocomplete('word') == true then return true end
    local line, pos = buffer:get_cur_line()
    return not line:sub(1, pos):find('^%s*$')
  end
  return false
end
keys['s\t'] = function()
  if buffer:auto_c_active() then buffer:line_up() return end -- scroll
  return textadept.snippets._previous()
end
keys.esc = textadept.snippets._cancel_current
-- TODO: textadept.snippets._select
-- Other.
-- m_tools[_L['_Complete Symbol']][2] is '\t'
keys[GUI and 'a?' or 'm?'] = textadept.editing.show_documentation
-- TODO: m_tools[_L['Show St_yle']][2]

-- Buffers.
local m_buffer = textadept.menu.menubar[_L['_Buffer']]
-- TODO: m_buffer[_L['_Next Buffer']][2]
-- TODO: m_buffer[_L['_Previous Buffer']][2]
keys[GUI and 'cab' or 'cmb'] = function() ui.switch_buffer(true) end
-- Indentation.
local m_indentation = m_buffer[_L['_Indentation']]
-- TODO: m_indentation[_L['Tab width: _2']][2]
-- TODO: m_indentation[_L['Tab width: _3']][2]
-- TODO: m_indentation[_L['Tab width: _4']][2]
-- TODO: m_indentation[_L['Tab width: _8']][2]
-- TODO: m_indentation[_L['_Toggle Use Tabs']][2]
-- TODO: textadept.editing.convert_indentation
-- EOL Mode.
-- TODO: m_buffer[_L['_EOL Mode']][_L['CRLF']][2]
-- TODO: m_buffer[_L['_EOL Mode']][_L['LF']][2]
-- Encoding.
-- TODO: m_buffer[_L['E_ncoding']][_L['_UTF-8 Encoding']][2]
-- TODO: m_buffer[_L['E_ncoding']][_L['_ASCII Encoding']][2]
-- TODO: m_buffer[_L['E_ncoding']][_L['_ISO-8859-1 Encoding']][2]
-- TODO: m_buffer[_L['E_ncoding']][_L['_MacRoman Encoding']][2]
-- TODO: m_buffer[_L['E_ncoding']][_L['UTF-1_6 Encoding']][2]
-- TODO: m_buffer[_L['Toggle View _EOL']][2]
-- TODO: m_buffer[_L['Toggle _Wrap Mode']][2]
-- TODO: m_buffer[_L['Toggle View White_space']][2]
-- TODO: textadept.file_types.select_lexer
keys.f5 = m_buffer[_L['_Refresh Syntax Highlighting']][2]

-- Views.
local m_view = textadept.menu.menubar[_L['_View']]
keys[GUI and 'can' or 'cmn'] = m_view[_L['_Next View']][2]
keys[GUI and 'cap' or 'cmp'] = m_view[_L['_Previous View']][2]
-- TODO: m_view[_L['Split View _Horizontal']][2]
-- TODO: m_view[_L['Split View _Vertical']][2]
keys[GUI and 'cax' or 'cmx'] = m_view[_L['_Unsplit View']][2]
-- TODO: m_view[_L['Unsplit _All Views']][2]
-- TODO: m_view[_L['_Grow View']][2]
-- TODO: m_view[_L['Shrin_k View']][2]
-- TODO: m_view[_L['Toggle Current _Fold']][2]
-- TODO: m_view[_L['Toggle Show In_dent Guides']][2]
-- TODO: m_view[_L['Toggle _Virtual Space']][2]
if GUI then
  keys['c='] = buffer.zoom_in
  keys['c-'] = buffer.zoom_out
  keys['c0'] = m_view[_L['_Reset Zoom']][2]
end

-- Help.
--if GUI then
-- TODO: textadept.menu.menubar[_L['_Help']][_L['Show _Manual']][2]
-- TODO: textadept.menu.menubar[_L['_Help']][_L['Show _LuaDoc']][2]
--end

-- Movement/selection commands.
keys.cf = buffer.char_right
-- TODO: buffer.char_right_extend
keys[GUI and 'af' or 'mf'] = buffer.word_right
-- TODO: buffer.word_right_extend
-- TODO: buffer.word_right_end
-- TODO: buffer.word_right_end_extend
keys[GUI and 'aF' or 'mF'] = buffer.word_part_right
-- TODO: buffer.word_part_right_extend
keys.cb = buffer.char_left
-- TODO: buffer.char_left_extend
keys[GUI and 'ab' or 'mb'] = buffer.word_left
-- TODO: buffer.word_left_extend
-- TODO: buffer.word_left_end
-- TODO: buffer.word_left_end_extend
keys[GUI and 'aB' or 'mB'] = buffer.word_part_left
-- TODO: buffer.word_part_left_extend
keys.cn = buffer.line_down
-- TODO: buffer.line_down_extend
keys.cp = buffer.line_up
-- TODO: buffer.line_up_extend
-- TODO: buffer.home
-- TODO: buffer.home_extend
-- TODO: buffer.vc_home
-- TODO: buffer.vc_home_extend
-- TODO: buffer.home_display
-- TODO: buffer.home_display_extend
-- TODO: buffer.home_wrap
-- TODO: buffer.home_wrap_extend
keys.ca = buffer.vc_home_wrap
-- TODO: buffer.vc_home_wrap_extend
-- TODO: buffer.vc_home_display
-- TODO: buffer.vc_home_display_extend
-- TODO: buffer.line_end
-- TODO: buffer.line_end_extend
-- TODO: buffer.line_end_display
-- TODO: buffer.line_end_display_extend
keys.ce = buffer.line_end_wrap
-- TODO: buffer.line_end_wrap_extend
keys.cv = buffer.page_down
-- TODO: buffer.page_down_extend
keys[GUI and 'an' or 'mn'] = buffer.para_down
-- TODO: buffer.para_down_extend
-- TODO: buffer.stuttered_page_down
-- TODO: buffer.stuttered_page_down_extend
-- TODO: buffer.document_start
-- TODO: buffer.document_start_extend
keys[GUI and 'av' or 'mv'] = buffer.page_up
-- TODO: buffer.page_up_extend
keys[GUI and 'ap' or 'mp'] = buffer.para_up
-- TODO: buffer.para_up_extend
-- TODO: buffer.stuttered_page_up
-- TODO: buffer.stuttered_page_up_extend
-- TODO: buffer.document_end
-- TODO: buffer.document_end_extend
keys.ch = buffer.delete_back
-- TODO: buffer.delete_back_not_line
keys[GUI and 'ah' or 'mh'] = buffer.del_word_left
keys.cd = buffer.clear
keys[GUI and 'ad' or 'md'] = buffer.del_word_right
-- TODO: buffer.del_word_right_end
-- TODO: buffer.del_line_left
-- TODO: buffer.del_line_right
-- TODO: buffer.line_delete
-- TODO: buffer.line_cut
-- TODO: buffer.line_copy
-- TODO: buffer.line_transpose
-- TODO: buffer.line_reverse
keys.ci = buffer.tab
keys.cm = buffer.new_line
-- TODO: buffer.char_right_rect_extend
-- TODO: buffer.char_left_rect_extend
-- TODO: buffer.line_down_rect_extend
-- TODO: buffer.line_up_rect_extend
-- TODO: buffer.home_rect_extend
-- TODO: buffer.vc_home_rect_extend
-- TODO: buffer.line_end_rect_extend
-- TODO: buffer.page_down_rect_extend
-- TODO: buffer.page_up_rect_extend
keys.cl = buffer.vertical_centre_caret
-- TODO: buffer.line_scroll_down
-- TODO: buffer.line_scroll_up
-- TODO: buffer.scroll_to_start
-- TODO: buffer.scroll_to_end
keys['c '] = function() buffer.selection_mode = 0 end
keys['c]'] = buffer.swap_main_anchor_caret

-- Miscellaneous not in standard menu.
keys[GUI and 'aW' or 'mW'] = function()
  buffer:drop_selection_n(buffer.selections - 1)
end
local char = ' '
local function goto_char()
  local pos = buffer.current_pos
  buffer.target_start = pos + 1
  buffer.target_end = buffer.line_end_position[buffer:line_from_position(pos)]
  buffer.search_flags = buffer.FIND_MATCHCASE
  if buffer:search_in_target(char) > 0 then
    if buffer.move_extends_selection then
      buffer.current_pos = buffer.target_start
    else
      buffer:goto_pos(buffer.target_start)
    end
  end
end
keys[GUI and 'ag' or 'mg'] = setmetatable({}, {__index = function(_, k)
  if #k > 1 then return end
  char = k
  return goto_char
end})
keys[GUI and 'aG' or 'mG'] = goto_char
keys.co = function()
  buffer:line_end()
  buffer:new_line()
end
keys[GUI and 'ao' or 'mo'] = function()
  if buffer:line_from_position(buffer.current_pos) > 0 then
    buffer:line_up()
    buffer:line_end()
    buffer:new_line()
  else
    buffer:home()
    buffer:new_line()
    buffer:line_up()
  end
end
keys[GUI and 'a<' or 'm<'] = function() buffer:line_scroll(-20, 0) end
keys[GUI and 'a>' or 'm>'] = function() buffer:line_scroll(20, 0) end
keys.f10 = function() ui.maximized = not ui.maximized end
keys.cal = function()
  if #_VIEWS == 1 then return end
  view.size = ui.size[ui.get_split_table().vertical and 1 or 2] / 2
end

-- Language modules or LSP.
events.connect(events.LEXER_LOADED, function(lang)
  if not keys[lang] then return end
  if not keys[lang]['\t'] then
    keys[lang]['\t'] = function()
      return buffer.selection_empty and
             (textadept.editing.autocomplete(lang) == true or
              textadept.editing.autocomplete('lsp') == true)
    end
  end
  if not keys[lang][GUI and 'a?' or 'm?'] then
    keys[lang][GUI and 'a?' or 'm?'] = function()
      _M.lsp.signature_help()
      if not buffer:call_tip_active() then _M.lsp.hover() end
      return buffer:call_tip_active()
    end
  end
end)

--keys[GUI and 'a.' or 'm,'] = _M.ctags.goto_tag
--keys[GUI and 'a,' or 'm,'] = m_search['_Ctags']['Jump Back']
--keys.f7 = m_tools[_L['Spe_lling']][_L['_Check Spelling...']][2]
--keys.sf7 = m_tools[_L['Spe_lling']][_L['_Mark Misspelled Words']][2]
--keys.f8 = _M.file_diff.start
--keys.adown = m_tools[_L['_Compare Files']][_L['_Next Change']][2]
--keys.aup = m_tools[_L['_Compare Files']][_L['_Previous Change']][2]
--keys.aleft = m_tools[_L['_Compare Files']][_L['Merge _Left']][2]
--keys.aright = m_tools[_L['_Compare Files']][_L['Merge _Right']][2]

-- Modes.
ui.find.find_incremental_keys[GUI and 'an' or 'mn'] = function()
  ui.find.find_entry_text = ui.command_entry:get_text() -- save
  ui.find.find_incremental(ui.command_entry:get_text(), true, true)
end
ui.find.find_incremental_keys[GUI and 'ap' or 'mp'] = function()
  ui.find.find_incremental(ui.command_entry:get_text(), false, true)
end
ui.find.find_incremental_keys[GUI and 'am' or 'mm'] = function()
  ui.find.match_case = not ui.find.match_case
  ui.statusbar_text = 'Match case '..(ui.find.match_case and 'on' or 'off')
  ui.find.find_incremental(ui.command_entry:get_text(), true)
end
ui.find.find_incremental_keys['\n'] = nil -- close on Enter
if OSX or CURSES then
  -- UTF-8 input.
  -- TODO: function()
  --   ui.command_entry.run(function(code)
  --     buffer:add_text(utf8.char(tonumber(code, 16)))
  --   end)
  -- end
end

-- Keys for the command entry.
local ekeys = ui.command_entry.editing_keys.__index
ekeys.cf = function() ui.command_entry:char_right() end
ekeys[GUI and 'af' or 'mf'] = function() ui.command_entry:word_right() end
ekeys.cb = function() ui.command_entry:char_left() end
ekeys[GUI and 'ab' or 'mb'] = function() ui.command_entry:word_left() end
ekeys.cn = function() ui.command_entry:line_down() end
ekeys.cp = function() ui.command_entry:line_up() end
ekeys.ca = function() ui.command_entry:vc_home() end
ekeys.ce = function() ui.command_entry:line_end() end
ekeys.ch = function() ui.command_entry:delete_back() end
ekeys[GUI and 'ah' or 'mh'] = function() ui.command_entry:del_word_left() end
ekeys.cd = function() ui.command_entry:clear() end
ekeys[GUI and 'ad' or 'md'] = function() ui.command_entry:del_word_right() end
ekeys.cy = function() ui.command_entry:paste() end
ekeys.ck = function()
  ui.command_entry:line_end_extend()
  ui.command_entry:cut()
end

return {}
