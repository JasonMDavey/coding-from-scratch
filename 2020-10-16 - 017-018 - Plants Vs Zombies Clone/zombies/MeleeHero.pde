class MeleeHero extends Hero {
  
  float ATTACK_INTERVAL_SECONDS = 2f;
  float DAMAGE_AMOUNT = 10;
  
  float attackIntervalCounter = 0f;
  
  public MeleeHero(int row, int column) {
    super(row, column);
    
    health = 50;
    
    sprite.spritesheet = warriorImage;
    sprite.spriteFootOffset = 62;
  
    sprite.animations.put("idle", new Animation(0, 0, 128, 128, 35, 1f/20f, true));
    sprite.animations.put("attack", new Animation(0, 128*2, 128, 128, 27, 1f/20f, false));
    sprite.animations.put("die", new Animation(0, 128*3, 128, 128, 35, 1f/20f, false));
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
    
    // Find the closest enemy in front of us (so we can attack them!)
    Enemy closestEnemy = null;
    float closestDistance = 0;
    
    for (Enemy e : enemies.get(this.row)) {
      float distanceToEnemy = e.xPos - this.column;
      
      if (e.health > 0 && distanceToEnemy >= 0 && distanceToEnemy <= 0.1f) {
        if (closestEnemy == null || closestDistance > distanceToEnemy) {
          closestEnemy = e;
          closestDistance = distanceToEnemy;
        }
      }
    }
    
    // Attack periodically
    attackIntervalCounter += secondsElapsed;
    if (attackIntervalCounter >= ATTACK_INTERVAL_SECONDS) {
      // Reset counter
      attackIntervalCounter -= ATTACK_INTERVAL_SECONDS;
      
      // Play attacking animation (only if there is at least one enemy in this lane)
      if (closestEnemy != null) {
        sprite.changeAnimation("attack");
      }
    }
    
    if (sprite.currentAnimationName.equals("attack") && sprite.isAnimationComplete()) {
      // Attack animation complete - damage an enemy!
      sprite.changeAnimation("idle");
      
      // If we found an enemy, damage it
      if (closestEnemy != null) {
        closestEnemy.health -= DAMAGE_AMOUNT;
      }
    }
  }
}
