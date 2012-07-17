require 'textadept'

_M.file_browser = require 'file_browser'
keys[not NCURSES and 'ae' or 'me'] = _M.file_browser.init

_M.version_control = require 'version_control'
keys[not NCURSES and 'caj' or 'cmj'] = _M.version_control.snapopen_project
keys[not NCURSES and 'aj' or 'mj'] = _M.version_control.command
