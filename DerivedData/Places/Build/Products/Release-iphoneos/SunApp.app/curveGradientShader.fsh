
void main() {
  vec4 current_color = SKDefaultShading();
  
  float x = center_point.x;
  float y = center_point.y;
  
  float maxD = minmax_dist.y;
  float minD = minmax_dist.x;
  
  //float x = 0;
  //float y = 0;
  
  //float maxD = 1000;
  //float minD = 800;
  
  float a = gl_FragCoord.x - x;
  float b = gl_FragCoord.y - y;
  
  float dist = sqrt(a * a + b * b);
  
  current_color.a = max(min((dist - minD) / (maxD - minD),1.0),0.0);
  if(reverse < 0.0){
    current_color.a = 1.0 - current_color.a;
  }
  current_color.a = max(current_color.a - 0.1,0.0);
  current_color.a /= 2;
  
  current_color.r *= current_color.a;
  current_color.g *= current_color.a;
  current_color.b *= current_color.a;

  gl_FragColor = current_color;
}
