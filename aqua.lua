
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

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
	vec2 p = (screen_coords.xy / love_ScreenSize.xy * 4.0) - vec2(15.0);
	vec2 i = p;
	float c = 1.0;
	float inten = .05;
	for (int n = 0; n < 32; n++){
		float t = -iGlobalTime + (0.5 - (2.0 / float(n+1)));
		i = p - vec2(cos(t / i.x) + cos(t + i.y), sin(t - i.y) - cos(t + i.x));
		c -= 1.0/length(vec2(p.x / (2.*cos(i.x+t)/inten),p.y / (sin(i.y+t)/inten)));
	}
	c /= float(32);
	c = 1.5-sqrt(pow(c,3.2));
	float col = c*c*c*c;
	return vec4(vec3(col * 0.2, col * 0.75, col * 1.1), 1.0);
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
