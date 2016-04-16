-- Copyright 2007-2016 Mitchell mitchell.att.foicica.com. See LICENSE.

ui.tabs = false
if not CURSES then
  ui.set_theme(not WIN32 and not OSX and 'dark' or 'light',
               {font = 'DejaVu Sans Mono', fontsize = 11})
end

textadept.editing.STRIP_TRAILING_SPACES = true
textadept.file_types.extensions.luadoc = 'lua'

-- Settings for Textadept development.
io.snapopen_filters[_HOME] = {
  extensions = {'a', 'o', 'dll', 'zip', 'tgz', 'gz', 'exe', 'osx'},
  folders = {
    '%.hg$',
    'doc/api', 'doc/book', 'doc/doxygen',
    'images',
    'ipk',
    'releases',
    'scintilla/cocoa', 'scintilla/doc', 'scintilla/lexers', 'scintilla/qt',
    'scintilla/test', 'scintilla/win32',
    'src/cdk', 'src/luajit', 'src/win.*', 'src/gtkosx', 'src/termkey',
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

-- File browser module.
_M.file_browser = require('file_browser')
keys[not CURSES and 'ae' or 'me'] = function()
  _M.file_browser.init(io.get_project_root())
end

-- Ctags module.
_M.ctags = require('ctags')
_M.ctags[_HOME] = _HOME..'/src/tags'
_M.ctags[_USERHOME] = _HOME..'/src/tags'
local m_ctags = textadept.menu.menubar[_L['_Search']]['_Ctags']
keys[not CURSES and 'a&' or 'm&'] = _M.ctags.goto_tag
keys[not CURSES and 'a*' or 'm*'] = m_ctags['G_oto Ctag...'][2]
keys[not CURSES and 'a,' or 'm,'] = m_ctags['Jump _Back'][2]
keys[not CURSES and 'a.' or 'm.'] = m_ctags['Jump _Forward'][2]
keys[not CURSES and 'aC' or 'mC'] = m_ctags['_Autocomplete Tag'][2]

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
