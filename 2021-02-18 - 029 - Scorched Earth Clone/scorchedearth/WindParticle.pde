class WindParticle {
  PVector pos = new PVector();
  PVector vel = new PVector();
  
  void update(float deltaSeconds) {
    //this.vel.add(PVector.mult(GRAVITY, deltaSeconds));
    vel.add(PVector.mult(wind, deltaSeconds));
    pos.add(PVector.mult(vel, deltaSeconds));
    
    if (pos.x < 0 || pos.x >= WORLD_WIDTH || pos.y < 0 || pos.y >= WORLD_HEIGHT) {
      // Out of bounds - respawn elsewhere
      respawn();
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
    vel.set(0,0);
  }
}
