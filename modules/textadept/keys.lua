-- Copyright 2007-2016 Mitchell mitchell.att.foicica.com. See LICENSE.

--[[ This comment is for LuaDoc.
---
-- Manages and defines key commands in Textadept.
module('textadept.keys')]]

-- c:         ~~   ~
-- ca:        ~~          t    y
-- a:  aA                   K Lm   oO          uU         Z_           +  -

local keys, GUI = keys, not CURSES

-- File.
keys[GUI and 'cac' or 'cmc'] = buffer.new
keys.cr = function() ui.command_entry.enter_mode('open_file') end
keys[GUI and 'car' or 'cmr'] = io.open_recent_file
-- TODO: io.reload_file
keys.co = io.save_file
keys[GUI and 'cao' or 'cmo'] = io.save_file_as
-- TODO: io.save_all_files
keys.cx = io.close_buffer
keys[GUI and 'ax' or 'mx'] = io.close_all_buffers
-- TODO: textadept.session.load
-- TODO: textadept.session.save
keys.cq = quit

-- Edit.
local m_edit = textadept.menu.menubar[_L['_Edit']]
keys.cz = buffer.undo
if CURSES then keys.mz = keys.cz end -- usually ^Z suspends
keys.cZ = buffer.redo -- GTK only
keys[GUI and 'caz' or 'cmz'] = buffer.redo
keys.ck = function()
  if buffer.selection_empty then buffer:line_end_extend() end
  buffer:cut()
end
keys.cK = buffer.copy -- GTK only
keys[GUI and 'cak' or 'cmk'] = keys.cK
keys.cu = buffer.paste
keys[GUI and 'cad' or 'cmd'] = buffer.line_duplicate
keys.del = buffer.clear
keys.cw = m_edit[_L['D_elete Word']][2]
keys[GUI and 'caa' or 'cma'] = buffer.select_all
keys['c]'] = textadept.editing.match_brace
keys[GUI and 'c ' or 'c@'] = m_edit[_L['Complete _Word']][2]
keys[GUI and 'aw' or 'mw'] = textadept.editing.highlight_word
keys[GUI and 'c/' or 'c_'] = textadept.editing.block_comment
keys.ct = textadept.editing.transpose_chars
keys.cj = textadept.editing.join_lines
keys[GUI and 'a|' or 'm|'] = m_edit[_L['_Filter Through']][2]
-- Select.
local m_sel = m_edit[_L['_Select']]
keys[GUI and 'ca]' or 'cm]'] = m_sel[_L['Select to _Matching Brace']][2]
keys[GUI and 'a>' or 'm>'] = m_sel[_L['Select between _XML Tags']][2]
-- TODO: m_sel[_L['Select in XML _Tag']][2]
keys[GUI and "a'" or "m'"] = m_sel[_L['Select in _Single Quotes']][2]
keys[GUI and 'a"' or 'm"'] = m_sel[_L['Select in _Double Quotes']][2]
keys[GUI and 'a)' or 'm)'] = m_sel[_L['Select in _Parentheses']][2]
keys[GUI and 'a]' or 'm]'] = m_sel[_L['Select in _Brackets']][2]
keys[GUI and 'a}' or 'm}'] = m_sel[_L['Select in B_races']][2]
-- TODO: any_char_mt(textadept.editing.select_enclosed)
keys[GUI and 'caw' or 'cmw'] = textadept.editing.select_word
keys[GUI and 'cae' or 'cme'] = textadept.editing.select_line
keys[GUI and 'caq' or 'cmq'] = textadept.editing.select_paragraph
-- Selection.
m_sel = m_edit[_L['Selectio_n']]
-- TODO: buffer.upper_case
-- TODO: buffer.lower_case
keys[GUI and 'a<' or 'm<'] = m_sel[_L['Enclose as _XML Tags']][2]
keys[GUI and 'a/' or 'm/'] = m_sel[_L['Enclose as Single XML _Tag']][2]
keys[GUI and 'aq' or 'mq'] = m_sel[_L['Enclose in Single _Quotes']][2]
keys[GUI and 'aQ' or 'mQ'] = m_sel[_L['Enclose in _Double Quotes']][2]
keys[GUI and 'a(' or 'm('] = m_sel[_L['Enclose in _Parentheses']][2]
keys[GUI and 'a[' or 'm['] = m_sel[_L['Enclose in _Brackets']][2]
keys[GUI and 'a{' or 'm{'] = m_sel[_L['Enclose in B_races']][2]
keys[GUI and 'a%' or 'm%'] = setmetatable({}, {__index = function(_, k)
  if #k == 1 then return textadept.editing.enclose(k, k) end
end})
-- TODO: buffer.move_selected_lines_up
-- TODO: buffer.move_selected_lines_down

