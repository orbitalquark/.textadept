-- Copyright 2007-2013 Mitchell mitchell.att.foicica.com. See LICENSE.

local buffer = buffer

-- Multiple Selection and Virtual Space
buffer.multiple_selection = true
buffer.additional_selection_typing = true
--buffer.multi_paste = buffer.MULTIPASTE_EACH
--buffer.virtual_space_options = buffer.VS_RECTANGULARSELECTION +
--                               buffer.VS_USERACCESSIBLE
buffer.rectangular_selection_modifier = (WIN32 or OSX) and buffer.MOD_ALT or
                                                           buffer.MOD_SUPER
--buffer.additional_carets_blink = false
--buffer.additional_carets_visible = false

-- Scrolling.
buffer:set_x_caret_policy(1, 20) -- CARET_SLOP
buffer:set_y_caret_policy(13, 1) -- CARET_SLOP | CARET_STRICT | CARET_EVEN
--buffer:set_visible_policy()
buffer.h_scroll_bar = false
buffer.v_scroll_bar = false
--buffer.x_offset =
--buffer.scroll_width =
--buffer.scroll_width_tracking = true
--buffer.end_at_last_line = false

-- Whitespace
--buffer.view_ws = buffer.WS_VISIBLEALWAYS
--buffer.whitespace_size =
--buffer.extra_ascent =
--buffer.extra_descent =

-- Line Endings
--buffer.view_eol = true

-- Caret and Selection Styles.
--buffer.sel_eol_filled = true
buffer.caret_line_visible = not CURSES
--buffer.caret_line_visible_always = true
buffer.caret_period = 0
buffer.caret_style = buffer.CARETSTYLE_BLOCK
--buffer.caret_width =
--buffer.caret_sticky = buffer.CARETSTICKY_ON

-- Margins.
--buffer.margin_left =
--buffer.margin_right =
-- Line Number Margin.
local width = 4 * buffer:text_width(buffer.STYLE_LINENUMBER, '9')
buffer.margin_width_n[0] = width + (not CURSES and 4 or 0)
-- Marker Margin.
buffer.margin_width_n[1] = not CURSES and 4 or 1
buffer.margin_sensitive_n[1] = true
buffer.margin_cursor_n[1] = buffer.CURSORARROW
-- Fold Margin.
buffer.margin_width_n[2] = not CURSES and 12 or 1
buffer.margin_mask_n[2] = buffer.MASK_FOLDERS
buffer.margin_sensitive_n[2] = true
buffer.margin_cursor_n[2] = buffer.CURSORARROW

-- Annotations.
buffer.annotation_visible = buffer.ANNOTATION_BOXED

-- Other.
buffer.buffered_draw = not CURSES and not OSX -- Quartz buffers drawing on OSX
--buffer.two_phase_draw = false
--buffer.word_chars =
--buffer.whitespace_chars =
--buffer.punctuation_chars =

-- Tabs and Indentation Guides.
-- Note: tab and indentation settings apply to individual buffers.
buffer.tab_width = 2
buffer.use_tabs = false
--buffer.indent = 2
buffer.tab_indents = true
buffer.back_space_un_indents = true
buffer.indentation_guides = buffer.IV_LOOKBOTH

-- Margin Markers.
local mark = not CURSES and buffer.MARK_FULLRECT or
             buffer.MARK_CHARACTER + string.byte(' ')
buffer:marker_define(textadept.bookmarks.MARK_BOOKMARK, mark)
buffer:marker_define(textadept.run.MARK_ERROR, mark)
if not CURSES then
  -- Arrow Folding Symbols.
--  buffer:marker_define(buffer.MARKNUM_FOLDEROPEN, buffer.MARK_ARROWDOWN)
--  buffer:marker_define(buffer.MARKNUM_FOLDER, buffer.MARK_ARROW)
--  buffer:marker_define(buffer.MARKNUM_FOLDERSUB, buffer.MARK_EMPTY)
--  buffer:marker_define(buffer.MARKNUM_FOLDERTAIL, buffer.MARK_EMPTY)
--  buffer:marker_define(buffer.MARKNUM_FOLDEREND, buffer.MARK_EMPTY)
--  buffer:marker_define(buffer.MARKNUM_FOLDEROPENMID, buffer.MARK_EMPTY)
--  buffer:marker_define(buffer.MARKNUM_FOLDERMIDTAIL, buffer.MARK_EMPTY)
  -- Plus/Minus Folding Symbols.
