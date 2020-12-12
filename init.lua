-- Copyright 2007-2020 Mitchell. See LICENSE.

if not CURSES then
  view:set_theme(
    LINUX and 'dark' or 'light', {font = 'DejaVu Sans Mono', size = 12})
end

view.h_scroll_bar, view.v_scroll_bar = false, false
view.caret_period = 0
view.caret_style = view.CARETSTYLE_BLOCK | view.CARETSTYLE_OVERSTRIKE_BLOCK |
  view.CARETSTYLE_BLOCK_AFTER
view.edge_mode = not CURSES and view.EDGE_LINE or view.EDGE_BACKGROUND
view.edge_column = 80

ui.tabs = false
ui.find.highlight_all_matches = true

textadept.editing.auto_pairs[string.byte('`')] = '`'
textadept.editing.typeover_chars[string.byte('`')] = true
textadept.editing.highlight_words = textadept.editing.HIGHLIGHT_SELECTED
textadept.editing.auto_enclose = true
textadept.file_types.extensions.luadoc = 'lua'

-- Settings for Textadept development.
io.quick_open_filters[_HOME] = {
  -- Extensions to exclude.
  '!.a', '!.o', '!.so', '!.dll', '!.zip', '!.tgz', '!.gz', '!.exe', '!.osx',
  '!.orig', '!.rej',
  -- Folders to exclude.
  '!/%.hg$', '!/.git$',
  '!images',
  '!lua/doc', '!lua/src/lib/lpeg', '!lua/src/lib/lfs',
  '!modules/spellcheck/hunspell',
  '!modules/yaml/libyaml', '!modules/yaml/lyaml',
  '!releases',
  '!scintilla/bin', '!scintilla/cocoa', '!scintilla/doc', '!scintilla/qt',
  '!scintilla/scripts', '!scintilla/test', '!scintilla/win32',
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

-- Hide margins when writing e-mails and commit messages.
events.connect(events.FILE_OPENED, function(filename)
  if filename and
     (filename:find('tmpmsg%-0x%x+') or filename:find('hg%-editor')) then
    for i = 1, view.margins do view.margin_width_n[i] = 0 end
    view.wrap_mode = view.WRAP_WHITESPACE
    view.edge_mode = view.EDGE_NONE
  end
end)

-- Always strip trailing spaces, except in patch files.
events.connect(events.LEXER_LOADED, function(name)
  textadept.editing.strip_trailing_spaces = name ~= 'diff'
end)

-- VCS diff of current file.
local m_file = textadept.menu.menubar[_L['File']]
table.insert(m_file, #m_file - 1, {''}) -- before Quit
table.insert(m_file, #m_file - 1, {'VCS Diff', function()
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

-- Ctags module.
local ctags = require('ctags')

-- Settings for Textadept development.
local ta_tags = {_HOME .. '/modules/lua/ta_tags'}
local extra_tags = {
  _HOME .. '/modules/ctags/tags',
  _HOME .. '/modules/debugger/tags',
  _HOME .. '/modules/export/tags',
  _HOME .. '/modules/file_diff/tags',
  _HOME .. '/modules/lsp/tags',
  _HOME .. '/modules/lua_repl/tags',
  _HOME .. '/modules/open_file_mode/tags',
  _HOME .. '/modules/spellcheck/tags'
}
for _, tags in ipairs(extra_tags) do ta_tags[#ta_tags + 1] = tags end
ctags[_HOME] = ta_tags
ctags[_HOME .. '/src/scintilla'] = _HOME .. '/tags'
ctags[_USERHOME] = ta_tags
ctags.ctags_flags[_HOME] = table.concat({
  '-R', 'src/textadept.c', 'src/gtdialog/gtdialog.c',
  'src/scintilla/curses', 'src/scintilla/gtk', 'src/scintilla/include',
  'src/scintilla/lexlib', 'src/scintilla/src',
  'src/scintilla/lexers/LexLPeg.cxx'
}, ' ')
ctags.api_commands[_HOME] = function()
  os.spawn('make -C ' .. _HOME .. '/src luadoc'):wait()
  return nil -- keep default behavior
end
local function ta_api()
  return (buffer.filename or ''):find(_HOME) and _HOME .. '/api' or nil
end
-- Load tags and api for external modules.
events.connect(events.LEXER_LOADED, function(name)
  if name ~= 'lua' or _M.lua._extras then return end
  for _, tags in ipairs(extra_tags) do
    table.insert(_M.lua.tags, tags)
    table.insert(textadept.editing.api_files.lua, (tags:gsub('tags$', 'api')))
  end
  _M.lua._extras = true
end)
table.insert(textadept.editing.api_files.ansi_c, ta_api)
table.insert(textadept.editing.api_files.cpp, ta_api)
table.insert(
  textadept.editing.api_files.cpp, _HOME .. '/modules/ansi_c/lua_api')

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
  local args = {'-n -f'}
  if button == 1 then
    args[#args + 1] = [[-e '_=require("debugger.lua")']] -- update package.cpath
    args[#args + 1] = [[-e '_=require("debugger.lua.mobdebug").coro()']]
    args[#args + 1] = [[-e '_=require("debugger.lua.mobdebug").start()']]
  end
  debugger.start(
    'ansi_c', '/home/mitchell/code/textadept/textadept',
    table.concat(args, ' '))
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
snip.openif = "local %1(f) = io.open(%2(file), '%3(r)')\n" ..
  "if %1 then\n\t%0\n\t%1:close()\nend"
snip.popen = "local %1(p) = io.popen(%2(cmd))\n%0\n%1:close()"
-- Textadept.
snip.ta = 'textadept'
snip.tab = 'textadept.bookmarks'
snip.tae = 'textadept.editing'
snip.taft = 'textadept.file_types'
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
local loaded = false
events.connect(events.LEXER_LOADED, function(name)
  if name ~= 'lua' or loaded then return end
  -- Love framework autocompletion and documentation.
  _M.lua.tags[#_M.lua.tags + 1] = _USERHOME .. '/modules/lua/love_0.9.2f_tags'
  table.insert(
    textadept.editing.api_files.lua,
    _USERHOME .. '/modules/lua/love_0.9.2f_api')
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
  loaded = true
end)
-- Lua REPL.
require('lua_repl')
