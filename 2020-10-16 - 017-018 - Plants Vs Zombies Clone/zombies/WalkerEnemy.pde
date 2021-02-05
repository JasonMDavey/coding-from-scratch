class WalkerEnemy extends Enemy {
  float walkSpeed;
  
  public WalkerEnemy(float xPos, float yPos, int health, float walkSpeed) {
    super(xPos, yPos);
    
    this.health = health;
    this.walkSpeed = walkSpeed;
    
    sprite.spritesheet = zombieImage;
    sprite.spriteFootOffset = 19;
  
    sprite.animations.put("idle", new Animation(0, 0, 64, 64, 10, 1f/20f, true));
    sprite.animations.put("hurt", new Animation(0, 64, 64, 64, 1, 5f/20f, false));
    sprite.animations.put("attack", new Animation(0, 128, 64, 64, 11, 1f/20f, false));
    sprite.changeAnimation("idle");
  }
  
  @Override
  public void update(float secondsElapsed) {
    super.update(secondsElapsed);
    
    this.xPos -= walkSpeed * secondsElapsed;
    
    Hero heroHere = checkForHeroInFront();
    if (heroHere != null) {
      if (!sprite.currentAnimationName.equals("attack")) {
        sprite.changeAnimation("attack");
      }
      else if (sprite.isAnimationComplete()) {
        // Deal damage
        heroHere.health -= 1;
        if (heroHere.health > 0) {
          // Attack again!
          sprite.changeAnimation("attack");
        }
      }
    }
    else if (!sprite.currentAnimationName.equals("idle")) {
      sprite.changeAnimation("idle");
    }
  }
}
  
