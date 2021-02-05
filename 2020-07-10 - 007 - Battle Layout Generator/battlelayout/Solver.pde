import java.util.*;

static class Solver {
  static TileObject[][] solve(Library library, int numObjects) {
    TileObject[][] grid = new TileObject[GRID_SIZE][GRID_SIZE];
    
    TileObject[][] result = place(library, grid, numObjects);
    
    if (result == null) {
      println("No possible solution!");
      return grid;
    }
    return result; //<>//
  }
  
  static TileObject[][] copyGrid(TileObject[][] grid) {
    TileObject[][] result = new TileObject[GRID_SIZE][GRID_SIZE];
    for (int x=0; x<GRID_SIZE; ++x) {
      for (int y=0; y<GRID_SIZE; ++y) {
        result[x][y] = grid[x][y];
      }
    }
    return result;
  }
  
  static TileObject[][] place(Library library, TileObject[][] grid, int numObjects) {
    
    // Place an object
    ArrayList<CompoundObject> objects = new ArrayList<CompoundObject>(library.compoundObjects);
    Collections.shuffle(objects);
    
    for (CompoundObject o : objects) {
      TileObject[][] result = place(library, o, copyGrid(grid), numObjects);
      if (result != null) return result;
    }
    
    println("Failed to place any objects");
    return null; //<>//
  }
  
  static TileObject[][] place(Library library, CompoundObject o, TileObject[][] grid, int numObjects) {
    
    println("Trying to place specific object");
    
    // Try all possible positions
    int maxX = (GRID_SIZE-1)-(o.width-1);  // the wider an object is, the less far to the right it is possible to place it
    int maxY = (GRID_SIZE-1)-(o.height-1);  // the taller an object is, the less far down it is possible to place it
    
    ArrayList<PVector> legalPositions = new ArrayList<PVector>();
    for (int x=0; x<=maxX; ++x) {
      for (int y=0; y<=maxY; ++y) {
        legalPositions.add(new PVector(x,y));
      }
    }
    
    Collections.shuffle(legalPositions);
    
    for (PVector pos : legalPositions) {
      // Check that no objects overlap
      boolean overlaps = false;

      checkPositions:
      for (int x=0; x<o.width; ++x) {
        for (int y=0; y<o.height; ++y) {
          int worldX = x+(int)pos.x;
          int worldY = y+(int)pos.y;
          if (o.tileObjects[x][y] != null && grid[worldX][worldY] != null) {
            overlaps = true;
            break checkPositions;
          }
        }
      }
      
      if (!overlaps) {
        // Place the object!
        
        TileObject[][] gridCopy = copyGrid(grid);
        
        for (int x=0; x<o.width; ++x) {
          for (int y=0; y<o.height; ++y) {
            int worldX = x+(int)pos.x;
            int worldY = y+(int)pos.y;
            
            if (o.tileObjects[x][y] != null) {
              gridCopy[worldX][worldY] = library.getTileObject(o.tileObjects[x][y]);
            }
          }
        }
    
        println("Placed object");
        
        if (numObjects == 1) return gridCopy; //<>//
        
        TileObject[][] result = place(library, gridCopy, numObjects-1);
        if (result != null) return result;
      }
    }
    
    println("No legal positions for object =(");
    return null; //<>//
  }
}
