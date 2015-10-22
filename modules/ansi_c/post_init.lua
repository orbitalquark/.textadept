
local e = textadept.editing
-- Indent on 'Enter' when between auto-paired '{}'.
events.connect(events.CHAR_ADDED, function(ch)
  if buffer:get_lexer() == 'ansi_c' and ch == 10 and e.AUTOINDENT then
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

-- Define C snippets.
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
