-- Copyright 2007-2012 Mitchell mitchell<att>caladbolg.net. See LICENSE.
-- Terminal editor theme for Textadept.

local buffer = buffer

-- Folding.
buffer.property['fold'] = '1'
buffer.property['fold.by.indentation'] = '1'
buffer.property['fold.line.comments'] = '0'

-- Tabs and Indentation.
buffer.tab_width = 2
buffer.use_tabs = false
--buffer.indent = 2
buffer.tab_indents = true
buffer.back_space_un_indents = true
