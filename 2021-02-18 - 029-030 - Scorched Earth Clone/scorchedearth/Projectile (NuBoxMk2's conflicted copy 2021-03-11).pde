class Projectile {
  
  PVector pos;
  PVector vel;
  color col;
  float explosionRadius;
  
  boolean isDead;
  
  ArrayList<PVector> oldPoss = new ArrayList<PVector>();
  
  public Projectile(PVector pos, PVector vel, color col, float explosionRadius) {
    this.pos = pos;
    this.vel = vel;
    this.col = col;
    this.explosionRadius = explosionRadius;
  }
  
  void update(float deltaSeconds) {
    if (isDead) return;
    
    oldPoss.add(new PVector(pos.x, pos.y, pos.z));
    
    // Physics
    this.vel.add(PVector.mult(GRAVITY, deltaSeconds));
    this.vel.add(PVector.mult(wind, deltaSeconds));
    this.pos.add(PVector.mult(vel, deltaSeconds));
    
    // Collision detection with terrain
    int roundedX = Math.round(pos.x);
    int roundedY = Math.round(pos.y);
    if (roundedX < 0 || roundedX >= WORLD_WIDTH || roundedY >= WORLD_HEIGHT) {
      // Out-of-bounds!
      isDead = true;
      return;
    }
    
    if (roundedY < 0) {
      // Off the top of the screen - bail out to avoid checking a non-existent pixel in the terrain texture
      return;
    }
    
    // Check to see if we've collided with the terrain texture
    terrainTexture.loadPixels();
    if (terrainTexture.pixels[roundedX + roundedY*terrainTexture.width] == TERRAIN_COLOR) {
      // Collision! We've hit a solid pixel in the terrain texture
      activeExplosions.add(new Explosion(pos, explosionRadius));
      isDead = true;
    }
    terrainTexture.updatePixels();
  }
  
  void draw() {

    noFill();
    stroke(100,100,255);
    strokeWeight(1);
    beginShape();
    for (PVector p : oldPoss) {
      vertex(p.x, p.y);
    }
    endShape();
    
    if (isDead) return;
    
    noFill();
    stroke(col);
    strokeWeight(2);
    point(pos.x, pos.y);
  }
  
  void onSecondaryInput() {}
}
