
function _M.java.set_buffer_properties()
  buffer.use_tabs = true
  _M.textadept.editing.STRIP_WHITESPACE_ON_SAVE = false
end

local e = _M.textadept.editing
-- Indent on 'Enter' when between auto-paired '{}'.
events.connect(events.CHAR_ADDED, function(ch)
  if buffer:get_lexer() == 'java' and ch == 10 and e.AUTOINDENT then
    local buffer = buffer
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

