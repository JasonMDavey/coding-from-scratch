/*
 * Utility functions relating to geometry
 */
public static class Geometry {
  
  public static PVector calculateInwardFacingCornerNormal(List<PVector> polygon, int cornerIndex) {
    PVector cornerPoint = polygon.get(cornerIndex);
    PVector previousPoint = polygon.get((cornerIndex-1+polygon.size()) % polygon.size());
    PVector nextPoint = polygon.get((cornerIndex+1) % polygon.size());
    
    PVector directionFromPrevious = PVector.sub(cornerPoint, previousPoint).normalize();
    PVector directionFromNext = PVector.sub(cornerPoint, nextPoint).normalize();
    PVector normal = PVector.add(directionFromPrevious, directionFromNext).normalize();
    
    // We want an offset which points "inside" the polygon
    // The direction of the normal we calculated flips depending on whether we're a concave or convex point of the polygon
    if (isConcaveCorner(polygon, cornerIndex)) {
      return normal;
    }
    else {
      return normal.mult(-1f);
    }
  }
  
  
  public static boolean isConcaveCorner(List<PVector> polygon, int cornerIndex) {
    PVector cornerPoint = polygon.get(cornerIndex);
    PVector previousPoint = polygon.get((cornerIndex-1+polygon.size()) % polygon.size());
    PVector nextPoint = polygon.get((cornerIndex+1) % polygon.size());
    
    PVector directionFromPrevious = PVector.sub(cornerPoint, previousPoint).normalize();
    PVector directionToNext = PVector.sub(nextPoint, cornerPoint).normalize();
        
    // Distinguish concave/convex by looking at the change in angle between the two line segments meeting at this point
    // (Assumes polygons are created by placing points in clockwise order, which would mean angle at each convex corner increases clockwise)
    
    float angleBetween = directionFromPrevious.heading() - directionToNext.heading();
    
    return (angleBetween > 0 && angleBetween < PI) || angleBetween < -PI;
  }
  
  
  public static PVector generateInsetPoint(List<PVector> polygon, int cornerIndex, float insetAmount) {
    PVector cornerPoint = polygon.get(cornerIndex);
    PVector cornerInsetNormal = calculateInwardFacingCornerNormal(polygon, cornerIndex);
    
    return PVector.add(cornerPoint, PVector.mult(cornerInsetNormal, insetAmount));
  }
}
