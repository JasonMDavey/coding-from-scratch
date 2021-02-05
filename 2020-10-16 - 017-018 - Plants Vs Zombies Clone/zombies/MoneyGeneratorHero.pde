class MoneyGeneratorHero extends Hero {
  
  float MONEY_GENERATION_INTERVAL_SECONDS = 10f;
  float MONEY_GENERATION_AMOUNT = 25;
  
  float moneyIntervalCounter = 0f;
  
  public MoneyGeneratorHero(int row, int column) {
    super(row, column);
    
    health = 10;
    
    sprite.spritesheet = engiImage;
    sprite.spriteFootOffset = 62;
  
    sprite.animations.put("idle", new Animation(0, 0, 128, 128, 12, 1f/20f, true));
    sprite.animations.put("money!", new Animation(0, 128, 128, 128, 31, 1f/20f, false));
    sprite.animations.put("die", new Animation(0, 256, 128, 128, 28, 1f/20f, false));
    sprite.changeAnimation("idle");
  }
  
  @Override
  public void update(float secondsElapsed) {
    super.update(secondsElapsed);
    
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
    
    // Generate money at regular intervals
    moneyIntervalCounter += secondsElapsed;
    if (moneyIntervalCounter >= MONEY_GENERATION_INTERVAL_SECONDS) {
      // Reset counter
      moneyIntervalCounter -= MONEY_GENERATION_INTERVAL_SECONDS;
            
      // Give the player some money
      money += MONEY_GENERATION_AMOUNT;
      
      // Play money generation animation
      sprite.changeAnimation("money!");
    }
    
    if (sprite.currentAnimationName.equals("money!") && sprite.isAnimationComplete()) {
      sprite.changeAnimation("idle");
    }
  }
}
