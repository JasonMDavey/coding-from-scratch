public class QuadTreeNode {
  ArrayList<PVector> objects = new ArrayList<PVector>(MAX_OBJECTS_PER_NODE);

  float topBound, bottomBound, leftBound, rightBound;

  QuadTreeNode topLeft;
  QuadTreeNode topRight;
  QuadTreeNode bottomLeft;
  QuadTreeNode bottomRight;

  public QuadTreeNode(float topBound, float bottomBound, float leftBound, float rightBound) {
    this.topBound = topBound;
    this.bottomBound = bottomBound;
    this.leftBound = leftBound;
    this.rightBound = rightBound;

    //println("Creating node. X " + leftBound + "->" + rightBound + ", Y " + topBound + "->" + bottomBound);
  }

  public void draw() {
    if (isSubdivided()) {
      topLeft.draw();
      topRight.draw();
      bottomLeft.draw();
      bottomRight.draw();
    }
    else {
      strokeWeight(1);
      stroke(0, 255, 0);
      
      noFill();
      rect(leftBound, topBound, rightBound-leftBound, bottomBound-topBound);
    }
  }
  
  public boolean overlapsRect(float rectTop, float rectBottom, float rectLeft, float rectRight) {
    return !(rectLeft >= rightBound || rectRight < leftBound || rectBottom < topBound || rectTop >= bottomBound);
  }
  
  public void queryRect(float rectTop, float rectBottom, float rectLeft, float rectRight, ArrayList<PVector> results) {
    
    if (overlapsRect(rectTop, rectBottom, rectLeft, rectRight)) {
      if (isSubdivided()) {
        topLeft.queryRect(rectTop, rectBottom, rectLeft, rectRight, results);
        topRight.queryRect(rectTop, rectBottom, rectLeft, rectRight,results);
        bottomLeft.queryRect(rectTop, rectBottom, rectLeft, rectRight, results);
        bottomRight.queryRect(rectTop, rectBottom, rectLeft, rectRight, results);
      }
      else {
        results.addAll(objects);
      }
    }
  }
  
  public void add(PVector object) {
    if (!isWithinBounds(object)) {
      //println("Tried to add out-of-bounds object!");
      return;  // Bail out - we can't put the object in here!
    }

    if (isSubdivided()) {
      // Figure out which quadrant the new object should be placed into
      addToAppropriateChild(object);
    } else if (objects.size() < MAX_OBJECTS_PER_NODE) {
      // We have capacity to just shove the new object directly into this cell
      objects.add(object);
    } else {
      // Just crossed the threshold - need to split ourself up
      subdivide();

      // Figure out which quadrant the new object should be placed into
      addToAppropriateChild(object);
    }
  }

  private void subdivide() {
    //println("Subdividing!");

    float midpointX = (leftBound + rightBound) / 2f;
    float midpointY = (topBound + bottomBound) / 2f;

    topLeft = new QuadTreeNode(topBound, midpointY, leftBound, midpointX);
    topRight = new QuadTreeNode(topBound, midpointY, midpointX, rightBound);
    bottomLeft = new QuadTreeNode(midpointY, bottomBound, leftBound, midpointX);
    bottomRight = new QuadTreeNode(midpointY, bottomBound, midpointX, rightBound);

    for (PVector object : objects) {
      addToAppropriateChild(object);
    }
    
    objects.clear();
  }

  private void addToAppropriateChild(PVector object) {
    if (topLeft.isWithinBounds(object)) {
      topLeft.add(object);
    } else if (topRight.isWithinBounds(object)) {
      topRight.add(object);
    } else if (bottomRight.isWithinBounds(object)) {
      bottomRight.add(object);
    } else if (bottomLeft.isWithinBounds(object)) {
      bottomLeft.add(object);
    } else {
      println("Can't find a child for object!");
    }
  }

  private boolean isWithinBounds(PVector point) {
    return point.x >= leftBound && point.x < rightBound
      && point.y >= topBound  && point.y < bottomBound;
  }

  private boolean isSubdivided() {
    return topLeft != null;
  }
}
