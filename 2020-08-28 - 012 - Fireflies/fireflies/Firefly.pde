class Firefly {
  PVector pos;
  PVector vel;
  PVector seekPos;
  float phase;
  
  public Firefly(PVector pos) {
    this.pos = pos;
    this.vel = new PVector(0,0,0);
    this.phase = random(0f, 10f);
  }
  
  public void update(float timeDeltaSeconds) {
    if (seekPos == null || PVector.sub(pos, seekPos).mag() < FIREFLY_SEEK_RANGE) {
      // Pick a new seek position
      seekPos = generateRandomFireflyPosition();
      seekPos.z = pos.z; // Prevent fireflies from moving depth-wise
    }
    
    // Accelerate towards our seek position
    PVector vectorToTarget = PVector.sub(seekPos, pos);
    vectorToTarget.setMag(FIREFLY_ACCELERATION);
    vectorToTarget.mult(timeDeltaSeconds);
    vel.add(vectorToTarget);
    
    // Enforce max speed!
    float speed = vel.mag();
    if (speed > FIREFLY_MAX_SPEED) {
      vel.setMag(FIREFLY_MAX_SPEED);
    }
    
    // Move!
    pos.add(PVector.mult(vel, timeDeltaSeconds));
    
    if (pos.z > MAX_PLANE_DEPTH) {
      println("uhoh!");
    }
  }
  
  public void draw() {
    float secondsElapsed = (millis()/1000f) + phase;
    float brightness = max( 0f, 1f-(float)Math.pow(1f-sin(secondsElapsed), 3) );
    color col = color(255, 255, 255, 255*brightness);
    
    float parallaxOffset = calculateParallaxOffset(cameraX, pos.z);
    float scale = map(pos.z, MIN_PLANE_DEPTH, MAX_PLANE_DEPTH*0.5f, 1.5f, 0f);
    drawQueue.add(new Image3D(fireflyImage, new PVector(pos.x + parallaxOffset, pos.y, -pos.z), scale, col, ADD));
  }
}