-- Search.
local m_search = textadept.menu.menubar[_L['_Search']]
keys.cs = m_search[_L['_Find']][2]
keys[GUI and 'as' or 'ms'] = ui.find.find_next
keys[GUI and 'aS' or 'mS'] = ui.find.find_prev
keys[GUI and 'ar' or 'mr'] = ui.find.replace
keys[GUI and 'aR' or 'mR'] = ui.find.replace_all
-- Find Next is an when find pane is focused in GUI.
-- Find Prev is ap when find pane is focused in GUI.
-- Replace is ar when find pane is focused in GUI.
-- Replace All is aa when find pane is focused in GUI.
keys[GUI and 'ai' or 'mi'] = ui.find.find_incremental
-- TODO: m_search[_L['Find in Fi_les']][2]
-- Find in Files is ai when find pane is focused in GUI.
-- TODO: m_search[_L['Goto Nex_t File Found']][2]
-- TODO: m_search[_L['Goto Previou_s File Found']][2]
keys.cg = textadept.editing.goto_line

-- Tools.
local m_tools = textadept.menu.menubar[_L['_Tools']]
keys.cc = m_tools[_L['Command _Entry']][2]
keys.ac = m_tools[_L['Select Co_mmand']][2]
keys[GUI and 'ag' or 'mg'] = textadept.run.run
keys[GUI and 'aG' or 'mG'] = textadept.run.compile
keys[GUI and 'aJ' or 'mJ'] = textadept.run.build
keys.aX = textadept.run.stop
-- TODO: m_tools[_L['_Next Error']][2]
-- TODO: m_tools[_L['_Previous Error']][2]
-- Bookmarks.
local m_bookmark = m_tools[_L['_Bookmark']]
keys[GUI and 'aM' or 'mM'] = textadept.bookmarks.toggle
-- TODO: textadept.bookmarks.clear
keys[GUI and 'aN' or 'mN'] = m_bookmark[_L['_Next Bookmark']][2]
keys[GUI and 'aP' or 'mP'] = m_bookmark[_L['_Previous Bookmark']][2]
keys.cam = textadept.bookmarks.goto_mark -- GTK only
-- Quick Open.
local m_quickopen = m_tools[_L['Quick _Open']]
keys[GUI and 'cau' or 'cmu'] = m_quickopen[_L['Quickly Open _User Home']][2]
keys[GUI and 'cah' or 'cmh'] = m_quickopen[_L['Quickly Open _Textadept Home']][2]
if CURSES then keys.cmg = keys.cmh end -- cmh is sometimes just ch
keys[GUI and 'caj' or 'cmj'] = io.quick_open
-- Snippets.
keys['\t'] = textadept.snippets._insert
keys['s\t'] = textadept.snippets._previous
-- TODO: textadept.snippets._cancel_current
-- TODO: textadept.snippets._select
-- Other.
-- Complete symbol is 'c '.
keys[GUI and 'a?' or 'm?'] = textadept.editing.show_documentation
keys['a='] = m_tools[_L['Show St_yle']][2]

-- Buffers.
local m_buffer = textadept.menu.menubar[_L['_Buffer']]
keys[GUI and 'an' or 'mn'] = m_buffer[_L['_Next Buffer']][2]
keys[GUI and 'ap' or 'mp'] = m_buffer[_L['_Previous Buffer']][2]
keys[GUI and 'cab' or 'cmb'] = ui.switch_buffer
-- Indentation.
local m_indentation = m_buffer[_L['_Indentation']]
-- TODO: m_indentation[_L['Tab width: _2']][2]
-- TODO: m_indentation[_L['Tab width: _3']][2]
-- TODO: m_indentation[_L['Tab width: _4']][2]
-- TODO: m_indentation[_L['Tab width: _8']][2]
keys[GUI and 'at' or 'mt'] = m_indentation[_L['_Toggle Use Tabs']][2]
keys[GUI and 'aT' or 'mT'] = textadept.editing.convert_indentation
-- EOL Mode.
-- TODO: m_buffer[_L['_EOL Mode']][_L['CRLF']][2]
-- TODO: m_buffer[_L['_EOL Mode']][_L['CR']][2]
-- TODO: m_buffer[_L['_EOL Mode']][_L['LF']][2]
-- Encoding.
-- TODO: m_buffer[_L['E_ncoding']][_L['_UTF-8 Encoding']][2]
-- TODO: m_buffer[_L['E_ncoding']][_L['_ASCII Encoding']][2]
-- TODO: m_buffer[_L['E_ncoding']][_L['_ISO-8859-1 Encoding']][2]
-- TODO: m_buffer[_L['E_ncoding']][_L['_MacRoman Encoding']][2]
-- TODO: m_buffer[_L['E_ncoding']][_L['UTF-1_6 Encoding']][2]
keys[GUI and 'aE' or 'mE'] = m_buffer[_L['Toggle View _EOL']][2]
keys[GUI and 'aW' or 'mW'] = m_buffer[_L['Toggle _Wrap Mode']][2]
keys[GUI and 'aH' or 'mH'] = m_buffer[_L['Toggle View White_space']][2]
keys[GUI and 'cal' or 'cml'] = textadept.file_types.select_lexer
keys.f5 = m_buffer[_L['_Refresh Syntax Highlighting']][2]

