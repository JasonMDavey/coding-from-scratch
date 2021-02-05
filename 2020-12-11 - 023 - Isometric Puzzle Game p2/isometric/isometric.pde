//
// You are free to modify or use this code however you would like!
//
// • Tile assets by Kenney: https://kenney.nl/assets
//

import java.util.HashSet;
import com.google.gson.*;

boolean capture = false;
PImage hand;

final PVector TILE_SIZE = new PVector(128f, 64f);
final PVector X_STRIDE = new PVector(TILE_SIZE.x/2f, TILE_SIZE.y/2f);
final PVector Y_STRIDE = new PVector(-TILE_SIZE.x/2f, TILE_SIZE.y/2f);
final float CAMERA_SPEED = 10f;

PVector cameraPosition;

static String[] tileAssets = new String[] {
  "grass", "water", "cone!", 
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

static String[] placeableTileNames = new String[] {
  "road_1", "road_2",
  "roadcorner_1", "roadcorner_2", "roadcorner_3", "roadcorner_4",
  "roadtee_1", "roadtee_2", "roadtee_3", "roadtee_4", "roadtee_5",
  "roadend_1", "roadend_2", "roadend_3", "roadend_4"
};

ArrayList<Integer> placeableTiles = new ArrayList<Integer>();
int selectedTileType = 0;

HashSet<String> interactableTiles;
HashMap<String, Integer> tilesUsed;

PImage[] tileImages;
PImage towerImage, buildingImage;

Library library;
int currentLevelIndex = 0;
Level currentLevel;

boolean editorMode = true;
boolean creativeMode = false;

void setup() {
  size(800, 800, P3D);
  
  hand = loadImage("hand.png");
  
  cameraPosition = new PVector(width/2f, height/2f);

  tileImages = new PImage[tileAssets.length];
  for (int i=0; i<tileAssets.length; ++i) {
    tileImages[i] = loadImage(tileAssets[i] + ".png");
  }
  
  towerImage = loadImage("tower.png");
  buildingImage = loadImage("building.png");
  
  for (String tileName : placeableTileNames) {
    for (int i=0; i<tileAssets.length; ++i) {
      if (tileAssets[i].equals(tileName)) {
        placeableTiles.add(i);
      }
    }
  }  

  String libraryAsString = String.join("\n", loadStrings("library.json"));
  library = new Gson().fromJson(libraryAsString, Library.class);
  
  if (library.levels.isEmpty()) {
    library.levels.add(new Level());
  }
  startLevel(library.levels.get(0));
}

void startLevel(Level l) {
  tilesUsed = new HashMap<String, Integer>();
  
  currentLevel = l;
  interactableTiles = new HashSet<String>();
  
  // Locate all grass tiles - these are the only tiles the player can interact with
  for (int y=0; y<l.world.length; ++y) {
    for (int x=0; x<l.world[0].length; ++x) {
      if (l.world[y][x] == 0) {
        interactableTiles.add(x+","+y);
      }
    }
  }
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
  
  pushMatrix();
  translate(cameraPosition.x, cameraPosition.y);

  imageMode(CENTER);

  int[] hoveredTile = getTileAt(mouseX, mouseY);

  for (int y=0; y<currentLevel.world.length; ++y) {
    for (int x=0; x<currentLevel.world[0].length; ++x) {
      int tileType = currentLevel.world[y][x]; // Indices are reversed so we can define our array in a friendly-looking way

      // Highlight hovered tile
      if (hoveredTile != null && x==hoveredTile[0] && y==hoveredTile[1]) {
        if (!editorMode) {
          // Preview tile we're about to place
          tileType = placeableTiles.get(selectedTileType);
        }
        tint(255, 0, 0);
      } else if (tileType != 0 && interactableTiles.contains(x+","+y)) {
        // This tile is marked as interactable, but it doens't contain grass - the player must have placed something here
        tint(128, 255, 255);
      } else {
        tint(255, 255, 255);
      }

      drawTile(tileType, x, y);
      
      // Draw tower or buildings, if they are on this tile
      if (x==currentLevel.towerPosition[0] && y==currentLevel.towerPosition[1]) {
        PVector screenPosition = getScreenPos(x, y);
        image(towerImage, screenPosition.x, screenPosition.y);
      }
      
      for (int[] buildingPosition : currentLevel.buildingPositions) {
        if (x==buildingPosition[0] && y==buildingPosition[1]) {
          PVector screenPosition = getScreenPos(x, y);
          image(buildingImage, screenPosition.x, screenPosition.y);
        }
      }
    }
  }
  
  popMatrix();
  
  if (!editorMode) {
    drawGameUI();
  }
  
  tint(255);
  image(hand,mouseX,mouseY);
  
  if (capture) saveFrame("fr#####.png");
}

void drawGameUI() {
  int yCursor = 55;
  int xCursor = 60;
  int xStep = 135;
  
  noStroke();
  fill(0,0,0,128);
  rect(0,0,width,50);
  
  pushMatrix();
  scale(0.4);
  textSize(40);
  
  for (int i=0; i<placeableTiles.size(); ++i) {
    int placeableTile = placeableTiles.get(i);
    
    String tileTypeName = placeableTileNames[i];
    int numTilesInPool = currentLevel.tilePool.getOrDefault(tileTypeName, 0);
    numTilesInPool -= tilesUsed.getOrDefault(tileTypeName, 0);
    
    int alpha = creativeMode || numTilesInPool > 0 ? 255 : 128;
    
    if (i == selectedTileType) {
      tint(255,0,0, alpha);
    }
    else {
      tint(255, 255, 255, alpha);
    }
    
    image(tileImages[placeableTile], xCursor, yCursor);
    
    fill(255);
    text(Integer.toString(numTilesInPool), xCursor-10, yCursor+85);
    
    xCursor += xStep;
  }
  popMatrix();
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
 
  float xStrides = (screenX-cameraPosition.x) / X_STRIDE.x;
  
  // Our coordinate system's origin actually corresponds to what is visually the "top" corner of each tile,
  // but we don't draw the tile sprites centered on that position - we add this y-offset to account for that
  float yStrides = (screenY-cameraPosition.y+25f) / X_STRIDE.y;
  
  // Solving the following for tileX and tileY
  // xStrides = tileX-tileY   ->   tileX = xStrides + tileY
  // yStrides = tileX+tileY   ->   tileY = yStrides - tileX   ->   tileY = yStrides - (xStrides + tileY)   ->   tileY = (yStrides-xStrides)/2
  
  float tileY = (yStrides-xStrides)/2f;
  float tileX = xStrides + tileY;
  
  if (tileX < 0f || tileY < 0f || tileX >= currentLevel.world[0].length || tileY >= currentLevel.world.length) return null;  // Out-of-bounds
  
  return new int[] { (int)tileX, (int)tileY };
}

void mouseWheel(MouseEvent event) {
  if (editorMode) {
    int[] hoveredTile = getTileAt(mouseX, mouseY);
    if (hoveredTile == null) return;
    
    int tileIndex = currentLevel.world[hoveredTile[1]][hoveredTile[0]];
    tileIndex += event.getCount();
    tileIndex %= tileImages.length;
    while (tileIndex < 0) {
      tileIndex += tileImages.length;
    }
    
    currentLevel.world[hoveredTile[1]][hoveredTile[0]] = tileIndex;
  }
  else {
    selectedTileType += event.getCount();
    selectedTileType %= placeableTiles.size();
    while (selectedTileType < 0) {
      selectedTileType += placeableTiles.size();
    }
  }
}

void mousePressed() {
  if (editorMode) return;
  
  int[] hoveredTile = getTileAt(mouseX, mouseY);
  if (hoveredTile == null) return;

  // We can't place/un-place from tiles which aren't marked as interactable for this level
  if (!creativeMode && !interactableTiles.contains(hoveredTile[0]+","+hoveredTile[1])) return;
  
  if (mouseButton == LEFT) {
    // Place a tile
    
    String tileTypeName = placeableTileNames[selectedTileType];
    int numTilesInPool = currentLevel.tilePool.getOrDefault(tileTypeName, 0);
    numTilesInPool -= tilesUsed.getOrDefault(tileTypeName, 0);
    
    if (creativeMode || numTilesInPool > 0) {
      // Before overwriting, we may need to return the current tile at this location to the player's pool
      unPlaceTile(hoveredTile[0], hoveredTile[1]);
      
      currentLevel.world[hoveredTile[1]][hoveredTile[0]] = placeableTiles.get(selectedTileType);
      
      int tilesOfThisTypeUsed = tilesUsed.getOrDefault(tileTypeName, 0);
      ++tilesOfThisTypeUsed;
      tilesUsed.put(tileTypeName, tilesOfThisTypeUsed);
      
      if (!creativeMode) {
        checkForWin();
      }
    }
  }
  else if (mouseButton == RIGHT) {
    // Un-place a tile
    unPlaceTile(hoveredTile[0], hoveredTile[1]);
    if (!creativeMode) {
      checkForWin();
    }
  }
}

void unPlaceTile(int x, int y) {
  
  String tileTypeName = tileAssets[currentLevel.world[y][x]];
  int numUsed = tilesUsed.getOrDefault(tileTypeName, 0);
  
  if (!creativeMode && numUsed == 0) return;  // Can't un-place tiles the player didn't place
  
  --numUsed;
  tilesUsed.put(tileTypeName, numUsed); // Return tile to pool
  currentLevel.world[y][x] = 0;  // Set to grass
}

void checkForWin() {
  boolean isValid = currentLevel.isValid();
    
  if (isValid) {
    boolean connected = currentLevel.areBuildingsConnected();
    if (connected) {
      println("You did it!");
      proceedToNextLevel();
    }
  }
}

void proceedToNextLevel() {
  ++currentLevelIndex;
  if (currentLevelIndex == library.levels.size()) {
    print("Game complete!");
    exit();
  }
  else {
    startLevel(library.levels.get(currentLevelIndex));
  }
}

HashSet<Integer> heldKeys = new HashSet<Integer>();

void keyPressed() {
  if (key == CODED) {
    heldKeys.add(keyCode);
  }
  else if (key == 'e') {
    editorMode = !editorMode;
  }
  else if (key == 'c') {
    creativeMode = !creativeMode;
  }
  else if (key == 'p') {
    String placedTilesAsJson = new GsonBuilder().setPrettyPrinting().create().toJson(tilesUsed);
    println(placedTilesAsJson);
  }
  else if (editorMode && key == 's') {
    String libraryAsJson = new GsonBuilder().setPrettyPrinting().create().toJson(library);
    saveStrings("data/library.json", new String[]{ libraryAsJson });
  }
  else if (editorMode && key == 'n') {
    proceedToNextLevel();
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
      
