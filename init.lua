-- Copyright 2007-2020 Mitchell mitchell.att.foicica.com. See LICENSE.

ui.tabs = false

textadept.editing.strip_trailing_spaces = true
textadept.file_types.extensions.luadoc = 'lua'

if not CURSES then
  view:set_theme(LINUX and 'dark' or 'light',
                 {font = 'DejaVu Sans Mono', fontsize = 12})
end
view.h_scroll_bar = false
view.v_scroll_bar = false
view.caret_period = 0
view.caret_style = view.CARETSTYLE_BLOCK | view.CARETSTYLE_OVERSTRIKE_BLOCK |
  view.CARETSTYLE_BLOCK_AFTER
view.edge_mode = not CURSES and view.EDGE_LINE or view.EDGE_BACKGROUND
view.edge_column = 80

-- Settings for Textadept development.
io.quick_open_filters[_HOME] = {
  -- Extensions to exclude.
  '!.a', '!.o', '!.so', '!.dll', '!.zip', '!.tgz', '!.gz', '!.exe', '!.osx',
  '!.orig', '!.rej',
  -- Folders to exclude.
  '![/\\]%.hg$',
  '!doc/api', '!doc/book',
  '!gtdialog/cdk',
  '!images',
  '!lua/doc', '!lua/src/lib/lpeg', '!lua/src/lib/lfs',
  '!modules/file_diff/diff_match_patch', '!modules/file_diff/test',
  '!modules/spellcheck/hunspell',
  '!modules/yaml/src',
  '!releases',
  '!scintilla/cocoa', '!scintilla/doc', '!scintilla/lua',
  '!scintilla/qt', '!scintilla/scripts', '!scintilla/test', '!scintilla/win32',
  '!src/cdk', '!src/win32', '!src/gtkosx', '!src/termkey',
  -- Files to exclude.
  '!api$', '![^c]tags$'
}
ui.find.find_in_files_filters[_HOME] = io.quick_open_filters[_HOME]
textadept.run.build_commands[_HOME] = function()
  local button, target = ui.dialogs.standard_inputbox{
    title = _L['Command'], informative_text = 'make -C src'
  }
  if button == 1 then return 'make -C src '..target end
end

-- Filter for ~/.textadept.
io.quick_open_filters[_USERHOME] = {
  '!.a', '!.o', '!.so', '!.dll', '!.zip', '!.tgz', '!.gz', -- extensions
  '!/%.hg$' -- folders
}

-- Settings for Scintilla LongTerm3 development.
local scintilla_dir = '/home/mitchell/code/scintilla'
textadept.run.build_commands[scintilla_dir] = 'make -f check.mak'

-- Hide margins when writing e-mails and commit messages.
events.connect(events.FILE_OPENED, function(filename)
  if filename and
     (filename:find('pico%.%d+$') or filename:find('hg%-editor')) then
    for i = 1, view.margins do view.margin_width_n[i] = 0 end
    view.wrap_mode = view.WRAP_WHITESPACE
    view.edge_mode = view.EDGE_NONE
  end
end)

-- VCS diff of current file.
local m_file = textadept.menu.menubar[_L['File']]
table.insert(m_file, #m_file - 1, {''}) -- before Quit
table.insert(m_file, #m_file - 1, {'VCS Diff', function()
  local root = io.get_project_root()
  if not buffer.filename or not root then return end
  local diff
  if lfs.attributes(root..'/.hg') then
    diff = os.spawn('hg diff "'..buffer.filename..'"', root):read('a')
  elseif lfs.attributes(root..'/.git') then
    diff = os.spawn('git diff "'..buffer.filename..'"', root):read('a')
  else
    return
  end
  local buffer = buffer.new()
  buffer:set_lexer('diff')
  buffer:add_text(diff)
  buffer:goto_pos(1)
  buffer:set_save_point()
end})

-- Run shell commands at project root.
local m_tools = textadept.menu.menubar[_L['Tools']]
table.insert(m_tools, 8 --[[after Build]], {'Run Project Command', function()
  local root = io.get_project_root()
  if not root then return end
  local button, command = ui.dialogs.standard_inputbox{
    title = _L['Command'], informative_text = root
  }
  if button == 1 then os.spawn(command, root, ui.print, ui.print) end
end})

-- History module.
require('history')

-- Ctags module.
local ctags = require('ctags')
ctags[_HOME] = _HOME..'/modules/lua/ta_tags'
ctags[_HOME..'/src/scintilla'] = _HOME..'/tags'
ctags[_USERHOME] = _HOME..'/modules/lua/ta_tags'

