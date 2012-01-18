-- Copyright 2007-2012 Mitchell Foral mitchell<att>caladbolg.net. See LICENSE.

--[[ This comment is for LuaDoc.
---
-- Manages and defines key commands in Textadept.
module('_M.textadept.keys')]]

-- c:       C       G     J                   T ~              ) ] }     /  \t\r
-- a:  a   cC DeE     H IjJkK L   NoO P Q    tTuU  w xX  zZ_   ) ] }   +-/  ~~\r
-- ca: a b  CdDe    GhHiIjJkK L    oO  qQ       U  wW  y zZ_"'()[]{}<>*+ /?
-- ~: reserved.

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

-- File.
keys.cac = new_buffer
keys.cr = io.open_file
keys.car = io.open_recent_file
keys.cR = buffer.reload
keys.co = buffer.save
keys.cO = buffer.save_as
keys.cx = buffer.close
keys.cX = io.close_all
-- TODO: Mtextadept.session.load after prompting with open dialog
-- TODO: Mtextadept.session.save after prompting with save dialog
keys.aq = quit

-- Edit.
keys.cz = buffer.undo
keys.cZ = buffer.redo
keys.ck = function()
  local buffer = _G.buffer
  if #buffer:get_sel_text() == 0 then buffer:line_end_extend() end
  buffer:cut()
end
keys.cK = buffer.copy
keys.cu = buffer.paste
keys.cD = buffer.line_duplicate
keys.del = buffer.clear
keys.aA = buffer.select_all
keys.cm = Mediting.match_brace
keys['c '] = { Mediting.autocomplete_word, '%w_' }
keys.cw = function()
  Mediting.select_word()
  _G.buffer:delete_back()
end
keys.aW = Mediting.highlight_word
keys.cq = Mediting.block_comment
keys.ct = Mediting.transpose_chars
keys.cj = Mediting.join_lines
-- Select.
keys.cM = { Mediting.match_brace, 'select' }
keys['c<'] = { Mediting.select_enclosed, '>', '<' }
keys['c>'] = { Mediting.select_enclosed, '<', '>' }
keys['c"'] = { Mediting.select_enclosed, '"', '"' }
keys["c'"] = { Mediting.select_enclosed, "'", "'" }
keys['c('] = { Mediting.select_enclosed, '(', ')' }
keys['c['] = { Mediting.select_enclosed, '[', ']' }
keys['c{'] = { Mediting.select_enclosed, '{', '}' }
keys['c*'] = any_char_mt(Mediting.select_enclosed)
keys.cW = Mediting.select_word
keys.cL = Mediting.select_line
keys.cQ = Mediting.select_paragraph
keys['cs\t'] = Mediting.select_indented_block
-- TODO: Mediting.select_style
-- Selection.
-- TODO: buffer.upper_case
-- TODO: buffer.lower_case
keys['a<'] = function()
  Mediting.enclose('<', '>')
  local buffer = _G.buffer
  local pos = buffer.current_pos
  while buffer.char_at[pos - 1] ~= 60 do pos = pos - 1 end -- '<'
  buffer:insert_text(-1, '</'..buffer:text_range(pos, buffer.current_pos))
end
keys['a>'] = { Mediting.enclose, '<', ' />' }
keys['a"'] = { Mediting.enclose, '"', '"' }
keys["a'"] = { Mediting.enclose, "'", "'" }
keys['a('] = { Mediting.enclose, '(', ')' }
keys['a['] = { Mediting.enclose, '[', ']' }
keys['a{'] = { Mediting.enclose, '{', '}' }
keys['a*'] = any_char_mt(Mediting.enclose)
keys['c+'] = { Mediting.grow_selection, 1 }
keys['c_'] = { Mediting.grow_selection, -1 }
-- TODO: buffer.move_selected_lines_up
-- TODO: buffer.move_selected_lines_down

-- Search.
keys.cs = gui.find.focus
keys.as = gui.find.find_next
keys.aS = gui.find.find_prev
keys.ar = gui.find.replace
keys.aR = gui.find.replace_all
-- Find Next is an when find pane is focused.
-- Find Prev is ap when find pane is focused.
-- Replace is ar when find pane is focused.
-- Replace All is aa when find pane is focused.
keys.cS = gui.find.find_incremental
-- Find in Files is ai when find pane is focused.
-- TODO: { gui.find.goto_file_in_list, true }
-- TODO: { gui.find.goto_file_in_list, false }
keys.cg = Mediting.goto_line

-- Tools.
keys.cc = gui.command_entry.focus
keys.ag = Mtextadept.run.run
keys.aG = Mtextadept.run.compile
keys['a|'] = Mtextadept.filter_through.filter_through
-- Adeptsense.
-- Complete symbol is 'c '.
keys['c?'] = function()
  local m = _M[_G.buffer:get_lexer()]
  if m and m.sense then m.sense:show_apidoc() end
