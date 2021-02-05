//
// Changes since video:
//
// • Removed some unused code
// • Tweaked reset on game over
// • Stopped Enemy class from re-loading the enemy spritesheet each time an enemy spawns 
//
// You are free to modify or use this code however you would like!
// Background image by Luis Zuno (https://opengameart.org/content/gothicvania-cemetery-pack)
// Other assets are copyright Stray Basilisk Ltd., and for personal / non-commercial / educational use only.
//

import java.util.LinkedList;
import java.util.Iterator;

static final float FLOOR_Y = 650;

PImage backgroundImage;
PImage enemyImage;

float enemySpeed = 50f; // Pixels-per-second

Player player;

LinkedList<Enemy> enemies = new LinkedList<Enemy>();

boolean debugDraw = false;

float spawnDelaySeconds = 4.5;
float secondsSinceLastSpawn;

void setup() {
  size(1428, 775, P3D);
  
  backgroundImage = loadImage("background.png");
  enemyImage = loadImage("sprite_enemy.png");
  
  player = new Player();
}

int previousMillis;

void draw() {
  // Calculate delta time since last frame
  int millisElapsed = millis() - previousMillis;
  float secondsElapsed = millisElapsed / 1000f;
  previousMillis = millis();
  
  // Draw background
  tint(255,255,255);
  imageMode(CORNER);
  image(backgroundImage, 0, 0);
  
  // Spawn enemies
  secondsSinceLastSpawn += secondsElapsed;
  if (player.state != PlayerState.DEAD) {
    while (secondsSinceLastSpawn > spawnDelaySeconds) {
      if (random(0f, 1f) < 0.5f) {
        enemies.add(new Enemy(-width/2f));
      }
      else {
        enemies.add(new Enemy(width/2f));
      }
      
      secondsSinceLastSpawn -= spawnDelaySeconds;
    }
  }
  
  // Update + draw player
  player.update(secondsElapsed);
  player.draw();
  
  // Update + draw enemies
  for (Iterator<Enemy> enemyIter = enemies.iterator(); enemyIter.hasNext();) {
    Enemy enemy = enemyIter.next();
    
    enemy.update(secondsElapsed);
    
    if (enemy.state == EnemyState.DEAD) {
      enemyIter.remove();
      continue;
    }
      
    if (debugDraw && enemy.xPosition < Player.ATTACK_RANGE && enemy.xPosition > -Player.ATTACK_RANGE) {
      tint(255,0,0);
    }
    else {
      tint(255,255,255); 
    }
    
    enemy.draw();
  }
  
  // Debug drawing
  if (debugDraw) {
    stroke(255,0,0);
    line(player.xPosition + (width/2) + Player.ATTACK_RANGE, 0, player.xPosition + (width/2) + Player.ATTACK_RANGE, height);
    line(player.xPosition + (width/2) - Player.ATTACK_RANGE, 0, player.xPosition + (width/2) - Player.ATTACK_RANGE, height);
  }
}

void keyPressed() {
  if (player.state == PlayerState.DEAD && key == ' ') {
    // Reset
    player.reset();
    enemies.clear();
    secondsSinceLastSpawn = 0;
  }
}

void keyReleased() {
  if (keyCode == LEFT) {
    player.directionReleased(true);
  }
  else if (keyCode == RIGHT) {
    player.directionReleased(false);
  }
  else if (key == 'd') {
    debugDraw = !debugDraw;
  }
}
