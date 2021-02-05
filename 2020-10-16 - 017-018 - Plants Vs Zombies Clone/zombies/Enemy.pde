abstract class Enemy {
  Sprite sprite;
  
  int health;
  
  float xPos, yPos;
  
  public Enemy(float x, float y) {
    this.xPos = x;
    this.yPos = y;
    
    sprite = new Sprite();   
    sprite.position = World.getWorldPos(x, y);
    sprite.facingLeft = true;
  }
  
  void update(float secondsElapsed) {
    sprite.position = World.getWorldPos(yPos, xPos);
    sprite.updateAnimation(secondsElapsed);
  }
  
  void draw() {
    sprite.draw();
    textSize(12);
    text(Integer.toString(health), sprite.position.x, sprite.position.y - 55);
  }
  
  Hero checkForHeroInFront() {
    int heroRow = (int)yPos;
    
    // Find closest cell
    float roundedXPos = Math.round(xPos);
    
    if (roundedXPos < World.NUM_COLS && xPos > roundedXPos-0.1f && xPos <= roundedXPos) {
      // Enemy is in the "zone" immediately adjacent to a potential hero's slot
      Hero heroHere = heroes[heroRow][(int)roundedXPos];
      if (heroHere != null && heroHere.health > 0) {
        // Snap ourselves to be exactly aligned with the hero
        xPos = roundedXPos;
      }
      return heroHere;
    }
    else {
      return null;
    }
  }
}
