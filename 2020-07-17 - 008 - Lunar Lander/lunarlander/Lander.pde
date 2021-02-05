class Lander {
  static final float LAND_RADIUS = 35;
  static final float CRASH_RADIUS = 30;
    
  Sprite sprite;
  
  LanderState state = LanderState.GROUNDED;
  float fuel = 1f;
  
  PVector pos;
  float rotation = 0f;
  
  PVector vel = new PVector(0,0);
  
  public Lander(PVector pos) {
    this.pos = pos;
    
    this.sprite = new Sprite(loadImage("engi_sprite.png"));
    sprite.animations.put("idle", new Animation(0, 0, 128, 128, 12, 1f/20f, true));
    sprite.animations.put("takeoff", new Animation(0, 128, 128, 128, 5, 1f/20f, false));
    sprite.animations.put("fly", new Animation(0, 128*2, 128, 128, 7, 1f/20f, true));
    sprite.animations.put("hover", new Animation(128*7, 128*2, 128, 128, 1, 1f/20f, true));
    sprite.animations.put("land", new Animation(0, 128*3, 128, 128, 4, 1f/20f, false));
    
    sprite.changeAnimation("idle");
  }
  
  public void update(float deltaSeconds) {
    sprite.updateAnimation(deltaSeconds);
    
    switch (state) {
      case GROUNDED: takeoffIfThrustPressed(); break;
      case TAKEOFF:  launchWhenTakeoffAnimationDone(); break;
      case FLYING:   fly(deltaSeconds);        break;
      case LANDING:  settleWhenLandingAnimationDone(); break;
      case DEAD: break;
    }
  }
  
  private void takeoffIfThrustPressed() {
    if (heldKeys.contains(UP)) {
      sprite.changeAnimation("takeoff");
      state = LanderState.TAKEOFF;
    }
  }
  
  private void launchWhenTakeoffAnimationDone() {
    if (heldKeys.contains(UP)) {
      if (sprite.isAnimationComplete()) {
        vel.set(0, -10, 0);
        sprite.changeAnimation("fly");
        state = LanderState.FLYING;
      }
    }
    else {
      sprite.changeAnimation("idle");
      state = LanderState.GROUNDED;
    }
  }
  
  private void settleWhenLandingAnimationDone() {
    if (sprite.isAnimationComplete()) {
      sprite.changeAnimation("idle");
      state = LanderState.GROUNDED;
    }
  }
  
  private void fly(float deltaSeconds) {
    // Rotation
    if (heldKeys.contains(RIGHT)) {
      rotation += ROTATION_SPEED * deltaSeconds;
      if (rotation > TWO_PI) { rotation -= TWO_PI; }; // Wrap angle
    }
    
    if (heldKeys.contains(LEFT)) {
      rotation -= ROTATION_SPEED * deltaSeconds;
      if (rotation < -TWO_PI) { rotation += TWO_PI; }; // Wrap angle
    }
    
    // Thrust
    if (heldKeys.contains(UP) && fuel > 0f) {
      // Determine thrust vector, based on which direction we're facing
      PVector thrustVector = PVector.fromAngle(rotation - PI/2f);
      thrustVector.mult(THRUST_STRENGTH * deltaSeconds);
      
      vel.add(thrustVector);
      
      fuel = max(0f, fuel - FUEL_CONSUMPTION_RATE*deltaSeconds);
      
      if (sprite.currentAnimation != sprite.animations.get("fly")) {
        sprite.changeAnimation("fly");
      }
    }
    else {
      sprite.changeAnimation("hover");
    }
    
    // Gravity
    vel.add(0, GRAVITY_STRENGTH * deltaSeconds, 0);
        
    // Apply velocity to position
    pos.add(PVector.mult(vel, deltaSeconds));
    
    // Check for collisions with terrain
    collideWithTerrain();
  }

  private void collideWithTerrain() {
    for (int i=0; i<terrainHeights.length-1; ++i) {
      PVector startPoint = getTerrainPoint(i);
      PVector endPoint = getTerrainPoint(i+1);
      
      /*
       * Determine distance from lander to terrain line segment
       */
       
      // t is ratio along vector from start->end, in range 0-1
      float t = ((pos.x-startPoint.x)*(endPoint.x-startPoint.x)
               + (pos.y-startPoint.y)*(endPoint.y-startPoint.y))
               / PVector.sub(endPoint, startPoint).magSq();
      
      float distSquared;       
      if (t < 0) {
        distSquared = PVector.sub(pos, startPoint).magSq();
      }
      else if (t > 1) {
        distSquared = PVector.sub(pos, endPoint).magSq(); 
      }
      else {
        // Find closest point along line segment
        float x = startPoint.x + t*(endPoint.x-startPoint.x);
        float y = startPoint.y + t*(endPoint.y-startPoint.y);
        PVector closestPoint = new PVector(x,y);
        
        distSquared = PVector.sub(pos, closestPoint).magSq(); 
      }
      
      if (distSquared < LAND_RADIUS*LAND_RADIUS) {
        // Touched terrain! Was this a landing, or a crash!?
        if (hasCrashed(startPoint, endPoint)) {
          if (distSquared < CRASH_RADIUS*CRASH_RADIUS) {
            // Crash =(
            state = LanderState.DEAD;
            break;
          }
        }
        else {
          // Landed!
          sprite.changeAnimation("land");
          state = LanderState.LANDING;
          vel.set(0,0);
          rotation = 0f;
          pos.y = startPoint.y - LAND_RADIUS;
        }
      }
    }
  }
  
  boolean hasCrashed(PVector startPoint, PVector endPoint) {
    if (startPoint.y != endPoint.y) return true;  // Ground must be level
    if (!isAtLandingSpeedAndOrientation()) return true;   // Don't come in too hot, or upside-down!
    return false;
  }
  
  boolean isAtLandingSpeedAndOrientation() {
    if (abs(vel.x) > LANDING_X_SPEED_THRESHOLD) return false;           // X speed must be reasonable (either left or right)
    if (vel.y < 0 || vel.y > LANDING_Y_SPEED_THRESHOLD) return false;   // Must be moving down, slowly
    
    float rotationOffset;
    if (rotation > PI) { rotationOffset = abs(rotation-TWO_PI); }
    else if (rotation < -PI) { rotationOffset = abs(rotation+TWO_PI); }
    else { rotationOffset = abs(rotation); }
    
    if (abs(rotationOffset) > LANDING_ROTATION_THRESHOLD) return false;       // Must be upright
    return true;
  }
  
  public void draw() {
    pushMatrix();
      translate(pos.x, pos.y);
      rotate(rotation);
      
      if (state == LanderState.DEAD) {
        tint(255,0,0);
      }
      else if (state == LanderState.FLYING && isAtLandingSpeedAndOrientation()) {
        tint(0,255,0);
      }
      else {
        tint(255,255,255);
      }
        
      sprite.draw();
    popMatrix();
  }
}
