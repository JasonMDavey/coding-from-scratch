class Particle {
  static final float MAX_SPEED = 75f;
  static final float NOISE_INTENSITY = 20f;
  static final float NOISE_SCALE = 0.01f;
  static final float NOISE_TIMESCALE = 0.001f;
  static final float GRAVITY = 20.0f;
  
  PVector pos = new PVector();
  PVector vel = new PVector();
  
  void spawn() {
    pos.x = random(-SCENE_WIDTH*0.5f,SCENE_WIDTH*1.5f);
    pos.y = random(-SCENE_HEIGHT*0.5f, SCENE_HEIGHT);
    
    vel.x = 0f;
    vel.y = random(5,20);
  }
  
  void respawn() {
    pos.x = random(-SCENE_WIDTH*0.5f,SCENE_WIDTH*1.5f);
    pos.y = -5;

    vel.x = 0f;
    vel.y = random(5,20);
  }
  
  void update(float deltaSeconds) {
    // Sample perlin noise to get a random direction
    float t = millis() * NOISE_TIMESCALE;
    
    float noiseVal = noise(pos.x*NOISE_SCALE, pos.y*NOISE_SCALE, t* NOISE_TIMESCALE);
    float angle = noiseVal * TWO_PI + PI*0.5f; // Rotate to bias towards upwards direction
    
    // Accelerate the particle in the direction derived from noise
    vel.x += cos(angle) * NOISE_INTENSITY * deltaSeconds;
    vel.y += sin(angle) * NOISE_INTENSITY * deltaSeconds;
    
    // Gravity 
    vel.y += GRAVITY * deltaSeconds;
    
    // Limit velocity
    if (vel.magSq() > MAX_SPEED*MAX_SPEED) {
      vel.setMag(MAX_SPEED);
    }
    
    pos.x += vel.x * deltaSeconds;
    pos.y += vel.y * deltaSeconds;
    
    if (pos.x < -SCENE_WIDTH*0.5f || pos.x >= SCENE_WIDTH*1.5f || pos.y < -SCENE_HEIGHT*0.5f || pos.y >= SCENE_HEIGHT) {
      // Went out-of-bounds
      respawn();
    }
    
    // If any of our neighbouring pixels are filled, settle here
    int x = round(pos.x);
    int y = round(pos.y);
    
    if (x >= 0 && x < SCENE_WIDTH && y >= 0 && y < SCENE_HEIGHT) {
      for (int xOff = -1; xOff <= 1; ++xOff) {
        for (int yOff = -1; yOff <= 1; ++yOff) {
          if (isSceneryPixelSet(x+xOff, y+yOff)) {
            if (alpha(sceneryImage.pixels[x + y*sceneryImage.width]) == 0) {
              // Only settle if the pixel is empty
              sceneryImage.pixels[x + y*sceneryImage.width] = SNOW_COLOR;
            }
            respawn();
            return;
          }
        }
      }
    }
  }
  
  void draw() {
    // Draw a white dot at the particle's position
    rectMode(CENTER);
    fill(255);
    noStroke();
    rect(pos.x, pos.y, 1, 1);
  }
}
