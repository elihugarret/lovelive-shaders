
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

float noice(){
    float k = 2.0;
    k = k * (1.0 + 0.5 * sin(100.0 * iGlobalTime));
    return k;
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
    float k = screen_coords.x / love_ScreenSize.x;
    float b = screen_coords.y / love_ScreenSize.y;
    float l = iGlobalTime / 1.5;
    float c = 0.05 / abs(5.0 / k - 2.0 - (sin(b-l)));
    float d = 0.05 * abs(2.0 * k - 2.0 - (tan(10305.0 + b+l) + cos(10000035.0 * b - 1.0 * l) + tan(10035.0 * b - 1.0 * l)));
    float c2 = 0.05 / abs(5.0 * k - 2.0 -(tan(b-l)));
    vec4 i = vec4(0.13 - c2, c + 0.3 * c2, 0.0, 1.0) + vec4(0.0, d, 0.0, 1.0);
    return i;
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