-- Views.
local m_view = textadept.menu.menubar[_L['_View']]
keys[GUI and 'can' or 'cmn'] = m_view[_L['_Next View']][2]
keys[GUI and 'cap' or 'cmp'] = m_view[_L['_Previous View']][2]
keys[GUI and 'cas' or 'cms'] = m_view[_L['Split View _Horizontal']][2]
keys[GUI and 'cav' or 'cmv'] = m_view[_L['Split View _Vertical']][2]
keys[GUI and 'cax' or 'cmx'] = m_view[_L['_Unsplit View']][2]
if GUI then keys.caX = m_view[_L['Unsplit _All Views']][2] end
-- TODO: m_view[_L['_Grow View']][2]
-- TODO: m_view[_L['Shrin_k View']][2]
keys[GUI and 'caf' or 'cmf'] = m_view[_L['Toggle Current _Fold']][2]
keys[GUI and 'aI' or 'mI'] = m_view[_L['Toggle Show In_dent Guides']][2]
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
if GUI then keys.cF = buffer.char_right_extend end
keys[GUI and 'af' or 'mf'] = buffer.word_right
keys[GUI and 'aF' or 'mF'] = buffer.word_right_extend
-- TODO: buffer.word_part_right
-- TODO: buffer.word_part_right_extend
keys.cb = buffer.char_left
if GUI then keys.cB = buffer.char_left_extend end
keys[GUI and 'ab' or 'mb'] = buffer.word_left
keys[GUI and 'aB' or 'mB'] = buffer.word_left_extend
-- TODO: buffer.word_part_left
-- TODO: buffer.word_part_left_extend
keys.cn = buffer.line_down
if GUI then keys.cN = buffer.line_down_extend end
keys.cp = buffer.line_up
if GUI then keys.cP = buffer.line_up_extend end
keys.ca = buffer.vc_home
if GUI then keys.cA = buffer.home_extend end
keys.ce = buffer.line_end
if GUI then keys.cE = buffer.line_end_extend end
keys.cv = buffer.page_down
if GUI then keys.cV = buffer.page_down_extend end
keys[GUI and 'av' or 'mv'] = buffer.para_down
keys[GUI and 'aV' or 'mV'] = buffer.para_down_extend
keys['c^'] = buffer.document_start
-- TODO: buffer.document_start_extend
keys.cy = buffer.page_up
if GUI then keys.cY = buffer.page_up_extend end
keys[GUI and 'ay' or 'my'] = buffer.para_up
keys[GUI and 'aY' or 'mY'] = buffer.para_up_extend
keys[GUI and 'c$' or 'c\\'] = buffer.document_end
-- TODO: buffer.document_end_extend
keys.ch = buffer.delete_back
keys[GUI and 'ah' or 'mh'] = buffer.del_word_left
keys.cd = buffer.clear
keys[GUI and 'ad' or 'md'] = buffer.del_word_right
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
keys.f10 = function() ui.maximized = not ui.maximized end

-- Language modules.
events.connect(events.LEXER_LOADED, function(lang)
  if not keys[lang] or keys[lang][GUI and 'c ' or 'c@'] then return end
  keys[lang][GUI and 'c ' or 'c@'] = function()
    if not textadept.editing.autocomplete(lang) then return false end
  end
end)

local last_buffer = buffer
-- Save last buffer. Useful after ui.switch_buffer().
events.connect(events.BUFFER_BEFORE_SWITCH, function() last_buffer = buffer end)
keys[GUI and 'al' or 'ml'] = function()
  if _BUFFERS[last_buffer] then view:goto_buffer(last_buffer) end
end

-- Prompt for project root command to run (e.g. "hg status").
keys[GUI and 'aj' or 'mj'] = function()
  local root = io.get_project_root()
  if not root then return end
  local button, command = ui.dialogs.standard_inputbox{
    title = _L['Command'], informative_text = root
  }
  if button == 1 then spawn(command, root, ui.print, ui.print) end
end

keys[GUI and 'ak' or 'mk'] = function()
  ui.command_entry.enter_mode('find_in_project')
end

