import java.util.LinkedList;

class Level {
  int[][] world = new int[32][32];
  int[] towerPosition = new int[]{0,0};
  int[][] buildingPositions = new int[][]{{1,1}};
  
  // TODO: available tile pool
   
  // Checks that tiles connect properly with their neighbours
  public boolean isValid() {
    HashMap<String, Direction[]> tileTypeConnectivity = getConnectivityInfo();
    
    for (int y=0; y<world.length; ++y) {
      for (int x=0; x<world[0].length; ++x) {
        int tileType = world[y][x];
        String tileTypeName = tileAssets[tileType];
        Direction[] tileConnectivity = tileTypeConnectivity.get(tileTypeName);
        if (tileConnectivity == null) continue;  // Not a road tile!
        
        // Check neighbours
        for (Direction d : tileConnectivity) {
          switch (d) {
            case NORTH:
              if (!neighbourConnects(tileTypeConnectivity, x, y-1, Direction.SOUTH)) return false;
              break;
            case EAST:
              if (!neighbourConnects(tileTypeConnectivity, x+1, y, Direction.WEST)) return false;
              break;
            case SOUTH:
              if (!neighbourConnects(tileTypeConnectivity, x, y+1, Direction.NORTH)) return false;
              break;
            case WEST:
              if (!neighbourConnects(tileTypeConnectivity, x-1, y, Direction.EAST)) return false;
              break;
          }
        }
      }
    }
    
    return true;
  }
  
  public boolean areBuildingsConnected() {
    HashMap<String, Direction[]> tileTypeConnectivity = getConnectivityInfo(); //<>//
    
    HashSet<String> tilesVisited = new HashSet<String>();
    HashSet<String> buildingsReached = new HashSet<String>();
    
    LinkedList<int[]> tilesToVisit = new LinkedList<int[]>();
    tilesToVisit.add(towerPosition);
    
    while (!tilesToVisit.isEmpty()) {
      // Visit a tile
      int[] tileToVisit = tilesToVisit.removeFirst();
      int x = tileToVisit[0];
      int y = tileToVisit[1];
      
      tilesVisited.add(x + "," + y);
      
      // Check whether there is a building here
      for (int[] buildingPos : buildingPositions) {
        if (buildingPos[0] == x && buildingPos[1] == y) {
          buildingsReached.add(x + "," + y);
          
          if (buildingsReached.size() == buildingPositions.length) {
            return true;
          }
        }
      }
      
      int tileType = world[y][x];
      String tileTypeName = tileAssets[tileType];
      Direction[] tileConnectivity = tileTypeConnectivity.get(tileTypeName);
      if (tileConnectivity == null) throw new RuntimeException("Encountered non-road tile when checking connectivity");
      
      // Queue up its neighbours for visiting
      for (Direction d : tileConnectivity) {
        int[] neighbourPos = null;
        switch (d) {
          case NORTH: neighbourPos = new int[]{x,y-1}; break;
          case EAST: neighbourPos = new int[]{x+1,y}; break;
          case SOUTH: neighbourPos = new int[]{x,y+1}; break;
          case WEST: neighbourPos = new int[]{x-1,y}; break;
        }
        
        if (!tilesVisited.contains(neighbourPos[0] + "," + neighbourPos[1])) {
          tilesToVisit.add(neighbourPos);
        }
      }
    }
    
    return false;
  }
  
  private HashMap<String, Direction[]> getConnectivityInfo() {
    // Big mapping telling us which neighbour tiles different roads expect to be connected to
    HashMap<String, Direction[]> tileTypeConnectivity = new HashMap<String, Direction[]>();
    
    tileTypeConnectivity.put("road_1", new Direction[]{Direction.EAST,Direction.WEST});
    tileTypeConnectivity.put("road_2", new Direction[]{Direction.NORTH,Direction.SOUTH});
    tileTypeConnectivity.put("roadcorner_1", new Direction[]{Direction.EAST,Direction.SOUTH});
    tileTypeConnectivity.put("roadcorner_2", new Direction[]{Direction.NORTH,Direction.EAST});
    tileTypeConnectivity.put("roadcorner_3", new Direction[]{Direction.WEST,Direction.SOUTH});
    tileTypeConnectivity.put("roadcorner_4", new Direction[]{Direction.NORTH,Direction.WEST});
    tileTypeConnectivity.put("roadtee_1", new Direction[]{Direction.NORTH,Direction.WEST,Direction.SOUTH});
    tileTypeConnectivity.put("roadtee_2", new Direction[]{Direction.NORTH,Direction.EAST,Direction.SOUTH});
    tileTypeConnectivity.put("roadtee_3", new Direction[]{Direction.EAST,Direction.SOUTH,Direction.WEST});
    tileTypeConnectivity.put("roadtee_4", new Direction[]{Direction.NORTH,Direction.EAST,Direction.WEST});
    tileTypeConnectivity.put("roadtee_5", new Direction[]{Direction.NORTH,Direction.EAST,Direction.SOUTH,Direction.WEST});
    tileTypeConnectivity.put("roadend_1", new Direction[]{Direction.EAST});
    tileTypeConnectivity.put("roadend_2", new Direction[]{Direction.SOUTH});
    tileTypeConnectivity.put("roadend_3", new Direction[]{Direction.WEST});
    tileTypeConnectivity.put("roadend_4", new Direction[]{Direction.NORTH});
    
    return tileTypeConnectivity;
  }
  
  private boolean neighbourConnects(HashMap<String, Direction[]> tileTypeConnectivity, int x, int y, Direction requiredConnection) {
    if (x < 0 || y < 0 || x >= world[0].length || y >= world.length) return false;  // Out-of-bounds
    
    int tileType = world[y][x];
    String tileTypeName = tileAssets[tileType];
    Direction[] tileConnectivity = tileTypeConnectivity.get(tileTypeName);
    if (tileConnectivity == null) return false;  // Not a road tile!
    
    for (Direction d : tileConnectivity) {
      if (d == requiredConnection) return true;
    }
    return false;
  }
}
