class RangedHero extends Hero {
  
  float SHOOT_INTERVAL_SECONDS = 2.5f;
  float SHOOT_DAMAGE_AMOUNT = 3;
  
  float shootIntervalCounter = 0f;
  
  public RangedHero(int row, int column) {
    super(row, column);
    
    health = 5;
    
    sprite.spritesheet = rangerImage;
    sprite.spriteFootOffset = 62;
  
    sprite.animations.put("idle", new Animation(0, 0, 128, 128, 12, 1f/20f, true));
    sprite.animations.put("shoot", new Animation(0, 128, 128, 128, 20, 1f/20f, false));
    sprite.animations.put("die", new Animation(0, 256, 128, 128, 83, 1f/20f, false));
    sprite.changeAnimation("idle");
  }
  
  @Override
  public void update(float secondsElapsed) {
    super.update(secondsElapsed);
    
    // Play death animation when health reaches zero
    if (health <= 0) {
      health = 0;
      if (!sprite.currentAnimationName.equals("die")) {
        sprite.changeAnimation("die");
      }
      else if (sprite.isAnimationComplete()) {
        dead = true;
      }
      return;
    }
    
    // Find the closest enemy in front of us (so we can shoot them!)
    Enemy closestEnemy = null;
    float closestDistance = 0;
    
    for (Enemy e : enemies.get(this.row)) {
      float distanceToEnemy = e.xPos - this.column;
      
      if (e.health > 0 && distanceToEnemy >= 0) {
        if (closestEnemy == null || closestDistance > distanceToEnemy) {
          closestEnemy = e;
          closestDistance = distanceToEnemy;
        }
      }
    }
    
    // Shoot periodically
    shootIntervalCounter += secondsElapsed;
    if (shootIntervalCounter >= SHOOT_INTERVAL_SECONDS) {
      // Reset counter
      shootIntervalCounter -= SHOOT_INTERVAL_SECONDS;
      
      // Play shooting animation (only if there is at least one enemy in this lane)
      if (closestEnemy != null) {
        sprite.changeAnimation("shoot");
      }
    }
    
    if (sprite.currentAnimationName.equals("shoot") && sprite.isAnimationComplete()) {
      // Shooting animation complete - damage an enemy!
      sprite.changeAnimation("idle");
      
      // If we found an enemy, damage it
      if (closestEnemy != null) {
        closestEnemy.health -= SHOOT_DAMAGE_AMOUNT;
      }
    }
  }
}
