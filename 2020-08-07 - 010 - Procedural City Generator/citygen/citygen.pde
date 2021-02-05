//
// Changes since video:
//
// • Cleaned up code formatting a bit
// • Tweaked geometry code to handle concave regions
//
// You are free to modify or use this code however you would like!
//

import java.util.*;

// How close does the mouse need to be to an existing point to snap to it when drawing
static final float SNAP_DISTANCE = 10f;

// Points and polygons which define the layout of the city
List<PVector> screenPoints = new ArrayList<PVector>();
List<List<PVector>> polygons = new ArrayList<List<PVector>>();

// Current editing state
List<PVector> inProgressPolygon = new ArrayList<PVector>();
static PVector draggedPoint = null;
boolean debugDraw = true;

/*
 * Called once at beginning of program
 */
void setup() {
  // Create window
  size(800, 500, P3D);
}


/*
 * Called for each frame
 */
void draw() {
  background(235,235,220);
  
  /*
   * Generate / draw regions
   */
  for (List<PVector> polygon : polygons) {
    Region region = ProcGen.generateRegion(polygon);
    drawRegion(region); //<>//
  }
  
  
  /*
   * Debug drawing
   */
  if (debugDraw) {
    PVector snapToPoint = getSnapToPoint();
    noStroke();
    
    // Draw all vertices in the city
    for (PVector p : screenPoints) {
      // Highlight point if it's within "snap to" range
      if (p == snapToPoint) {
        fill(255,255,0);
      }
      else {
        fill(255,0,0);
      }
      
      ellipse(p.x, p.y, 10, 10);
    }
    
    // Draw all polygons
    noFill();
    stroke(255,0,0);
    for (List<PVector> polygon : polygons) {
      drawPolygon(polygon);
    }
    
    stroke(0,255,0);
    drawPolygon(inProgressPolygon);
  }
  
  //saveFrame("frame#####.png");
}

void drawRegion(Region region) {
  noStroke();
  fill(200,190,170); //<>//
  drawPolygon(region.cornerVertices);
  
  fill(235,235,220);
  drawPolygon(region.roadVertices);
  
  stroke(200);
  strokeWeight(3);
  fill(255);
  for (List<PVector> building : region.buildings) {
    drawPolygon(building);
  } 
}

void mousePressed() {
  if (mouseButton == RIGHT) {
    polygons.add(inProgressPolygon);
    inProgressPolygon = new ArrayList<PVector>();
    
    return;
  }
  
  PVector clickedPoint = getSnapToPoint();
  if (clickedPoint == null) {
    clickedPoint = new PVector(mouseX, mouseY);
    screenPoints.add(clickedPoint);
  }
  else if (inProgressPolygon.isEmpty()) {
    draggedPoint = clickedPoint; //<>//
    return;
  }
  
  inProgressPolygon.add(clickedPoint);
}

void mouseDragged() {
  if (draggedPoint != null) {
    draggedPoint.x = mouseX;
    draggedPoint.y = mouseY;
  }
}

void mouseReleased() {
  draggedPoint = null;
}

void keyPressed() {
  debugDraw = !debugDraw;
}

PVector getSnapToPoint() {
  PVector mousePosition = new PVector(mouseX, mouseY);
  
  PVector closestPoint = null;
  float closestDist = 0f;
  for (PVector p : screenPoints) {
    float dist = p.dist(mousePosition);
    if (dist < closestDist || closestPoint == null) {
      closestPoint = p;
      closestDist = dist;
    }
  }
  
  return (closestDist <= SNAP_DISTANCE) ? closestPoint : null;
}

void drawPolygon(List<PVector> polygon) {
  beginShape();
  for (int i=0; i<polygon.size(); ++i) {
    PVector p = polygon.get(i);
    vertex(p.x, p.y);
  }
  endShape(CLOSE);
}
