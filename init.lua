-- Copyright 2007-2017 Mitchell mitchell.att.foicica.com. See LICENSE.

ui.tabs = false

textadept.editing.strip_trailing_spaces = true
textadept.file_types.extensions.luadoc = 'lua'

if not CURSES then
  buffer:set_theme(LINUX and 'dark' or 'light',
                   {font = 'DejaVu Sans Mono', fontsize = 15})
end
buffer.h_scroll_bar = false
buffer.v_scroll_bar = false
buffer.caret_period = 0
buffer.caret_style = buffer.CARETSTYLE_BLOCK
buffer.edge_mode = not CURSES and buffer.EDGE_LINE or buffer.EDGE_BACKGROUND
buffer.edge_column = 80

-- Settings for Textadept development.
io.quick_open_filters[_HOME] = {
  extensions = {
    'a', 'o', 'so', 'dll', 'zip', 'tgz', 'gz', 'exe', 'osx', 'orig', 'rej'
  },
  folders = {
    '%.hg$',
    'doc/api', 'doc/book',
    'gtdialog/cdk',
    'images',
    'lua/doc', 'lua/src/lib/lpeg', 'lua/src/lib/lfs',
    'modules/yaml/src',
    'releases',
    'scintilla/cocoa', 'scintilla/doc', 'scintilla/lexers', 'scintilla/lua',
    'scintilla/qt', 'scintilla/scripts', 'scintilla/test', 'scintilla/win32',
    'src/cdk', 'src/win.*', 'src/gtkosx', 'src/termkey'
  },
  'textadept$',
  'textadept-curses'
}
textadept.run.build_commands[_HOME] = function()
  local button, target = ui.dialogs.standard_inputbox{
    title = _L['Command'], informative_text = 'make -C src'
  }
  if button == 1 then return 'make -C src '..target end
end

-- Filter for ~/.textadept.
io.quick_open_filters[_USERHOME] = {
  extensions = {'a', 'o', 'so', 'dll', 'zip', 'tgz', 'gz'},
  folders = {'%.hg$', 'spellcheck/hunspell'}
}

