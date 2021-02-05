public static class ProcGen {
  static final float ROAD_RADIUS = 15f;
  static final float BUILDING_THICKNESS = 50f;
  static final float BUILDING_WIDTH = 40f;
  
  static List<float[]> buildingLibrary = new ArrayList<float[]>();
  
  static {
    buildingLibrary.add(new float[] {0f,0f, 0f,1f, 1f,1f, 1f,0f});
    buildingLibrary.add(new float[] {0f,0f, 0f,1f, 0.3f,1f, 0.3f,0.7f, 0.7f,0.7f, 0.7f,1f, 1f,1f, 1f,0f});
    buildingLibrary.add(new float[] {0f,0f, 0f,1f, 0.5f,1f, 0.5f,0.5f, 1f,0.5f, 1f,0f});
  }
  
  public static Region generateRegion(List<PVector> polygon) {
    Random rand = new Random(polygon.hashCode());
    
    // Allocate a new region
    Region region = new Region();
    region.cornerVertices = polygon;
    region.roadVertices = new ArrayList<PVector>(polygon.size());
    region.buildingBackVertices = new ArrayList<PVector>(polygon.size());
    region.buildings = new ArrayList<List<PVector>>();
    
    // Precalculate road / building lines (by insetting from outer boundary)
    for (int i=0; i<polygon.size(); ++i) {
      region.roadVertices.add(Geometry.generateInsetPoint(polygon, i, ROAD_RADIUS));
      region.buildingBackVertices.add(Geometry.generateInsetPoint(polygon, i, ROAD_RADIUS + BUILDING_THICKNESS));
    }
    
    List<RegionBoundary> boundaries = new ArrayList<RegionBoundary>(polygon.size());
    
    // Precalulate info about edges
    for (int i=0; i<polygon.size(); ++i) {
      // Figure out how to evenly subdivide this side of the region polygon
      int nextIndex = (i+1) % polygon.size();
      region.roadVertices.add(Geometry.generateInsetPoint(polygon, i, ROAD_RADIUS));
      region.buildingBackVertices.add(Geometry.generateInsetPoint(polygon, i, ROAD_RADIUS + BUILDING_THICKNESS));
      
      PVector backFaceStartVertex = region.buildingBackVertices.get(i);
      PVector backFaceEndVertex = region.buildingBackVertices.get(nextIndex);
      PVector backFaceVector = PVector.sub(backFaceEndVertex, backFaceStartVertex);
      float backFaceLength = backFaceVector.mag();
      
      PVector frontFaceStartVertex = region.roadVertices.get(i);
      PVector frontFaceEndVertex = region.roadVertices.get(nextIndex);
      PVector frontFaceMidpoint = PVector.add(frontFaceStartVertex, frontFaceEndVertex).mult(0.5f);
      
      PVector frontFaceHalfStep = PVector.sub(frontFaceEndVertex, frontFaceStartVertex).setMag(backFaceLength*0.5f);
      PVector frontFaceAdjustedStartVertex = PVector.add(frontFaceMidpoint, PVector.mult(frontFaceHalfStep, -1f));
      PVector frontFaceAdjustedEndVertex = PVector.add(frontFaceMidpoint, frontFaceHalfStep);
      
      RegionBoundary boundary = new RegionBoundary();
      boundary.frontFaceStart = frontFaceAdjustedStartVertex;
      boundary.frontFaceEnd = frontFaceAdjustedEndVertex;
      boundary.backFaceStart = backFaceStartVertex;
      boundary.backFaceEnd = backFaceEndVertex;
      boundaries.add(boundary);
    }
      
    // Populate with buildings
    for (int i=0; i<polygon.size(); ++i) {
      RegionBoundary boundary = boundaries.get(i);
      
      PVector backFaceVector = PVector.sub(boundary.backFaceEnd, boundary.backFaceStart);
      PVector frontFaceVector = PVector.sub(boundary.frontFaceEnd, boundary.frontFaceStart);
      
      // Figure out how long the front-face of this side of the region is,
      // and therefore how many buildings we can comfortably fit inside
      float frontFaceLength = frontFaceVector.mag();
      int buildingCount = floor(frontFaceLength / BUILDING_WIDTH);
            
      // Figure out how far along the front and back faces we'll step when placing each building
      PVector frontFaceStep = PVector.mult(frontFaceVector, 1f/buildingCount);
      PVector backFaceStep = PVector.mult(backFaceVector, 1f/buildingCount);
      
      for (int buildingIndex=0; buildingIndex<buildingCount; ++buildingIndex) {
        // Calculating corners of building's "plot"
        PVector p0 = PVector.add(boundary.frontFaceStart, PVector.mult(frontFaceStep, buildingIndex));
        PVector p1 = PVector.add(boundary.backFaceStart, PVector.mult(backFaceStep, buildingIndex));
        PVector p2 = PVector.add(boundary.backFaceStart, PVector.mult(backFaceStep, buildingIndex+1));
        PVector p3 = PVector.add(boundary.frontFaceStart, PVector.mult(frontFaceStep, buildingIndex+1));
 //<>//
        region.buildings.add(insertRandomBuilding(rand, p0, p1, p2, p3)); //<>//
      }
      
      // Add corner building
      int neighbourIndex = (i+1)%polygon.size();
      if (!Geometry.isConcaveCorner(polygon, neighbourIndex)) {
        RegionBoundary neighbouringBoundary = boundaries.get(neighbourIndex);
        
        PVector p0 = boundary.backFaceEnd;
        PVector p1 = boundary.frontFaceEnd;
        PVector p2 = region.roadVertices.get(neighbourIndex);
        PVector p3 = neighbouringBoundary.frontFaceStart;
        region.buildings.add(insertRandomBuilding(rand, p0, p1, p2, p3));
      }
    }
    
    return region;
  }
  
  private static List<PVector> insertRandomBuilding(Random rand, PVector p0, PVector p1, PVector p2, PVector p3) {
    float[] buildingTemplate = buildingLibrary.get(rand.nextInt(buildingLibrary.size()));
    List<PVector> buildingPoints = new ArrayList<PVector>(buildingTemplate.length / 2);
    for (int buildingVertexIndex=0; buildingVertexIndex<buildingTemplate.length; buildingVertexIndex += 2) {
      float x = buildingTemplate[buildingVertexIndex];
      float y = buildingTemplate[buildingVertexIndex+1];
      
      // Map/interpolate onto corners of the building's plot
      PVector minY = PVector.mult(p0, x).add(PVector.mult(p3, 1f-x));
      PVector maxY = PVector.mult(p1, x).add(PVector.mult(p2, 1f-x));
      PVector point = PVector.mult(minY, 1f-y).add(PVector.mult(maxY, y));
      buildingPoints.add(point);
    }
    
    return buildingPoints;
  }
}
