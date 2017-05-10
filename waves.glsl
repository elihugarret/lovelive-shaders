extern number iGlobalTime;
vec4 resolution = love_ScreenSize;
int a = 0;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
  a++;
  if (a > 100) a = 0;
  vec2 p = (screen_coords.xy * 2.0 - resolution.xy) / min(resolution.x, resolution.y);
  vec3 destcolor = vec3(4.0/255.0, 32.0/255.0, 41.0/255.0);
  float f = 0.0;
  for(float i = 0.0; i < 100.0; i++){
    float s = tan(iGlobalTime + f * 0.0728318 * 1000.0) * 0.8;
    float c = sin(iGlobalTime + i * 0.628318) * 2.8;
    f += 0.009 / abs(length(p / vec2(c, s)) - 0.5);
  }
  return vec4(vec3(destcolor * f), 1);
}
