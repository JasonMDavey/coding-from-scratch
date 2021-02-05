public class QuadTree {

  QuadTreeNode rootNode;

  public QuadTree(float topBound, float bottomBound, float leftBound, float rightBound) {
    rootNode = new QuadTreeNode(topBound, bottomBound, leftBound, rightBound);
  }

  public void draw() {
    rootNode.draw();
  }

  public void add(PVector object) {
    rootNode.add(object);
  }

  public ArrayList<PVector> queryRect(float rectTop, float rectBottom, float rectLeft, float rectRight) {
    // "Broad phase" - find objects which *might* overlap with our rectangle
    ArrayList<PVector> candidates = new ArrayList<PVector>();
    rootNode.queryRect(rectTop, rectBottom, rectLeft, rectRight, candidates);

    // "Narrow phase" - filter objects by checking their individual positions
    ArrayList<PVector> results = new ArrayList<PVector>();
    for (PVector candidate : candidates) {
      if (candidate.x >= rectLeft && candidate.x < rectRight
        && candidate.y >= rectTop && candidate.y < rectBottom) {
        results.add(candidate);
      }
    }

    return results;
  }
}
