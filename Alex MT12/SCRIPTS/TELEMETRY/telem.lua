-- Telemetry Display Script for EdgeTX
-- Shows Receiver Battery Voltage, LQ, and RSSI
-- Compatible with EdgeTX 2.11+

-- Script configuration
local script = {
    -- Script configuration
    name = "Telemetry",
    version = "1.0",

    -- Display settings
    refreshRate = 100, -- Update every 100ms
    lastUpdate = 0,

    -- Battery settings
    battery = {
        minVoltsPerCell = 3.0,  -- Minimum voltage per cell (empty)
        fullVoltsPerCell = 4.2, -- Full voltage per cell
        fieldId = nil,          -- Field ID for RxBt
        cellCount = 0,
        voltage = 0,
        percent = 0
    },

    -- Link quality and signal strength
    link = {
        RF_MODES = {
            { name = "4Hz",       minRSSI = -128 },
            { name = "25Hz",      minRSSI = -123 },
            { name = "50Hz",      minRSSI = -115 },
            { name = "100Hz",     minRSSI = -117 },
            { name = "100HzFull", minRSSI = -112 },
            { name = "150Hz",     minRSSI = -112 },
            { name = "200Hz",     minRSSI = -112 },
            { name = "250Hz",     minRSSI = -108 },
            { name = "333HzFull", minRSSI = -105 },
            { name = "500Hz",     minRSSI = -105 },
            { name = "D250",      minRSSI = -104 },
            { name = "D500",      minRSSI = -104 },
            { name = "F500",      minRSSI = -104 },
            { name = "F1000",     minRSSI = -104 }
        },
        lqFieldId = nil,   -- Field ID for LQ
        rssiFieldId = nil, -- Field ID for RSSI
        rfmdFieldId = nil, -- Field ID for RF Mode
        lq = 0,
        rssi = 0,
        rfmd = 0
    }
}

local function init()
    -- Get field IDs for telemetry values
    local rxBattInfo = getFieldInfo("RxBt")
    local lqInfo = getFieldInfo("RQly")
    local rssiInfo = getFieldInfo("1RSS")
    local rfmdInfo = getFieldInfo("RFMD")

    if rxBattInfo then
        script.battery.fieldId = rxBattInfo.id
    end
    if lqInfo then
        script.link.lqFieldId = lqInfo.id
    end
    if rssiInfo then
        script.link.rssiFieldId = rssiInfo.id
    end
    if rfmdInfo then
        script.link.rfmdFieldId = rfmdInfo.id
    end
end

local function updateTelemetry()
    -- Get telemetry values using field IDs

    if script.battery.fieldId then
        local rxBatt = getValue(script.battery.fieldId) -- Receiver battery voltage
        if rxBatt ~= 0 then
            script.battery.voltage = rxBatt

            script.battery.cellCount = math.floor(rxBatt / 3.7 + 0.5)

            -- Calculate battery percentage
            local fullVoltage = script.battery.cellCount * script.battery.fullVoltsPerCell
            local emptyVoltage = script.battery.cellCount * script.battery.minVoltsPerCell
            script.battery.percent = math.max(0,
                math.min(100, (rxBatt - emptyVoltage) / (fullVoltage - emptyVoltage) * 100))
        end
    end

    if script.link.lqFieldId then
        local lqValue = getValue(script.link.lqFieldId) -- Link Quality
        if lqValue ~= 0 then
            script.link.lq = lqValue
        end
    end

    if script.link.rssiFieldId then
        local rssiValue = getValue(script.link.rssiFieldId) -- RSSI
        if rssiValue ~= 0 then
            script.link.rssi = rssiValue
        end
    end
    if script.link.rfmdFieldId then
        local rfmdValue = getValue(script.link.rfmdFieldId) -- RF Mode
        if rfmdValue ~= 0 then
            script.link.rfmd = rfmdValue
        end
    end
end

local function calculateRange()
    local rfmd = script.link.rfmd
    local rssi = script.link.rssi
    local rfmdIndex = rfmd + 1
    local rssiIndex = rssi + 1
    local rfModeData = script.link.RF_MODES[rfmdIndex]
    local range = rfModeData.minRSSI + rssiIndex
    return range
end

local function drawBattery(x, y)
    -- Draw visual battery indicator (vertical, right side)
    local batteryX = x
    local batteryY = y + 2
    local batteryWidth = 8
    local batteryHeight = 20

    -- Battery outline
    lcd.drawRectangle(batteryX, batteryY, batteryWidth, batteryHeight)
    lcd.drawRectangle(batteryX + 2, batteryY - 2, 4, 2) -- Battery terminal (top)

    -- Battery fill (vertical)
    local fillHeight = math.floor((script.battery.percent / 100) * (batteryHeight - 2))
    if fillHeight > 0 then
        lcd.drawFilledRectangle(batteryX + 1, batteryY + batteryHeight - fillHeight - 1, batteryWidth - 2, fillHeight)
    end

    -- Battery percentage text (above battery)
    lcd.drawText(batteryX + batteryWidth + 3, batteryY - 2, string.format("%d%%", math.floor(script.battery.percent)),
        SMLSIZE)

    -- Battery voltage (to the right of battery)
    lcd.drawText(batteryX + batteryWidth + 3, batteryY + 6, string.format("%.1fV", script.battery.voltage), SMLSIZE)

    -- Cell count (below voltage)
    lcd.drawText(batteryX + batteryWidth + 3, batteryY + 14, string.format("(%dS)", script.battery.cellCount), SMLSIZE)
