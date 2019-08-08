-- Copyright 2019 Mitchell mitchell.att.foicica.com.

local M = {}

-- Localizations.
local _L = _L
if _L['Find in Pro_ject']:find('^No Localization') then
  _L['Find in Pro_ject'] = 'Find in Pro_ject'
  _L['_In Project'] = '_In Project'
  _L['No project found'] = 'No project found'
  _L['The current file does not belong to a project'] =
    'The current file does not belong to a project'
end

-- Flag that differentiates between "in project" search and "in files" search.
local find_in_project = false

-- Modify Search menu.
local m_search = textadept.menu.menubar[_L['_Search']]
-- Modify "Find" menu function to disable find in project features and update
-- the default key binding if necessary.
local find_f = m_search[_L['_Find']][2]
m_search[_L['_Find']][2] = function()
  find_in_project = false
  ui.find.in_files_label_text = _L['_In files']
  find_f()
end
if keys[not OSX and not CURSES and 'cf' or 'mf'] == find_f then
  keys[not OSX and not CURSES and 'cf' or 'mf'] = m_search[_L['_Find']][2]
end
-- Modify "Find in Files" menu function to disable find in project features and
-- update the default key binding if necessary.
local find_in_files_f = m_search[_L['Find in Fi_les']][2]
m_search[_L['Find in Fi_les']][2] = function()
  find_in_project = false
  ui.find.in_files_label_text = _L['_In files']
  find_in_files_f()
end
if not CURSES and keys[not OSX and 'cF' or 'mF'] == find_in_files_f then
  keys[not OSX and 'cF' or 'mF'] = m_search[_L['Find in Fi_les']][2]
end
-- Add "Find in Project" menu item.
for i = 1, #m_search do
  if m_search[i][1] == _L['Find in Fi_les'] then
    table.insert(m_search, i + 1, {_L['Find in Pro_ject'], function()
      if not io.get_project_root() then
        ui.dialogs.msgbox{
          title = _L['No project found'],
          informative_text = _L['The current file does not belong to a project']
        }
        return
      end
      find_in_project = true
      ui.find.in_files = true
      ui.find.in_files_label_text = _L['_In Project']
      ui.find.focus()
    end})
    break
  end
end

-- Perform find in project when necessary instead of the default find behavior.
events.connect(events.FIND, function(text)
  if not ui.find.in_files or not find_in_project or text == '' then return end
  ui.find.find_in_files(io.get_project_root())
  return true -- do not propagate
end, 1)

return M
