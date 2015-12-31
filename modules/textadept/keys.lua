-- Copyright 2007-2016 Mitchell mitchell.att.foicica.com. See LICENSE.

--[[ This comment is for LuaDoc.
---
-- Manages and defines key commands in Textadept.
module('textadept.keys')]]

-- c:         ~~   ~
-- ca:        ~~          t    y
-- a:  aA   C               K Lm   oO          uU         Z_           +  -

-- Utility functions.
local function any_char_mt(f)
  return setmetatable({}, {__index = function(t, k)
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
local editing = textadept.editing

-- File.
keys[not CURSES and 'cac' or 'cmc'] = buffer.new
keys.cr = {ui.command_entry.enter_mode, 'open_file'}
keys[not CURSES and 'car' or 'cmr'] = io.open_recent_file
-- TODO: io.reload_file
keys.co = io.save_file
keys[not CURSES and 'cao' or 'cmo'] = io.save_file_as
keys.cx = io.close_buffer
keys[not CURSES and 'ax' or 'mx'] = io.close_all_buffers
-- TODO: textadept.session.load
-- TODO: textadept.session.save
keys.cq = quit

-- Edit.
keys.cz = buffer.undo
if CURSES then keys.mz = keys.cz end -- usually ^Z suspends
keys.cZ = buffer.redo -- GTK only
keys[not CURSES and 'caz' or 'cmz'] = buffer.redo
keys.ck = function()
  if #_G.buffer:get_sel_text() == 0 then _G.buffer:line_end_extend() end
  _G.buffer:cut()
end
keys.cK = buffer.copy -- GTK only
keys[not CURSES and 'cak' or 'cmk'] = keys.cK
keys.cu = buffer.paste
keys[not CURSES and 'cad' or 'cmd'] = buffer.line_duplicate
keys.del = buffer.clear
keys.cw = function() -- delete word
  editing.select_word()
  _G.buffer:delete_back()
end
keys[not CURSES and 'caa' or 'cma'] = buffer.select_all
keys['c]'] = editing.match_brace
keys[not CURSES and 'c ' or 'c@'] = {editing.autocomplete, 'word'}
keys[not CURSES and 'aw' or 'mw'] = editing.highlight_word
keys[not CURSES and 'c/' or 'c_'] = editing.block_comment
keys.ct = editing.transpose_chars
keys.cj = editing.join_lines
keys[not CURSES and 'a|' or 'm|'] = {ui.command_entry.enter_mode,
                                     'filter_through', 'bash'}
-- Select.
keys[not CURSES and 'ca]' or 'cm]'] = {editing.match_brace, 'select'}
keys[not CURSES and 'a>' or 'm>'] = {editing.select_enclosed, '>', '<'}
-- TODO: {editing.select_enclosed, '<', '>'}
keys[not CURSES and 'a"' or 'm"'] = {editing.select_enclosed, '"', '"'}
keys[not CURSES and "a'" or "m'"] = {editing.select_enclosed, "'", "'"}
keys[not CURSES and 'a)' or 'm)'] = {editing.select_enclosed, '(', ')'}
keys[not CURSES and 'a]' or 'm]'] = {editing.select_enclosed, '[', ']'}
keys[not CURSES and 'a}' or 'm}'] = {editing.select_enclosed, '{', '}'}
-- TODO: any_char_mt(editing.select_enclosed)
keys[not CURSES and 'caw' or 'cmw'] = editing.select_word
keys[not CURSES and 'cae' or 'cme'] = editing.select_line
keys[not CURSES and 'caq' or 'cmq'] = editing.select_paragraph
-- Selection.
-- TODO: buffer.upper_case
-- TODO: buffer.lower_case
keys[not CURSES and 'a<' or 'm<'] = function() -- enclose as XML tags
  editing.enclose('<', '>')
  local pos = _G.buffer.current_pos
  while _G.buffer.char_at[pos - 1] ~= 60 do pos = pos - 1 end -- '<'
  _G.buffer:insert_text(-1,
                        '</'.._G.buffer:text_range(pos, _G.buffer.current_pos))
end
keys[not CURSES and 'a/' or 'm/'] = {editing.enclose, '<', ' />'}
keys[not CURSES and 'aQ' or 'mQ'] = {editing.enclose, '"', '"'}
keys[not CURSES and 'aq' or 'mq'] = {editing.enclose, "'", "'"}
keys[not CURSES and 'a(' or 'm('] = {editing.enclose, '(', ')'}
keys[not CURSES and 'a[' or 'm['] = {editing.enclose, '[', ']'}
keys[not CURSES and 'a{' or 'm{'] = {editing.enclose, '{', '}'}
keys[not CURSES and 'a%' or 'm%'] = any_char_mt(editing.enclose)
-- TODO: buffer.move_selected_lines_up
-- TODO: buffer.move_selected_lines_down

-- Search.
keys.cs = ui.find.focus
keys[not CURSES and 'as' or 'ms'] = ui.find.find_next
keys[not CURSES and 'aS' or 'mS'] = ui.find.find_prev
keys[not CURSES and 'ar' or 'mr'] = ui.find.replace
keys[not CURSES and 'aR' or 'mR'] = ui.find.replace_all
-- Find Next is an when find pane is focused (GTK only).
-- Find Prev is ap when find pane is focused (GTK only).
-- Replace is ar when find pane is focused (GTK only).
-- Replace All is aa when find pane is focused (GTK only).
keys[not CURSES and 'ai' or 'mi'] = ui.find.find_incremental
-- Find in Files is ai when find pane is focused.
-- TODO: {ui.find.goto_file_found, false, true}
-- TODO: {ui.find.goto_file_found, false, false}
keys.cg = editing.goto_line

-- Tools.
keys.cc = {ui.command_entry.enter_mode, 'lua_command', 'lua'}
-- TODO: function() textadept.menu.select_command() end
keys[not CURSES and 'ag' or 'mg'] = textadept.run.run
keys[not CURSES and 'aG' or 'mG'] = textadept.run.compile
keys[not CURSES and 'aJ' or 'mJ'] = textadept.run.build
keys.aX = textadept.run.stop
-- TODO: {m_textadept.run.goto_error, false, true}
-- TODO: {m_textadept.run.goto_error, false, false}
-- Snippets.
keys['\t'] = textadept.snippets._insert
keys['s\t'] = textadept.snippets._previous
-- TODO: textadept.snippets._cancel_current
-- TODO: textadept.snippets._select
-- Bookmarks.
keys[not CURSES and 'aM' or 'mM'] = textadept.bookmarks.toggle
-- TODO: textadept.bookmarks.clear
keys[not CURSES and 'aN' or 'mN'] = {textadept.bookmarks.goto_mark, true}
keys[not CURSES and 'aP' or 'mP'] = {textadept.bookmarks.goto_mark, false}
keys.cam = textadept.bookmarks.goto_mark -- GTK only
-- Snapopen.
keys[not CURSES and 'cau' or 'cmu'] = {io.snapopen, _USERHOME}
keys[not CURSES and 'cah' or 'cmh'] = {io.snapopen, _HOME}
if CURSES then keys.cmg = keys.cmh end
keys[not CURSES and 'caj' or 'cmj'] = io.snapopen
-- Other.
-- Complete symbol is 'c '.
keys[not CURSES and 'a?' or 'm?'] = textadept.editing.show_documentation
keys['a='] = function() -- show style
  local pos = _G.buffer.current_pos
  local char = _G.buffer:text_range(pos, _G.buffer:position_after(pos))
  local code = utf8.codepoint(char)
  local bytes = string.rep(' 0x%02X', #char):format(char:byte(1, #char))
  local style = _G.buffer.style_at[pos]
  local text = string.format("'%s' (U+%04X:%s)\n%s %s\n%s %s (%d)", char, code,
                             bytes, _L['Lexer'], _G.buffer:get_lexer(true),
                             _L['Style'], _G.buffer.style_name[style], style)
  _G.buffer:call_tip_show(_G.buffer.current_pos, text)
end

-- Buffers.
keys[not CURSES and 'an' or 'mn'] = {view.goto_buffer, view, 1, true}
keys[not CURSES and 'ap' or 'mp'] = {view.goto_buffer, view, -1, true}
keys[not CURSES and 'cab' or 'cmb'] = ui.switch_buffer
-- Indentation.
keys[not CURSES and 'at' or 'mt'] = {toggle_setting, 'use_tabs'}
keys[not CURSES and 'aT' or 'mT'] = editing.convert_indentation
-- EOL Mode.
-- Encoding.
keys[not CURSES and 'cal' or 'cml'] = textadept.file_types.select_lexer
keys.f5 = {buffer.colourise, buffer, 0, -1}

-- Views.
keys[not CURSES and 'can' or 'cmn'] = {ui.goto_view, 1, true}
keys[not CURSES and 'cap' or 'cmp'] = {ui.goto_view, -1, true}
keys[not CURSES and 'cas' or 'cms'] = {view.split, view} -- horizontal
keys[not CURSES and 'cav' or 'cmv'] = {view.split, view, true} -- vertical
keys[not CURSES and 'cax' or 'cmx'] = function()
  _G.view:unsplit()
  return true -- always return true, even if the unsplit operation failed
end
keys.caX = function() while _G.view:unsplit() do end end -- GTK only
-- TODO: function() _G.view.size = _G.view.size + 10 end
-- TODO: function() _G.view.size = _G.view.size - 10 end
keys[not CURSES and 'caf' or 'cmf'] = function() -- toggle fold
  _G.buffer:toggle_fold(_G.buffer:line_from_position(_G.buffer.current_pos))
end
keys[not CURSES and 'aE' or 'mE'] = {toggle_setting, 'view_eol'}
keys[not CURSES and 'aW' or 'mW'] = {toggle_setting, 'wrap_mode'}
keys[not CURSES and 'aI' or 'mI'] = {toggle_setting, 'indentation_guides'}
keys[not CURSES and 'aH' or 'mH'] = {toggle_setting, 'view_ws'}
-- TODO: {toggle_setting, 'virtual_space_options', 2}
keys['c='] = buffer.zoom_in -- GTK only
keys['c-'] = buffer.zoom_out -- GTK only
keys['c0'] = function() _G.buffer.zoom = 0 end -- GTK only
-- TODO: ui.select_theme

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
keys.f10 = function() ui.maximized = not ui.maximized end

-- Language modules.
events.connect(events.LEXER_LOADED, function(lang)
  if not keys[lang] then return end
  keys[lang][not CURSES and 'c ' or 'c@'] = function()
    if not textadept.editing.autocomplete(lang) then return false end
  end
end)

local last_buffer = buffer
-- Save last buffer. Useful after ui.switch_buffer().
events.connect(events.BUFFER_BEFORE_SWITCH,
               function() last_buffer = _G.buffer end)
keys[not CURSES and 'al' or 'ml'] = function()
  if _BUFFERS[last_buffer] then _G.view:goto_buffer(_BUFFERS[last_buffer]) end
end

-- Prompt for project root command to run (e.g. "hg status").
keys[not CURSES and 'aj' or 'mj'] = function()
  local root = io.get_project_root()
  if not root then return end
  local button, command = ui.dialogs.standard_inputbox{
    title = _L['Command'], informative_text = root
  }
  if button == 1 then spawn(command, root, ui.print, ui.print) end
end

keys[not CURSES and 'ak' or 'mk'] = {ui.command_entry.enter_mode,
                                     'find_in_project'}

-- Mercurial diff of current file.
keys[not CURSES and 'aD' or 'mD'] = function()
  local root = io.get_project_root()
  if not _G.buffer.filename or not root then return end
  local p = io.popen('hg diff -R "'..root..'" "'.._G.buffer.filename..'"')
  local diff = p:read('*a')
  p:close()
  local buffer = _G.buffer.new()
  buffer:set_lexer('diff')
  buffer:add_text(diff)
  buffer:goto_pos(0)
  buffer:set_save_point()
end

--keys[not CURSES and 'ae' or 'me'] = _M.file_browser.init
--keys[not CURSES and 'a&' or 'm&'] = _M.ctags.goto_tag
--keys[not CURSES and 'a*' or 'm*'] = ...
--keys[not CURSES and 'a,' or 'm,'] = {_M.ctags.goto_tag, nil, true} -- back
--keys[not CURSES and 'a.' or 'm.'] = {_M.ctags.goto_tag, nil, false} -- forward
--keys[not CURSES and 'ac' or 'mc'] = {textadept.editing.autocomplete, 'ctag'}
--keys.f7 = {_M.spellcheck.check_spelling, true}
--keys.sf7 = _M.spellcheck.check_spelling
--keys.f8 = _M.file_diff.start
--keys.adown = {_M.file_diff.goto_change, true}
--keys.aup = _M.file_diff.goto_change
--keys.aleft = {_M.file_diff.merge, true}
--keys.aright = _M.file_diff.merge

-- Modes.
keys.open_file = {
  ['\n'] = {ui.command_entry.finish_mode, function(file)
    if file ~= '' and not file:find('^%a?:?[/\\]') then
      -- Convert relative path into an absolute one.
      file = (_G.buffer.filename or
              lfs.currentdir()..'/'):match('^.+[/\\]')..file
    end
    io.open_file(file ~= '' and file)
  end},
  ['\t'] = function()
    if not ui.command_entry:auto_c_active() then
      -- Autocomplete the filename in the command entry
      local files = {}
      local path = ui.command_entry:get_text()
      if not path:find('^a?:?[/\\]') then
        -- Convert relative path into an absolute one.
        path = (_G.buffer.filename or
                lfs.currentdir()..'/'):match('^.+[/\\]')..path
      end
      local dir, part = path:match('^(.-)([^/\\]*)$')
      if lfs.attributes(dir, 'mode') == 'directory' then
        -- Iterate over directory, finding file matches.
        part = '^'..part
        lfs.dir_foreach(dir, function(file)
          file = file:match('[^/\\]+[/\\]?$')
          if file:find(part) then files[#files + 1] = file end
        end, nil, false, 0, true)
        table.sort(files)
        keys.open_file.files = files -- store for tabbing through
        ui.command_entry:auto_c_show(#part - 1, table.concat(files, ' '))
      end
    else
      -- Cycle through filenames.
      local i = ui.command_entry.auto_c_current + 2
      if i > #keys.open_file.files then i = 1 end
      ui.command_entry:auto_c_select(keys.open_file.files[i])
    end
  end
}
keys.filter_through = {
  ['\n'] = {ui.command_entry.finish_mode, editing.filter_through},
}
keys.find_incremental = {
  ['\n'] = function()
    ui.find.find_entry_text = ui.command_entry:get_text() -- save
    ui.find.find_incremental(ui.command_entry:get_text(), true, true)
  end,
  ['cr'] = function()
    ui.find.find_incremental(ui.command_entry:get_text(), false, true)
  end,
  ['\b'] = function()
    ui.find.find_incremental(ui.command_entry:get_text():sub(1, -2), true)
    return false -- propagate
  end
}
setmetatable(keys.find_incremental, {__index = function(t, k)
               if #k > 1 and k:find('^[cams]*.+$') then return end
               ui.find.find_incremental(ui.command_entry:get_text()..k, true)
             end})
keys.find_in_project = {
  paths = {}, -- for per-project search path mappings
  ['\n'] = {ui.command_entry.finish_mode, function(text)
    local root = io.get_project_root()
    if not root or text == '' then return end
    ui.find.find_entry_text = text
    local match_case, in_files = ui.find.match_case, ui.find.in_files
    ui.find.match_case, ui.find.in_files = true, true
    ui.find.find_in_files(keys.find_in_project.paths[root] or root)
    ui.find.match_case, ui.find.in_files = match_case, in_files -- restore
  end}
}
keys.lua_command['a?'] = function()
  local orig_buffer = _G.buffer
  _G.buffer = ui.command_entry
  textadept.editing.show_documentation()
  _G.buffer = orig_buffer
end
if OSX or CURSES then
  -- UTF-8 input.
  keys.utf8_input = {['\n'] = {ui.command_entry.finish_mode, function(code)
    _G.buffer:add_text(utf8.char(tonumber(code, 16)))
  end}}
  keys[OSX and 'mU' or 'mu'] = {ui.command_entry.enter_mode, 'utf8_input'}
end

-- Keys for the command entry.
local ekeys = ui.command_entry.editing_keys.__index
ekeys.cf = {buffer.char_right, ui.command_entry}
ekeys.cb = {buffer.char_left, ui.command_entry}
ekeys.cn = {buffer.line_down, ui.command_entry}
ekeys.cp = {buffer.line_up, ui.command_entry}
ekeys.ca = {buffer.vc_home, ui.command_entry}
ekeys.ce = {buffer.line_end, ui.command_entry}
ekeys.cv = {buffer.page_down, ui.command_entry}
ekeys.cy = {buffer.page_up, ui.command_entry}
ekeys.ch = {buffer.delete_back, ui.command_entry}
ekeys.cd = {buffer.clear, ui.command_entry}
ekeys.cu = {buffer.paste, ui.command_entry}
ekeys.caa = {buffer.select_all, ui.command_entry}

return {utils = {}} -- so testing menu does not error
