--LIKO-12 Games Toolchain--

local bit = require("bit") --Load BitOp library.

local band, bor, lshift = bit.band, bit.bor, bit.lshift
local strChar = string.char

--PICO-8 Palette
local palette = {
  {0,0,0,255}, --Black 1
  {28,43,83,255}, --Dark Blue 2
  {127,36,84,255}, --Dark Red 3
  {0,135,81,255}, --Dark Green 4
  {171,82,54,255}, --Brown 5
  {96,88,79,255}, --Dark Gray 6
  {195,195,198,255}, --Gray 7
  {255,241,233,255}, --White 8
  {237,27,81,255}, --Red 9
  {250,162,27,255}, --Orange 10
  {247,236,47,255}, --Yellow 11
  {93,187,77,255}, --Green 12
  {81,166,220,255}, --Blue 13
  {131,118,156,255}, --Purple 14
  {241,118,166,255}, --Pink 15
  {252,204,171,255} --Human Skin 16
}

--Clear the last 2 bits from each color values.
for k1,col in ipairs(palette) do
  for k2,v in ipairs(col) do
    palette[k1][k2] = band(v,252)
  end
end

function love.run()
  print("--============================================--")
  print("--========LIKO-12 Games Toolchain V1.0========--")
  print("--============================================--")
  
  print("")
  
  if not love.filesystem.exists("/Games") then
    print("!!! The games folder doesn't exist !!!\n")
    return 1
  end
  
  print("# Loading Games Images #\n")
  
  local GamesImages = {}
  
  local files_list = love.filesystem.getDirectoryItems("/Games/")
  for k, filename in ipairs(files_list) do
    local filepath = "/Games/"..filename
    if love.filesystem.isFile(filepath) then
      if filename:sub(-4,-1) == ".png" then
        local gamename = filename:sub(1,-5)
        local ok, image = pcall(love.image.newImageData,filepath)
        if not ok then
          print("!!! Failed to load '"..gamename.."' !!!",image,"\n")
          return 1
        end
        
        local imageWidth, imageHeight = image:getDimensions()
        if imageWidth ~= 256 or imageHeight ~= 256 then
          print("!!! Invalid image size '"..gamename.."' !!!",imageWidth.."x"..imageHeight.."\n")
          return 1
        end
        
        GamesImages[gamename] = image
        print("Loaded '"..gamename.."'")
      end
    end
  end
  
  print("\n# Scanning Label Images #\n")
  
  local GamesLabels = {}
  
  --LabelX, LabelY = 32,120
  
  for gamename, gameimg in pairs(GamesImages) do
    
    local Data, DataPos = {}, 1 --The image data (in binary)
    
    for y=120,120+127 do
      for x=32,32+191, 2 do
        --Get the first pixel color
        local r1,g1,b1,a1 = gameimg:getPixel(x,y)
        
        --Clear the last 2 bits
        r1,g1,b1,a1 = band(r1,252), band(g1,252), band(b1,252), band(a1,252)
        
        --Try to findout the color id
        local Color1 = 0
        
        for id, color in ipairs(palette) do
          local cr, cg, cb, ca = unpack(color)
          
          if r1 == cr and g1 == cg and b1 == cb and a1 == ca then
            Color1 = id-1
            break
          end
        end
        
        --Get the second pixel color
        local r2,g2,b2,a2 = gameimg:getPixel(x+1,y)
        
        --Clear the last 2 bits
        r2,g2,b2,a2 = band(r2,252), band(g2,252), band(b2,252), band(a2,252)
        
        --Try to findout the color id
        local Color2 = 0
        
        for id, color in ipairs(palette) do
          local cr, cg, cb, ca = unpack(color)
          
          if r2 == cr and g2 == cg and b2 == cb and a2 == ca then
            Color2 = id-1
            break
          end
        end
        
        --Convert the colors to binary
        Color1 = lshift(Color1,4)
        local Color = bor(Color1, Color2)
        
        Data[DataPos] = strChar(Color)
        DataPos = DataPos + 1
      end
    end
    
    Data = table.concat(Data)
    
    GamesLabels[gamename] = Data
    
    print("Scanned '"..gamename.."'")
  end
  
  
  
  return 0
end