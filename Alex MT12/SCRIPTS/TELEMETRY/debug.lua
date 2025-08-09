-- Debug Script for EdgeTX
-- Shows all available telemetry sources
-- Compatible with EdgeTX 2.11+

-- Script configuration
local script = {
  -- Script configuration
  name = "Debug",
  version = "1.0",
  
  -- Display settings
  refreshRate = 100, -- Update every 100ms
  lastUpdate = 0
}

local function init()
  -- Initialize script
  return
end

local function run(event)
  -- Get current time
  local time = getTime()
  
  -- Check if it's time to update
  if time - script.lastUpdate < script.refreshRate then
    return
  end
  
  script.lastUpdate = time
  
  -- Clear the screen
  lcd.clear()
  
  local yPos = 1
  local xLabel = 5
  local xValue = 85
  
  -- Get and display available sources
  local sourcesList = {}
  local sourceCount = 0
  
  -- Collect source names from the iterator
  for sourceIndex, sourceName in sources() do
    sourceCount = sourceCount + 1
    sourcesList[sourceCount] = sourceName
  end
  
  -- Calculate how many lines can fit on the display
  local availableHeight = 64 - yPos - 10 -- Leave space for status bar
  local lineHeight = 8 -- Height of each source line (smaller font)
  local maxLines = math.floor(availableHeight / lineHeight)
  
  -- Display sources in compact format (multiple per line)
  local sourcesPerLine = 6 -- Approximate number of sources that fit per line
  local currentLine = ""
  local sourcesOnLine = 0
  
  for i = sourceCount, 1, -1 do
    local sourceName = sourcesList[i]
    
    if sourcesOnLine == 0 then
      currentLine = sourceName
      sourcesOnLine = 1
    else
      currentLine = currentLine .. "," .. sourceName
      sourcesOnLine = sourcesOnLine + 1
    end
    
    -- Print line when it's full or we're at the last source
    if sourcesOnLine >= sourcesPerLine or i == sourceCount then
      lcd.drawText(xLabel, yPos, currentLine, SMLSIZE)
      yPos = yPos + lineHeight
      currentLine = ""
      sourcesOnLine = 0
      
      -- Check if we've used all available lines
      if yPos >= 64 - 10 then -- Leave space for status bar
        if i < sourceCount then
          lcd.drawText(xLabel, yPos, "... and " .. (sourceCount - i) .. " more", 0) -- Smallest font
        end
        break
      end
    end
  end
  
  -- Draw status bar at bottom
  yPos = yPos + 18
  lcd.drawLine(5, yPos, 123, yPos, SOLID, 0)
  
  -- Show update time
  local timeStr = string.format("Updated: %ds", math.floor(time / 1000))
  lcd.drawText(64, yPos + 2, timeStr, CENTER + SMLSIZE)
  
  -- Handle key events
  if event == EVT_EXIT_BREAK then
    -- Exit script on EXIT key
    return
  end
end

-- Return the script functions
return { init = init, run = run } 