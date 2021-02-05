static class World {
  public static int NUM_ROWS = 4;
  public static int NUM_COLS = 8;
  
  public static int GRID_TOP_LEFT_X = 200;
  public static int GRID_TOP_LEFT_Y = 150;
  public static int GRID_CELL_WIDTH = 128;
  public static int GRID_CELL_HEIGHT = 128;
  
  public static float ENEMY_SPAWN_X = 9f;
  
  public static PVector getWorldPos(float row, float column) {
    return new PVector(GRID_TOP_LEFT_X + column*GRID_CELL_WIDTH, GRID_TOP_LEFT_Y + row*GRID_CELL_HEIGHT);
  }
  
  public static int[] getTileAt(float x, float y) {
    int row = Math.round((y-GRID_TOP_LEFT_Y) / GRID_CELL_HEIGHT); //<>//
    int col = Math.round((x-GRID_TOP_LEFT_X) / GRID_CELL_WIDTH);
    if (col < 0 || col >= NUM_COLS || row < 0 || row >= NUM_ROWS) return null;
    return new int[]{row, col};
  }
}