-- Indent on 'Enter' when between auto-paired '{}' for C and C++.
events.connect(events.CHAR_ADDED, function(ch)
  if (buffer:get_lexer() ~= 'ansi_c' and buffer:get_lexer() ~= 'cpp') or
     ch ~= 10 or not textadept.editing.AUTOINDENT then
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
  local func = require('snippet_extras').func
  -- C Standard library.
  snippets.mal = func('malloc')
  snippets.cal = func('calloc')
  snippets.real = func('realloc')
  snippets.cp = func('strcpy')
  snippets.mcp = func('memcpy')
  snippets.ncp = func('strncpy')
  snippets.cmp = func('strcmp')
  snippets.ncmp = func('strncmp')
  snippets.va = 'va_list %1(ap);\nva_start(%1, %2(lastparam))\n%0\nva_end(%1)'
  snippets.vaa = 'va_arg(%1(ap), %2(int));'
  -- Lua Standard library.
  snippets.lai = func('lua_absindex')
  snippets.lap = func('lua_atpanic')
  snippets.larith = func('lua_arith')
  snippets.lcat = func('lua_concat')
  snippets.lc = func('lua_call')
  snippets.lcmp = func('lua_compare')
  snippets.lcp = func('lua_copy')
  snippets.lcs = func('lua_checkstack')
  snippets.lct = func('lua_createtable')
  snippets.lgf = func('lua_getfield')
  snippets.lgg = func('lua_getglobal')
  snippets.lgi = func('lua_geti')
  snippets.lgmt = func('lua_getmetatable')
  snippets.lgt = func('lua_gettable')
  snippets.lgtop = func('lua_gettop')
  snippets.lguv = func('lua_getuservalue')
  snippets.lib = func('lua_isboolean')
  snippets.licf = func('lua_iscfunction')
  snippets.lif = func('lua_isfunction')
  snippets.lii = func('lua_isinteger')
  snippets.lilu = func('lua_islightuserdata')
  snippets.lin = func('lua_isnumber')
  snippets.linil = func('lua_isnil')
  snippets.linone = func('lua_isnone')
  snippets.linonen = func('lua_isnoneornil')
  snippets.lins = func('lua_insert')
  snippets.lint = 'lua_Integer'
  snippets.lis = func('lua_isstring')
  snippets.lit = func('lua_istable')
  snippets.liu = func('lua_isuserdata')
  snippets.liy = func('lua_isyieldable')
  snippets.llen = func('lua_len')
  snippets.ln = func('lua_next')
  snippets.lnt = func('lua_newtable')
  snippets.lnth = func('lua_newthread')
  snippets.lnu = '(%3 *)lua_newuserdata(%1(L), %2(sizeof(%3(struct))))'
  snippets.lnum = 'lua_Number'
  snippets.lpb = func('lua_pushboolean')
  snippets.lpcc = func('lua_pushcclosure')
  snippets.lpcf = func('lua_pushcfunction')
  snippets.lpc = func('lua_pcall')
  snippets.lpg = func('lua_pushglobaltable')
  snippets.lpi = func('lua_pushinteger')
  snippets.lplit = func('lua_pushliteral')
  snippets.lpls = func('lua_pushlstring')
  snippets.lplu = func('lua_pushlightuserdata')
  snippets.lpn = func('lua_pushnumber')
  snippets.lpnil = func('lua_pushnil')
  snippets.lpop = func('lua_pop')
  snippets.lps = func('lua_pushstring')
  snippets.lpth = func('lua_pushthread')
  snippets.lpv = func('lua_pushvalue')
  snippets.lre = func('lua_rawequal')
  snippets.lrepl = func('lua_replace')
  snippets.lr = func('lua_register')
  snippets.lrg = func('lua_rawget')
  snippets.lrgi = func('lua_rawgeti')
  snippets.lrgp = func('lua_rawgetp')
  snippets.lrlen = func('lua_rawlen')
  snippets.lrm = func('lua_remove')
  snippets.lrs = func('lua_rawset')
  snippets.lrsi = func('lua_rawseti')
  snippets.lrsp = func('lua_rawsetp')
  snippets.lsf = func('lua_setfield')
  snippets.lsg = func('lua_setglobal')
  snippets.lsi = func('lua_seti')
  snippets.ls = 'lua_State'
  snippets.lsmt = func('lua_setmetatable')
  snippets.lst = func('lua_settable')
  snippets.lsuv = func('lua_setuservalue')
  snippets.ltb = func('lua_toboolean')
  snippets.ltcf = func('lua_tocfunction')
  snippets.lt = func('lua_type')
  snippets.lti = func('lua_tointeger')
  snippets.ltls = func('lua_tolstring')
  snippets.ltn = func('lua_tonumber')
  snippets.lts = func('lua_tostring')
  snippets.ltth = func('lua_tothread')
  snippets.ltu = '(%3 *)lua_touserdata(%1(L), %2(index))'
  snippets.luvi = func('lua_upvalueindex')
  -- Auxiliary library.
  snippets.llac = func('luaL_argcheck')
  snippets.llach = 'luaL_addchar(&%1(buf), %2(c))'
  snippets.llae = func('luaL_argerror')
  snippets.llals = 'luaL_addlstring(&%1(buf), %2(s), %3(len))'
  snippets.llas = 'luaL_addstring(&%1(buf), %2(s))'
  snippets.llasz = 'luaL_addsize(&%1(buf), %2(n))'
  snippets.llav = 'luaL_addvalue(&%1(buf))'
  snippets.llbi = 'luaL_buffinit(%1(L), &%2(buf))'
  snippets.llbis = 'luaL_buffinitsize(%1(L), &%2(buf), %3(size))'
  snippets.llb = 'luaL_Buffer'
  snippets.llca = func('luaL_checkany')
  snippets.llci = func('luaL_checkinteger')
  snippets.llcls = func('luaL_checklstring')
  snippets.llcm = func('luaL_callmeta')
  snippets.llcn = func('luaL_checknumber')
  snippets.llcs = func('luaL_checkstring')
  snippets.llct = func('luaL_checktype')
  snippets.llcu = '(%4 *)luaL_checkudata(%1(L), %2(arg), %3(mt_name))'
  snippets.lldf = func('luaL_dofile')
  snippets.llds = func('luaL_dostring')
  snippets.llerr = func('luaL_error')
  snippets.llgmf = func('luaL_getmetafield')
  snippets.llgmt = func('luaL_getmetatable')
  snippets.llgs = func('luaL_gsub')
  snippets.llgst = func('luaL_getsubtable')
  snippets.lllen = func('luaL_len')
  snippets.lllf = func('luaL_loadfile')
  snippets.llls = func('luaL_loadstring')
  snippets.llnmt = func('luaL_newmetatable')
  snippets.llns = func('luaL_newstate')
  snippets.lloi = func('luaL_optinteger')
  snippets.llol = func('luaL_openlibs')
  snippets.llon = func('luaL_optnumber')
  snippets.llos = func('luaL_optstring')
  snippets.llpb = 'luaL_prepbuffer(&%1(buf))'
  snippets.llpbs = 'luaL_prepbuffersize(&%1(buf), %2(size))'
  snippets.llpr = 'luaL_pushresult(&%1(buf))'
  snippets.llprs = 'luaL_pushresultsize(&%1(buf), %2(size))'
  snippets.llref = func('luaL_ref')
  snippets.llsmt = func('luaL_setmetatable')
  snippets.lltu = '(%4 *)luaL_testudata(%1(L), %2(arg), %3(mt_name))'
  snippets.lluref = func('luaL_unref')
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
  -- REPL.
  _M.repl = require('lua.repl')
end)

