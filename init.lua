-- Copyright 2007-2024 Mitchell. See LICENSE.

if not CURSES then view:set_theme{font = 'Ubuntu', size = 13} end

view.h_scroll_bar, view.v_scroll_bar = false, false
buffer.tab_width = 2

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

-- Audio cue on build success or failure.
events.connect(events.BUILD_OUTPUT, function(output)
	local status = output:match('^> exit status: (%d+)')
	if not status then return end
	local wav = tonumber(status) == 0 and 'leveled_up2.wav' or 'sorry.wav'
	os.spawn(string.format('mpv %s/config/sounds/%s', os.getenv('HOME'), wav))
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
	snip.lai = 'lua_absindex(${1:L}, ${2:idx})'
	snip.lap = 'lua_atpanic(${1:L}, ${2:panicf})'
	snip.larith =
		'lua_arith(${1:L}, LUA_OP${|ADD,SUB,MUL,DIV,IDIV,MOD,POW,UNM,BNOT,BAND,BOR,BXOR,SHL,SHR|})'
	snip.lcat = 'lua_concat(${1:L}, ${2:n})'
	snip.lc = 'lua_call(${1:L}, ${2:nargs}, ${3:nresults})'
	snip.lcmp = 'lua_compare(${1:L}, ${2:index1}, ${3:index2}, LUA_OP${4|EQ,LT,LE|})'
	snip.lcp = 'lua_copy(${1:L}, ${2:fromidx}, ${3:toidx})'
	snip.lcs = 'lua_checkstack(${1:L}, ${2:n})'
	snip.lct = 'lua_createtable(${1:L}, ${2:narr}, ${3:nrec})'
	snip.lgf = 'lua_getfield(${1:L}, ${2:index}, ${3:k})'
	snip.lgg = 'lua_getglobal(${1:L}, ${2:name})'
	snip.lgi = 'lua_geti(${1:L}, ${2:index}, ${3:i})'
	snip.lgmt = 'lua_getmetatable(${1:L}, ${2:index})'
	snip.lgt = 'lua_gettable(${1:L}, ${2:index})'
	snip.lgtop = 'lua_gettop(${1:L})'
	snip.lguv = 'lua_getiuservalue(${1:L}, ${2:index}, ${3:n})'
	snip.lib = 'lua_isboolean(${1:L}, ${2:index})'
	snip.licf = 'lua_iscfunction(${1:L}, ${2:index})'
	snip.lif = 'lua_isfunction(${1:L}, ${2:index})'
	snip.lii = 'lua_isinteger(${1:L}, ${2:index})'
	snip.lilu = 'lua_islightuserdata(${1:L}, ${2:index})'
	snip.lin = 'lua_isnumber(${1:L}, ${2:index})'
	snip.linil = 'lua_isnil(${1:L}, ${2:index})'
	snip.linone = 'lua_isnone(${1:L}, ${2:index})'
	snip.linonen = 'lua_isnoneornil(${1:L}, ${2:index})'
	snip.lins = 'lua_insert(${1:L}, ${2:index})'
	snip.lint = 'lua_Integer'
	snip.lis = 'lua_isstring(${1:L}, ${2:index})'
	snip.lit = 'lua_istable(${1:L}, ${2:index})'
	snip.liu = 'lua_isuserdata(${1:L}, ${2:index})'
	snip.liy = 'lua_isyieldable(${1:L}, ${2:index})'
	snip.llen = 'lua_len(${1:L}, ${2:index})'
	snip.ln = 'lua_next(${1:L}, ${2:index})'
	snip.lnt = 'lua_newtable(${1:L})'
	snip.lnth = 'lua_newthread(${1:L})'
	snip.lnu = '($3 *)lua_newuserdatauv(${1:L}, ${2:sizeof(${3:struct}}), ${3:nuvalue})'
	snip.lnum = 'lua_Number'
	snip.lpb = 'lua_pushboolean(${1:L}, ${2:b})'
	snip.lpcc = 'lua_pushcclosure(${1:L}, ${2:fn}, ${3:n})'
	snip.lpcf = 'lua_pushcfunction(${1:L}, ${2:f})'
	snip.lpc = 'lua_pcall(${1:L}, ${2:nargs}, ${3:nresults}, ${4:msgh})'
	snip.lpg = 'lua_pushglobaltable(${1:L})'
	snip.lpi = 'lua_pushinteger(${1:L}, ${2:n})'
	snip.lplit = 'lua_pushliteral(${1:L}, "$2")'
	snip.lpls = 'lua_pushlstring(${1:L}, ${2:s}, ${3:len})'
	snip.lplu = 'lua_pushlightuserdata(${1:L}, ${2:p})'
	snip.lpn = 'lua_pushnumber(${1:L}, ${2:n})'
	snip.lpnil = 'lua_pushnil(${1:L})'
	snip.lpop = 'lua_pop(${1:L}, ${2:n})'
	snip.lps = 'lua_pushstring(${1:L}, ${2:s})'
	snip.lpth = 'lua_pushthread(${1:L})'
	snip.lpv = 'lua_pushvalue(${1:L}, ${2:index})'
	snip.lre = 'lua_rawequal(${1:L}, ${2:index1}, ${3:index2})'
	snip.lrepl = 'lua_replace(${1:L}, ${2:index})'
	snip.lr = 'lua_register(${1:L}, ${2:name}, ${3:f})'
	snip.lrg = 'lua_rawget(${1:L}, ${2:index})'
	snip.lrgi = 'lua_rawgeti(${1:L}, ${2:index}, ${3:n})'
	snip.lrgp = 'lua_rawgetp(${1:L}, ${2:index}, ${3:p})'
	snip.lrlen = 'lua_rawlen(${1:L}, ${2:index})'
	snip.lrm = 'lua_remove(${1:L}, ${2:index})'
	snip.lrs = 'lua_rawset(${1:L}, ${2:index})'
	snip.lrsi = 'lua_rawseti(${1:L}, ${2:index}, ${3:i})'
	snip.lrsp = 'lua_rawsetp(${1:L}, ${2:index}, ${3:p})'
	snip.lsf = 'lua_setfield(${1:L}, ${2:index}, ${3:k})'
	snip.lsg = 'lua_setglobal(${1:L}, ${2:name})'
	snip.lsi = 'lua_seti(${1:L}, ${2:index}, ${3:n})'
	snip.ls = 'lua_State'
	snip.lsmt = 'lua_setmetatable(${1:L}, ${2:index})'
	snip.lst = 'lua_settable(${1:L}, ${2:index})'
	snip.lsuv = 'lua_setiuservalue(${1:L}, ${2:index}, ${3:n})'
	snip.ltb = 'lua_toboolean(${1:L}, ${2:index})'
	snip.ltcf = 'lua_tocfunction(${1:L}, ${2:index})'
	snip.lt = 'lua_type(${1:L}, ${2:index})'
	snip.lti = 'lua_tointeger(${1:L}, ${2:index})'
	snip.ltls = 'lua_tolstring(${1:L}, ${2:index}, &${3:len})'
	snip.ltn = 'lua_tonumber(${1:L}, ${2:index})'
	snip.lts = 'lua_tostring(${1:L}, ${2:index})'
	snip.ltth = 'lua_tothread(${1:L}, ${2:index})'
	snip.ltu = '($3 *)lua_touserdata(${1:L}, ${2:index})'
	snip.luvi = 'lua_upvalueindex(${1:i})'
	-- Auxiliary library.
	snip.llac = 'luaL_argcheck(${1:L}, ${2:cond}, ${3:arg}, ${4:extramsg})'
	snip.llach = 'luaL_addchar(&${1:buf}, ${2:c})'
	snip.llae = 'luaL_argerror(${1:L}, ${2:arg}, ${3:extramsg})'
	snip.llals = 'luaL_addlstring(&${1:buf}, ${2:s}, ${3:len})'
	snip.llas = 'luaL_addstring(&${1:buf}, ${2:s})'
	snip.llasz = 'luaL_addsize(&${1:buf}, ${2:n})'
	snip.llav = 'luaL_addvalue(&${1:buf})'
	snip.llbi = 'luaL_buffinit(${1:L}, &${2:buf})'
	snip.llbis = 'luaL_buffinitsize(${1:L}, &${2:buf}, ${3:size})'
	snip.llb = 'luaL_Buffer'
	snip.llca = 'luaL_checkany(${1:L}, ${2:arg})'
	snip.llci = 'luaL_checkinteger(${1:L}, ${2:arg})'
	snip.llcls = 'luaL_checklstring(${1:L}, ${2:arg}, &${3:l})'
	snip.llcm = 'luaL_callmeta(${1:L}, ${2:obj}, ${3:e})'
	snip.llcn = 'luaL_checknumber(${1:L}, ${2:arg})'
	snip.llcs = 'luaL_checkstring(${1:L}, ${2:arg})'
	snip.llct = 'luaL_checktype(${1:L}, ${2:arg}, ${3:t})'
	snip.llcu = '($4 *)luaL_checkudata(${1:L}, ${2:arg}, ${3:tname})'
	snip.lldf = 'luaL_dofile(${1:L}, ${2:filename})'
	snip.llds = 'luaL_dostring(${1:L}, ${2:str})'
	snip.llerr = 'luaL_error(${1:L}, ${2:fmt}${3:, $4})'
	snip.llgmf = 'luaL_getmetafield(${1:L}, ${2:obj}, ${3:e})'
	snip.llgmt = 'luaL_getmetatable(${1:L}, ${2:tname})'
	snip.llgs = 'luaL_gsub(${1:L}, ${2:s}, ${3:p}, ${4:r})'
	snip.llgst = 'luaL_getsubtable(${1:L}, ${2:idx}, ${3:fname})'
	snip.lllen = 'luaL_len(${1:L}, ${2:index})'
	snip.lllf = 'luaL_loadfile(${1:L}, ${2:filename})'
	snip.llls = 'luaL_loadstring(${1:L}, ${2:s})'
	snip.llnmt = 'luaL_newmetatable(${1:L}, ${2:tname})'
	snip.llns = 'luaL_newstate()'
	snip.lloi = 'luaL_optinteger(${1:L}, ${2:arg}, ${3:d})'
	snip.llol = 'luaL_openlibs(${1:L})'
	snip.llon = 'luaL_optnumber(${1:L}, ${2:arg}, ${3:d})'
	snip.llos = 'luaL_optstring(${1:L}, ${2:arg}, ${3:d})'
	snip.llpb = 'luaL_prepbuffer(&${1:buf})'
	snip.llpbs = 'luaL_prepbuffsize(&${1:buf}, ${2:size})'
	snip.llpr = 'luaL_pushresult(&${1:buf})'
	snip.llprs = 'luaL_pushresultsize(&${1:buf}, ${2:size})'
	snip.llref = 'luaL_ref(${1:L}, ${2:LUA_REGISTRYINDEX})'
	snip.llsmt = 'luaL_setmetatable(${1:L}, ${2:tname})'
	snip.lltu = '($4 *)luaL_testudata(${1:L}, ${2:arg}, ${3:tname})'
	snip.lluref = 'luaL_unref(${1:L}, ${2:LUA_REGISTRYINDEX}, ${3:ref})'
	-- Other.
	snip.lf = [[static int ${1:func}(lua_State *${2:L}) {
    $0
    return ${3:0};
  }]]
end

-- Load Lua snippets, autocompletion and documentation files, and REPL module.
local snip = snippets.lua
-- Textadept.
snip.L = "_L['$1']"
-- Scintilla.
snip.banc = 'buffer.anchor'
snip.bca = 'buffer.char_at[${1:pos}]'
snip.bcp = 'buffer.current_pos'
snip.bgcl = 'buffer:get_cur_line()'
snip.bgl = 'buffer:get_lexer()'
snip.bgp = 'buffer:goto_pos(${1:pos})'
snip.bgst = 'buffer:get_sel_text()'
snip.bgt = 'buffer:get_text()'
snip.blep = 'buffer.line_end_position[${1:line}]'
snip.blfp = 'buffer:line_from_position(${1:pos})'
snip.bpfl = 'buffer:position_from_line(${1:line})'
snip.brs = 'buffer:replace_sel(${1:text})'
snip.brt = 'buffer:replace_target(${1:text})'
snip.bsa = 'buffer.style_at[${1:pos}]'
snip.bsele = 'buffer.selection_end'
snip.bsels = 'buffer.selection_start'
snip.bss = 'buffer:set_sel(${1:start_pos}, ${2:end_pos})'
snip.bst = 'buffer:set_target_range(${1:start_pos}, ${2:end_pos})'
snip.bte = 'buffer.target_end'
snip.btr = 'buffer:text_range(${1:start_pos}, ${2:end_pos})'
snip.bts = 'buffer.target_start'
snip.buf = 'buffer'
snip.bwep = 'buffer:word_end_position(${1:pos}, ${2:only_word_chars})'
snip.bwsp = 'buffer:word_start_position(${1:pos}, ${2:only_word_chars})'
-- Lua REPL.
require('lua_repl')

-- Settings for Scintillua development.
textadept.run.test_commands[os.getenv('HOME') .. '/code/scintillua'] = 'lua tests.lua'
