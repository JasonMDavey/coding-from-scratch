import java.util.HashSet;

final PVector TILE_SIZE = new PVector(128f, 64f);
final PVector X_STRIDE = new PVector(TILE_SIZE.x/2f, TILE_SIZE.y/2f);
final PVector Y_STRIDE = new PVector(-TILE_SIZE.x/2f, TILE_SIZE.y/2f);
final float CAMERA_SPEED = 10f;

PVector cameraPosition;

String[] tileAssets = new String[] {
  "water", "cone!", "grass",
  "river_curve_bottom", "river_curve_left", "river_curve_right", "river_curve_top",
  "river_down_right", "river_up_right",
  "rivercorner_1", "rivercorner_2", "rivercorner_3", "rivercorner_4",
  "rivericorner_1", "rivericorner_2", "rivericorner_3", "rivericorner_4",
  "riverside_1", "riverside_2", "riverside_3", "riverside_4",
  "road_1", "road_2",
  "roadbridge_1", "roadbridge_2",
  "roadcorner_1", "roadcorner_2", "roadcorner_3", "roadcorner_4",
  "roadend_1", "roadend_2", "roadend_3", "roadend_4",
  "roadriver_1", "roadriver_2",
  "roadtee_1", "roadtee_2", "roadtee_3", "roadtee_4", "roadtee_5"
};

boolean capture = false;
PImage hand;

PImage[] tileImages;

int[][] world;

void setup() {
  size(800, 800, P3D);

  hand = loadImage("hand.png");
  
  cameraPosition = new PVector(width/2f, height/2f);

  tileImages = new PImage[tileAssets.length];
  for (int i=0; i<tileAssets.length; ++i) {
    tileImages[i] = loadImage(tileAssets[i] + ".png");
  }

  world = new int[32][32];
}

void draw() { 
  background(0);

  if (heldKeys.contains(UP)) {
    cameraPosition.y += CAMERA_SPEED;
  }
  if (heldKeys.contains(DOWN)) {
    cameraPosition.y -= CAMERA_SPEED;
  }
  if (heldKeys.contains(LEFT)) {
    cameraPosition.x += CAMERA_SPEED;
  }
  if (heldKeys.contains(RIGHT)) {
    cameraPosition.x -= CAMERA_SPEED;
  }
  
  translate(cameraPosition.x, cameraPosition.y);

  imageMode(CENTER);

  int[] hoveredTile = getTileAt(mouseX, mouseY);

  for (int y=0; y<world.length; ++y) {
    for (int x=0; x<world[0].length; ++x) {
      int tileType = world[y][x]; // Indices are reversed so we can define our array in a friendly-looking way

      // Highlight hovered tile
      if (hoveredTile != null && x==hoveredTile[0] && y==hoveredTile[1]) {
        tint(255, 0, 0);
      } else {
        tint(255, 255, 255);
      }

      drawTile(tileType, x, y);
    }
  }
  
  tint(255);
  image(hand,mouseX-cameraPosition.x,mouseY-cameraPosition.y);
  
  if (capture) saveFrame("fr#####.png");
}


void drawTile(int type, int x, int y) {
  PVector screenPosition = getScreenPos(x, y);

  image(tileImages[type], screenPosition.x, screenPosition.y);
}

PVector getScreenPos(int x, int y) {
  PVector xTerm = PVector.mult(X_STRIDE, x);
  PVector yTerm = PVector.mult(Y_STRIDE, y);
  return PVector.add(xTerm, yTerm);
}

int[] getTileAt(int screenX, int screenY) {
  /*
  // Old code - couldn't resist replacing this after the stream =P 
  PVector mousePos = new PVector(screenX-cameraPosition.x, screenY-cameraPosition.y);

  float closestDist = Float.MAX_VALUE;
  int[] closestTile = null;

  for (int y=0; y<world.length; ++y) {
    for (int x=0; x<world[0].length; ++x) {
      PVector tilePos = getScreenPos(x, y);
      float dist = PVector.dist(tilePos, mousePos);
      if (dist < closestDist) {
        closestDist = dist;
        closestTile = new int[] {x, y};
      }
    }
  }

  if (closestDist <= TILE_SIZE.y / 2f) {
    return closestTile;
  } else {
    return null;
  }
  */
  
  float xStrides = (screenX-cameraPosition.x) / X_STRIDE.x;
  
  // Our coordinate system's origin actually corresponds to what is visually the "top" corner of each tile,
  // but we don't draw the tile sprites centered on that position - we add this y-offset to account for that
  float yStrides = (screenY-cameraPosition.y+50f) / X_STRIDE.y;
  
  // Solving the following for tileX and tileY
  // xStrides = tileX-tileY   ->   tileX = xStrides + tileY
  // yStrides = tileX+tileY   ->   tileY = yStrides - tileX   ->   tileY = yStrides - (xStrides + tileY)   ->   tileY = (yStrides-xStrides)/2
  
  float tileY = (yStrides-xStrides)/2f;
  float tileX = xStrides + tileY;
  
  //
  
  if (tileX < 0f || tileY < 0f || tileX >= world[0].length || tileY >= world.length) return null;  // Out-of-bounds
  
  return new int[] { (int)tileX, (int)tileY };
}

void mouseWheel(MouseEvent event) {
  int[] hoveredTile = getTileAt(mouseX, mouseY);
  if (hoveredTile == null) return;
  
  int tileIndex = world[hoveredTile[1]][hoveredTile[0]];
  tileIndex += event.getCount();
  tileIndex %= tileImages.length;
  while (tileIndex < 0) {
    tileIndex += tileImages.length;
  }
  
  world[hoveredTile[1]][hoveredTile[0]] = tileIndex;
}


HashSet<Integer> heldKeys = new HashSet<Integer>();

void keyPressed() {
  if (key == CODED) {
    heldKeys.add(keyCode);
  }
  
  if (key == ' ') {
    capture = !capture;
  }
}   
      
void keyReleased() {
  if (key == CODED) {
    heldKeys.remove(keyCode);
  }
} 
      
