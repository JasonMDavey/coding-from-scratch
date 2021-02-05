//
// Changes since video:
//
// • Added rendering of landing platforms
// • Added background image
// • Fixed bug with angle wrapping 
//
// You are free to modify or use this code however you would like!
// Images and other assets are for personal / non-commercial / educational use only.
//


import java.util.*;

/*
 * Tweakable gameplay parameters
 */
final int TERRAIN_POINTS = 28;
final int PLATFORM_SIZE = 5;

final float GRAVITY_STRENGTH = 20f;
final float THRUST_STRENGTH = 100f;
final float ROTATION_SPEED = 1f;

final float FUEL_CONSUMPTION_RATE = 1/30f;

final float LANDING_X_SPEED_THRESHOLD = 20f;
final float LANDING_Y_SPEED_THRESHOLD = 25f;
final float LANDING_ROTATION_THRESHOLD = 0.125f;

// Height of each terrain point
float[] terrainHeights;
float terrainXOffset = 0;

// Our lander craft
Lander lander;

int score;

PImage backgroundImage;

void setup() {
  println(350f%360f);
  println(370f%360f);
  println(-10f%360f);
  size(506, 506, P3D);
  
  backgroundImage = loadImage("background.png");
  randomizeTerrain();
}


float previousTimeMillis;

void draw() {
  // Determine how long has ellapsed since we rendered the last frame
  float millisNow = millis();
  float deltaSeconds = (millisNow - previousTimeMillis) / 1000f;
  previousTimeMillis = millisNow;

  imageMode(CORNER);
  tint(255,255,255);
  image(backgroundImage,0,0);
  
  /*
   * Update
   */
  lander.update(deltaSeconds);
  
  // Did we land on the right-hand platform?
  if (lander.state == LanderState.GROUNDED && lander.pos.x > width/2) {
    ++score;
    randomizeTerrain();
  }
  
  /*
   * Draw
   */
      
  // Terrain
  fill(0,0,0);
  stroke(255,255,255);
  strokeWeight(3);
  beginShape();
  vertex(-10, height+10);
  vertex(-10, getTerrainPoint(0).y);
  for (int i=0; i<terrainHeights.length; ++i) {
    PVector p = getTerrainPoint(i);
    vertex(p.x, p.y);
  }
  vertex(width+10, getTerrainPoint(TERRAIN_POINTS-1).y);
  vertex(width+10, height+10);
  endShape();
  
  // Platforms
  noStroke();
  fill(128,128,128);
  PVector p1Start = getTerrainPoint(1);
  PVector p1End = getTerrainPoint(1+PLATFORM_SIZE-1);
  PVector p2Start = getTerrainPoint(TERRAIN_POINTS-PLATFORM_SIZE-1);
  PVector p2End = getTerrainPoint(TERRAIN_POINTS-2);
  rect(p1Start.x, p1Start.y+1, p1End.x-p1Start.x, 10);
  rect(p2Start.x, p2Start.y+1, p2End.x-p2Start.x, 10);
  
  // Lander
  lander.draw();
  
  /*
   * UI
   */
   
  // Fuel
  noFill();
  stroke(255,255,255);
  rect(10,10,200,30);
  
  fill(255,255,255);
  noStroke();
  rect(10, 10, lander.fuel*200, 30);
  
  // Score
  noStroke();
  fill(255,255,255);
  textSize(20);
  text("Score: " + score, 10, 70);
  
  // Velocity
  noStroke();
  fill(0,80,0);
  rect(width-110, 60, 100, 50);
  
  if (lander.isAtLandingSpeedAndOrientation()) {
    stroke(0, 255, 0); 
  }
  else {
    stroke(255, 0, 0);
  }
  line(width-60, 60,
       width-60+(50*lander.vel.x/LANDING_X_SPEED_THRESHOLD),
       60 + 50*lander.vel.y/LANDING_Y_SPEED_THRESHOLD);
  
  noFill();
  stroke(255,255,255);
  rect(width-110, 10, 100, 100);
}

void randomizeTerrain() {
  terrainHeights = new float[TERRAIN_POINTS];
  for (int i=0; i<TERRAIN_POINTS; ++i) {
    float n = noise(terrainXOffset + i*0.1);
    terrainHeights[i] = map(n, 0f, 1f, 0, height*0.75f);
  }
  terrainXOffset += (TERRAIN_POINTS-2-PLATFORM_SIZE)*0.1f;
  
  // Create platforms
  makePlatform(1, PLATFORM_SIZE);
  makePlatform(TERRAIN_POINTS-PLATFORM_SIZE-1, PLATFORM_SIZE);
  
  // Place player
  float fuel = lander == null ? 1f : lander.fuel;
  PVector platformPoint = getTerrainPoint(3);
  lander = new Lander(new PVector(platformPoint.x, platformPoint.y - Lander.LAND_RADIUS));
  lander.fuel = fuel;
}

void makePlatform(int startIndex, int numSegments) {
  // Determine level by averaging points we want to turn into a platform 
  float avg = 0f;
  for (int i=0; i<numSegments; ++i) {
    avg += terrainHeights[i+startIndex];
  }
  avg /= numSegments;
  
  // Flatten platform points
  for (int i=0; i<numSegments; ++i) {
    terrainHeights[i+startIndex] = avg;
  }
}

Set<Integer> heldKeys = new HashSet<Integer>();
void keyPressed() {
  if (key == CODED) {
    heldKeys.add(keyCode);
  }
  if (key == ' ') {
   randomizeTerrain(); 
  }
}

void keyReleased() {
  if (key == CODED) {
    heldKeys.remove(keyCode);
  }
}

PVector getTerrainPoint(int i) {
  float xStep = width / (terrainHeights.length - 1f);
  float x = i * xStep; 
  float y = height - terrainHeights[i];
  return new PVector(x, y);
}
