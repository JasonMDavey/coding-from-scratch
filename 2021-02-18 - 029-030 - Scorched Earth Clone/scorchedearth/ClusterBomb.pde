class ClusterBomb extends Projectile {
  final int CHILD_COUNT = 5;
  final float SPREAD_ANGLE = PI*0.25;
  final float CHILD_SPEED = 25f;
  final float CHILD_EXPLOSION_RADIUS = 8f;
  
  public ClusterBomb(PVector pos, PVector vel, color col, float explosionRadius) {
    super(pos, vel, col, explosionRadius);
  }
  
  @Override
  void onSecondaryInput() {
    isDead = true;
    
    // Spawn children with an even spread
    float startAngle = -PI*0.5f - SPREAD_ANGLE;
    float totalSpread = SPREAD_ANGLE * 2f;
    float angleStep = totalSpread / (CHILD_COUNT+1);
    for (int i=0; i<CHILD_COUNT; ++i) {
      float launchAngle = startAngle + (i+1)*angleStep;
      PVector launchDirection = PVector.fromAngle(launchAngle);
      PVector launchVel = launchDirection.mult(CHILD_SPEED).add(vel);
      
      activeProjectiles.add(new Projectile(new PVector(pos.x, pos.y), launchVel, col, CHILD_EXPLOSION_RADIUS));
    }
  }
}
