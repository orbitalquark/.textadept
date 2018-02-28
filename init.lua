-- Copyright 2007-2017 Mitchell mitchell.att.foicica.com. See LICENSE.

ui.tabs = false

textadept.editing.strip_trailing_spaces = true
textadept.file_types.extensions.luadoc = 'lua'

if not CURSES then
  buffer.set_theme(LINUX and 'dark' or 'light',
                   {font = 'DejaVu Sans Mono', fontsize = 14})
end
buffer.h_scroll_bar = false
buffer.v_scroll_bar = false
buffer.caret_period = 0
buffer.caret_style = buffer.CARETSTYLE_BLOCK
buffer.edge_mode = not CURSES and buffer.EDGE_LINE or buffer.EDGE_BACKGROUND
buffer.edge_column = 80

events.connect(events.LEXER_LOADED, function(lexer)
  if lfs.attributes(_USERHOME..'/modules/'..lexer..'/post_init.lua') then
    require(lexer..'/post_init')
  end
end)

-- Settings for Textadept development.
io.quick_open_filters[_HOME] = {
  extensions = {
    'a', 'o', 'so', 'dll', 'zip', 'tgz', 'gz', 'exe', 'osx', 'orig', 'rej'
  },
  folders = {
    '%.hg$',
    'doc/api', 'doc/book', 'doc/doxygen',
    'gtdialog/cdk',
    'images',
    'lua/doc', 'lua/src/lib/lpeg', 'lua/src/lib/lfs',
    'modules/yaml/src',
    'releases',
    'scintilla/cocoa', 'scintilla/doc', 'scintilla/lexers', 'scintilla/qt',
    'scintilla/scripts', 'scintilla/test', 'scintilla/win32',
    'src/cdk', 'src/luajit', 'src/win.*', 'src/gtkosx', 'src/termkey', 'src/tre'
  },
  'textadept$',
  'textadept.*curses',
  'textadeptjit'
}
textadept.run.build_commands[_HOME] = function()
  local button, target = ui.dialogs.standard_inputbox{
    title = _L['Command'], informative_text = 'make -C src'
  }
  if button == 1 then return 'make -C src '..target end
end

io.quick_open_filters[_USERHOME] = {
  extensions = {'a', 'o', 'so', 'dll', 'zip', 'tgz', 'gz'},
  folders = {'%.hg$', 'spellcheck/hunspell'}
}

-- Hide margins when writing e-mails and commit messages.
events.connect(events.FILE_OPENED, function(filename)
  if filename and
     (filename:find('pico%.%d+$') or filename:find('hg%-editor')) then
    for i = 0, buffer.margins - 1 do
      buffer.margin_width_n[i] = 0
    end
    buffer.wrap_mode = buffer.WRAP_WHITESPACE
    buffer.edge_mode = buffer.EDGE_NONE
  end
end)

-- Mercurial diff of current file.
local m_file = textadept.menu.menubar[_L['_File']]
table.insert(m_file, #m_file - 1, {''})
table.insert(m_file, #m_file - 1, {'Hg Diff', function()
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
end})

-- Ctags module.
_M.ctags = require('ctags')
_M.ctags[_HOME] = _HOME..'/src/tags'
_M.ctags[_USERHOME] = _HOME..'/src/tags'
local m_ctags = textadept.menu.menubar[_L['_Search']]['_Ctags']
keys[not CURSES and 'a.' or 'm.'] = _M.ctags.goto_tag
-- TODO: m_ctags['G_oto Ctag...'][2]
keys[not CURSES and 'a,' or 'm,'] = m_ctags['Jump _Back'][2]
-- TODO: m_ctags['Jump _Forward'][2]
-- TODO: m_ctags['_Autocomplete Tag'][2]

-- Spellcheck module.
_M.spellcheck = require('spellcheck')
--keys.f7 = m_tools[_L['Spe_lling']][_L['_Check Spelling...']][2]
--keys.sf7 = m_tools[_L['Spe_lling']][_L['_Mark Misspelled Words']][2]

-- File diff module.
_M.file_diff = require('file_diff')
--keys.f8 = _M.file_diff.start
--keys.adown = m_tools[_L['_Compare Files']][_L['_Next Change']][2]
--keys.aup = m_tools[_L['_Compare Files']][_L['_Previous Change']][2]
--keys.aleft = m_tools[_L['_Compare Files']][_L['Merge _Left']][2]
--keys.aright = m_tools[_L['_Compare Files']][_L['Merge _Right']][2]

events.connect(events.INITIALIZED, function() textadept.menu.menubar = nil end)
