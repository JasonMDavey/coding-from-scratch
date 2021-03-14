import java.util.HashSet;

enum State { AIM, POWER, RESOLVE }

final PVector GRAVITY = new PVector(0, 20);
final float MAX_WIND_SPEED = 5f;

final float MAX_POWER_HOLD_SECONDS = 2f;
final float MAX_LAUNCH_SPEED = 200f;

final float SCALE_FACTOR = 3;

final color AIR_COLOR = color(0,0,0,0);
final color TERRAIN_COLOR = color(30, 180, 60);

final float NOISE_SCALE = 0.01f;

final int TANK_SIZE = 6;


int WORLD_WIDTH, WORLD_HEIGHT;

PImage terrainTexture;

WindParticleSystem windParticles;

State state = State.AIM;

Tank[] tanks;
int activeTankIndex = 0;
float launchPower = 0f;

PVector wind = new PVector();
Projectile activeProjectile;
Explosion activeExplosion;

void setup() {
  size(1000, 750, P2D);
  WORLD_WIDTH = (int)Math.ceil(width / SCALE_FACTOR);
  WORLD_HEIGHT = (int)Math.ceil(height / SCALE_FACTOR);
  
  // Hacky! Sets texture scaling filter to GL_NEAREST, giving us nice chunky pixel art
  // Does Processing give us a nicer way to do this?
  // TODO: clean this up
  ((PGraphicsOpenGL)g).textureSampling(2);
  
  generateTerrain();
  changeWind();
  
  tanks = new Tank[2];
  tanks[0] = spawnTank(30, color(255,0,0));
  tanks[1] = spawnTank(WORLD_WIDTH-30, color(255,0,255));
  
  windParticles = new WindParticleSystem(200);
}

float previousMillis = millis();

void draw() {
  float timeMillis = millis();
  float deltaMillis = timeMillis-previousMillis;
  float deltaSeconds = deltaMillis / 1000f;
  previousMillis = timeMillis;
  deltaSeconds = 1/20f;
  
  /*
   * Update
   */
  for (Tank tank : tanks) {
    tank.update(deltaSeconds);
  }
  
  switch (state) {
    case AIM: {
      Tank activeTank = tanks[activeTankIndex];
      float aimRate = heldKeys.contains(SHIFT) ? 0.1f : 0.5f;
      
      if (heldKeys.contains(RIGHT)) {
        activeTank.aimTurret(+aimRate * deltaSeconds);
      }
      if (heldKeys.contains(LEFT)) {
        activeTank.aimTurret(-aimRate * deltaSeconds);
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
      activeProjectile.update(deltaSeconds);
      if (activeExplosion != null) {
        activeExplosion.update(deltaSeconds);
      }
  
      if (activeProjectile.isDead && (activeExplosion == null || activeExplosion.isDead)) {
        // Done resolving - reset for next player's turn
        changeWind();
        state = State.AIM;
        activeProjectile = null;
        activeExplosion = null;
        activeTankIndex = (activeTankIndex+1) % tanks.length;
      }  
      break;
    }
  }
  
  windParticles.update(deltaSeconds); //<>//
  
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
  
  if (activeProjectile != null) {
    activeProjectile.draw();
  }
  
  if (activeExplosion != null) {
    activeExplosion.draw();
  }
  
  // UI
  if (state == State.POWER) {
    stroke(255,160,60);
    strokeWeight(1);
    noFill();
    rect(0,0,WORLD_WIDTH, 3);
        
    fill(255,160,60);
    noStroke();
    fill(255,160,60);
    rect(0,0,WORLD_WIDTH*launchPower, 3);
  }
  
  saveFrame("frame#####.png");
}

void generateTerrain() {
  terrainTexture = createImage(WORLD_WIDTH, WORLD_HEIGHT, ARGB);
  terrainTexture.loadPixels();
  for (int x=0; x<WORLD_WIDTH; ++x) {
    // Determine terrain height at this point
    float altitude = map(noise(x*NOISE_SCALE), 0, 1, 0.2f*WORLD_HEIGHT, 0.8f*WORLD_HEIGHT);
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

//Projectile spawn

HashSet<Integer> heldKeys = new HashSet<Integer>();
void keyPressed() {
  if (key == CODED) {
    heldKeys.add(keyCode);
  }
  else {
    if (state == State.AIM && key == ' ') {
      state = state.POWER;
      launchPower = 0f;
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
  }
}

void launchProjectile() {
  activeProjectile = tanks[activeTankIndex].launchProjectile(launchPower * MAX_LAUNCH_SPEED);
  state = State.RESOLVE;
}

void changeWind() {
  PVector dir = PVector.random2D();
  float speed = random(0, MAX_WIND_SPEED);
  wind = dir.mult(speed);
}
