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
  local GamesNames = {}
  
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
        
        table.insert(GamesNames, gamename)
        
        GamesImages[gamename] = image
        print("Loaded '"..gamename.."'")
      end
    end
  end
  
  print("\n# Scanning Label Images #\n")
  
  local GamesLabels = {}
  
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
  
  print("\n# Reading Games Data #\n")
  
  local GamesData = {}
    
  for gamename, gameimg in pairs(GamesImages) do
    
    local Data, DataPos = {}, 1
    
    gameimg:mapPixel(function(x,y, r,g,b,a)
      
      r,g,b,a = band(r,3), band(g,3), band(b,3), band(a,3)
      r,g,b = lshift(r,6), lshift(g,4), lshift(b,2)
      
      local byte = bor(r,g,b,a)
      
      Data[DataPos] = strChar(byte)
      DataPos = DataPos + 1
      
      return r,g,b,a
      
    end)
    
    GamesData[gamename] = table.concat(Data)
    
    print("Read '"..gamename.."'")
    
  end
  
  print("\n# Generating GH-Pages #\n")
  
  local ghDir = love.filesystem.getSource().."/GH-Pages/"
  
  os.execute("mkdir "..ghDir)
  print("Created directory: "..ghDir)
  
  os.execute("mkdir "..ghDir.."data/")
  print("Created directory: "..ghDir.."data/")
  
  local function write(path,data,mode)
    local file, err = io.open(ghDir..path,mode or "wb")
    if not file then
      print("Failed to open file '"..file.."': "..err)
      return true
    end
    
    file:write(data)
    file:flush()
    file:close()
    
    print("Wrote file: "..path)
  end
  
  local function writeData(path,data,mode)
    local file, err = io.open(ghDir.."data/"..path,mode or "wb")
    if not file then
      print("Failed to open file '"..file.."': "..err)
      return true
    end
    
    file:write(data)
    file:flush()
    file:close()
    
    print("Wrote file: "..path)
  end
  
  writeData("games.txt",table.concat(GamesNames,","))
  
  for k,gamename in ipairs(GamesNames) do
    
    writeData(gamename..".label",GamesLabels[gamename])
    writeData(gamename..".lk12",GamesData[gamename])
    
  end
  
  os.execute("cp -r -v -f "..love.filesystem.getSource().."/WEB/* "..ghDir)
  os.execute("cp -r -v -f "..love.filesystem.getSource().."/Games "..ghDir.."games")
    
  local htmlTemplate = [[    <div class="responsive">
      <div class="gallery">
        <a href="games/GAMENAME.png" download="GAMENAME.png">
          <img src="games/GAMENAME.png" alt="GAMENAME" width="256" height="256">
        </a>
        <div class="desc">GAMENAME</div>
      </div>
    </div>]]
  
  local htmlInsert = {}
  
  for k,gamename in ipairs(GamesNames) do
    htmlInsert[k] = htmlTemplate:gsub("GAMENAME",gamename)
  end
  
  htmlInsert = table.concat(htmlInsert,"\n\n")
  
  local htmlData = love.filesystem.read("/WEB/index.html")
  
  htmlData = htmlData:gsub("<!%-%- TOOLKIT INSERT HERE %-%->",htmlInsert)
  
  write("index.html",htmlData,"wb+")
  
  print("--============================================--")
  print("--================Job Finished================--")
  print("--============================================--")
  
  return 0
end