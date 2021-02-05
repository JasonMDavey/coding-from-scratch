class SpatialGrid {
  
  float cellSize;
  int numCellsX, numCellsY;
  
  ArrayList<ArrayList<Bird>> cells;
  
  public SpatialGrid(float _cellSize) {
    this.cellSize = _cellSize;
    this.numCellsX = ceil(width/cellSize);
    this.numCellsY = ceil(height/cellSize);
    
    int numCellsTotal = numCellsX * numCellsY;
    cells = new ArrayList<ArrayList<Bird>>(numCellsTotal);
    for (int i=0; i<numCellsTotal; ++i) {
      cells.add(new ArrayList<Bird>());
    }
  }
  
  /*
   * Clears all grid cells
   */
  public void empty() {
    for (ArrayList<Bird> cell : cells) {
      cell.clear();
    }
  }
  
  /*
   * Adds the bird to the appropriate grid cell
   */
  public void add(Bird b, float x, float y) {
    if (x < 0 || y < 0 || x >= width || y >= height) {
      throw new RuntimeException("Tried to add bird outside of grid bounds!!");
    }
    
    int cellX = (int)(x / cellSize);
    int cellY = (int)(y / cellSize);
    getCell(cellX, cellY).add(b);
  }
  
  /*
   * Returns a cell, based on its coordinates
   */
  public ArrayList<Bird> getCell(int cellX, int cellY) {
    int cellIndex = cellX + cellY*numCellsX;
    return cells.get(cellIndex);
  }
  
  /*
   * Performs a broad-phase lookup of all birds which *might* be within the specified radius of the specified point.
   * This can have false-positives, so the results need to be filtered with a proper distance check afterwards
   */
  public ArrayList<Bird> query(float x, float y, float radius) {
    ArrayList<Bird> results = new ArrayList<Bird>(32);
    
    float minX = x-radius;
    float maxX = x+radius;
    float minY = y-radius;
    float maxY = y+radius;
    
    int minCellX = max(0, (int)(minX/cellSize));
    int maxCellX = min(numCellsX-1, (int)(maxX/cellSize));
    int minCellY = max(0, (int)(minY/cellSize));
    int maxCellY = min(numCellsY-1, (int)(maxY/cellSize));
    
    for (int cellX=minCellX; cellX<=maxCellX; ++cellX) {
      for (int cellY=minCellY; cellY<=maxCellY; ++cellY) {
        results.addAll(getCell(cellX, cellY));
      }
    } 
    
    return results;
  }
  
  public void debugDraw() {
    noFill();
    stroke(128,128,128,20);
    for (int x=0; x<numCellsX; ++x) {
      line(x*cellSize, 0, x*cellSize, height); 
    }
    for (int y=0; y<numCellsY; ++y) {
      line(0, y*cellSize, width, y*cellSize); 
    }
  }
}
