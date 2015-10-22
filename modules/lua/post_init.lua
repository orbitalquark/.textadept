
-- Define Lua snippets.
local snippets = snippets.lua
local func = require('snippet_extras').func
-- Lua.
snippets.cat = func('table.concat')
snippets.afunc = 'function(%1(args))\n\t%0\nend'
snippets.lfunc = 'local function %1(name)(%2(args))\n\t%0\nend'
snippets.loc = 'local %1(name) = %2(value)'
snippets.open = "local %1(f) = io.open(%2(file), '%3(r)')\n%0\n%1:close()"
snippets.openif = "local %1(f) = io.open(%2(file), '%3(r)')\n"..
                  "if %1 then\n\t%0\n\t%1:close()\nend"
snippets.popen = "local %1(p) = io.popen(%2(cmd))\n%0\n%1:close()"
-- Textadept.
snippets.ta = 'textadept'
snippets.tab = 'textadept.bookmarks'
snippets.tae = 'textadept.editing'
snippets.taft = 'textadept.file_types'
snippets.tam = 'textadept.menu'
snippets.tar = 'textadept.run'
snippets.tas = 'textadept.session'
snippets.uice = 'ui.command_entry'
snippets.uid = 'ui.dialogs'
snippets.uif = 'ui.find'
-- Scintilla.
snippets.banc = 'buffer.anchor'
snippets.bca = 'buffer.char_at[%1(pos)]'
snippets.bcp = 'buffer.current_pos'
snippets.bgcl = func('buffer:get_cur_line')
snippets.bgl = func('buffer:get_lexer')
snippets.bgp = func('buffer:goto_pos')
snippets.bgst = func('buffer:get_sel_text')
snippets.bgt = func('buffer:get_text')
snippets.blep = 'buffer.line_end_position[%1(line)]'
snippets.blfp = func('buffer:line_from_position')
snippets.bpfl = func('buffer:position_from_line')
snippets.brs = func('buffer:replace_sel')
snippets.brt = func('buffer:replace_target')
snippets.bsa = 'buffer.style_at[%1(pos)]'
snippets.bsele = 'buffer.selection_end'
snippets.bsels = 'buffer.selection_start'
snippets.bss = func('buffer:set_sel')
snippets.bst = func('buffer:set_target_range')
snippets.bte = 'buffer.target_end'
snippets.btr = func('buffer:text_range')
snippets.bts = 'buffer.target_start'
snippets.buf = 'buffer'
snippets.bwep = func('buffer:word_end_position')
snippets.bwsp = func('buffer:word_start_position')
