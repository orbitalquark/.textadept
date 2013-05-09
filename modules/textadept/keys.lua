-- Copyright 2007-2013 Mitchell mitchell.att.foicica.com. See LICENSE.

--[[ This comment is for LuaDoc.
---
-- Manages and defines key commands in Textadept.
module('_M.textadept.keys')]]

-- c:         ~~   ~
-- ca:        ~~          t    y
-- a:  aA  cC D           JkKlLm   oO          uU     X   Z_           +  - =

-- Utility functions.
local function any_char_mt(f)
  return setmetatable({['\0'] = {}}, {__index = function(t, k)
                        if #k == 1 then return {f, k, k} end
                      end})
end
local function toggle_setting(setting, i)
  local state = buffer[setting]
  if type(state) == 'boolean' then
    buffer[setting] = not state
  elseif type(state) == 'number' then
    buffer[setting] = buffer[setting] == 0 and (i or 1) or 0
  end
  events.emit(events.UPDATE_UI) -- for updating statusbar
end

local _M, keys, buffer, view = _M, keys, buffer, view
local m_editing = _M.textadept.editing

keys.LANGUAGE_MODULE_PREFIX = 'cl'

-- File.
keys[not CURSES and 'cac' or 'cmc'] = buffer.new
keys.cr = io.open_file
keys[not CURSES and 'car' or 'cmr'] = io.open_recent_file
-- TODO: buffer.reload
keys.co = buffer.save
keys[not CURSES and 'cao' or 'cmo'] = buffer.save_as
keys.cx = buffer.close
keys[not CURSES and 'ax' or 'mx'] = io.close_all
-- TODO: _M.textadept.session.load
-- TODO: _M.textadept.session.save
keys.cq = quit

-- Edit.
keys.cz = buffer.undo
keys.cZ = buffer.redo -- GTK only
keys[not CURSES and 'caz' or 'cmz'] = keys.cZ
keys.ck = function()
  local buffer = _G.buffer
  if #buffer:get_sel_text() == 0 then buffer:line_end_extend() end
  buffer:cut()
end
keys.cK = buffer.copy -- GTK only
keys[not CURSES and 'cak' or 'cmk'] = keys.cK
keys.cu = buffer.paste
keys[not CURSES and 'cad' or 'cmd'] = buffer.line_duplicate
keys.del = buffer.clear
keys.cw = function() -- delete word
  m_editing.select_word()
  _G.buffer:delete_back()
end
keys[not CURSES and 'caa' or 'cma'] = buffer.select_all
keys['c]'] = m_editing.match_brace
keys[not CURSES and 'c ' or 'c@'] = m_editing.autocomplete_word
keys[not CURSES and 'aw' or 'mw'] = m_editing.highlight_word
keys[not CURSES and 'c/' or 'c_'] = m_editing.block_comment
keys.ct = m_editing.transpose_chars
keys.cj = m_editing.join_lines
keys[not CURSES and 'a|' or 'm|'] = {gui.command_entry.enter_mode,
                                     'filter_through'}
-- Select.
keys[not CURSES and 'ca]' or 'cm]'] = {m_editing.match_brace, 'select'}
keys[not CURSES and 'a>' or 'm>'] = {m_editing.select_enclosed, '>', '<'}
-- TODO: {m_editing.select_enclosed, '<', '>'}
keys[not CURSES and 'a"' or 'm"'] = {m_editing.select_enclosed, '"', '"'}
keys[not CURSES and "a'" or "m'"] = {m_editing.select_enclosed, "'", "'"}
keys[not CURSES and 'a)' or 'm)'] = {m_editing.select_enclosed, '(', ')'}
keys[not CURSES and 'a]' or 'm]'] = {m_editing.select_enclosed, '[', ']'}
keys[not CURSES and 'a}' or 'm}'] = {m_editing.select_enclosed, '{', '}'}
-- TODO: any_char_mt(m_editing.select_enclosed)
keys[not CURSES and 'caw' or 'cmw'] = m_editing.select_word
keys[not CURSES and 'cae' or 'cme'] = m_editing.select_line
keys[not CURSES and 'caq' or 'cmq'] = m_editing.select_paragraph
keys.cai = m_editing.select_indented_block -- GTK only
-- Selection.
-- TODO: buffer.upper_case
-- TODO: buffer.lower_case
keys[not CURSES and 'a<' or 'm<'] = function() -- enclose as XML tags
  m_editing.enclose('<', '>')
  local buffer = _G.buffer
  local pos = buffer.current_pos
  while buffer.char_at[pos - 1] ~= 60 do pos = pos - 1 end -- '<'
  buffer:insert_text(-1, '</'..buffer:text_range(pos, buffer.current_pos))
