//
// You are free to modify or use this code however you would like!
//

final int WIDTH=256;
final int HEIGHT=256;
final int SCALE_FACTOR = 4;

final byte AIR = 0;
final byte ROCK = 1;
final byte SAND = 2;
final byte WATER = 3;
final byte OIL = 4;
final byte FIRE = 5;

byte[] world;
boolean[] hasMovedFlags;
int[] momentum;

PGraphics worldGfx;

int brushSize = 1;
boolean brushToggle = false;

PImage cursor;

/*
 * Called once at the start of the program
 */
void setup() {
  size(1024, 1024, P3D);
  
  cursor = loadImage("hand.png");
  
  worldGfx = createGraphics(WIDTH, HEIGHT);
  ((PGraphicsOpenGL)g).textureSampling(2); // Prevent Processing from applying smoothing/filtering when we scale stuff
  
  world = new byte[WIDTH*HEIGHT];
  hasMovedFlags = new boolean[WIDTH*HEIGHT];
  momentum = new int[WIDTH*HEIGHT];
  
  // Make a line of rock at the bottom
  for (int y=HEIGHT-10; y<HEIGHT; ++y) {
    for (int x=0; x<WIDTH; ++x) {
      world[coord(x,y)] = ROCK;
    }
  }
  
  // Add some sand
  for (int y=100; y<110; ++y) {
    for (int x=100; x<110; ++x) {
      world[coord(x,y)] = SAND;
    }
  }
  
  frameRate(30);
}


/*
 * Called once per frame
 */
void draw() {
  
  /*
   * Add new stuff when mouse is pressed
   */
  if (mousePressed) {
    int mouseXInWorld = mouseX / SCALE_FACTOR;
    int mouseYInWorld = mouseY / SCALE_FACTOR;
    
    if (mouseButton == LEFT) {
      place(brushToggle ? OIL : SAND, mouseXInWorld, mouseYInWorld);
    }
    else if (mouseButton == CENTER) {
      place(ROCK, mouseXInWorld, mouseYInWorld);
    }
    else if (mouseButton == RIGHT) {
      place(brushToggle ? FIRE : WATER, mouseXInWorld, mouseYInWorld);
    }
  }
  
  /*
   * Update the world
   */
  // Clear out "has-moved" flags
  for (int y=0; y<HEIGHT; ++y) {
    for (int x=0; x<WIDTH; ++x) {
      hasMovedFlags[coord(x,y)] = false;
    }
  }
  
  for (int y=HEIGHT-1; y>=0; --y) {
    for (int x=0; x<WIDTH; ++x) {
      int coordHere = coord(x,y);
      if (hasMovedFlags[coordHere]) continue;
      
      byte substanceHere = world[coordHere];
      if (substanceHere == AIR || substanceHere == ROCK) continue;
      
      if (substanceHere == FIRE) {
        boolean fireSpread = false;
        if (canMove(FIRE, x-1, y)) {
          move(x,y,x-1,y);
          world[coordHere] = FIRE;
          fireSpread = true;
        }
        if (canMove(FIRE, x+1, y)) {
          move(x,y,x+1,y);
          world[coordHere] = FIRE;
          fireSpread = true;
        }
        if (canMove(FIRE, x, y-1)) {
          move(x,y,x,y-1);
          world[coordHere] = FIRE;
          fireSpread = true;
        }
        if (canMove(FIRE, x, y+1)) {
          move(x,y,x,y+1);
          world[coordHere] = FIRE;
          fireSpread = true;
        }
        
        if (!fireSpread) {
          // Fire burns out
          world[coordHere] = AIR;
        }
      }
      
      if (canMove(substanceHere, x, y+1)) {
        // Ideally, we want to move down
        move(x, y, x, y+1);
      }
      
      // If we have momentum, prefer moving in the same direction we previously moved.
      // Otherwise, pick left/right randomly, so there is no bias
      boolean checkLeftFirst;
      if (momentum[coordHere] == -1) { checkLeftFirst = true; }
      else if (momentum[coordHere] == 1) { checkLeftFirst = false; }
      else { checkLeftFirst = (random(1f)<0.5f); }
      
      if (checkLeftFirst) {
        if (canMove(substanceHere, x-1, y+1)) {
        // Next, try to move down+left
        move(x, y, x-1, y+1);
        }
        else if (canMove(substanceHere, x+1, y+1)) {
          // Next, try to move down+right
          move(x, y, x+1, y+1);
        }
      }
      else {
        if (canMove(substanceHere, x+1, y+1)) {
          // Next, try to move down+right
          move(x, y, x+1, y+1);
        }
        else if (canMove(substanceHere, x-1, y+1)) {
          // Next, try to move down+left
          move(x, y, x-1, y+1);
        } 
      }
      
      if ((substanceHere == WATER || substanceHere == OIL) && y<HEIGHT-1 && world[coord(x,y+1)] == substanceHere) {
        // If we're above a layer of water, spread out to left and right
        if (checkLeftFirst) {
          if (canMove(substanceHere, x-1, y)) {
            // Next, try to move left
            move(x, y, x-1, y);
          }
          else if (canMove(substanceHere, x+1, y)) {
            // Next, try to move right
            move(x, y, x+1, y);
          }
        }
        else {
          if (canMove(substanceHere, x+1, y)) {
            // Next, try to move right
            move(x, y, x+1, y);
          }
          else if (canMove(substanceHere, x-1, y)) {
            // Next, try to move left
            move(x, y, x-1, y);
          } 
        }
      }
    }
  }
  
  /*
   * Draw the world
   */
  worldGfx.beginDraw();
  worldGfx.loadPixels();
  for (int y=0; y<HEIGHT; ++y) {
    for (int x=0; x<WIDTH; ++x) {
      int coordHere = coord(x,y);
      
      byte whatHere = world[coordHere];
      color c;
            
      switch (whatHere) {
        case AIR: c = color(0,0,0); break;
        case ROCK: c = color(128,128,128); break;
        case WATER: c = color(0,0,255); break;
        case SAND: c = color(255,255,0); break;
        case OIL: c = color(160,70,160); break;
        case FIRE: c = color(255,70,0); break;
        default: c = color(255,0,0); break;
      }
      
      worldGfx.pixels[coordHere] = c;
    }
  }
  worldGfx.updatePixels();
  worldGfx.endDraw();
  
  scale(SCALE_FACTOR);
  image(worldGfx, 0, 0);
}

