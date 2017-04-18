
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
      extern number val1;

      float field(in vec3 p){
        float strength = (7.0 - val1) + 0.03 * log(1.e-6 + fract(sin(iGlobalTime) * 4373.11));
        float accum = 0.0;
        float prev = 0.0;
        float tw = 0.0;
        for (int i = 0; i < 32; ++i){
          float mag = dot(p, p);
          p = abs(p) / mag + vec3(-0.15, -0.4, -1.5);
          float w = exp(-float(i) / 7.0);
          accum += w * exp(-strength * pow(abs(mag - prev), 2.3));
          tw += w;
          prev = mag;
        }
        return max(0.0, 5.0 * accum / tw - 0.7);
      }

      vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
        vec2 uv = 2.0 * screen_coords.xy / love_ScreenSize.xy - 1.0;
        vec2 uvs = uv - love_ScreenSize.xy / max(love_ScreenSize.x, love_ScreenSize.y);
        vec3 p = vec3(uvs / 2.0, 0) + vec3(1.0, -1.13, 0.0);
        p += .8 * vec3(cos(iGlobalTime / 16.0), cos(iGlobalTime / 12.0), sin(iGlobalTime / 128.0));
        float t = field(p);
        float v = (1.0 - exp((abs(uv.x) - 11.0) * 6.0)) + (1.0 - exp((abs(uv.x) - 1.0) * 6.0));
        return mix(0.4, 1.0, v) * vec4(0.8 * t + t * t, 1.4 * t * t, t, 1.0); //color
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
  myShader:send("val1", value1)
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
