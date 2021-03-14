import java.util.HashSet;
import java.util.List;

// Physics / gameplay constants
int WORLD_WIDTH, WORLD_HEIGHT;

final PVector GRAVITY = new PVector(0, 20);
final float MAX_WIND_SPEED = 5f;
final float MAX_LAUNCH_SPEED = 200f;

// Visual constants
final float SCALE_FACTOR = 3;

final color AIR_COLOR = color(0,0,0,0);
final color TERRAIN_COLOR = color(30, 180, 60);

final float NOISE_SCALE = 0.01f;

final int TANK_SIZE = 6;

// UI constants
final float MAX_POWER_HOLD_SECONDS = 2f;
final float FAST_TURRET_TURN_RATE = 0.5f;
final float SLOW_TURRET_TURN_RATE = 0.1f;

// Game state
enum State { AIM, POWER, RESOLVE, GAME_OVER }
State state;

enum ProjectileType { 
  REGULAR("Regular"),
  CLUSTER_BOMB("Cluster");

  public String label;
  private ProjectileType(String label) { this.label = label; }
}
ProjectileType selectedProjectileType;

PImage terrainTexture;
WindParticleSystem windParticles;

Tank[] tanks;

int activeTankIndex = 0;
float launchPower = 0f;

PVector wind = new PVector();

List<Projectile> activeProjectiles = new ArrayList<Projectile>();
List<Explosion> activeExplosions = new ArrayList<Explosion>();

void setup() {
  size(1000, 600, P2D);
  WORLD_WIDTH = (int)Math.ceil(width / SCALE_FACTOR);
  WORLD_HEIGHT = (int)Math.ceil(height / SCALE_FACTOR);
  
  // Hacky! Sets texture scaling filter to GL_NEAREST, giving us nice chunky pixel art
  // Does Processing give us a nicer way to do this?
  // TODO: clean this up
  ((PGraphicsOpenGL)g).textureSampling(2);
 
  resetGame();
}

void resetGame() {
  generateTerrain();
  changeWind();
  
  tanks = new Tank[2];
  tanks[0] = spawnTank(30, color(255,0,0));
  tanks[1] = spawnTank(WORLD_WIDTH-30, color(255,0,255));
  
  state = State.AIM;
  activeTankIndex = 0;
  selectedProjectileType = ProjectileType.REGULAR;
  
  windParticles = new WindParticleSystem(200);
}

float previousMillis = millis();

void draw() {
  float timeMillis = millis();
  float deltaMillis = timeMillis-previousMillis;
  float deltaSeconds = deltaMillis / 1000f;
  previousMillis = timeMillis;
  
  /*
   * Update
   */
  for (Tank tank : tanks) {
    tank.update(deltaSeconds);
  }
  
  switch (state) {
    case AIM: {
      Tank activeTank = tanks[activeTankIndex];
      float turnRate = heldKeys.contains(SHIFT) ? SLOW_TURRET_TURN_RATE : FAST_TURRET_TURN_RATE;
      
      if (heldKeys.contains(RIGHT)) {
        activeTank.turnTurret(+turnRate * deltaSeconds);
      }
      if (heldKeys.contains(LEFT)) {
        activeTank.turnTurret(-turnRate * deltaSeconds);
      }    
      break;
    }
    case POWER: {
      launchPower += deltaSeconds / MAX_POWER_HOLD_SECONDS;
      if (launchPower >= 1f) {
        launchProjectile();
      }
      break;
    }
    case RESOLVE: {
      boolean somethingIsStillActive = false;
      for (Projectile p : activeProjectiles) {
        if (p.isDead) continue;
        
        p.update(deltaSeconds);
        somethingIsStillActive = true;
      }
      
      for (Explosion e : activeExplosions) {
        if (e.isDead) continue;
        
        e.update(deltaSeconds);
        somethingIsStillActive = true;
      }
      
      if (!somethingIsStillActive) {
        // Cleanup
        activeProjectiles.clear();
        activeExplosions.clear();
          
        // Done resolving - check for win
        int aliveTankCount = 0;
        for (Tank t : tanks) {
          if (t.health > 0) {
            ++aliveTankCount;
          }
        }
        
        if (aliveTankCount == 0 || aliveTankCount == 1) {
          // Win or draw
          state = State.GAME_OVER;
        }
        else {
          // Move to next turn
                    
          // Pick new wind direction
          changeWind();
  
          // Advance to next turn
          activeTankIndex = (activeTankIndex+1) % tanks.length;
          state = State.AIM;
        }
      }  
      break;
    }
  }
  
  windParticles.update(deltaSeconds);
  
  /*
   * Rendering
   */
  background(color(21,80,120));
     
  scale(SCALE_FACTOR);
  
  windParticles.draw();
  
  // World
  image(terrainTexture, 0,0);
  
  for (Tank tank : tanks) {
    tank.draw();
  }
  
  for (Projectile p : activeProjectiles) {
    //if (p.isDead) continue;
    p.draw();
  }
  
  for (Explosion e : activeExplosions) {
    if (e.isDead) continue;
    e.draw();
  }
  
  /*
   * UI
   */
  
  // Tank health
  textAlign(RIGHT);
  noStroke();
  int yOffset = 11;
  for (Tank t : tanks) {
    fill(t.col);
    text("Lives: " + t.health, WORLD_WIDTH-2, yOffset);
    yOffset += 13;
  }
  
  switch (state) {
    case AIM: {
      noStroke();
      fill(255,255,255);
      textAlign(LEFT);
      text(selectedProjectileType.label, 1, 11);
      break;
    }
    
    case POWER: {
      stroke(255,160,60);
      strokeWeight(1);
      noFill();
      rect(0,0,WORLD_WIDTH, 3);
          
      fill(255,160,60);
      noStroke();
      fill(255,160,60);
      rect(0,0,WORLD_WIDTH*launchPower, 3);
      
      break;
    }
    
    case RESOLVE: {
      for (Projectile p : activeProjectiles) {
        if (p.isDead) continue;
        
        if (p.pos.y < 0f) {
          noStroke();
          fill(255,0,0);
          beginShape();
          vertex(p.pos.x, 0);
          vertex(p.pos.x+3, 6);
          vertex(p.pos.x-3, 6);
          endShape();
        }
      }
      break;
    }
    
    case GAME_OVER: {
      int winnerIndex = -1;
      for (int i=0; i<tanks.length; ++i) {
        if (tanks[i].health > 0) {
          winnerIndex = i;
          break;
        }
      }
      
      String gameOverMessage;
      if (winnerIndex == -1) { gameOverMessage = "It's a draw!"; }
      else { gameOverMessage = "Player " + (winnerIndex+1) + " wins!"; }
      
      textAlign(CENTER,CENTER);
      noStroke();
      fill(255,255,255);
      text(gameOverMessage, WORLD_WIDTH*0.5f, WORLD_HEIGHT*0.4f);
      
      text("Press <SPACE> to restart", WORLD_WIDTH*0.5f, WORLD_HEIGHT*0.9f);
    }
  }
}