--  buffer:marker_define(buffer.MARKNUM_FOLDEROPEN, buffer.MARK_MINUS)
--  buffer:marker_define(buffer.MARKNUM_FOLDER, buffer.MARK_PLUS)
--  buffer:marker_define(buffer.MARKNUM_FOLDERSUB, buffer.MARK_EMPTY)
--  buffer:marker_define(buffer.MARKNUM_FOLDERTAIL, buffer.MARK_EMPTY)
--  buffer:marker_define(buffer.MARKNUM_FOLDEREND, buffer.MARK_EMPTY)
--  buffer:marker_define(buffer.MARKNUM_FOLDEROPENMID, buffer.MARK_EMPTY)
--  buffer:marker_define(buffer.MARKNUM_FOLDERMIDTAIL, buffer.MARK_EMPTY)
  -- Circle Tree Folding Symbols.
--  buffer:marker_define(buffer.MARKNUM_FOLDEROPEN, buffer.MARK_CIRCLEMINUS)
--  buffer:marker_define(buffer.MARKNUM_FOLDER, buffer.MARK_CIRCLEPLUS)
--  buffer:marker_define(buffer.MARKNUM_FOLDERSUB, buffer.MARK_VLINE)
--  buffer:marker_define(buffer.MARKNUM_FOLDERTAIL, buffer.MARK_LCORNERCURVE)
--  buffer:marker_define(buffer.MARKNUM_FOLDEREND,
--                       buffer.MARK_CIRCLEPLUSCONNECTED)
--  buffer:marker_define(buffer.MARKNUM_FOLDEROPENMID,
--                       buffer.MARK_CIRCLEMINUSCONNECTED)
--  buffer:marker_define(buffer.MARKNUM_FOLDERMIDTAIL, buffer.MARK_TCORNERCURVE)
  -- Box Tree Folding Symbols.
  buffer:marker_define(buffer.MARKNUM_FOLDEROPEN, buffer.MARK_BOXMINUS)
  buffer:marker_define(buffer.MARKNUM_FOLDER, buffer.MARK_BOXPLUS)
  buffer:marker_define(buffer.MARKNUM_FOLDERSUB, buffer.MARK_VLINE)
  buffer:marker_define(buffer.MARKNUM_FOLDERTAIL, buffer.MARK_LCORNER)
  buffer:marker_define(buffer.MARKNUM_FOLDEREND, buffer.MARK_BOXPLUSCONNECTED)
  buffer:marker_define(buffer.MARKNUM_FOLDEROPENMID,
                       buffer.MARK_BOXMINUSCONNECTED)
  buffer:marker_define(buffer.MARKNUM_FOLDERMIDTAIL, buffer.MARK_TCORNER)
end
--buffer:marker_enable_highlight(true)

-- Indicators.
buffer.indic_style[textadept.editing.INDIC_HIGHLIGHT] = buffer.INDIC_ROUNDBOX
if not CURSES then
  buffer.indic_under[textadept.editing.INDIC_HIGHLIGHT] = true
end

-- Autocompletion.
--buffer.auto_c_cancel_at_start = false
--buffer.auto_c_fill_ups = '('
buffer.auto_c_choose_single = true
--buffer.auto_c_ignore_case = true
--buffer.auto_c_case_insensitive_behaviour =
--  buffer.CASEINSENSITIVEBEHAVIOUR_IGNORECASE
--buffer.auto_c_auto_hide = false
--buffer.auto_c_drop_rest_of_word = true
--buffer.auto_c_max_height =
--buffer.auto_c_max_width =

-- Call Tips.
buffer.call_tip_use_style = buffer.tab_width *
                            buffer:text_width(buffer.STYLE_CALLTIP, ' ')
--buffer.call_tip_position = true

-- Folding.
buffer.property['fold'] = '1'
buffer.property['fold.by.indentation'] = '0'
buffer.property['fold.line.comments'] = '0'
buffer.automatic_fold = buffer.AUTOMATICFOLD_SHOW + buffer.AUTOMATICFOLD_CLICK +
                        buffer.AUTOMATICFOLD_CHANGE
buffer.fold_flags = not CURSES and buffer.FOLDFLAG_LINEAFTER_CONTRACTED or 0

-- Line Wrapping.
--buffer.wrap_mode = buffer.WRAP_WORD
--buffer.wrap_visual_flags = buffer.WRAPVISUALFLAG_MARGIN
--buffer.wrap_visual_flags_location = buffer.WRAPVISUALFLAGLOC_END_BY_TEXT
--buffer.wrap_indent_mode = buffer.WRAPINDENT_SAME
--buffer.wrap_start_indent =

-- Long Lines.
buffer.edge_mode = not CURSES and buffer.EDGE_LINE or buffer.EDGE_BACKGROUND
buffer.edge_column = 80