end
keys[not CURSES and 'a/' or 'm/'] = {m_editing.enclose, '<', ' />'}
keys[not CURSES and 'aQ' or 'mQ'] = {m_editing.enclose, '"', '"'}
keys[not CURSES and 'aq' or 'mq'] = {m_editing.enclose, "'", "'"}
keys[not CURSES and 'a(' or 'm('] = {m_editing.enclose, '(', ')'}
keys[not CURSES and 'a[' or 'm['] = {m_editing.enclose, '[', ']'}
keys[not CURSES and 'a{' or 'm{'] = {m_editing.enclose, '{', '}'}
keys[not CURSES and 'a*' or 'm*'] = any_char_mt(m_editing.enclose)
-- TODO: buffer.move_selected_lines_up
-- TODO: buffer.move_selected_lines_down

-- Search.
keys.cs = gui.find.focus
keys[not CURSES and 'as' or 'ms'] = gui.find.find_next
keys[not CURSES and 'aS' or 'mS'] = gui.find.find_prev
keys[not CURSES and 'ar' or 'mr'] = gui.find.replace
keys[not CURSES and 'aR' or 'mR'] = gui.find.replace_all
-- Find Next is an when find pane is focused (GTK only).
-- Find Prev is ap when find pane is focused (GTK only).
-- Replace is ar when find pane is focused (GTK only).
-- Replace All is aa when find pane is focused (GTK only).
keys[not CURSES and 'ai' or 'mi'] = gui.find.find_incremental
-- Find in Files is ai when find pane is focused.
-- TODO: {gui.find.goto_file_found, false, true}
-- TODO: {gui.find.goto_file_found, false, false}
keys.cg = m_editing.goto_line

-- Tools.
keys.cc = {gui.command_entry.enter_mode, 'lua_command'}
-- TODO: function() _M.textadept.menu.select_command() end
keys[not CURSES and 'ag' or 'mg'] = _M.textadept.run.run
keys[not CURSES and 'aG' or 'mG'] = _M.textadept.run.compile
-- TODO: {m_textadept.run.goto_error, false, true}
-- TODO: {m_textadept.run.goto_error, false, false}
-- Adeptsense.
-- Complete symbol is 'c '.
keys[not CURSES and 'a?' or 'm?'] = _M.textadept.adeptsense.show_apidoc
-- Snippets.
keys['\t'] = _M.textadept.snippets._insert
keys['s\t'] = _M.textadept.snippets._previous
-- TODO: _M.textadept.snippets._cancel_current
-- TODO: _M.textadept.snippets._select
-- Bookmarks.
keys[not CURSES and 'aM' or 'mM'] = _M.textadept.bookmarks.toggle
-- TODO: _M.textadept.bookmarks.clear
keys[not CURSES and 'aN' or 'mN'] = _M.textadept.bookmarks.goto_next
keys[not CURSES and 'aP' or 'mP'] = _M.textadept.bookmarks.goto_prev
keys.cam = _M.textadept.bookmarks.goto_bookmark -- GTK only
-- Snapopen.
keys[not CURSES and 'cau' or 'cmu'] = {io.snapopen, _USERHOME}
-- Miscellaneous.
-- TODO: function() -- show style
--   local buffer = _G.buffer
--   local style = buffer.style_at[buffer.current_pos]
--   local text = string.format("%s %s\n%s %s (%d)", _L['Lexer'],
--                              buffer:get_lexer(true), _L['Style'],
--                              buffer:get_style_name(style), style)
--   buffer:call_tip_show(buffer.current_pos, text)
-- end

-- Buffers.
keys[not CURSES and 'an' or 'mn'] = {view.goto_buffer, view, 1, true}
keys[not CURSES and 'ap' or 'mp'] = {view.goto_buffer, view, -1, true}
keys[not CURSES and 'cab' or 'cmb'] = gui.switch_buffer
-- Indentation.
keys[not CURSES and 'at' or 'mt'] = {toggle_setting, 'use_tabs'}
keys[not CURSES and 'aT' or 'mT'] = m_editing.convert_indentation
-- EOL Mode.
-- Encoding.
keys[not CURSES and 'cal' or 'cml'] = _M.textadept.mime_types.select_lexer
keys.f5 = {buffer.colourise, buffer, 0, -1}

-- Views.
keys.can = {gui.goto_view, 1, true}
keys.cap = {gui.goto_view, -1, true}
keys.cas = {view.split, view} -- horizontal
keys.cav = {view.split, view, true} -- vertical
keys.cax = function() _G.view:unsplit() return true end
keys.caX = function() while _G.view:unsplit() do end end -- GTK only
-- TODO: function() _G.view.size = _G.view.size + 10 end
-- TODO: function() _G.view.size = _G.view.size - 10 end
keys[not CURSES and 'caf' or 'cmf'] = function() -- toggle fold
  local buffer = _G.buffer
  buffer:toggle_fold(buffer:line_from_position(buffer.current_pos))
end
keys[not CURSES and 'aE' or 'mE'] = {toggle_setting, 'view_eol'}
keys[not CURSES and 'aW' or 'mW'] = {toggle_setting, 'wrap_mode'}
keys[not CURSES and 'aI' or 'mI'] = {toggle_setting, 'indentation_guides'}
keys[not CURSES and 'aH' or 'mH'] = {toggle_setting, 'view_ws'}
-- TODO: {toggle_setting, 'virtual_space_options', 2}
keys['c='] = buffer.zoom_in -- GTK only
keys['c-'] = buffer.zoom_out -- GTK only
keys['c0'] = function() _G.buffer.zoom = 0 end -- GTK only
-- TODO: gui.select_theme

