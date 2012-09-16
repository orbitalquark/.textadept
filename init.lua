_M.textadept = require 'textadept'

_M.file_browser = require 'file_browser'
keys[not NCURSES and 'ae' or 'me'] = _M.file_browser.init

_M.version_control = require 'version_control'
local vc = _M.version_control
keys[not NCURSES and 'caj' or 'cmj'] = vc.snapopen_project
keys[not NCURSES and 'aj' or 'mj'] = vc.command
keys[not NCURSES and 'cah' or 'cmh'] = { vc.snapopen_project, _HOME..'/' }
