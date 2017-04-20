
local app = {}
local socket = require"socket"

function app.liveconf(t)
  t.live = true
  t.use_pcall = true
  t.autoreload.enable = true
  t.autoreload.interval = 1.0
  t.reloadkey = "f5"
  t.gc_before_reload = false
  t.error_file = nil  -- "error.txt"
end

function app.load()
  udp = socket.udp()
  local data
  udp:settimeout(0)
  udp:setsockname("*", 12345)
  value1 = 0
  time = 0
  app.reload()
end

function app.reload()
    myShader = love.graphics.newShader[[
      extern number iGlobalTime;
      //extern number val1;

      vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
        vec2 p = (screen_coords.xy / love_ScreenSize.xy) - 0.5;
        float sx = 0.1 * (p.x * 0.16) * sin(200.0 * p.y - 10.0 * iGlobalTime);
        float dy = 4.0 / (100.0 * abs(p.y - sx));
        dy += (vec2(p.x, 0.0) * 0.6 / (10.0 * length(p + vec2(p.y, 0.0)))).y;
        sx += (vec2(p.y, 0.0) * 0.1 * (p.yx * 0.9) + dy).x;
        return vec4((p.x + 0.15) * dy, 0.2 * dy, dy, 10.0);
      }
   ]]
end

function app.update(dt)
  time = time + dt;
  data = udp:receivefrom()
  if data then 
    value1 = tonumber(data) 
  end
	myShader:send("iGlobalTime", time)
  --myShader:send("val1", value1)
end

function app.draw()
  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()
  love.graphics.setShader(myShader)
	love.graphics.rectangle("fill", 0, 0, width, height)
  love.graphics.setShader()
  love.timer.sleep(.001)
end

return app