-- Movement/selection commands.
keys.cf = buffer.char_right
keys.cF = buffer.char_right_extend -- GTK only
keys[not CURSES and 'af' or 'mf'] = buffer.word_right
keys[not CURSES and 'aF' or 'mF'] = buffer.word_right_extend
-- TODO: buffer.word_part_right
-- TODO: buffer.word_part_right_extend
keys.cb = buffer.char_left
keys.cB = buffer.char_left_extend -- GTK only
keys[not CURSES and 'ab' or 'mb'] = buffer.word_left
keys[not CURSES and 'aB' or 'mB'] = buffer.word_left_extend
-- TODO: buffer.word_part_left
-- TODO: buffer.word_part_left_extend
keys.cn = buffer.line_down
keys.cN = buffer.line_down_extend -- GTK only
keys.cp = buffer.line_up
keys.cP = buffer.line_up_extend -- GTK only
keys.ca = buffer.vc_home
keys.cA = buffer.home_extend -- GTK only
keys.ce = buffer.line_end
keys.cE = buffer.line_end_extend -- GTK only
keys.cv = buffer.page_down
keys.cV = buffer.page_down_extend -- GTK only
keys[not CURSES and 'av' or 'mv'] = buffer.para_down
keys[not CURSES and 'aV' or 'mV'] = buffer.para_down_extend
keys['c^'] = buffer.document_start
-- TODO: buffer.document_start_extend
keys.cy = buffer.page_up
keys.cY = buffer.page_up_extend -- GTK only
keys[not CURSES and 'ay' or 'my'] = buffer.para_up
keys[not CURSES and 'aY' or 'mY'] = buffer.para_up_extend
keys[not CURSES and 'c$' or 'c\\'] = buffer.document_end
-- TODO: buffer.document_end_extend
keys.ch = buffer.delete_back
keys[not CURSES and 'ah' or 'mh'] = buffer.del_word_left
keys.cd = buffer.clear
keys[not CURSES and 'ad' or 'md'] = buffer.del_word_right
keys.ci = buffer.tab
keys.cm = buffer.new_line
-- TODO: buffer.char_right_rect_extend
-- TODO: buffer.char_left_rect_extend
-- TODO: buffer.line_down_rect_extend
-- TODO: buffer.line_up_rect_extend
-- TODO: buffer.vc_home_rect_extend
-- TODO: buffer.line_end_rect_extend
-- TODO: buffer.page_down_rect_extend
-- TODO: buffer.page_up_rect_extend
-- TODO: buffer.vertical_centre_caret
-- TODO: buffer.line_scroll_down
-- TODO: buffer.line_scroll_up

-- Miscellaneous not in standard menu.
-- TODO: {events.emit, events.CALL_TIP_CLICK, 1}
-- TODO: {events.emit, events.CALL_TIP_CLICK, 2}

-- Language-specific modules.
events.connect(events.LANGUAGE_MODULE_LOADED, function(lang)
  if not _M[lang].sense then return end
  keys[lang][not CURSES and 'c ' or 'c@'] = function()
    local ret = _M[lang].sense:complete()
    if not _G.buffer:auto_c_active() then return false end
    return ret
  end
end)

local last_buffer = buffer
-- Save last buffer. Useful after gui.switch_buffer().
events.connect(events.BUFFER_BEFORE_SWITCH, function()
  last_buffer = _G.buffer
end)
keys['az'] = function()
  if (_BUFFERS[last_buffer]) then _G.view:goto_buffer(_BUFFERS[last_buffer]) end
end

--keys[not CURSES and 'ae' or 'me'] = _M.file_browser.init
--keys[not CURSES and 'caj' or 'cmj'] = _M.version_control.snapopen_project
--keys[not CURSES and 'aj' or 'mj'] = _M.version_control.command

-- Modes.
keys.lua_command = {
  ['\t'] = gui.command_entry.complete_lua,
  ['\n'] = {gui.command_entry.finish_mode, gui.command_entry.execute_lua}
}
keys.filter_through = {
  ['\n'] = {gui.command_entry.finish_mode, m_editing.filter_through},
}
keys.find_incremental = {
  ['\n'] = function()
    gui.find.find_incremental(gui.command_entry.entry_text, true, true)
  end,
  ['cr'] = function()
    gui.find.find_incremental(gui.command_entry.entry_text, false, true)
  end,
  ['\b'] = function()
    gui.find.find_incremental(gui.command_entry.entry_text:sub(1, -2), true)
    return false -- propagate
  end
}
setmetatable(keys.find_incremental, {__index = function(t, k)
               if #k > 1 and k:find('^[cams]*.+$') then return end
               gui.find.find_incremental(gui.command_entry.entry_text..k, true)
             end})

return {utils = {}} -- so testing menu does not error
