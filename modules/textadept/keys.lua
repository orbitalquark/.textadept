-- Copyright 2007-2012 Mitchell Foral mitchell<att>caladbolg.net. See LICENSE.

--[[ This comment is for LuaDoc.
---
-- Manages and defines key commands in Textadept.
module('_M.textadept.keys')]]

-- c:          ~   ~
-- ca:       g ~          t    y
-- a:  aA  cC D           JkKlLm   oO          uU     X   Z_               =

-- Utility functions.
local function any_char_mt(f)
  return setmetatable({['\0'] = {}}, { __index = function(t, k)
                          if #k == 1 then return { f, k, k } end
                        end })
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

local keys, io, gui, buffer, view = keys, io, gui, buffer, view
local Mtextadept, Mediting = _M.textadept, _M.textadept.editing
local Mbookmarks, Msnippets = Mtextadept.bookmarks, Mtextadept.snippets

keys.LANGUAGE_MODULE_PREFIX = 'cl'

-- File.
keys[not NCURSES and 'cac' or 'cmc'] = new_buffer
keys.cr = io.open_file
keys[not NCURSES and 'car' or 'cmr'] = io.open_recent_file
-- TODO: buffer.reload
keys.co = buffer.save
keys[not NCURSES and 'cao' or 'cmo'] = buffer.save_as
keys.cx = buffer.close
keys[not NCURSES and 'ax' or 'mx'] = io.close_all
-- TODO: Mtextadept.session.load after prompting with open dialog
-- TODO: Mtextadept.session.save after prompting with save dialog
keys.cq = quit

-- Edit.
keys.cz = buffer.undo
keys.cZ = buffer.redo -- GTK only
keys[not NCURSES and 'caz' or 'cmz'] = keys.cZ
keys.ck = function()
  local buffer = _G.buffer
  if #buffer:get_sel_text() == 0 then buffer:line_end_extend() end
  buffer:cut()
end
keys.cK = buffer.copy -- GTK only
keys[not NCURSES and 'cak' or 'cmk'] = keys.cK
keys.cu = buffer.paste
keys[not NCURSES and 'cad' or 'cmd'] = buffer.line_duplicate
keys.del = buffer.clear
keys.cw = function() -- delete word
  Mediting.select_word()
  _G.buffer:delete_back()
end
keys[not NCURSES and 'caa' or 'cma'] = buffer.select_all
keys['c]'] = Mediting.match_brace
keys[not NCURSES and 'c ' or 'c@'] = { Mediting.autocomplete_word, '%w_' }
keys[not NCURSES and 'aw' or 'mw'] = Mediting.highlight_word
keys[not NCURSES and 'c/' or 'c_'] = Mediting.block_comment
keys.ct = Mediting.transpose_chars
keys.cj = Mediting.join_lines
-- Select.
keys[not NCURSES and 'ca]' or 'cm]'] = { Mediting.match_brace, 'select' }
keys[not NCURSES and 'a>' or 'm>'] = { Mediting.select_enclosed, '>', '<' }
-- TODO: { Mediting.select_enclosed, '<', '>' }
keys[not NCURSES and 'a"' or 'm"'] = { Mediting.select_enclosed, '"', '"' }
keys[not NCURSES and "a'" or "m'"] = { Mediting.select_enclosed, "'", "'" }
keys[not NCURSES and 'a)' or 'm)'] = { Mediting.select_enclosed, '(', ')' }
keys[not NCURSES and 'a]' or 'm]'] = { Mediting.select_enclosed, '[', ']' }
keys[not NCURSES and 'a}' or 'm}'] = { Mediting.select_enclosed, '{', '}' }
-- TODO: any_char_mt(Mediting.select_enclosed)
keys[not NCURSES and 'caw' or 'cmw'] = Mediting.select_word
keys[not NCURSES and 'cae' or 'cme'] = Mediting.select_line
keys[not NCURSES and 'caq' or 'cmq'] = Mediting.select_paragraph
keys.cai = Mediting.select_indented_block -- GTK only
-- Selection.
-- TODO: buffer.upper_case
-- TODO: buffer.lower_case
keys[not NCURSES and 'a<' or 'm<'] = function() -- enclose as XML tags
  Mediting.enclose('<', '>')
  local buffer = _G.buffer
  local pos = buffer.current_pos
  while buffer.char_at[pos - 1] ~= 60 do pos = pos - 1 end -- '<'
  buffer:insert_text(-1, '</'..buffer:text_range(pos, buffer.current_pos))
