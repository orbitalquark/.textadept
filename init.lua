-- Copyright 2007-2020 Mitchell. See LICENSE.

if not CURSES then
  view:set_theme('light', {font = 'Ubuntu', size = 13})
end

view.h_scroll_bar, view.v_scroll_bar = false, false

ui.tabs = false
ui.find.highlight_all_matches = true

textadept.editing.highlight_words = textadept.editing.HIGHLIGHT_SELECTED
textadept.editing.auto_enclose = true
-- Always strip trailing spaces, except in patch files.
local function set_strip_trailing_spaces()
  textadept.editing.strip_trailing_spaces = buffer.lexer_language ~= 'diff'
end
events.connect(events.LEXER_LOADED, set_strip_trailing_spaces)
events.connect(events.BUFFER_AFTER_SWITCH, set_strip_trailing_spaces)
events.connect(events.VIEW_AFTER_SWITCH, set_strip_trailing_spaces)
lexer.detect_extensions.luadoc = 'lua'

-- Audio cue on build success or failure.
events.connect(events.BUILD_OUTPUT, function(output)
  local status = output:match('^> exit status: (%d+)')
  if not status then return end
  local wav = tonumber(status) == 0 and 'leveled_up2.wav' or 'sorry.wav'
  os.spawn('mpv /home/mitchell/config/sounds/' .. wav)
end)

-- Core settings for Textadept development.
local ta_filter = {
  -- Extensions to exclude.
  '!.a', '!.o', '!.so', '!.dll', '!.zip', '!.tgz', '!.gz', '!.exe', '!.osx', '!.orig', '!.rej',
  -- Files to exclude.
  '!api$', '![^c]tags$',
  -- Folders to exclude.
  '!/.hg$', '!/.git$', '!/.cache', --
  '!CMakeFiles', '!autogen', '!%-build', '!%-subbuild', --
  '!images', --
  '!modules/debugger/luasocket', --
  '!modules/spellcheck/hunspell', --
  '!modules/yaml/libyaml', '!modules/yaml/lyaml', --
  '!scintilla%-src/bin', '!scintilla%-src/cocoa', '!scintilla%-src/doc', '!scintilla%-src/scripts',
  '!scintilla%-src/test', '!scintilla%-src/win32', --
  '!lexilla%-src/access', '!lexilla%-src/bin', '!lexilla%-src/doc', '!lexilla%-src/examples',
  '!lexilla%-src/lexers', '!lexilla%-src/scripts', '!lexilla%-src/src', '!lexilla%-src/test', --
  '!scintillua%-src/docs', '!scintillua%-src/lexers', '!scintillua%-src/themes', --
  '!scinterm%-src/docs', '!scinterm%-src/jinx', --
  '!lua%-src/doc', '!lua/src/lib/lpeg', '!lfs%-src/docs', '!lfs%-src/vc6', --
  '!cdk%-src/c%+%+', '!cdk%-src/cli', '!cdk%-src/demos', '!cdk%-src/examples', '!cdk%-src/man',
  '!cdk%-src/package', --
  '!termkey%-src/t/', '!termkey%-src/man'
}
io.quick_open_filters[_HOME] = ta_filter
ui.find.find_in_files_filters[_HOME] = ta_filter
textadept.run.build_commands[_HOME] = string.format('cmake --build %s -j', _HOME .. '/build')
textadept.run.test_commands[_HOME] = 'textadept -n -f -t -locale,-interactive'

-- VCS diff of current file.
local m_file = textadept.menu.menubar[_L['File']]
table.insert(m_file, #m_file - 1, {''}) -- before Quit
table.insert(m_file, #m_file - 1, {
  'VCS Diff', function()
    local root = io.get_project_root()
    if not buffer.filename or not root then return end
    local diff
    if lfs.attributes(root .. '/.hg') then
      diff = os.spawn('hg diff "' .. buffer.filename .. '"', root):read('a')
    elseif lfs.attributes(root .. '/.git') then
      diff = os.spawn('git diff "' .. buffer.filename .. '"', root):read('a')
    else
      return
    end
    local buffer = buffer.new()
    buffer:set_lexer('diff')
    buffer:add_text(diff)
    buffer:goto_pos(1)
    buffer:set_save_point()
  end
})