void mouseWheel(MouseEvent event) {
  if (event.getCount() < 0) {
    ++brushSize;
  }
  else {
    --brushSize;
    if (brushSize <= 0) { brushSize = 1; }
  }
  println("Brush size: " + brushSize);
}

void keyPressed() {
  if (key == ' ') {
    brushToggle = !brushToggle;
    
    if (brushToggle) { println("OIL / ROCK / FIRE"); }
    else { println("SAND / ROCK / WATER"); }
  }
}

void place(byte substance, int xPos, int yPos) {
  for (int y=max(0,yPos-brushSize); y<min(HEIGHT-1, yPos+brushSize); ++y) {
    for (int x=max(0,xPos-brushSize); x<min(WIDTH-1, xPos+brushSize); ++x) {
      world[coord(x,y)] = substance;
    }
  }
}

void move(int fromX, int fromY, int toX, int toY) {
  int fromCoord = coord(fromX, fromY);
  int toCoord = coord(toX, toY);
  byte otherSubstance = world[toCoord];
  
  world[toCoord] = world[fromCoord];
  world[fromCoord] = otherSubstance;
  hasMovedFlags[toCoord] = true;
  hasMovedFlags[fromCoord] = true;
  momentum[fromCoord] = 0;
  
  if (toX > fromX) { momentum[toCoord] = 1; }
  else if (toX < fromX) { momentum[toCoord] = -1; }
  else { momentum[toCoord] = 0; }
}

boolean canMove(byte substance, int x, int y) {
  if (x<0 || x>=WIDTH || y<0 || y>=HEIGHT) return false;
  byte otherSubstance = world[coord(x,y)];
  if (substance == FIRE) return (otherSubstance == OIL);
  if (otherSubstance == AIR) return true;
  if (substance == SAND && otherSubstance == WATER && random(1f)<0.5f) return true;
  return false;
}

int coord(int x, int y) {
  return x + y*WIDTH;
}
