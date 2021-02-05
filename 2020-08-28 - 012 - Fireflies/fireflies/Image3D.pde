class Image3D {
  static final int FIREFLY = 0;
  static final int SCENERY = 1;
  
  int type;
  PImage img;
  PVector pos;
  color col;
  int blendMode;
  float scale;
  
  public Image3D(PImage img, PVector pos) {
    this.type = SCENERY;
    this.img = img;
    this.pos = pos;
    this.scale = 1f;
    this.col = color(255,255,255);
    this.blendMode = NORMAL;
  }
  
  public Image3D(PImage img, PVector pos, float scale, color col, int blendMode) {
    this.type = FIREFLY;
    this.img = img;
    this.pos = pos;
    this.scale = scale;
    this.col = col;
    this.blendMode = blendMode;
  }
}
