class Explosion {
  final float DURATION_SECONDS = 1.0f;
  
  PVector pos;
  float radius;
  float timeElapsed;
  
  boolean isTriggered;
  boolean isDead;
  
  public Explosion(PVector pos, float radius) {
    this.pos = pos;
    this.radius = radius;
  }
  
  void update(float deltaSeconds) {
    timeElapsed += deltaSeconds;
    
    if (timeElapsed >= DURATION_SECONDS) {
      isDead = true;
    }
  }
  
  void draw() {
    float animationProgress = constrain(timeElapsed / DURATION_SECONDS, 0f, 1f);
    
    if (animationProgress >= 0.5f && !isTriggered) {
      // Carve out terrain
      terrainTexture.loadPixels();
      int leftX = (int)Math.max(0, pos.x-radius);
      int rightX = (int)Math.min(WORLD_WIDTH-1, pos.x+radius);
      int topY = (int)Math.max(0, pos.y-radius);
      int bottomY = (int)Math.min(WORLD_HEIGHT-1, pos.y+radius);
      for (int x=leftX; x<=rightX; ++x) {
        for (int y=topY; y<=bottomY; ++y) {
          float distSq = new PVector(x-pos.x, y-pos.y).magSq();
          if (distSq < radius*radius) {
            terrainTexture.pixels[x + y*terrainTexture.width] = AIR_COLOR;
          }
        }
      }
      
      terrainTexture.updatePixels();
      isTriggered = true;
    }
    
    float currentRadius = radius * sin(animationProgress * PI);
    noStroke();
    fill(255,180,60);
    ellipseMode(CENTER);
    ellipse(pos.x, pos.y, currentRadius*2, currentRadius*2);
  }
}