-- Hide margins when writing e-mails and commit messages.
events.connect(events.FILE_OPENED, function(filename)
  if filename and
     (filename:find('pico%.%d+$') or filename:find('hg%-editor')) then
    for i = 0, buffer.margins - 1 do
      buffer.margin_width_n[i] = 0
    end
    buffer.wrap_mode = buffer.WRAP_WHITESPACE
    buffer.edge_mode = buffer.EDGE_NONE
  end
end)

-- Mercurial diff of current file.
local m_file = textadept.menu.menubar[_L['_File']]
table.insert(m_file, #m_file - 1, {''})
table.insert(m_file, #m_file - 1, {'Hg Diff', function()
  local root = io.get_project_root()
  if not buffer.filename or not root then return end
  local p = io.popen('hg diff -R "'..root..'" "'..buffer.filename..'"')
  local diff = p:read('*a')
  p:close()
  local buffer = buffer.new()
  buffer:set_lexer('diff')
  buffer:add_text(diff)
  buffer:goto_pos(0)
  buffer:set_save_point()
end})

-- Ctags module.
_M.ctags = require('ctags')
_M.ctags[_HOME] = _HOME..'/src/tags'
_M.ctags[_USERHOME] = _HOME..'/src/tags'
local m_ctags = textadept.menu.menubar[_L['_Search']]['_Ctags']
keys[not CURSES and 'a.' or 'm.'] = _M.ctags.goto_tag
-- TODO: m_ctags['G_oto Ctag...'][2]
keys[not CURSES and 'a,' or 'm,'] = m_ctags['Jump _Back'][2]
-- TODO: m_ctags['Jump _Forward'][2]
-- TODO: m_ctags['_Autocomplete Tag'][2]

-- Spellcheck module.
_M.spellcheck = require('spellcheck')
--keys.f7 = m_tools[_L['Spe_lling']][_L['_Check Spelling...']][2]
--keys.sf7 = m_tools[_L['Spe_lling']][_L['_Mark Misspelled Words']][2]

-- File diff module.
_M.file_diff = require('file_diff')
--keys.f8 = _M.file_diff.start
--keys.adown = m_tools[_L['_Compare Files']][_L['_Next Change']][2]
--keys.aup = m_tools[_L['_Compare Files']][_L['_Previous Change']][2]
--keys.aleft = m_tools[_L['_Compare Files']][_L['Merge _Left']][2]
--keys.aright = m_tools[_L['_Compare Files']][_L['Merge _Right']][2]

events.connect(events.INITIALIZED, function() textadept.menu.menubar = nil end)
