class Enemy extends Sprite {

  static final float APPROACH_RANGE = 100;
  static final float ATTACK_IMPACT_DELAY_SECONDS = 0.3;
  static final float RESET_DURATION_SECONDS = 0.25;
  static final float IDLE_DURATION_SECONDS = 0.5;
  static final float DIE_DURATION_SECONDS = 1;

  EnemyState state = EnemyState.APPROACH;
  float secondsInCurrentState = 0;

  int health = 2;
  
  float xSpeed = 0;
  
  public Enemy(float xPosition) {
    sprite = enemyImage;
    spriteFootOffset = 60;

    animations.put("idle", new Animation(0, 0, 192, 192, 10, 50/1000f, true));
    animations.put("hurt", new Animation(0, 192, 192, 192, 1, 50/1000f, false));
    animations.put("attack", new Animation(0, 384, 192, 192, 11, 50/1000f, false));

    changeAnimation("idle");

    this.xPosition = xPosition;
    this.facingLeft = (xPosition > 0);
  }

  void draw() {
    if (state == EnemyState.DYING) {
      float dieProgress = secondsInCurrentState / DIE_DURATION_SECONDS;
      tint(255, 255-255*dieProgress, 255-255*dieProgress, 255-255*dieProgress);
    }
    super.draw();
  }
  
  void update(float secondsElapsed) {
    secondsInCurrentState += secondsElapsed;
    
    xPosition += xSpeed * secondsElapsed;
    xSpeed *= 0.95;
    
    if (health <= 0 && state != EnemyState.DYING) {
      state = EnemyState.DYING;
      secondsInCurrentState = 0;
      changeAnimation("hurt");
    }
    
    switch (state) {
      
      case APPROACH: {
        if (facingLeft) {
          xPosition -= enemySpeed * secondsElapsed;
        } else {
          xPosition += enemySpeed * secondsElapsed;
        }

        if (abs(xPosition) < APPROACH_RANGE) {
          state = EnemyState.ATTACK;
          changeAnimation("attack");
          secondsInCurrentState = 0;
        }
        
        break;
      }
      
      case ATTACK: {
        if (secondsInCurrentState >= ATTACK_IMPACT_DELAY_SECONDS) {
          applyAttackImpact();
          state = EnemyState.RESET;
          secondsInCurrentState = 0;        
        }
        break;
      }
      
      case RESET: {
        if (secondsInCurrentState >= RESET_DURATION_SECONDS) { //<>//
          state = EnemyState.IDLE;
          changeAnimation("idle");
          secondsInCurrentState = 0;
        }
        break;
      } 
      
      case IDLE: {
        if (abs(xPosition) > APPROACH_RANGE) { //<>//
          state = EnemyState.APPROACH;
          changeAnimation("idle");
          secondsInCurrentState = 0;
        }
        else if (secondsInCurrentState >= IDLE_DURATION_SECONDS && player.state != PlayerState.DEAD) {
          state = EnemyState.ATTACK;
          changeAnimation("attack");
          secondsInCurrentState = 0;
        }
        break;
      }
      
      case DYING: {
        if (secondsInCurrentState >= DIE_DURATION_SECONDS) {
          state = EnemyState.DEAD;
          secondsInCurrentState = 0;
        }
        break;
      }
    }

    updateAnimation(secondsElapsed);
  }

  void applyAttackImpact() {
    if (abs(xPosition) <= APPROACH_RANGE) {
      --player.health;
    }
    println("Ouch!");
    
  }
}
