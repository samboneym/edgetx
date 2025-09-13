local function init()
end

local function run()

  thr = math.floor((getOutputValue(2)+1024) * 200 / 2048)
  
  ail = math.abs(getOutputValue(0)) * 200 / 2048
  ele = math.abs(getOutputValue(1)) * 200 / 2048
  rud = math.abs(getOutputValue(3)) * 200 / 2048
  
  for i=0, LED_STRIP_LENGTH - 1, 1
  do
    setRGBLedColor(i, thr, ail+ele+3, rud+ele)
  end
  applyRGBLedColors()
end

local function background()
  -- Called periodically while the Special Function switch is off
end

return { run=run, background=background, init=init }
