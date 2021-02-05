class Player extends Sprite {
  
  static final float CHARGE_DURATION_SECONDS = 0.75;
  static final float ATTACK_IMPACT_DELAY_SECONDS = 0.4;
  static final float RESET_DURATION_SECONDS = 0.6;
  
  static final float ATTACK_RANGE = 175;
  static final float ATTACK_PUSHBACK_SPEED = 500;
  
  PlayerState state = PlayerState.IDLE;
  float secondsInCurrentState = 0;
  
  int health = 10;
  
  PImage glowImage;
  static final float GLOW_DURATION_SECONDS = 0.75;
  
  public Player() {
    sprite = loadImage("sprite_warrior.png");
    spriteFootOffset = 176;
    
    glowImage = loadImage("warrior_glow.png");
    
    animations.put("idle", new Animation(0, 0, 384, 384, 35, 50/1000f, true));
    animations.put("hurt", new Animation(0, 384, 384, 384, 12, 50/1000f, false));
    animations.put("charge", new Animation(0, 768, 384, 384, 7, 50/1000f, false));
    animations.put("attack", new Animation(2688, 768, 384, 384, 20, 50/1000f, false));
    animations.put("death", new Animation(0, 1152, 384, 384, 35, 50/1000f, false));
    
    reset();
  }
    
  void reset() {
    changeAnimation("idle");
    health = 10;
    state = PlayerState.IDLE;
    secondsInCurrentState = 0;
  }
  
  void directionReleased(boolean isLeft) {
    if (state == PlayerState.CHARGE) {
      state = PlayerState.IDLE;
      changeAnimation("idle");
      secondsInCurrentState = 0;
    }
    else if (state == PlayerState.READY) {
      state = PlayerState.ATTACK;
      changeAnimation("attack");
      secondsInCurrentState = 0;
    }
  }
  
  void draw() {   
    super.draw();
    
    if (state == PlayerState.READY) {
      imageMode(CENTER);
      pushMatrix();
      translate(width/2 + xPosition, FLOOR_Y - spriteFootOffset);
      if (facingLeft) {
        rotateY(PI);
      }
      
      float opacity = max(0, map(secondsInCurrentState, 0, GLOW_DURATION_SECONDS, 255, 0));
      tint(255,255,255,opacity);
      image(glowImage, 0, 0);
      tint(255,255,255);
  
      popMatrix();
    }
  }
  
  void update(float secondsElapsed) {    
    secondsInCurrentState += secondsElapsed;
    
    if (health <= 0 && state != PlayerState.DEAD) {
      state = PlayerState.DEAD;
      changeAnimation("death");
      secondsInCurrentState = 0;
    }
    
    switch (state) {
      case IDLE: {
        if (keyPressed && (keyCode == RIGHT || keyCode == LEFT)) {
          facingLeft = keyCode == LEFT;
          state = PlayerState.CHARGE;
          changeAnimation("charge");
          secondsInCurrentState = 0;
        }
        break;
      }
      case CHARGE: {
        if (secondsInCurrentState >= CHARGE_DURATION_SECONDS) {
          state = PlayerState.READY;
          secondsInCurrentState = 0;
        }
        break;
      }
      
      case ATTACK: {
        if (secondsInCurrentState >= ATTACK_IMPACT_DELAY_SECONDS) {
          applyAttackImpact();
          state = PlayerState.RESET;
          secondsInCurrentState = 0;
        }
        break;
      }
      
      case RESET: {
        if (secondsInCurrentState >= RESET_DURATION_SECONDS) {
          state = PlayerState.IDLE;
          changeAnimation("idle");
          secondsInCurrentState = 0;
        }
        break;
      }
    }   
    
    println(health);
    
    updateAnimation(secondsElapsed);
  }
  
  void applyAttackImpact() {
    for (Enemy enemy : enemies) {
      if (facingLeft) {
        if (enemy.xPosition > -Player.ATTACK_RANGE && enemy.xPosition < 0) {
          enemy.xSpeed = -ATTACK_PUSHBACK_SPEED;
          --enemy.health;
        }
      }
      else {
        if (enemy.xPosition < Player.ATTACK_RANGE && enemy.xPosition > 0) {
          enemy.xSpeed = +ATTACK_PUSHBACK_SPEED;
          --enemy.health;
        }
      }
    }
  }
}
