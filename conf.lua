io.stdout:setvbuf("no")

function love.conf(t)
  t.identity = "LIKO-12-Games-Toolchain"                    -- The name of the save directory (string)
  t.version = "11.0"                -- The LÖVE version this game was made for (string)
  t.console = false                   -- Attach a console (boolean, Windows only)
  t.accelerometerjoystick = false      -- Enable the accelerometer on iOS and Android by exposing it as a Joystick (boolean)
  t.externalstorage = true           -- True to save files (and read from the save directory) in external storage on Android (boolean) 
  t.gammacorrect = false              -- Enable gamma-correct rendering, when supported by the system (boolean)
  
  t.audio.mixwithsystem = false        -- Keep background music playing when opening LOVE (boolean, iOS and Android only)
  
  t.window = nil --I don't want a window for the toolchain.

  t.modules.audio = false             -- Disable the audio module (boolean)
  t.modules.data = true               -- Enable the data module (boolean)
  t.modules.event = true              -- Enable the event module (boolean)
  t.modules.font = true               -- Enable the font module (boolean)
  t.modules.graphics = false          -- Disable the graphics module (boolean)
  t.modules.image = true              -- Enable the image module (boolean)
  t.modules.joystick = false          -- Disable the joystick module (boolean)
  t.modules.keyboard = false          -- Disable the keyboard module (boolean)
  t.modules.math = true               -- Enable the math module (boolean)
  t.modules.mouse = false             -- Disable the mouse module (boolean)
  t.modules.physics = false           -- Disable the physics module (boolean)
  t.modules.sound = false             -- Disable the sound module (boolean)
  t.modules.system = false            -- Disable the system module (boolean)
  t.modules.thread = false            -- Disable the thread module (boolean)
  t.modules.timer = false             -- Disable the timer module (boolean), Disabling it will result 0 delta time in love.update
  t.modules.touch = false             -- Disable the touch module (boolean)
  t.modules.video = false             -- Disable the video module (boolean)
  t.modules.window = false            -- Disable the window module (boolean)
end