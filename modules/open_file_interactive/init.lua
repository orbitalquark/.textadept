-- Copyright 2019 Mitchell mitchell.att.foicica.com.

-- Key mode for using the command entry to open files relative to the current
-- file. Tab-completion is available.
keys.open_file = {
  ['\n'] = function()
    return ui.command_entry.finish_mode(function(file)
      if file ~= '' and not file:find('^%a?:?[/\\]') then
        -- Convert relative path into an absolute one.
        file = (buffer.filename or
                lfs.currentdir()..'/'):match('^.+[/\\]')..file
      end
      io.open_file(file ~= '' and file)
    end)
  end,
  ['\t'] = function()
    if ui.command_entry:auto_c_active() then
      ui.command_entry:line_down()
      return
    end
    -- Autocomplete the filename in the command entry
    local files = {}
    local path = ui.command_entry:get_text()
    if not path:find('^%a?:?[/\\]') then
      -- Convert relative path into an absolute one.
      local sep = not WIN32 and '/' or '\\'
      path = (buffer.filename or lfs.currentdir()..sep):match('^.+[/\\]')..path
    end
    local dir, part = path:match('^(.-)\\?([^/\\]*)$')
    if lfs.attributes(dir, 'mode') == 'directory' then
      -- Iterate over directory, finding file matches.
      part = '^'..part:gsub('(%p)', '%%%1')
      lfs.dir_foreach(dir, function(file)
        file = file:match('[^/\\]+[/\\]?$')
        if file:find(part) then files[#files + 1] = file end
      end, nil, 0, true)
      table.sort(files)
      ui.command_entry:auto_c_show(#part - 1, table.concat(files, ' '))
    end
  end,
  ['s\t'] = function()
    if ui.command_entry:auto_c_active() then ui.command_entry:line_up() end
  end
}

return function() ui.command_entry.enter_mode('open_file') end