void generateTerrain() {
  noiseSeed(millis());
  
  terrainTexture = createImage(WORLD_WIDTH, WORLD_HEIGHT, ARGB);
  terrainTexture.loadPixels();
  for (int x=0; x<WORLD_WIDTH; ++x) {
    // Determine terrain height at this point
    float altitude = map(noise(x*NOISE_SCALE), 0, 1, 0.2f*WORLD_HEIGHT, 0.8f*WORLD_HEIGHT);
    // Fill in terrain up to this height
    setTerrainHeight(x, altitude);
  }
  terrainTexture.updatePixels();
}

Tank spawnTank(int spawnX, color col) {
  // Find the terrain height at the base of the tank
  float altitude = map(noise(spawnX*NOISE_SCALE), 0, 1, 0.2f*WORLD_HEIGHT, 0.8f*WORLD_HEIGHT);
  
  // Flatten terrain around the tank to be level with it
  terrainTexture.loadPixels();
  for (int x=spawnX-TANK_SIZE/2; x<spawnX+TANK_SIZE/2; ++x) {
    setTerrainHeight(x, altitude);
  }
  
  terrainTexture.updatePixels();
  
  return new Tank(new PVector(spawnX, altitude), col);
}

void setTerrainHeight(int x, float altitude) {
  // Fill pixels above with empty space
  for (int y=0; y<(int)altitude; ++y) {
    terrainTexture.pixels[x + y*terrainTexture.width] = AIR_COLOR;
  }
  
  // Fill pixels below with ground
  for (int y=(int)altitude; y<WORLD_HEIGHT; ++y) {
    terrainTexture.pixels[x + y*terrainTexture.width] = TERRAIN_COLOR;
  }
}


/*
 * Keep track of which keys are being held
 */
HashSet<Integer> heldKeys = new HashSet<Integer>();

void keyPressed() {
  if (key == CODED) {
    heldKeys.add(keyCode); //<>//
  }
  else {
    if (state == State.AIM) {
      if (key == ' ') {
        // Begin launch phase
        state = State.POWER;
        launchPower = 0f;
      }
      else if (key == TAB) {
        // Cycle selected projectile type
        int newSelectedIndex = (selectedProjectileType.ordinal()+1) % ProjectileType.values().length;
        selectedProjectileType = ProjectileType.values()[newSelectedIndex];  
      }
    }
    else if (state == State.GAME_OVER) {
      // Reset the game
      resetGame();
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    heldKeys.remove(keyCode);
  }
  else {
    if (state == State.POWER && key == ' ') {
      launchProjectile();
    }
    else if (state == State.RESOLVE && key == ' ') {
      for (Projectile p : new ArrayList<Projectile>(activeProjectiles)) {
        if (p.isDead) continue;
        p.onSecondaryInput();
      }
    }
  }
}

void launchProjectile() {
  activeProjectiles.add(tanks[activeTankIndex].launchProjectile(launchPower * MAX_LAUNCH_SPEED, selectedProjectileType));
  state = State.RESOLVE;
}

void changeWind() {
  // Generate a random wind vector
  float x = random(-MAX_WIND_SPEED, MAX_WIND_SPEED);
  float y = random(-MAX_WIND_SPEED, MAX_WIND_SPEED)*0.1f;
  wind = new PVector(x, y);
    
}
