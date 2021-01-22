// Main
void main(void) {
  vec4 current_color = SKDefaultShading();
  
  if (current_color.a > 0.0) {
    gl_FragColor = vec4(1,1,1,1);
  } else {
    gl_FragColor = current_color;
  }
}