-- Ctags module.
local ctags = require('ctags')

-- Ctags settings for Textadept development.
local ta_tags = {_HOME .. '/modules/lua/ta_tags'}
local extra_tags = {}
local extra_modules = {
  'ctags', 'debugger', 'export', 'file_diff', 'format', 'lsp', 'lua_repl', 'open_file_mode',
  'spellcheck'
}
for _, name in ipairs(extra_modules) do
  extra_tags[#extra_tags + 1] = string.format('%s/modules/%s/tags', _HOME, name)
end
for _, tags in ipairs(extra_tags) do ta_tags[#ta_tags + 1] = tags end
ctags[_HOME] = ta_tags
ctags[_HOME .. '/src/scintilla'] = _HOME .. '/tags'
ctags[_HOME .. '/src/scintilla/curses'] = _HOME .. '/tags'
ctags[_USERHOME] = ta_tags
ctags.ctags_flags[_HOME] = table.concat({
  '-R', 'src', 'build/_deps/scintilla-src/gtk', 'build/_deps/scintilla-src/include',
  'build/_deps/scintilla-src/qt', 'build/_deps/scintilla-src/src',
  'build/_deps/lexilla-src/include', 'build/_deps/lexilla-src/lexlib', 'build/_deps/scinterm-src',
  'build/_deps/scintillua-src'
}, ' ')
ctags.api_commands[_HOME] = function()
  os.spawn(string.format('cmake --build %s/build --target luadoc', _HOME)):wait()
  return nil -- keep default behavior
end
-- Load tags and api for external modules.
events.connect(events.LEXER_LOADED, function(name)
  if name ~= 'lua' or _M.lua._loaded_extras then return end
  for _, tags in ipairs(extra_tags) do
    table.insert(_M.lua.tags, tags)
    table.insert(textadept.editing.api_files.lua, (tags:gsub('tags$', 'api')))
  end
  _M.lua._loaded_extras = true
end)
-- Load api for C/C++ files in _HOME.
local function ta_api() return (buffer.filename or ''):find(_HOME) and _HOME .. '/api' or nil end
table.insert(textadept.editing.api_files.ansi_c, ta_api)
table.insert(textadept.editing.api_files.cpp, ta_api)
table.insert(textadept.editing.api_files.cpp, _HOME .. '/modules/ansi_c/api')
table.insert(textadept.editing.api_files.cpp, _HOME .. '/modules/ansi_c/lua_api')

-- Spellcheck module.
require('spellcheck')

-- File diff module.
require('file_diff')

-- Language Server Protocol.
require('lsp')

-- Debugger module.
local debugger = require('debugger')

-- Debugger settings for Textadept development.
local debug_f = function(args)
  local debug_lua = WIN32 or
    (ui.dialogs.yesno_msgbox{title = 'Lua?', text = 'Debug Lua too?', icon = 'dialog-question'} == 1)
  if debug_lua then
    args = {args}
    args[#args + 1] = string.format([[-e "package.path='%s/modules/debugger/lua/?.lua;%s'"]], _HOME,
      package.path)
    args[#args + 1] = string.format([[-e "package.cpath='%s/modules/debugger/lua/?.%s;%s'"]], _HOME,
      not WIN32 and 'so' or 'dll', package.cpath)
    args[#args + 1] = [[-e "_=require('mobdebug').coro()"]]
    args[#args + 1] = [[-e "_=require('mobdebug').start()"]]
    args = table.concat(args, ' ')
    timeout(0.5, function()
      require('debugger.lua') -- load events
      if debugger.start('lua', '-') then debugger.continue('lua') end
    end)
  end
  if WIN32 then
    -- Cannot run gdb, so just run and debug Lua
    os.spawn(((arg[0] .. ' ' .. args):gsub('\\', '\\\\')))
    return
  end
  require('debugger.gdb').logging = true -- also loads events
  print('textadept', args)
  if debugger.start('ansi_c', 'textadept', args) then debugger.continue('ansi_c') end
end
debugger.project_commands[_HOME] = function()
  if CURSES then return end -- not possible
  ui.command_entry.run('Debug Textadept:', debug_f, 'bash', '-n -f')
  -- Do not return anything, let debug_f invoke the debug start command(s).
end

-- Format module.
local format = require('format')

-- Format settings for Textadept development.
table.insert(format.ignore_file_patterns, '/build/')

-- Add option for toggling menubar visibility.
local menubar_visible = false -- will be hidden on init
local m_view = textadept.menu.menubar[_L['View']]
m_view[#m_view + 1] = {''}
m_view[#m_view + 1] = {
  'Toggle _Menubar', function()
    menubar_visible = not menubar_visible
    textadept.menu.menubar = menubar_visible and textadept.menu.menubar or nil
  end
}

-- if not OSX then events.connect(events.INITIALIZED, function() textadept.menu.menubar = nil end) end

keys['ctrl+o'] = require('open_file_mode')
if OSX then
  keys['cmd+right'], keys['cmd+shift+right'] = buffer.word_right, buffer.word_right_extend
  keys['cmd+left'], keys['cmd+shift+left'] = buffer.word_left, buffer.word_left_extend
  keys['cmd+down'], keys['cmd+shift+down'] = buffer.para_down, buffer.para_down_extend
  keys['cmd+up'], keys['cmd+shift+up'] = buffer.para_up, buffer.para_up_extend
  keys['ctrl+cmd+right'] = buffer.word_part_right
  keys['ctrl+cmd+shift+right'] = buffer.word_part_right_extend
  keys['ctrl+cmd+left'] = buffer.word_part_left
  keys['ctrl+cmd+shift+left'] = buffer.word_part_left_extend
end

-- Language-specific settings.

-- Indent on 'Enter' when between auto-paired '{}' for C and C++.
events.connect(events.CHAR_ADDED, function(ch)
  if (buffer:get_lexer() ~= 'ansi_c' and buffer:get_lexer() ~= 'cpp') or ch ~= string.byte('\n') or
    not textadept.editing.auto_indent then return end
  local line = buffer:line_from_position(buffer.current_pos)
  if buffer:get_line(line - 1):find('{%s+$') and buffer:get_line(line):find('^%s*}') then
    buffer:new_line()
    buffer.line_indentation[line] = buffer.line_indentation[line - 1] + buffer.tab_width
    buffer:goto_pos(buffer.line_indent_position[line])
  end
end)

local wrap = require('snippet_wrapper')
for _, lexer in ipairs{'ansi_c', 'cpp'} do
  local snip = snippets[lexer]
  -- C Standard library.
  if lexer == 'ansi_c' then
    snip.mal = wrap('malloc')
    snip.cal = wrap('calloc')
    snip.real = wrap('realloc')
    snip.cp = wrap('strcpy')
    snip.mcp = wrap('memcpy')
    snip.ncp = wrap('strncpy')
    snip.cmp = wrap('strcmp')
    snip.ncmp = wrap('strncmp')
    snip.va = 'va_list %1(ap);\nva_start(%1, %2(lastparam))\n%0\nva_end(%1)'
    snip.vaa = 'va_arg(%1(ap), %2(int));'
  end
  -- Lua Standard library.
  snip.lai = wrap('lua_absindex')
  snip.lap = wrap('lua_atpanic')
  snip.larith = wrap('lua_arith')
  snip.lcat = wrap('lua_concat')
  snip.lc = wrap('lua_call')
  snip.lcmp = wrap('lua_compare')
  snip.lcp = wrap('lua_copy')
  snip.lcs = wrap('lua_checkstack')
  snip.lct = wrap('lua_createtable')
  snip.lgf = wrap('lua_getfield')
  snip.lgg = wrap('lua_getglobal')
  snip.lgi = wrap('lua_geti')
  snip.lgmt = wrap('lua_getmetatable')
  snip.lgt = wrap('lua_gettable')
  snip.lgtop = wrap('lua_gettop')
  snip.lguv = wrap('lua_getuservalue')
  snip.lib = wrap('lua_isboolean')
  snip.licf = wrap('lua_iscfunction')
  snip.lif = wrap('lua_isfunction')
  snip.lii = wrap('lua_isinteger')
  snip.lilu = wrap('lua_islightuserdata')
  snip.lin = wrap('lua_isnumber')
  snip.linil = wrap('lua_isnil')
  snip.linone = wrap('lua_isnone')
  snip.linonen = wrap('lua_isnoneornil')
  snip.lins = wrap('lua_insert')
  snip.lint = 'lua_Integer'
  snip.lis = wrap('lua_isstring')
  snip.lit = wrap('lua_istable')
  snip.liu = wrap('lua_isuserdata')
  snip.liy = wrap('lua_isyieldable')
  snip.llen = wrap('lua_len')
  snip.ln = wrap('lua_next')
  snip.lnt = wrap('lua_newtable')
  snip.lnth = wrap('lua_newthread')
  snip.lnu = '(%3 *)lua_newuserdata(%1(L), %2(sizeof(%3(struct))))'
  snip.lnum = 'lua_Number'
  snip.lpb = wrap('lua_pushboolean')
  snip.lpcc = wrap('lua_pushcclosure')
  snip.lpcf = wrap('lua_pushcfunction')
  snip.lpc = wrap('lua_pcall')
  snip.lpg = wrap('lua_pushglobaltable')
  snip.lpi = wrap('lua_pushinteger')
  snip.lplit = wrap('lua_pushliteral')
  snip.lpls = wrap('lua_pushlstring')
  snip.lplu = wrap('lua_pushlightuserdata')
  snip.lpn = wrap('lua_pushnumber')
  snip.lpnil = wrap('lua_pushnil')
  snip.lpop = wrap('lua_pop')
  snip.lps = wrap('lua_pushstring')
  snip.lpth = wrap('lua_pushthread')
  snip.lpv = wrap('lua_pushvalue')
  snip.lre = wrap('lua_rawequal')
  snip.lrepl = wrap('lua_replace')
  snip.lr = wrap('lua_register')
  snip.lrg = wrap('lua_rawget')
  snip.lrgi = wrap('lua_rawgeti')
  snip.lrgp = wrap('lua_rawgetp')
  snip.lrlen = wrap('lua_rawlen')
  snip.lrm = wrap('lua_remove')
  snip.lrs = wrap('lua_rawset')
  snip.lrsi = wrap('lua_rawseti')
  snip.lrsp = wrap('lua_rawsetp')
  snip.lsf = wrap('lua_setfield')
  snip.lsg = wrap('lua_setglobal')
  snip.lsi = wrap('lua_seti')
  snip.ls = 'lua_State'
  snip.lsmt = wrap('lua_setmetatable')
  snip.lst = wrap('lua_settable')
  snip.lsuv = wrap('lua_setuservalue')
  snip.ltb = wrap('lua_toboolean')
  snip.ltcf = wrap('lua_tocfunction')
  snip.lt = wrap('lua_type')
  snip.lti = wrap('lua_tointeger')
  snip.ltls = wrap('lua_tolstring')
  snip.ltn = wrap('lua_tonumber')
  snip.lts = wrap('lua_tostring')
  snip.ltth = wrap('lua_tothread')
  snip.ltu = '(%3 *)lua_touserdata(%1(L), %2(index))'
  snip.luvi = wrap('lua_upvalueindex')
  -- Auxiliary library.
  snip.llac = wrap('luaL_argcheck')
  snip.llach = 'luaL_addchar(&%1(buf), %2(c))'
  snip.llae = wrap('luaL_argerror')
  snip.llals = 'luaL_addlstring(&%1(buf), %2(s), %3(len))'
  snip.llas = 'luaL_addstring(&%1(buf), %2(s))'
  snip.llasz = 'luaL_addsize(&%1(buf), %2(n))'
  snip.llav = 'luaL_addvalue(&%1(buf))'
  snip.llbi = 'luaL_buffinit(%1(L), &%2(buf))'
  snip.llbis = 'luaL_buffinitsize(%1(L), &%2(buf), %3(size))'
  snip.llb = 'luaL_Buffer'
  snip.llca = wrap('luaL_checkany')
  snip.llci = wrap('luaL_checkinteger')
  snip.llcls = wrap('luaL_checklstring')
  snip.llcm = wrap('luaL_callmeta')
  snip.llcn = wrap('luaL_checknumber')
  snip.llcs = wrap('luaL_checkstring')
  snip.llct = wrap('luaL_checktype')
  snip.llcu = '(%4 *)luaL_checkudata(%1(L), %2(arg), %3(mt_name))'
  snip.lldf = wrap('luaL_dofile')
  snip.llds = wrap('luaL_dostring')
  snip.llerr = wrap('luaL_error')
  snip.llgmf = wrap('luaL_getmetafield')
  snip.llgmt = wrap('luaL_getmetatable')
  snip.llgs = wrap('luaL_gsub')
  snip.llgst = wrap('luaL_getsubtable')
  snip.lllen = wrap('luaL_len')
  snip.lllf = wrap('luaL_loadfile')
  snip.llls = wrap('luaL_loadstring')
  snip.llnmt = wrap('luaL_newmetatable')
  snip.llns = wrap('luaL_newstate')
  snip.lloi = wrap('luaL_optinteger')
  snip.llol = wrap('luaL_openlibs')
  snip.llon = wrap('luaL_optnumber')
  snip.llos = wrap('luaL_optstring')
  snip.llpb = 'luaL_prepbuffer(&%1(buf))'
  snip.llpbs = 'luaL_prepbuffersize(&%1(buf), %2(size))'
  snip.llpr = 'luaL_pushresult(&%1(buf))'
  snip.llprs = 'luaL_pushresultsize(&%1(buf), %2(size))'
  snip.llref = wrap('luaL_ref')
  snip.llsmt = wrap('luaL_setmetatable')
  snip.lltu = '(%4 *)luaL_testudata(%1(L), %2(arg), %3(mt_name))'
  snip.lluref = wrap('luaL_unref')
  -- Other.
  snip.lf = [[static int %1(func)(lua_State *%2(L)) {
    %0
    return %3(0);
  }]]
end

-- Load Lua snippets, autocompletion and documentation files, and REPL module.
local snip = snippets.lua
-- Lua.
snip.cat = wrap('table.concat')
snip.afunc = 'function(%1(args))\n\t%0\nend'
snip.lfunc = 'local function %1(name)(%2(args))\n\t%0\nend'
snip.loc = 'local %1(name) = %2(value)'
snip.open = "local %1(f) = io.open(%2(file), '%3(r)')\n%0\n%1:close()"
snip.openif = "local %1(f) = io.open(%2(file), '%3(r)')\nif %1 then\n\t%0\n\t%1:close()\nend"
snip.popen = "local %1(p) = io.popen(%2(cmd))\n%0\n%1:close()"
-- Textadept.
snip.ta = 'textadept'
snip.tab = 'textadept.bookmarks'
snip.tae = 'textadept.editing'
snip.tam = 'textadept.menu'
snip.tar = 'textadept.run'
snip.tas = 'textadept.session'
snip.uice = 'ui.command_entry'
snip.uid = 'ui.dialogs'
snip.uif = 'ui.find'
snip.L = "_L['%1']"
-- Scintilla.
snip.banc = 'buffer.anchor'
snip.bca = 'buffer.char_at[%1(pos)]'
snip.bcp = 'buffer.current_pos'
snip.bgcl = wrap('buffer:get_cur_line')
snip.bgl = wrap('buffer:get_lexer')
snip.bgp = wrap('buffer:goto_pos')
snip.bgst = wrap('buffer:get_sel_text')
snip.bgt = wrap('buffer:get_text')
snip.blep = 'buffer.line_end_position[%1(line)]'
snip.blfp = wrap('buffer:line_from_position')
snip.bpfl = wrap('buffer:position_from_line')
snip.brs = wrap('buffer:replace_sel')
snip.brt = wrap('buffer:replace_target')
snip.bsa = 'buffer.style_at[%1(pos)]'
snip.bsele = 'buffer.selection_end'
snip.bsels = 'buffer.selection_start'
snip.bss = wrap('buffer:set_sel')
snip.bst = wrap('buffer:set_target_range')
snip.bte = 'buffer.target_end'
snip.btr = wrap('buffer:text_range')
snip.bts = 'buffer.target_start'
snip.buf = 'buffer'
snip.bwep = wrap('buffer:word_end_position')
snip.bwsp = wrap('buffer:word_start_position')
-- Lua REPL.
require('lua_repl')

-- Settings for Scintillua development.
textadept.run.test_commands['/home/mitchell/code/scintillua'] = 'lua tests.lua'