-- Settings for Textadept development.
ctags.ctags_flags[_HOME] = table.concat({
  '-R', 'src/textadept.c', 'src/gtdialog/gtdialog.c',
  'src/scintilla/curses', 'src/scintilla/gtk', 'src/scintilla/include',
  'src/scintilla/lexlib', 'src/scintilla/src',
  'src/scintilla/lexers/LexLPeg.cxx'
}, ' ')
ctags.api_commands[_HOME] = function()
  os.spawn('make -C '.._HOME..'/src luadoc'):wait()
  return nil -- keep default behavior
end
local api_files = textadept.editing.api_files
local function ta_api()
  return (buffer.filename or ''):find(_HOME) and _HOME..'/api' or nil
end
api_files.ansi_c[#api_files.ansi_c + 1] = ta_api
api_files.cpp[#api_files.cpp + 1] = ta_api

-- Spellcheck module.
require('spellcheck')

-- File diff module.
require('file_diff')

-- Language Server Protocol.
require('lsp')

-- Debugger module.
local debugger = require('debugger')
-- Add an extra debug menu entry for debugging Textadept.
local m_debug = textadept.menu.menubar[_L['Debug']]
if m_debug[#m_debug][1] ~= '' then m_debug[#m_debug + 1] = {''} end
m_debug[#m_debug + 1] = {'Debug Text_adept...', function()
  local button = ui.dialogs.yesno_msgbox{
    title = 'Lua?', text = 'Debug Lua too?', icon = 'gtk-dialog-question'
  }
  if button == -1 then return end
  require('debugger.ansi_c').logging = true
  require('debugger.lua')
  local args = '-n -f'
  if button == 1 then
    args = args..[[ -e '_=require("debugger.lua.mobdebug").start()']]
  end
  debugger.start('ansi_c', '/home/mitchell/code/textadept/textadept', args)
  debugger.continue('ansi_c')
  if button ~= 1 then return end
  timeout(0.1, function()
    if debugger.start('lua', '-') then debugger.continue('lua') end
  end)
end}

-- Add option for toggling menubar visibility.
local menubar_visible = false -- will be hidden on init
local m_view = textadept.menu.menubar[_L['View']]
m_view[#m_view + 1] = {''}
m_view[#m_view + 1] = {'Toggle _Menubar', function()
  menubar_visible = not menubar_visible
  textadept.menu.menubar = menubar_visible and textadept.menu.menubar or nil
end}

events.connect(events.INITIALIZED, function() textadept.menu.menubar = nil end)

-- Language-specific settings.

-- Indent on 'Enter' when between auto-paired '{}' for C and C++.
events.connect(events.CHAR_ADDED, function(ch)
  if (buffer:get_lexer() ~= 'ansi_c' and buffer:get_lexer() ~= 'cpp') or
     ch ~= 10 or not textadept.editing.auto_indent then
    return
  end
  local line = buffer:line_from_position(buffer.current_pos)
  if buffer:get_line(line - 1):find('{%s+$') and
     buffer:get_line(line):find('^%s*}') then
    buffer:new_line()
    buffer.line_indentation[line] = buffer.line_indentation[line - 1] +
                                    buffer.tab_width
    buffer:goto_pos(buffer.line_indent_position[line])
  end
end)

-- Load C snippets.
events.connect(events.LEXER_LOADED, function(lexer)
  if lexer ~= 'ansi_c' or snippets.ansi_c.mal then return end
  local snippets = snippets.ansi_c
  local wrap = require('snippet_wrapper')
  -- C Standard library.
  snippets.mal = wrap('malloc')
  snippets.cal = wrap('calloc')
  snippets.real = wrap('realloc')
  snippets.cp = wrap('strcpy')
  snippets.mcp = wrap('memcpy')
  snippets.ncp = wrap('strncpy')
  snippets.cmp = wrap('strcmp')
  snippets.ncmp = wrap('strncmp')
  snippets.va = 'va_list %1(ap);\nva_start(%1, %2(lastparam))\n%0\nva_end(%1)'
  snippets.vaa = 'va_arg(%1(ap), %2(int));'
  -- Lua Standard library.
  snippets.lai = wrap('lua_absindex')
  snippets.lap = wrap('lua_atpanic')
  snippets.larith = wrap('lua_arith')
  snippets.lcat = wrap('lua_concat')
  snippets.lc = wrap('lua_call')
  snippets.lcmp = wrap('lua_compare')
  snippets.lcp = wrap('lua_copy')
  snippets.lcs = wrap('lua_checkstack')
  snippets.lct = wrap('lua_createtable')
  snippets.lgf = wrap('lua_getfield')
  snippets.lgg = wrap('lua_getglobal')
  snippets.lgi = wrap('lua_geti')
  snippets.lgmt = wrap('lua_getmetatable')
  snippets.lgt = wrap('lua_gettable')
  snippets.lgtop = wrap('lua_gettop')
  snippets.lguv = wrap('lua_getuservalue')
  snippets.lib = wrap('lua_isboolean')
  snippets.licf = wrap('lua_iscfunction')
  snippets.lif = wrap('lua_isfunction')
  snippets.lii = wrap('lua_isinteger')
  snippets.lilu = wrap('lua_islightuserdata')
  snippets.lin = wrap('lua_isnumber')
  snippets.linil = wrap('lua_isnil')
  snippets.linone = wrap('lua_isnone')
  snippets.linonen = wrap('lua_isnoneornil')
  snippets.lins = wrap('lua_insert')
  snippets.lint = 'lua_Integer'
  snippets.lis = wrap('lua_isstring')
  snippets.lit = wrap('lua_istable')
  snippets.liu = wrap('lua_isuserdata')
  snippets.liy = wrap('lua_isyieldable')
  snippets.llen = wrap('lua_len')
  snippets.ln = wrap('lua_next')
  snippets.lnt = wrap('lua_newtable')
  snippets.lnth = wrap('lua_newthread')
  snippets.lnu = '(%3 *)lua_newuserdata(%1(L), %2(sizeof(%3(struct))))'
  snippets.lnum = 'lua_Number'
  snippets.lpb = wrap('lua_pushboolean')
  snippets.lpcc = wrap('lua_pushcclosure')
  snippets.lpcf = wrap('lua_pushcfunction')
  snippets.lpc = wrap('lua_pcall')
  snippets.lpg = wrap('lua_pushglobaltable')
  snippets.lpi = wrap('lua_pushinteger')
  snippets.lplit = wrap('lua_pushliteral')
  snippets.lpls = wrap('lua_pushlstring')
  snippets.lplu = wrap('lua_pushlightuserdata')
  snippets.lpn = wrap('lua_pushnumber')
  snippets.lpnil = wrap('lua_pushnil')
  snippets.lpop = wrap('lua_pop')
  snippets.lps = wrap('lua_pushstring')
  snippets.lpth = wrap('lua_pushthread')
  snippets.lpv = wrap('lua_pushvalue')
  snippets.lre = wrap('lua_rawequal')
  snippets.lrepl = wrap('lua_replace')
  snippets.lr = wrap('lua_register')
  snippets.lrg = wrap('lua_rawget')
  snippets.lrgi = wrap('lua_rawgeti')
  snippets.lrgp = wrap('lua_rawgetp')
  snippets.lrlen = wrap('lua_rawlen')
  snippets.lrm = wrap('lua_remove')
  snippets.lrs = wrap('lua_rawset')
  snippets.lrsi = wrap('lua_rawseti')
  snippets.lrsp = wrap('lua_rawsetp')
  snippets.lsf = wrap('lua_setfield')
  snippets.lsg = wrap('lua_setglobal')
  snippets.lsi = wrap('lua_seti')
  snippets.ls = 'lua_State'
  snippets.lsmt = wrap('lua_setmetatable')
  snippets.lst = wrap('lua_settable')
  snippets.lsuv = wrap('lua_setuservalue')
  snippets.ltb = wrap('lua_toboolean')
  snippets.ltcf = wrap('lua_tocfunction')
  snippets.lt = wrap('lua_type')
  snippets.lti = wrap('lua_tointeger')
  snippets.ltls = wrap('lua_tolstring')
  snippets.ltn = wrap('lua_tonumber')
  snippets.lts = wrap('lua_tostring')
  snippets.ltth = wrap('lua_tothread')
  snippets.ltu = '(%3 *)lua_touserdata(%1(L), %2(index))'
  snippets.luvi = wrap('lua_upvalueindex')
  -- Auxiliary library.
  snippets.llac = wrap('luaL_argcheck')
  snippets.llach = 'luaL_addchar(&%1(buf), %2(c))'
  snippets.llae = wrap('luaL_argerror')
  snippets.llals = 'luaL_addlstring(&%1(buf), %2(s), %3(len))'
  snippets.llas = 'luaL_addstring(&%1(buf), %2(s))'
  snippets.llasz = 'luaL_addsize(&%1(buf), %2(n))'
  snippets.llav = 'luaL_addvalue(&%1(buf))'
  snippets.llbi = 'luaL_buffinit(%1(L), &%2(buf))'
  snippets.llbis = 'luaL_buffinitsize(%1(L), &%2(buf), %3(size))'
  snippets.llb = 'luaL_Buffer'
  snippets.llca = wrap('luaL_checkany')
  snippets.llci = wrap('luaL_checkinteger')
  snippets.llcls = wrap('luaL_checklstring')
  snippets.llcm = wrap('luaL_callmeta')
  snippets.llcn = wrap('luaL_checknumber')
  snippets.llcs = wrap('luaL_checkstring')
  snippets.llct = wrap('luaL_checktype')
  snippets.llcu = '(%4 *)luaL_checkudata(%1(L), %2(arg), %3(mt_name))'
  snippets.lldf = wrap('luaL_dofile')
  snippets.llds = wrap('luaL_dostring')
  snippets.llerr = wrap('luaL_error')
  snippets.llgmf = wrap('luaL_getmetafield')
  snippets.llgmt = wrap('luaL_getmetatable')
  snippets.llgs = wrap('luaL_gsub')
  snippets.llgst = wrap('luaL_getsubtable')
  snippets.lllen = wrap('luaL_len')
  snippets.lllf = wrap('luaL_loadfile')
  snippets.llls = wrap('luaL_loadstring')
  snippets.llnmt = wrap('luaL_newmetatable')
  snippets.llns = wrap('luaL_newstate')
  snippets.lloi = wrap('luaL_optinteger')
  snippets.llol = wrap('luaL_openlibs')
  snippets.llon = wrap('luaL_optnumber')
  snippets.llos = wrap('luaL_optstring')
  snippets.llpb = 'luaL_prepbuffer(&%1(buf))'
  snippets.llpbs = 'luaL_prepbuffersize(&%1(buf), %2(size))'
  snippets.llpr = 'luaL_pushresult(&%1(buf))'
  snippets.llprs = 'luaL_pushresultsize(&%1(buf), %2(size))'
  snippets.llref = wrap('luaL_ref')
  snippets.llsmt = wrap('luaL_setmetatable')
  snippets.lltu = '(%4 *)luaL_testudata(%1(L), %2(arg), %3(mt_name))'
  snippets.lluref = wrap('luaL_unref')
  -- Other.
  snippets.lf = [[static int %1(func)(lua_State *%2(L)) {
    %0
    return %3(0);
  }]]
end)

-- Load Lua snippets, autocompletion and documentation files, and REPL module.
events.connect(events.LEXER_LOADED, function(lexer)
  if lexer ~= 'lua' or snippets.lua.cat then return end
  local snippets = snippets.lua
  local wrap = require('snippet_wrapper')
  -- Lua.
  snippets.cat = wrap('table.concat')
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
  snippets.L = "_L['%1']"
  -- Scintilla.
  snippets.banc = 'buffer.anchor'
  snippets.bca = 'buffer.char_at[%1(pos)]'
  snippets.bcp = 'buffer.current_pos'
  snippets.bgcl = wrap('buffer:get_cur_line')
  snippets.bgl = wrap('buffer:get_lexer')
  snippets.bgp = wrap('buffer:goto_pos')
  snippets.bgst = wrap('buffer:get_sel_text')
  snippets.bgt = wrap('buffer:get_text')
  snippets.blep = 'buffer.line_end_position[%1(line)]'
  snippets.blfp = wrap('buffer:line_from_position')
  snippets.bpfl = wrap('buffer:position_from_line')
  snippets.brs = wrap('buffer:replace_sel')
  snippets.brt = wrap('buffer:replace_target')
  snippets.bsa = 'buffer.style_at[%1(pos)]'
  snippets.bsele = 'buffer.selection_end'
  snippets.bsels = 'buffer.selection_start'
  snippets.bss = wrap('buffer:set_sel')
  snippets.bst = wrap('buffer:set_target_range')
  snippets.bte = 'buffer.target_end'
  snippets.btr = wrap('buffer:text_range')
  snippets.bts = 'buffer.target_start'
  snippets.buf = 'buffer'
  snippets.bwep = wrap('buffer:word_end_position')
  snippets.bwsp = wrap('buffer:word_start_position')
  -- Love framework autocompletion and documentation.
  _M.lua.tags[#_M.lua.tags + 1] = _USERHOME..'/modules/lua/love_0.9.2f_tags'
  local lua_api_files = textadept.editing.api_files.lua
  lua_api_files[#lua_api_files + 1] = _USERHOME..'/modules/lua/love_0.9.2f_api'
  _M.lua.expr_types['^love%.audio%.newSource%('] = 'Source'
  _M.lua.expr_types['^love%.filesystem%.newFile%('] = 'File'
  _M.lua.expr_types['^love%.graphics%.newCanvas%('] = 'Canvas'
  _M.lua.expr_types['^love%.graphics%.newFont%('] = 'Font'
  _M.lua.expr_types['^love%.graphics%.newImageFont%('] = 'Font'
  _M.lua.expr_types['^love%.graphics%.newMesh%('] = 'Mesh'
  _M.lua.expr_types['^love%.graphics%.newImage%('] = 'Image'
  _M.lua.expr_types['^love%.graphics%.newParticleSystem%('] = 'ParticleSystem'
  _M.lua.expr_types['^love%.graphics%.newQuad%('] = 'Quad'
  _M.lua.expr_types['^love%.graphics%.newShader%('] = 'Shader'
  _M.lua.expr_types['^love%.graphics%.newSpriteBatch%('] = 'SpriteBatch'
  _M.lua.expr_types['^love%.image%.newCompressedData%('] = 'CompressedData'
  _M.lua.expr_types['^love%.image%.newImageData%('] = 'ImageData'
  _M.lua.expr_types['^love%.joystick%.getJoysticks%('] = 'Joystick'
  _M.lua.expr_types['^love%.math%.newRandomGenerator%('] = 'RandomGenerator'
  _M.lua.expr_types['^love%.math%.newBezierCurve%('] = 'BezierCurve'
  _M.lua.expr_types['^love%.mouse%.getSystemCursor%('] = 'Cursor'
  _M.lua.expr_types['^love%.mouse%.newCursor%('] = 'Cursor'
  _M.lua.expr_types['^love%.physics%.newBody%('] = 'Body'
  _M.lua.expr_types['^love%.physics%.newChainShape%('] = 'ChainShape'
  _M.lua.expr_types['^love%.physics%.newCircleShape%('] = 'CircleShape'
  _M.lua.expr_types['^love%.physics%.newEdgeShape%('] = 'EdgeShape'
  _M.lua.expr_types['^love%.physics%.newDistanceJoint%('] = 'DistanceJoint'
  _M.lua.expr_types['^love%.physics%.newFixture%('] = 'Fixture'
  _M.lua.expr_types['^love%.physics%.newFrictionJoint%('] = 'FrictionJoint'
  _M.lua.expr_types['^love%.physics%.newGearJoint%('] = 'GearJoint'
  _M.lua.expr_types['^love%.physics%.newMouseJoint%('] = 'MouseJoint'
  _M.lua.expr_types['^love%.physics%.newPolygonShape%('] = 'PolygonShape'
  _M.lua.expr_types['^love%.physics%.newRectangleShape%('] = 'PolygonShape'
  _M.lua.expr_types['^love%.physics%.newPrismaticJoint%('] = 'PrismaticJoint'
  _M.lua.expr_types['^love%.physics%.newPulleyJoint%('] = 'PulleyJoint'
  _M.lua.expr_types['^love%.physics%.newRevoluteJoint%('] = 'RevoluteJoint'
  _M.lua.expr_types['^love%.physics%.newRopeJoint%('] = 'RopeJoint'
  _M.lua.expr_types['^love%.physics%.newChainShape%('] = 'Shape'
  _M.lua.expr_types['^love%.physics%.newEdgeShape%('] = 'Shape'
  _M.lua.expr_types['^love%.physics%.newPolygonShape%('] = 'Shape'
  _M.lua.expr_types['^love%.physics%.newRectangleShape%('] = 'Shape'
  _M.lua.expr_types['^love%.physics%.newWeldJoint%('] = 'WeldJoint'
  _M.lua.expr_types['^love%.physics%.newWorld%('] = 'World'
  _M.lua.expr_types['^love%.sound%.newSoundData%('] = 'SoundData'
  _M.lua.expr_types['^love%.thread%.newThread%('] = 'Thread'
  _M.lua.expr_types['^love%.thread%.getChannel%('] = 'Channel'
  _M.lua.expr_types['^love%.thread%.newChannel%('] = 'Channel'
end)
-- Lua REPL.
require('lua_repl')
