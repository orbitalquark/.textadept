-- Copyright 2007-2013 Mitchell mitchell.att.foicica.com. See LICENSE.

ui.tabs = false
if not CURSES then
  ui.set_theme(not WIN32 and not OSX and 'dark' or 'light',
               {font = 'DejaVu Sans Mono', fontsize = 11})
end

_M.file_browser = require 'file_browser'
keys[not CURSES and 'ae' or 'me'] = _M.file_browser.init

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
  'textadeptjit',
  'textadept32',
  '%d%d.*%.html$'
}
textadept.run.build_commands[_HOME] = function()
  local button, target = ui.dialogs.standard_inputbox{
    title = _L['Command'], informative_text = 'make -C src'
  }
  if button == 1 then return 'make -C src '..target end
end

_M.ctags = require 'ctags'
_M.ctags[_HOME] = _HOME..'/src/tags'
_M.ctags[_USERHOME] = _HOME..'/src/tags'
keys[not CURSES and 'a&' or 'm&'] = _M.ctags.goto_tag
keys[not CURSES and 'a*' or 'm*'] = function()
  local ok, name = ui.dialogs.inputbox{title = 'Goto Tag'}
  if ok == 1 then _M.ctags.goto_tag(name) end
end
keys[not CURSES and 'a,' or 'm,'] = {_M.ctags.goto_tag, nil, true} -- back
keys[not CURSES and 'a.' or 'm.'] = {_M.ctags.goto_tag, nil, false} -- forward
keys[not CURSES and 'ac' or 'mc'] = {textadept.editing.autocomplete, 'ctag'}

_M.spellcheck = require 'spellcheck'
--keys.f7 = {_M.spellcheck.check_spelling, true}
--keys.sf7 = _M.spellcheck.check_spelling
_M.file_diff = require 'file_diff'
--keys.f8 = _M.file_diff.start
--keys.adown = {_M.file_diff.goto_change, true}
--keys.aup = _M.file_diff.goto_change
--keys.aleft = {_M.file_diff._M.file_differge, true}
--keys.aright = _M.file_diff._M.file_differge

textadept.editing.STRIP_TRAILING_SPACES = true
textadept.file_types.extensions.luadoc = 'lua'
