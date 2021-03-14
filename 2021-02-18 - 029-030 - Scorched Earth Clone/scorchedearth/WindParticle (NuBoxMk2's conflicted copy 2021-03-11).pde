class WindParticle {
  PVector pos = new PVector();
  PVector vel = new PVector();
  
  void update(float deltaSeconds) {
    vel = PVector.lerp(vel, PVector.mult(wind,5f), 0.05f);
    
    pos.add(PVector.mult(vel, deltaSeconds));
    
    // Wrap around screen when out-of-bounds
    if (pos.x < 0) {
      pos.x += WORLD_WIDTH;
    }
    else if (pos.x >= WORLD_WIDTH) {
      pos.x -= WORLD_WIDTH;
    }
    else if (pos.y < 0) {
      pos.y += WORLD_HEIGHT;
    }
    else if (pos.y >= WORLD_HEIGHT) {
      pos.y -= WORLD_HEIGHT;
    }
  }
  
  void draw() {
    noFill();
    stroke(color(170,200,220));
    strokeWeight(1);
    point(pos.x, pos.y);
  }
  
  void respawn() {
    pos = new PVector(random(0,WORLD_WIDTH), random(0,WORLD_HEIGHT));
    vel.set(wind.x,wind.y);
  }
}
