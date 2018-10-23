-- Copyright 2018 Mitchell mitchell.att.foicica.com. See LICENSE.

if _L['Paste Re_indent']:find('^No Localization') then
  _L['Paste Re_indent'] = 'Paste Re_indent'
end

-- Pastes the text from the clipboard, taking into account the buffer's
-- indentation settings and the indentation of the current and preceding lines.
local function paste_reindent()
  local line = buffer:line_from_position(buffer.selection_start)
  -- Strip leading indentation from clipboard text.
  local text = ui.clipboard_text
  if not buffer.encoding then text = text:iconv('ISO-8859-1', 'UTF-8') end
  local lead = text:match('^[ \t]*')
  if lead ~= '' then text = text:sub(#lead + 1):gsub('\n'..lead, '\n') end
  -- Change indentation to match buffer indentation settings.
  local tab_width = math.huge
  text = text:gsub('\n([ \t]+)', function(indentation)
    if indentation:find('^\t') then
      if buffer.use_tabs then return '\n'..indentation end
      return '\n'..indentation:gsub('\t', string.rep(' ', buffer.tab_width))
    else
      tab_width = math.min(tab_width, #indentation)
      local indent = math.floor(#indentation / tab_width)
      local spaces = string.rep(' ', math.fmod(#indentation, tab_width))
      if buffer.use_tabs then return '\n'..string.rep('\t', indent)..spaces end
      return '\n'..string.rep(' ', buffer.tab_width):rep(indent)..spaces
    end
  end)
  -- Re-indent according to whichever of the current and preceding lines has the
  -- higher indentation amount. However, if the preceding line is a fold header,
  -- indent by an extra level.
  local i = line - 1
  while i >= 0 and buffer:get_line(i):find('^[\r\n]+$') do i = i - 1 end
  if i < 0 or buffer.line_indentation[i] < buffer.line_indentation[line] then
    i = line
  end
  local indentation = buffer:text_range(buffer:position_from_line(i),
                                        buffer.line_indent_position[i])
  local fold_header = i ~= line and
                      buffer.fold_level[i] & buffer.FOLDLEVELHEADERFLAG > 0
  if fold_header then
    indentation = indentation..(buffer.use_tabs and '\t' or
                                string.rep(' ', buffer.tab_width))
  end
  text = text:gsub('\n', '\n'..indentation)
  -- Paste the text and adjust first and last line indentation accordingly.
  local start_indent = buffer.line_indentation[i]
  if fold_header then start_indent = start_indent + buffer.tab_width end
  local end_line = buffer:line_from_position(buffer.selection_end)
  local end_indent = buffer.line_indentation[end_line]
  local end_column = buffer.column[buffer.selection_end]
  buffer:begin_undo_action()
  buffer:replace_sel(text)
  buffer.line_indentation[line] = start_indent
  if text:find('\n') then
    local line = buffer:line_from_position(buffer.current_pos)
    buffer.line_indentation[line] = end_indent
    buffer:goto_pos(buffer:find_column(line, end_column))
  end
  buffer:end_undo_action()
end

-- Add a menu item.
local m_edit = textadept.menu.menubar[_L['_Edit']]
for i = 1, #m_edit do
  if m_edit[i][1] == _L['_Paste'] then
    table.insert(m_edit, i + 1, {_L['Paste Re_indent'], paste_reindent})
    break
  end
end

return paste_reindent
