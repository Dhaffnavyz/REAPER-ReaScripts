--[[
 * ReaScript Name: Set item under mouse start and end to items selection
 * About: Useful if you need to adjust regions created with empty items. If you had to resize thiese regions, you can do it easily with this script.
 * Screenshot: http://i.imgur.com/iFUNNCC.gifv
 * Author: X-Raym
 * Author URI: http://www.extremraym.com/
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2016-04-01)
  + Initial Release
--]]

-- Design for adjusting regions when using the Heda's regions manger from empty items.
-- Useful for sound design, if you change side of one item and that you need to adjust the region for rendering.


-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console

------------------------------------------------------- END OF USER CONFIG AREA


-- UTILITIES -------------------------------------------------------------

-- Save item selection
function SaveSelectedItems (table)
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    table[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
end


-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

--------------------------------------------------------- END OF UTILITIES


-- Main function
function main()

  for i, item in ipairs(init_sel_items) do

    local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local item_end = reaper.GetMediaItemInfo_Value(item, "D_LENGTH") + item_pos

    if not min_pos then
      min_pos = item_pos
    else
      if item_pos < min_pos then min_pos = item_pos end
    end

    if not max_end then
      max_end = item_end
    else
      if item_end > max_end then max_end = item_end end
    end

  end

  len = max_end - min_pos

  reaper.SetMediaItemInfo_Value(mouse_item, "D_POSITION", min_pos)
  reaper.SetMediaItemInfo_Value(mouse_item, "D_LENGTH", len)

end


-- INIT

-- See if there is items selected
count_sel_items = reaper.CountSelectedMediaItems(0)
mouse_item, mouse_pos = reaper.BR_ItemAtMouseCursor()

if count_sel_items > 0 and mouse_item then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  init_sel_items =  {}
  SaveSelectedItems(init_sel_items)

  main()

  reaper.Undo_EndBlock("Set item under mouse start and end to items selection", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)

end