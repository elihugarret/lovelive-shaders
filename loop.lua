
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
	vec2 p = -1.0 + 2.0 * screen_coords.xy / love_ScreenSize.xy;
	float a = iGlobalTime*60.0;
	float d,e,f,g=2.0/40.0,h,i,r,q;
	e=400.0*(p.x*0.5+0.5);
	f=400.0*(p.y*0.5+0.5);
	i=200.0+sin(e*g+a/150.0)*20.0;
	d=200.0+sin(f*g/2.0)*18.0+cos(e*g)*7.0;
	r=sqrt(pow(i-e,2.0)+pow(d-f,2.0));
	q=f/r;
	e=(r*cos(q))-a/2.0;f=(r*tan(q))-a/1.0;
	d=sin(e*g)*176.0+cos(e*g)*164.0+r;
	h=((f+d)+a/2.0)*g;
	i=cos(h+r*p.x/1.3)*(e+e+a)+cos(q*g*6.0)*(r+h/3.0);
	h=sin(f*g)*144.0-sin(e*g)*212.0*p.x;
	h=(h+(f-e)*q+sin(r-(a+h)/7.0)*10.0+i/4.0)*g;
	i+=cos(h*2.3*sin(a/350.0-q))*284.0*sin(q-(r*4.3+a/12.0)*g)+tan(r*g+h)*184.0*cos(r*g+h);
	i=mod(i/4.6,256.0)/64.0;
	if(i<0.0) i+=4.0;
	if(i>=2.0) i=4.0-i;
	d=r/350.0;
	d+=sin(d*d*8.0)*0.52;
	f=(sin(a*g)+1.0)/2.0;
	return vec4(vec3(f*i/1.6,i/2.0+d/13.0,i)*d*p.x+vec3(i/1.3+d/8.0,i/2.0+d/18.0,i)*d*(1.0-p.x),1.0);

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
