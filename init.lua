_M.textadept = require 'textadept'

_M.file_browser = require 'file_browser'
keys[not CURSES and 'ae' or 'me'] = _M.file_browser.init

_M.version_control = require 'version_control'
local vc = _M.version_control
keys[not CURSES and 'caj' or 'cmj'] = vc.snapopen_project
keys[not CURSES and 'aj' or 'mj'] = vc.command
keys[not CURSES and 'cah' or 'cmh'] = {vc.snapopen_project, _HOME..'/'}
if CURSES then keys.cmg = keys.cmh end