-- Mercurial diff of current file.
keys[GUI and 'aD' or 'mD'] = function()
  local root = io.get_project_root()
  if not buffer.filename or not root then return end
  local p = io.popen('hg diff -R "'..root..'" "'..buffer.filename..'"')
  local diff = p:read('*a')
  p:close()
  local buffer = buffer.new()
  buffer:set_lexer('diff')
  buffer:add_text(diff)
  buffer:goto_pos(0)
  buffer:set_save_point()
end

--keys[GUI and 'ae' or 'me'] = _M.file_browser.init
--keys[GUI and 'a&' or 'm&'] = _M.ctags.goto_tag
--keys[GUI and 'a*' or 'm*'] = m_search['_Ctags']['G_oto Ctag...']
--keys[GUI and 'a,' or 'm,'] = m_search['_Ctags']['Jump Back']
--keys[GUI and 'a.' or 'm.'] = m_search['_Ctags']['Jump Forward']
--keys[GUI and 'aC' or 'mC'] = m_search['_Ctags']['Autocomplete Tag']
--keys.f7 = m_tools[_L['Spe_lling']][_L['_Check Spelling...']][2]
--keys.sf7 = m_tools[_L['Spe_lling']][_L['_Mark Misspelled Words']][2]
--keys.f8 = _M.file_diff.start
--keys.adown = m_tools[_L['_Compare Files']][_L['_Next Change']][2]
--keys.aup = m_tools[_L['_Compare Files']][_L['_Previous Change']][2]
--keys.aleft = m_tools[_L['_Compare Files']][_L['Merge _Left']][2]
--keys.aright = m_tools[_L['_Compare Files']][_L['Merge _Right']][2]

-- Modes.
keys.open_file = {
  ['\n'] = function()
    return ui.command_entry.finish_mode(function(file)
      if file ~= '' and not file:find('^%a?:?[/\\]') then
        -- Convert relative path into an absolute one.
        file = (_G.buffer.filename or
                lfs.currentdir()..'/'):match('^.+[/\\]')..file
      end
      io.open_file(file ~= '' and file)
    end)
  end,
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
        end, nil, 0, true)
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
  ['\n'] = function()
    return ui.command_entry.finish_mode(textadept.editing.filter_through)
  end,
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
    local e = ui.command_entry:position_before(ui.command_entry.length)
    ui.find.find_incremental(ui.command_entry:text_range(0, e), true)
    return false -- propagate
  end
}
-- Add the character for any key pressed without modifiers to incremental find.
setmetatable(keys.find_incremental, {__index = function(_, k)
               if #k > 1 and k:find('^[cams]*.+$') then return end
               ui.find.find_incremental(ui.command_entry:get_text()..k, true)
             end})
keys.find_in_project = {
  paths = {}, -- for per-project search path mappings
  ['\n'] = function()
    return ui.command_entry.finish_mode(function(text)
      local root = io.get_project_root()
      if not root or text == '' then return end
      ui.find.find_entry_text = text
      local match_case, in_files = ui.find.match_case, ui.find.in_files
      ui.find.match_case, ui.find.in_files = true, true
      ui.find.find_in_files(keys.find_in_project.paths[root] or root)
      ui.find.match_case, ui.find.in_files = match_case, in_files -- restore
    end)
  end
}
-- Show documentation for symbols in the Lua command entry.
keys.lua_command['a?'] = function()
  -- Temporarily change _G.buffer since ui.command_entry is the "active" buffer.
  local orig_buffer = _G.buffer
  _G.buffer = ui.command_entry
  textadept.editing.show_documentation()
  _G.buffer = orig_buffer
end
if OSX or CURSES then
  -- UTF-8 input.
  keys.utf8_input = {
    ['\n'] = function()
      return ui.command_entry.finish_mode(function(code)
        buffer:add_text(utf8.char(tonumber(code, 16)))
      end)
    end
  }
  keys[OSX and 'mU' or 'mu'] = function()
    ui.command_entry.enter_mode('utf8_input')
  end
end

-- Keys for the command entry.
local ekeys = ui.command_entry.editing_keys.__index
ekeys.cf = function() ui.command_entry:char_right() end
ekeys.cb = function() ui.command_entry:char_left() end
ekeys.cn = function() ui.command_entry:line_down() end
ekeys.cp = function() ui.command_entry:line_up() end
ekeys.ca = function() ui.command_entry:vc_home() end
ekeys.ce = function() ui.command_entry:line_end() end
ekeys.cv = function() ui.command_entry:page_down() end
ekeys.cy = function() ui.command_entry:page_up() end
ekeys.ch = function() ui.command_entry:delete_back() end
ekeys.cd = function() ui.command_entry:clear() end
ekeys.cu = function() ui.command_entry:paste() end
ekeys.caa = function() ui.command_entry:select_all() end

return {}