end
keys[not NCURSES and 'a/' or 'm/'] = { Mediting.enclose, '<', ' />' }
keys[not NCURSES and 'aQ' or 'mQ'] = { Mediting.enclose, '"', '"' }
keys[not NCURSES and 'aq' or 'mq'] = { Mediting.enclose, "'", "'" }
keys[not NCURSES and 'a(' or 'm('] = { Mediting.enclose, '(', ')' }
keys[not NCURSES and 'a[' or 'm['] = { Mediting.enclose, '[', ']' }
keys[not NCURSES and 'a{' or 'm{'] = { Mediting.enclose, '{', '}' }
keys[not NCURSES and 'a*' or 'm*'] = any_char_mt(Mediting.enclose)
keys[not NCURSES and 'a+' or 'm+'] = { Mediting.grow_selection, 1 }
keys[not NCURSES and 'a-' or 'm-'] = { Mediting.grow_selection, -1 }
-- TODO: buffer.move_selected_lines_up
-- TODO: buffer.move_selected_lines_down

-- Search.
keys.cs = gui.find.focus
keys[not NCURSES and 'as' or 'ms'] = gui.find.find_next
keys[not NCURSES and 'aS' or 'mS'] = gui.find.find_prev
keys[not NCURSES and 'ar' or 'mr'] = gui.find.replace
keys[not NCURSES and 'aR' or 'mR'] = gui.find.replace_all
-- Find Next is an when find pane is focused.
-- Find Prev is ap when find pane is focused.
-- Replace is ar when find pane is focused.
-- Replace All is aa when find pane is focused.
keys[not NCURSES and 'ai' or 'mi'] = gui.find.find_incremental
-- Find in Files is ai when find pane is focused.
-- TODO: { gui.find.goto_file_in_list, true }
-- TODO: { gui.find.goto_file_in_list, false }
keys.cg = Mediting.goto_line

-- Tools.
keys.cc = gui.command_entry.focus
-- TODO: function() _M.textadept.menu.select_command() end
keys[not NCURSES and 'ag' or 'mg'] = Mtextadept.run.run
keys[not NCURSES and 'aG' or 'mG'] = Mtextadept.run.compile
keys[not NCURSES and 'a|' or 'm|'] = Mtextadept.filter_through.filter_through
-- Adeptsense.
-- Complete symbol is 'c '.
keys[not NCURSES and 'a?' or 'm?'] = function()
  local m = _M[_G.buffer:get_lexer()]
  if m and m.sense then m.sense:show_apidoc() end
end
-- Snippets.
keys['\t'] = Msnippets._insert
keys['s\t'] = Msnippets._previous
-- TODO: Msnippets._cancel_current
-- TODO: Msnippets._select
-- Bookmarks.
keys[not NCURSES and 'aM' or 'mM'] = Mbookmarks.toggle
-- TODO: Mbookmarks.clear
keys[not NCURSES and 'aN' or 'mN'] = Mbookmarks.goto_next
keys[not NCURSES and 'aP' or 'mP'] = Mbookmarks.goto_prev
keys.cam = Mbookmarks.goto_bookmark -- GTK only
-- Snapopen.
keys[not NCURSES and 'cau' or 'cmu'] = { Mtextadept.snapopen.open, _USERHOME }
local excludes = {
  extensions = { 'html' },
  folders = {
    '.hg', 'api', 'doxygen', 'images', 'releases', 'cdk', 'gtkosx', 'luajit',
    'scintilla', 'termkey', 'win32gtk'
  }
}
keys[not NCURSES and 'cah' or 'cmh'] =
  { Mtextadept.snapopen.open, _HOME, excludes }
-- Miscellaneous.
-- TODO: function() -- show style
--   local buffer = _G.buffer
--   local style = buffer.style_at[buffer.current_pos]
--   local text = string.format("%s %s\n%s %s (%d)", _L['Lexer'],
--                              buffer:get_lexer(), _L['Style'],
--                              buffer:get_style_name(style), style)
--   buffer:call_tip_show(buffer.current_pos, text)
-- end

