class Animation {
  int topLeftX, topLeftY;
  int frameWidth, frameHeight;
  int numFrames;
  float frameDurationSeconds;
  boolean looping;
  
  public Animation(int topLeftX, int topLeftY, int frameWidth, int frameHeight, int numFrames, float frameDurationSeconds, boolean looping) {
    this.topLeftX = topLeftX;
    this.topLeftY = topLeftY;
    this.frameWidth = frameWidth;
    this.frameHeight = frameHeight;
    this.numFrames = numFrames;
    this.frameDurationSeconds = frameDurationSeconds;
    this.looping = looping;
  }
}