end
-- Snippets.
keys['\t'] = Msnippets._insert
keys['s\t'] = Msnippets._previous
keys.cI = Msnippets._cancel_current
keys.ci = Msnippets._select
-- Bookmarks.
keys.am = Mbookmarks.toggle
keys.aM = Mbookmarks.clear
keys.cam = Mbookmarks.goto_next
keys.caM = Mbookmarks.goto_prev
-- TODO: Mbookmarks.goto
-- Snapopen.
keys.cau = { Mtextadept.snapopen.open, _USERHOME }
local excludes = {
  extensions = { 'html' },
  folders = {
    '.hg', 'releases', 'win32gtk', 'doxygen', 'images', 'scintilla', 'luajit'
  }
}
keys.cat = { Mtextadept.snapopen.open, _HOME, excludes }
-- Miscellaneous.
keys.ai = function()
  local buffer = _G.buffer
  local style = buffer.style_at[buffer.current_pos]
  local text = string.format("%s %s\n%s %s (%d)", _L['Lexer'],
                             buffer:get_lexer(), _L['Style'],
                             buffer:get_style_name(style), style)
  buffer:call_tip_show(buffer.current_pos, text)
end
--keys.caR = _M.version_control.snapopen_project
--keys.cH = hg module commands

-- Buffers.
keys.an = { view.goto_buffer, view, 1, true }
keys.ap = { view.goto_buffer, view, -1, true }
keys.cal = gui.switch_buffer
-- Indentation.
keys['ca\t'] = { toggle_setting, 'use_tabs' }
keys.caT = Mediting.convert_indentation
-- EOL Mode.
-- Encoding.
keys.al = Mtextadept.mime_types.select_lexer
keys.f5 = { buffer.colourise, buffer, 0, -1 }

-- Views.
keys.can = { gui.goto_view, 1, true }
keys.cap = { gui.goto_view, -1, true }
keys.cas = { view.split, view } -- horizontal
keys.caS = { view.split, view, true } -- vertical
keys.cax = function() _G.view:unsplit() return true end
keys.caX = function() while _G.view:unsplit() do end end
keys['ca='] = function() _G.view.size = _G.view.size + 10 end
keys['ca-'] = function() _G.view.size = _G.view.size - 10 end
keys.caf = function()
  local buffer = _G.buffer
  buffer:toggle_fold(buffer:line_from_position(buffer.current_pos))
end
keys['ca\n'] = { toggle_setting, 'view_eol' }
keys['ca\\'] = { toggle_setting, 'wrap_mode' }
keys.cag = { toggle_setting, 'indentation_guides' }
keys['ca '] = { toggle_setting, 'view_ws' }
keys.cav = { toggle_setting, 'virtual_space_options', 2 }
keys['c='] = buffer.zoom_in
keys['c-'] = buffer.zoom_out
keys.c0 = function() _G.buffer.zoom = 0 end

-- Movement/selection commands.
keys.cf = buffer.char_right
keys.cF = buffer.char_right_extend
keys.af = buffer.word_right
keys.aF = buffer.word_right_extend
-- TODO: buffer.word_part_right
-- TODO: buffer.word_part_right_extend
keys.cb = buffer.char_left
keys.cB = buffer.char_left_extend
keys.ab = buffer.word_left
keys.aB = buffer.word_left_extend
-- TODO: buffer.word_part_left
-- TODO: buffer.word_part_left_extend
keys.cn = buffer.line_down
keys.cN = buffer.line_down_extend
keys.cp = buffer.line_up
keys.cP = buffer.line_up_extend
keys.ca = buffer.vc_home
keys.cA = buffer.home_extend
keys.ce = buffer.line_end
keys.cE = buffer.line_end_extend
keys.cv = buffer.page_down
keys.cV = buffer.page_down_extend
keys.av = buffer.para_down
keys.aV = buffer.para_down_extend
-- TODO: buffer.document_start
-- TODO: buffer.document_start_extend
keys.cy = buffer.page_up
keys.cY = buffer.page_up_extend
keys.ay = buffer.para_up
keys.aY = buffer.para_up_extend
-- TODO: buffer.document_end
-- TODO: buffer.document_end_extend
keys.ch = buffer.delete_back
keys.ah = buffer.del_word_left
keys.cd = buffer.clear
keys.ad = buffer.del_word_right
keys.caF = buffer.char_right_rect_extend
keys.caB = buffer.char_left_rect_extend
keys.caN = buffer.line_down_rect_extend
keys.caP = buffer.line_up_rect_extend
keys.caA = buffer.vc_home_rect_extend
keys.caE = buffer.line_end_rect_extend
keys.caV = buffer.page_down_rect_extend
keys.caY = buffer.page_up_rect_extend
-- TODO: buffer.vertical_centre_caret
-- TODO: buffer.line_scroll_down
-- TODO: buffer.line_scroll_up

-- Miscellaneous not in standard menu.
-- TODO: { events.emit, events.CALL_TIP_CLICK, 1 }
keys['a?'] = { events.emit, events.CALL_TIP_CLICK, 2 }

-- Language-specific modules.
events.connect(events.LANGUAGE_MODULE_LOADED, function(lang)
  if not _M[lang].sense then return end
  keys[lang]['c '] = function()
    local ret = _M[lang].sense:complete()
    if not _G.buffer:auto_c_active() then return false end
    return ret
  end
end)

return { utils = {} } -- so testing menu does not error