-- Buffers.
keys[not NCURSES and 'an' or 'mn'] = { view.goto_buffer, view, 1, true }
keys[not NCURSES and 'ap' or 'mp'] = { view.goto_buffer, view, -1, true }
keys[not NCURSES and 'cab' or 'cmb'] = gui.switch_buffer
-- Indentation.
keys[not NCURSES and 'at' or 'mt'] = { toggle_setting, 'use_tabs' }
keys[not NCURSES and 'aT' or 'mT'] = Mediting.convert_indentation
-- EOL Mode.
-- Encoding.
keys[not NCURSES and 'cal' or 'cml'] = Mtextadept.mime_types.select_lexer
keys.f5 = { buffer.colourise, buffer, 0, -1 }

-- Views.
keys.can = { gui.goto_view, 1, true }
keys.cap = { gui.goto_view, -1, true }
keys.cas = { view.split, view } -- horizontal
keys.cav = { view.split, view, true } -- vertical
keys.cax = function() _G.view:unsplit() return true end
keys.caX = function() while _G.view:unsplit() do end end -- GTK only
-- TODO: function() _G.view.size = _G.view.size + 10 end
-- TODO: function() _G.view.size = _G.view.size - 10 end
keys[not NCURSES and 'caf' or 'cmf'] = function() -- toggle fold
  local buffer = _G.buffer
  buffer:toggle_fold(buffer:line_from_position(buffer.current_pos))
end
keys[not NCURSES and 'aE' or 'mE'] = { toggle_setting, 'view_eol' }
keys[not NCURSES and 'aW' or 'mW'] = { toggle_setting, 'wrap_mode' }
keys[not NCURSES and 'aI' or 'mI'] = { toggle_setting, 'indentation_guides' }
keys[not NCURSES and 'aH' or 'mH'] = { toggle_setting, 'view_ws' }
-- TODO: { toggle_setting, 'virtual_space_options', 2 }
keys['c='] = buffer.zoom_in -- GTK only
keys['c-'] = buffer.zoom_out -- GTK only
keys['c0'] = function() _G.buffer.zoom = 0 end -- GTK only
-- TODO: gui.select_theme

-- Movement/selection commands.
keys.cf = buffer.char_right
keys.cF = buffer.char_right_extend -- GTK only
keys[not NCURSES and 'af' or 'mf'] = buffer.word_right
keys[not NCURSES and 'aF' or 'mF'] = buffer.word_right_extend
-- TODO: buffer.word_part_right
-- TODO: buffer.word_part_right_extend
keys.cb = buffer.char_left
keys.cB = buffer.char_left_extend -- GTK only
keys[not NCURSES and 'ab' or 'mb'] = buffer.word_left
keys[not NCURSES and 'aB' or 'mB'] = buffer.word_left_extend
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
keys[not NCURSES and 'av' or 'mv'] = buffer.para_down
keys[not NCURSES and 'aV' or 'mV'] = buffer.para_down_extend
keys['c^'] = buffer.document_start
-- TODO: buffer.document_start_extend
keys.cy = buffer.page_up
keys.cY = buffer.page_up_extend -- GTK only
keys[not NCURSES and 'ay' or 'my'] = buffer.para_up
keys[not NCURSES and 'aY' or 'mY'] = buffer.para_up_extend
keys[not NCURSES and 'c$' or 'c\\'] = buffer.document_end
-- TODO: buffer.document_end_extend
keys.ch = buffer.delete_back
keys[not NCURSES and 'ah' or 'mh'] = buffer.del_word_left
keys.cd = buffer.clear
keys[not NCURSES and 'ad' or 'md'] = buffer.del_word_right
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
-- TODO: { events.emit, events.CALL_TIP_CLICK, 1 }
-- TODO: { events.emit, events.CALL_TIP_CLICK, 2 }

-- Language-specific modules.
events.connect(events.LANGUAGE_MODULE_LOADED, function(lang)
  if not _M[lang].sense then return end
  keys[lang][not NCURSES and 'c ' or 'c@'] = function()
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
keys['az'] = function() view:goto_buffer(_BUFFERS[last_buffer]) end

--keys[not NCURSES and 'ae' or 'me'] = _M.file_browser.init
--keys[not NCURSES and 'caj' or 'cmj'] = _M.version_control.snapopen_project
--keys[not NCURSES and 'aj' or 'mj'] = _M.version_control.command

return { utils = {} } -- so testing menu does not error
