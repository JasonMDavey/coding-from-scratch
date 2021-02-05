abstract class Hero {
  Sprite sprite;
  
  int health;
  boolean dead;
  
  int row, column;
  
  public Hero(int row, int column) {
    this.row = row;
    this.column = column;
    
    sprite = new Sprite();   
    sprite.position = World.getWorldPos(row, column);
  }
  
  void update(float secondsElapsed) {
    sprite.updateAnimation(secondsElapsed);
  }
  
  void draw() {
    sprite.draw();
    
    textSize(12);
    text(Integer.toString(health), sprite.position.x - 20, sprite.position.y - 55);
  }
}
