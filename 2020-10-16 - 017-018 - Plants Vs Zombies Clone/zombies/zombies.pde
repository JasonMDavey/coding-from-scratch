import java.util.List;
import java.util.LinkedList;
import java.util.Iterator;

// Assets
static PImage engiImage, rangerImage, warriorImage;
static PImage engiIcon, rangerIcon, warriorIcon;
static PImage zombieImage;

// Game-state
int money = 100;
Hero[][] heroes;
List<LinkedList<Enemy>> enemies;

List<Wave> waves = new LinkedList<Wave>();
Spawner spawner = new Spawner();

// UI-state
HeroType draggedHero = null;


// Called once at start of program - do setup stuff!
void setup() {
  // Create our window
  size(1428, 775, P3D);
  
  // Load in our image assets
  engiImage = loadImage("sprite_engineer.png");
  engiIcon = loadImage("icon_engineer.png");
  rangerImage = loadImage("sprite_ranger.png");
  rangerIcon = loadImage("icon_ranger.png");
  warriorImage = loadImage("sprite_warrior.png");
  warriorIcon = loadImage("icon_warrior.png");
  
  zombieImage = loadImage("sprite_zombie.png");
  
  // Initialise containers for heroes / enemies
  heroes = new Hero[World.NUM_ROWS][World.NUM_COLS];
  enemies = new ArrayList<LinkedList<Enemy>>(World.NUM_ROWS);
  for (int row=0; row<World.NUM_ROWS; ++row) {
    enemies.add(new LinkedList<Enemy>());
  }
  
  // Set up waves
  Wave w1 = new Wave();
  w1.name = "First Wave!";
  w1.durationSeconds = 60;
  w1.numEnemiesToSpawn.put(EnemyType.WALKER, 10);
  waves.add(w1);
  
  Wave w2 = new Wave();
  w2.name = "Second Wave!";
  w2.durationSeconds = 60;
  w2.numEnemiesToSpawn.put(EnemyType.WALKER, 30);
  w2.numEnemiesToSpawn.put(EnemyType.FAST_WALKER, 5);
  waves.add(w2);
  
  Wave w3 = new Wave();
  w3.name = "Final Wave!";
  w3.durationSeconds = 60;
  w3.numEnemiesToSpawn.put(EnemyType.WALKER, 45);
  w2.numEnemiesToSpawn.put(EnemyType.FAST_WALKER, 15);
  waves.add(w3);
  
  // Kick off spawning!
  startNextWave();
}


int previousMillis;