end

-- Draw a wifi-style signal strength symbol for Link Quality (LQ) using arcs and a dot
local function drawLQ(x, y, lq)
    -- lq: 0-100
    -- Number of arcs to fill (0-3), dot is always drawn
    local arcs = 0
    if lq >= 80 then
        arcs = 3
    elseif lq >= 50 then
        arcs = 2
    elseif lq >= 20 then
        arcs = 1
    else
        arcs = 0
    end

    local width = 21
    local height = 21

    local centerX = x + math.floor(width / 2)

    local xOff = math.floor(3 / 2)
    lcd.drawFilledRectangle(centerX - xOff, y + height - 3, 3, 3)

    local xOff = math.floor(9 / 2)
    lcd.drawFilledRectangle(centerX - xOff, y + height - 9, 9, 3)

    local xOff = math.floor(15 / 2)
    lcd.drawFilledRectangle(centerX - xOff, y + height - 15, 15, 3)

    local xOff = math.floor(21 / 2)
    lcd.drawFilledRectangle(centerX - xOff, y + height - 21, 21, 3)

    -- Draw arcs (simulate with lines for EdgeTX LCD)
    -- local centerX = x + 8
    -- local centerY = y + 10
    -- local arcRadii = { 3, 6, 9 }
    -- local currentY = centerY

    -- for i = 1, 3 do
    --     if arcs >= i then
    --         -- Draw filled arc (simulate with lines)
    --         lcd.drawFilledRectangle(centerX - arcRadii[i], currentY, arcRadii[i] * 2, 3)

    --         -- lcd.drawLine(centerX - arcRadii[i], currentY, centerX + arcRadii[i], currentY, SOLID, 0)
    --         -- lcd.drawLine(centerX - arcRadii[i], currentY + 1, centerX + arcRadii[i], currentY + 1, SOLID, 0)
    --     else
    --         -- Optionally, draw faint/empty arc (skip for clarity)
    --     end
    --     currentY = currentY - 5
    -- end


    -- -- Draw dot (always present)
    -- lcd.drawFilledRectangle(centerX, centerY + 5, 3, 3)
end

local function drawRFMode(x, y)
    if script.link.rfmd ~= 0 then
        local rfModeEntry = script.link.RF_MODES[script.link.rfmd + 1]
        if rfModeEntry then
            lcd.drawText(x, y, "Mode: " .. rfModeEntry.name, SMLSIZE)
        end
    end
end

local function run(event)
    -- Get current time
    local time = getTime()

    -- Check if it's time to update
    if time - script.lastUpdate < script.refreshRate then
        return
    end

    script.lastUpdate = time

    -- Update telemetry data
    updateTelemetry()

    -- Clear the screen
    lcd.clear()

    -- Draw title and version on same line
    --[[
  local titleText = script.name
  local versionText = "v" .. script.version

  -- Fixed positioning for monochrome display
  -- Title centered, version positioned to the right with spacing
  lcd.drawText(64, 1, titleText, CENTER)
  lcd.drawText(100, 1, versionText, 0)

  -- Draw separator line
  lcd.drawLine(5, 16, 123, 16, SOLID, 0)
  --]]

    local yPos = 1
    local xLabel = 5
    local xValue = 95

    -- Display Receiver Battery Voltage
    lcd.drawText(xLabel, yPos, "Rx Batt:")
    if script.battery.voltage ~= 0 then
        lcd.drawText(xValue, yPos, string.format("%.1fV (%dS)", script.battery.voltage, script.battery.cellCount), RIGHT)
    else
        lcd.drawText(xValue, yPos, "N/A", RIGHT)
    end

    yPos = yPos + 14


    -- Display Link Quality (LQ)
    lcd.drawText(xLabel, yPos, "LQ:")
    if script.link.lq ~= 0 then
        lcd.drawText(xValue, yPos, string.format("%d%%", script.link.lq), RIGHT)
        -- Draw wifi-style LQ symbol to the right of the value
        drawLQ(xValue + 10, yPos, script.link.lq)
    else
        lcd.drawText(xValue, yPos, "N/A", RIGHT)
        drawLQ(xValue + 10, yPos, 0)
    end

    yPos = yPos + 14

    -- Display RSSI
    lcd.drawText(xLabel, yPos, "RSSI:")
    if script.link.rssi ~= 0 then
        lcd.drawText(xValue, yPos, string.format("%ddB", script.link.rssi), RIGHT)
    else
        lcd.drawText(xValue, yPos, "N/A", RIGHT)
    end

    -- Draw battery icon and percentage at bottom left
    if script.battery.voltage ~= 0 then
        drawBattery(5, 40) -- Position at bottom left
    end

    -- Draw status bar at bottom
    --[[
  yPos = yPos + 18
  lcd.drawLine(5, yPos, 123, yPos, SOLID, 0)

  -- Show update time
  local timeStr = string.format("Updated: %ds", math.floor(time / 1000))
  lcd.drawText(64, yPos + 2, timeStr, CENTER + SMLSIZE)
  --]]

    -- Handle key events
    if event == EVT_EXIT_BREAK then
        -- Exit script on EXIT key
        return
    end
end

-- Return the script functions
return { init = init, run = run }
