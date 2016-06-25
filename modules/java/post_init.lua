
events.connect(event.LEXER_LOADED, function(lang)
  if lang ~= 'java' then return end
  buffer.use_tabs = true
  textadept.editing.strip_trailing_spaces = false
end

local e = textadept.editing
-- Indent on 'Enter' when between auto-paired '{}'.
events.connect(events.CHAR_ADDED, function(ch)
  if buffer:get_lexer() == 'java' and ch == 10 and e.auto_indent then
    local line = buffer:line_from_position(buffer.current_pos)
    if buffer:get_line(line - 1):find('{%s+$') and
       buffer:get_line(line):find('^%s*}') then
      buffer:new_line()
      buffer.line_indentation[line] = buffer.line_indentation[line - 1] +
                                      buffer.tab_width
      buffer:goto_pos(buffer.line_indent_position[line])
    end
  end
end)

