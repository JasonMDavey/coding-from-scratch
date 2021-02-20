class Projectile {
  PVector pos;
  PVector vel;
  color col;
  boolean isDead;
  
  public Projectile(PVector pos, PVector vel, color col) {
    this.pos = pos;
    this.vel = vel;
    this.col = col;
  }
  
  void update(float deltaSeconds) {
    if (isDead) return;
    
    // Physics
    this.vel.add(PVector.mult(GRAVITY, deltaSeconds));
    this.vel.add(PVector.mult(wind, deltaSeconds));
    this.pos.add(PVector.mult(vel, deltaSeconds));
    
    // Collision detection
    int roundedX = Math.round(pos.x);
    int roundedY = Math.round(pos.y);
    if (roundedX < 0 || roundedX >= WORLD_WIDTH || roundedY >= WORLD_HEIGHT) {
      // Out-of-bounds!
      isDead = true;
      return;
    }
    
    if (roundedY < 0) {
      return; // Off the top of the screen
    }
    
    // Check to see if we've collided with the terrain texture
    terrainTexture.loadPixels();
    if (terrainTexture.pixels[roundedX + roundedY*terrainTexture.width] == TERRAIN_COLOR) {
      // Collision!     
      activeExplosion = new Explosion(pos, 20);
      isDead = true;
    }
    terrainTexture.updatePixels();
  }
  
  void draw() {
    if (isDead) return;
    
    noFill();
    stroke(col);
    strokeWeight(2);
    point(pos.x, pos.y);
  }
}
