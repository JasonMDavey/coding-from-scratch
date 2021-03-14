class Tank {
  final float MIN_TURRET_ANGLE = -PI*0.9f;
  final float MAX_TURRET_ANGLE = -PI*0.1f;
  
  final float TURRET_LENGTH = 7;
  
  PVector pos;
  color col;
  float aimAngle;
  int health = 3;
  
  public Tank(PVector pos, color col) {
    this.pos = pos;
    this.col = col;
    this.aimAngle = -PI/2f;
  }
  
  void turnTurret(float delta) {
    aimAngle = constrain(aimAngle+delta, MIN_TURRET_ANGLE, MAX_TURRET_ANGLE);
  }
  
  void onHit() {
    if (health > 0) {
      --health;
    }
  }
  
  Projectile launchProjectile(float speed, ProjectileType projectileType) {
    PVector turretDirection = PVector.fromAngle(aimAngle);
    PVector spawnPos = PVector.add(pos, PVector.mult(turretDirection,TURRET_LENGTH)); // Spawn at tip of turret
    PVector spawnVel = PVector.mult(turretDirection, speed);
    
    switch (projectileType) {
      case REGULAR:       return new Projectile(spawnPos, spawnVel, col, 20f);
      case CLUSTER_BOMB:  return new ClusterBomb(spawnPos, spawnVel, col, 15f);
      default:            throw new RuntimeException("Attempt to launch invalid projectile type =(");
    }
    
  }
  
  void update(float deltaSeconds) {

    // If we're off the bottom of the screen, we're dead!
    if ((int)pos.y >= WORLD_HEIGHT) {
      health = 0;
      pos.y += 1;
      return;
    }

    // If there is no ground beneath us, fall down one pixel
    terrainTexture.loadPixels();
    boolean groundExists = false;
    for (int x=(int)(pos.x-TANK_SIZE/2f); x<=(int)(pos.x+TANK_SIZE/2f); ++x) {
      if (terrainTexture.pixels[x + (int)pos.y*terrainTexture.width] == TERRAIN_COLOR) {
        groundExists = true;
        break;
      }
    }
    terrainTexture.updatePixels();
    
    if (!groundExists) {
      pos.y += 1;
    }
  }
  
  void draw() {
    pushMatrix();
      translate(pos.x, pos.y);
      
      // Draw body
      noStroke();
      fill(col);
      beginShape();
      vertex(-TANK_SIZE/2, 0);
      vertex(-TANK_SIZE/2, -2);
      vertex(-TANK_SIZE/2 + 1, -3);
      vertex(TANK_SIZE/2 - 1, -3);
      vertex(TANK_SIZE/2, -2);
      vertex(TANK_SIZE/2, 0);
      endShape(CLOSE);
      
      // Draw turret
      stroke(col);
      strokeWeight(1);
      noFill();
      rotate(aimAngle);
      line(2,0,7,0);
      
    popMatrix();
  }
}
