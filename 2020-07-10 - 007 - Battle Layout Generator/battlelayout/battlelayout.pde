//
// You are free to modify or use this code however you would like!
//
// Images and other assets are for personal / non-commercial / educational use only.
//

import com.google.gson.*;

PImage backgroundImage, gridCellImage, cursorImage;

static int GRID_SIZE = 3;

static PVector GRID_TOP_LEFT = new PVector(85, 91);
static float GRID_CELL_PADDING = 8f;

static PVector LIBRARY_TOP_LEFT = new PVector(567, 66);
static float LIBRARY_SPACING = 120f;
static int LIBRARY_NUM_COLUMNS = 4;

TileObject grid[][];
PVector gridCursorPosition = new PVector(0,0);

Library library;
int libraryCursorPosition = 0;


/*
 * Called once during startup
 */
void setup() {
  // Create the window
  size(1000, 434, P3D);
  
  // Load common image assets
  backgroundImage = loadImage("background.png");
  gridCellImage = loadImage("gridCell.png");
  cursorImage = loadImage("cursor.png");
  
  // Define empty grid
  grid = new TileObject[GRID_SIZE][GRID_SIZE];
  
  // Load tile / asset library
  String libraryAsString = String.join("\n", loadStrings("library.json"));
  library = new Gson().fromJson(libraryAsString, Library.class);
  
  //grid = Solver.solve(library, 2); //<>//
}


/*
 * Called once per frame
 */
void draw() {
  // Draw background
  tint(255,255,255,255);
  background(0,0,0);
  imageMode(CORNER);
  image(backgroundImage, 0, 0);
  
  /*
   * Render grid
   */
  imageMode(CENTER);
  for (int x=0; x<GRID_SIZE; ++x) {
    for (int y=0; y<GRID_SIZE; ++y) {
      float xPos = GRID_TOP_LEFT.x + x*GRID_CELL_PADDING + x*gridCellImage.width;
      float yPos = GRID_TOP_LEFT.y + y*GRID_CELL_PADDING + y*gridCellImage.height;
      
      if (x == gridCursorPosition.x && y == gridCursorPosition.y) {
        image(cursorImage, xPos, yPos);
      }
      else {
        image(gridCellImage, xPos, yPos);
      }
      
      TileObject objectHere = grid[x][y];
      
      if (objectHere != null) {
        image(getAssetImage(objectHere.imageAsset), xPos, yPos);
      }
    }
  }
  
  // Render library
  for (int i=0; i<library.tileObjects.size(); ++i) {
    TileObject o = library.tileObjects.get(i);
    
    int row = floor(i/LIBRARY_NUM_COLUMNS);
    int column = i%LIBRARY_NUM_COLUMNS;
    float xPos = LIBRARY_TOP_LEFT.x + column*LIBRARY_SPACING;
    float yPos = LIBRARY_TOP_LEFT.y + row*LIBRARY_SPACING;
    
    if (i == libraryCursorPosition) {
      tint(255,255,255,255);
    }
    else {
      tint(255,255,255,80);
    }
    image(getAssetImage(o.imageAsset), xPos, yPos);
  }
}

/*
 * Handle keyboard input
 */
void keyPressed() {
  // Moving grid / library cursors
  switch (keyCode) {
    case RIGHT:  gridCursorPosition.x = min(GRID_SIZE-1, gridCursorPosition.x+1);  break;
    case LEFT:   gridCursorPosition.x = max(0, gridCursorPosition.x-1);  break;
    case UP:     gridCursorPosition.y = max(0, gridCursorPosition.y-1);  break;
    case DOWN:   gridCursorPosition.y = min(GRID_SIZE-1, gridCursorPosition.y+1);  break;
    
    case TAB:    libraryCursorPosition = (libraryCursorPosition+1) % library.tileObjects.size();  break;
  }
  
  // Place / un-place object
  if (key == ' ') {
    if (grid[(int)gridCursorPosition.x][(int)gridCursorPosition.y] == null) {
      // The tile is empty - add the currently highlighted object from the library here
      grid[(int)gridCursorPosition.x][(int)gridCursorPosition.y] = library.tileObjects.get(libraryCursorPosition);
    }
    else {
      // Tile is not empty - remove the current object
      grid[(int)gridCursorPosition.x][(int)gridCursorPosition.y] = null;
    }
  }
  
  // Save grid as compound object
  if (key == 's') {
    // Find bounding-box of object
    
    int minX = Integer.MAX_VALUE;
    int maxX = -Integer.MIN_VALUE;
    int minY = Integer.MAX_VALUE;
    int maxY = -Integer.MIN_VALUE;
    for (int x=0; x<GRID_SIZE; ++x) {
      for (int y=0; y<GRID_SIZE; ++y) {
        if (grid[x][y] != null) {
          minX = min(minX, x);
          maxX = max(maxX, x);
          minY = min(minY, y);
          maxY = max(maxY, y);
        }
      }
    }
    
    if (minX == Integer.MAX_VALUE) {
      println("Grid is empty");
    }
    else {
      CompoundObject o = new CompoundObject();
      o.width = 1+maxX-minX;
      o.height = 1+maxY-minY;
      o.tileObjects = new String[o.width][o.height];
      
      // Copy data into compound-object's array
      for (int x=minX; x<=maxX; ++x) {
        for (int y=minY; y<=maxY; ++y) {
          if (grid[x][y] != null) {
            o.tileObjects[x-minX][y-minY] = grid[x][y].id;
          }
        }
      }
      
      library.compoundObjects.add(o);
      println(new Gson().toJson(o));
      
      String libraryAsJson =  new GsonBuilder().setPrettyPrinting().create().toJson(library);
      saveStrings("data/library.json", new String[]{ libraryAsJson });
    }
  }
  
  if (key == 'g') {
    grid = Solver.solve(library, 3);
    saveFrame("frame#####.png");
  }
}

/*
 * Returns the PImage corresponding to the given asset name.
 * Caches images to avoid repeatedly loading them
 */
HashMap<String, PImage> cachedAssetImages = new HashMap<String, PImage>();
PImage getAssetImage(String imageName) {
  
  if (cachedAssetImages.containsKey(imageName)) return cachedAssetImages.get(imageName);
  
  PImage img = loadImage("images/" + imageName);
  cachedAssetImages.put(imageName, img);
  return img;
}
