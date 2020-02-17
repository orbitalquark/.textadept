-- Copyright 2015-2019 Mitchell mitchell.att.foicica.com. See LICENSE.

-- Retrieves the API documentation for function name *symbol* in lexer language
-- *lang* and returns its signature in snippet form for insertion.
-- Documentation is read from API files in the `textadept.editing.api_files`
-- table. As a result, if *symbol* is a full symbol name, only the last
-- alphanumeric part of it is considered.
-- @param symbol The symbol the retrieve arguments for.
-- @param lang The lexer language of *symbol*.
-- @see textadept.editing.api_files
local function get_api_snippet(symbol, lang)
  local apis = {}
  local api_files = textadept.editing.api_files[lang]
  if api_files and symbol:match('[%w_-]+$') then
    local symbol_patt = '^'..symbol:match('[%w_-]+$'):gsub('(%p)', '%%%1')
    local signature_patt = '%f[%w_-]'..symbol:gsub('(%p)', '%%%1')..'(%b())'
    for i = 1, #api_files do
      local api_file = api_files[i]
      if type(api_file) == 'function' then api_file = api_file() end
      if api_file and lfs.attributes(api_file) then
        for line in io.lines(api_file) do
          if line:find(symbol_patt) then
            apis[#apis + 1] = line:match(signature_patt)
            if lang == 'lua' and not line:match(signature_patt) then
              apis[#apis + 1] = line:match((signature_patt:gsub(':', '.')))
            end
          end
        end
      end
    end
  end
  if #apis == 0 then return end
  -- Get the one function whose arguments are to be inserted.
  if #apis > 1 then
    local button, i = ui.dialogs.filteredlist{
      title = _L['Select Snippet'], columns = {_L['Snippet Text']},
      items = apis, width = CURSES and ui.size[1] - 2 or nil
    }
    if button ~= 1 then return end
    apis[1] = apis[i]
  end
  -- Parse the argument list and create placeholders for arguments.
  local arg_patt = '^(%s*).-([%w_-]+)$' -- matches the space between ','s
  if lang == 'lua' then
    -- If the function is a 'self' function, strip the first self arg.
    local line, pos = buffer:get_cur_line()
    if line:sub(1, pos):find(':'..symbol..'$') or symbol:find(':') then
      apis[1] = apis[1]:gsub('[^(,)]+,?%s*', '', 1)
    end
    -- Handle Lua API documentation's optional argument bracket delimiters.
    arg_patt = '^(%s*).-([%w_]+)%s*[%[%]]*$'
  end
  local index = 0
  return symbol..apis[1]:gsub('%s*[^(,)]+', function(arg)
    local space, name = arg:match(arg_patt)
    index = index + 1
    return ("%s%%%d(%s)"):format(space or (index > 1 and ' ' or ''), index,
                                 name or ' ')
  end)
end

-- Defines a snippet that inserts the argument list for function *name* based on
-- its API documentation.
-- @param name The function name to insert the argument list for as a snippet.
local function wrap(name)
  return function() return get_api_snippet(name, buffer:get_lexer(true)) end
end

-- Hook into language-specific snippets in order to attempt to insert a
-- recognized API function's argument list as a snippet.
events.connect(events.LEXER_LOADED, function(lexer)
  if not snippets[lexer] or getmetatable(snippets[lexer]) then return end
  setmetatable(snippets[lexer], {__index = function(t, k)
    return get_api_snippet(k, lexer)
  end})
end)

return wrap