// Called once per frame
void draw() {
  // Calculate delta time since last frame
  int millisElapsed = millis() - previousMillis;
  float secondsElapsed = millisElapsed / 1000f;
  previousMillis = millis();

  // Clear screen
  background(0);
  
  // Spawn enemies
  spawner.update(secondsElapsed);
  
  // Update heroes
  for (int row=0; row<World.NUM_ROWS; ++row) {
    for (int col=0; col<World.NUM_COLS; ++col) {
      Hero h = heroes[row][col];
      if (h == null) continue;
      h.update(secondsElapsed);
      
      if (h.dead) {
        heroes[row][col] = null;
      }
    }
  }
  
  // Update enemies
  for (LinkedList<Enemy> rowOfEnemies : enemies) {        // Iterate over each lane
    Iterator<Enemy> enemyIter = rowOfEnemies.iterator();
    while (enemyIter.hasNext()) {                         // Iterate over each enemy in the lane
      Enemy e = enemyIter.next();
      
      e.update(secondsElapsed);
      
      if (e.health <= 0) {
        enemyIter.remove();
      }
      else if (e.xPos < -0.5f) {
        // Enemy reached end of lane!
        println("GAME OVER!");
        exit();
        return;
      }
    }
  }
      
  // Draw grid
  stroke(50);
    
  // Vertical lines
  for (int x=0; x<=World.NUM_COLS; ++x) {
    PVector screenStart = World.getWorldPos(-0.5, x-0.5);
    PVector screenEnd = World.getWorldPos(World.NUM_ROWS-0.5, x-0.5);
    line(screenStart.x, screenStart.y, screenEnd.x, screenEnd.y);
  }
  
  // Horizontal lines
  for (int y=0; y<=World.NUM_ROWS; ++y) {
    PVector screenStart = World.getWorldPos(y-0.5, -0.5);
    PVector screenEnd = World.getWorldPos(y-0.5, World.NUM_COLS-0.5);
    line(screenStart.x, screenStart.y, screenEnd.x, screenEnd.y);
  }
  
  // Draw heroes
  for (int row=0; row<World.NUM_ROWS; ++row) {
    for (int col=0; col<World.NUM_COLS; ++col) {
      Hero h = heroes[row][col];
      if (h == null) continue;
      h.draw();
    }
  }
  
  // Draw enemies
  for (LinkedList<Enemy> rowOfEnemies : enemies) {
    for (Enemy e : rowOfEnemies) {
      e.draw();
    }
  }
   
  // Draw UI
  textSize(30);
  text("Money: " + money, 10, 30);
  text("Enemies Remaining: " + spawner.enemiesRemaining, width-375, 30);
  
  // Character listing ("shop")
  textSize(20);
  imageMode(CENTER);
  for (HeroType t : HeroType.values()) {
    int price = Shop.getPrice(t);
    PVector pos = Shop.getPosition(t);
    if (price <= money) {
      tint(255);
    }
    else {
      tint(50);
    }
    image(Shop.getIcon(t), pos.x, pos.y);
    text("$" + price, pos.x-20, pos.y+50);
  }
  
  if (draggedHero != null) {
    int[] tileHere = World.getTileAt(mouseX, mouseY);
    if (tileHere == null) {
      tint(50);
    }
    else {
      tint(255);
    }
    image(Shop.getIcon(draggedHero), mouseX, mouseY);
  }
  
  
  checkForWaveCompletion();
}


// Spawns a hero at the specified location
void spawnHero(HeroType type, int row, int col) {
  Hero h;
  switch (type) {
    case MONEY_GENERATOR: h = new MoneyGeneratorHero(row, col); break;
    case RANGED: h = new RangedHero(row, col); break;
    case MELEE: h = new MeleeHero(row, col); break;
    default: throw new RuntimeException("UHOH!");
  }
  
  heroes[row][col] = h;
}

void checkForWaveCompletion() {
  if (spawner.enemiesRemaining == 0) {
    // Check for still-alive enemies
    boolean enemyLiving = false;
    
    for (List<Enemy> lane : enemies) {
      for (Enemy e : lane) {
        if (e.health > 0) {
          enemyLiving = true;
          break;
        }
      }
      if (enemyLiving) break;
    }
    
    if (!enemyLiving) {
      startNextWave();
    }
  }
}

void startNextWave() {
  if (waves.isEmpty()) {
    println("YOU WIN!");
    exit();
    return;
  }
  
  Wave w = waves.remove(0);
  spawner.init(w);
}

void mousePressed() {
  // Check to see if the mouse is over an icon in the shop
  PVector mousePos = new PVector(mouseX, mouseY);
  
  for (HeroType t : HeroType.values()) {
    int price = Shop.getPrice(t);
    if (money < price) continue;  // Can't afford it!
    
    PVector pos = Shop.getPosition(t);
    float dist = pos.dist(mousePos);
    if (dist > 30) continue;      // Too far away!
    
    draggedHero = t;
  }
}

void mouseReleased() {
  if (draggedHero == null) return;
  
  int price = Shop.getPrice(draggedHero);
  if (price > money) {
    draggedHero = null;
    return;
  }
  
  int[] tileHere = World.getTileAt(mouseX, mouseY);
  if (tileHere == null) {
    draggedHero = null;
    return;
  }
  
  int row = tileHere[0];
  int col = tileHere[1];
  if (heroes[row][col] != null) {
    draggedHero = null;
    return;
  }
  
  money -= price;
  spawnHero(draggedHero, row, col);
  draggedHero = null;
}
