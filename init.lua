-- Copyright 2007-2023 Mitchell. See LICENSE.

if not CURSES then view:set_theme{font = 'Noto Sans', size = 12} end

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
textadept.run.build_commands['CMakeLists.txt'] = 'cmake --build build'
textadept.run.run_in_background = true

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
  '!.a', '!.o', '!.so', '!.zip', '!.tgz', '!.gz',
  -- Folders to exclude.
  '!/.hg', '!/.git/', '!/.cache', --
  '!CMakeFiles', '!*_autogen', '!*-build', '!*-subbuild', --
  '!images', --
  '!modules/debugger/build', --
  '!modules/file_diff/build', --
  '!modules/lsp/build', '!modules/lsp/doc', '!modules/lsp/pl', '!modules/lsp/ldoc',
  '!modules/lsp/logging', --
  '!modules/spellcheck/build', --
  '!scintilla-src/bin', '!scintilla-src/cocoa', '!scintilla-src/doc', '!scintilla-src/scripts',
  '!scintilla-src/test', '!scintilla-src/win32', --
  '!lexilla-src/access', '!lexilla-src/bin', '!lexilla-src/doc', '!lexilla-src/examples',
  '!lexilla-src/lexers', '!lexilla-src/scripts', '!lexilla-src/src', '!lexilla-src/test', --
  '!scintillua-src/docs', '!scintillua-src/lexers', '!scintillua-src/themes', --
  '!scinterm-src/docs', '!scinterm-src/jinx', --
  '!lua-src/doc', '!lua/src/lib/lpeg', '!lfs-src/docs', '!lfs-src/vc6', --
  '!cdk-src/c++', '!cdk-src/cli', '!cdk-src/demos', '!cdk-src/examples', '!cdk-src/man',
  '!cdk-src/package', --
  '!termkey-src/t', '!termkey-src/man'
}
io.quick_open_filters[_HOME] = ta_filter
ui.find.find_in_files_filters[_HOME] = ta_filter
textadept.run.test_commands[_HOME] = 'textadept -n -f -u /tmp -t -locale,-interactive'

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
  local debug_lua = WIN32 or (ui.dialogs.message{
    title = 'Lua?', text = 'Debug Lua too?', icon = 'dialog-question', button1 = '&Yes',
    button2 = '&No'
  } == 1)
  if debug_lua then
    args = {args}
    args[#args + 1] = string.format([[-e "package.path='%s/modules/debugger/lua/?.lua;%s'"]], _HOME,
      package.path)
    args[#args + 1] = string.format([[-e "package.cpath='%s/modules/debugger/lua/?.%s;%s'"]], _HOME,
      not WIN32 and 'so' or 'dll', package.cpath)
    args[#args + 1] = [[-e "_=require('mobdebug').coro()"]]
    args[#args + 1] = [[-e "_=require('mobdebug').start()"]]
    args = table.concat(args, ' ')
    -- Start the Lua debugger after the C debugger, but before the program starts (the program
    -- tries to connect to the debug socket on startup). If 'failed to establish debug connection'
    -- errors are happening, try lowering the timeout value.
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
  if debugger.start('ansi_c', _HOME .. '/build/textadept', args) then debugger.continue('ansi_c') end
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

keys[not OSX and 'ctrl+o' or 'cmd+o'] = require('open_file_mode')
keys[not OSX and 'ctrl+f' or 'cmd+f'] =
  textadept.menu.menubar[_L['Search']][_L['Find Incremental']][2]
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

for _, lexer in ipairs{'ansi_c', 'cpp'} do
  local snip = snippets[lexer]
  -- Lua Standard library.
  snip.lai = 'lua_absindex'
  snip.lap = 'lua_atpanic'
  snip.larith = 'lua_arith'
  snip.lcat = 'lua_concat'
  snip.lc = 'lua_call'
  snip.lcmp = 'lua_compare'
  snip.lcp = 'lua_copy'
  snip.lcs = 'lua_checkstack'
  snip.lct = 'lua_createtable'
  snip.lgf = 'lua_getfield'
  snip.lgg = 'lua_getglobal'
  snip.lgi = 'lua_geti'
  snip.lgmt = 'lua_getmetatable'
  snip.lgt = 'lua_gettable'
  snip.lgtop = 'lua_gettop'
  snip.lguv = 'lua_getuservalue'
  snip.lib = 'lua_isboolean'
  snip.licf = 'lua_iscfunction'
  snip.lif = 'lua_isfunction'
  snip.lii = 'lua_isinteger'
  snip.lilu = 'lua_islightuserdata'
  snip.lin = 'lua_isnumber'
  snip.linil = 'lua_isnil'
  snip.linone = 'lua_isnone'
  snip.linonen = 'lua_isnoneornil'
  snip.lins = 'lua_insert'
  snip.lint = 'lua_Integer'
  snip.lis = 'lua_isstring'
  snip.lit = 'lua_istable'
  snip.liu = 'lua_isuserdata'
  snip.liy = 'lua_isyieldable'
  snip.llen = 'lua_len'
  snip.ln = 'lua_next'
  snip.lnt = 'lua_newtable'
  snip.lnth = 'lua_newthread'
  snip.lnu = '(%3 *)lua_newuserdata(%1(L), %2(sizeof(%3(struct))))'
  snip.lnum = 'lua_Number'
  snip.lpb = 'lua_pushboolean'
  snip.lpcc = 'lua_pushcclosure'
  snip.lpcf = 'lua_pushcfunction'
  snip.lpc = 'lua_pcall'
  snip.lpg = 'lua_pushglobaltable'
  snip.lpi = 'lua_pushinteger'
  snip.lplit = 'lua_pushliteral'
  snip.lpls = 'lua_pushlstring'
  snip.lplu = 'lua_pushlightuserdata'
  snip.lpn = 'lua_pushnumber'
  snip.lpnil = 'lua_pushnil'
  snip.lpop = 'lua_pop'
  snip.lps = 'lua_pushstring'
  snip.lpth = 'lua_pushthread'
  snip.lpv = 'lua_pushvalue'
  snip.lre = 'lua_rawequal'
  snip.lrepl = 'lua_replace'
  snip.lr = 'lua_register'
  snip.lrg = 'lua_rawget'
  snip.lrgi = 'lua_rawgeti'
  snip.lrgp = 'lua_rawgetp'
  snip.lrlen = 'lua_rawlen'
  snip.lrm = 'lua_remove'
  snip.lrs = 'lua_rawset'
  snip.lrsi = 'lua_rawseti'
  snip.lrsp = 'lua_rawsetp'
  snip.lsf = 'lua_setfield'
  snip.lsg = 'lua_setglobal'
  snip.lsi = 'lua_seti'
  snip.ls = 'lua_State'
  snip.lsmt = 'lua_setmetatable'
  snip.lst = 'lua_settable'
  snip.lsuv = 'lua_setuservalue'
  snip.ltb = 'lua_toboolean'
  snip.ltcf = 'lua_tocfunction'
  snip.lt = 'lua_type'
  snip.lti = 'lua_tointeger'
  snip.ltls = 'lua_tolstring'
  snip.ltn = 'lua_tonumber'
  snip.lts = 'lua_tostring'
  snip.ltth = 'lua_tothread'
  snip.ltu = '(%3 *)lua_touserdata(%1(L), %2(index))'
  snip.luvi = 'lua_upvalueindex'
  -- Auxiliary library.
  snip.llac = 'luaL_argcheck'
  snip.llach = 'luaL_addchar(&%1(buf), %2(c))'
  snip.llae = 'luaL_argerror'
  snip.llals = 'luaL_addlstring(&%1(buf), %2(s), %3(len))'
  snip.llas = 'luaL_addstring(&%1(buf), %2(s))'
  snip.llasz = 'luaL_addsize(&%1(buf), %2(n))'
  snip.llav = 'luaL_addvalue(&%1(buf))'
  snip.llbi = 'luaL_buffinit(%1(L), &%2(buf))'
  snip.llbis = 'luaL_buffinitsize(%1(L), &%2(buf), %3(size))'
  snip.llb = 'luaL_Buffer'
  snip.llca = 'luaL_checkany'
  snip.llci = 'luaL_checkinteger'
  snip.llcls = 'luaL_checklstring'
  snip.llcm = 'luaL_callmeta'
  snip.llcn = 'luaL_checknumber'
  snip.llcs = 'luaL_checkstring'
  snip.llct = 'luaL_checktype'
  snip.llcu = '(%4 *)luaL_checkudata(%1(L), %2(arg), %3(mt_name))'
  snip.lldf = 'luaL_dofile'
  snip.llds = 'luaL_dostring'
  snip.llerr = 'luaL_error'
  snip.llgmf = 'luaL_getmetafield'
  snip.llgmt = 'luaL_getmetatable'
  snip.llgs = 'luaL_gsub'
  snip.llgst = 'luaL_getsubtable'
  snip.lllen = 'luaL_len'
  snip.lllf = 'luaL_loadfile'
  snip.llls = 'luaL_loadstring'
  snip.llnmt = 'luaL_newmetatable'
  snip.llns = 'luaL_newstate'
  snip.lloi = 'luaL_optinteger'
  snip.llol = 'luaL_openlibs'
  snip.llon = 'luaL_optnumber'
  snip.llos = 'luaL_optstring'
  snip.llpb = 'luaL_prepbuffer(&%1(buf))'
  snip.llpbs = 'luaL_prepbuffersize(&%1(buf), %2(size))'
  snip.llpr = 'luaL_pushresult(&%1(buf))'
  snip.llprs = 'luaL_pushresultsize(&%1(buf), %2(size))'
  snip.llref = 'luaL_ref'
  snip.llsmt = 'luaL_setmetatable'
  snip.lltu = '(%4 *)luaL_testudata(%1(L), %2(arg), %3(mt_name))'
  snip.lluref = 'luaL_unref'
  -- Other.
  snip.lf = [[static int %1(func)(lua_State *%2(L)) {
    %0
    return %3(0);
  }]]
end

-- Load Lua snippets, autocompletion and documentation files, and REPL module.
local snip = snippets.lua
-- Textadept.
snip.L = "_L['%1']"
-- Scintilla.
snip.banc = 'buffer.anchor'
snip.bca = 'buffer.char_at[%1(pos)]'
snip.bcp = 'buffer.current_pos'
snip.bgcl = 'buffer:get_cur_line'
snip.bgl = 'buffer:get_lexer'
snip.bgp = 'buffer:goto_pos'
snip.bgst = 'buffer:get_sel_text'
snip.bgt = 'buffer:get_text'
snip.blep = 'buffer.line_end_position[%1(line)]'
snip.blfp = 'buffer:line_from_position'
snip.bpfl = 'buffer:position_from_line'
snip.brs = 'buffer:replace_sel'
snip.brt = 'buffer:replace_target'
snip.bsa = 'buffer.style_at[%1(pos)]'
snip.bsele = 'buffer.selection_end'
snip.bsels = 'buffer.selection_start'
snip.bss = 'buffer:set_sel'
snip.bst = 'buffer:set_target_range'
snip.bte = 'buffer.target_end'
snip.btr = 'buffer:text_range'
snip.bts = 'buffer.target_start'
snip.buf = 'buffer'
snip.bwep = 'buffer:word_end_position'
snip.bwsp = 'buffer:word_start_position'
-- Lua REPL.
require('lua_repl')

-- Settings for Scintillua development.
textadept.run.test_commands['/home/mitchell/code/scintillua'] = 'lua tests.lua'
