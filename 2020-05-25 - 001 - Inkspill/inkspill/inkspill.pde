import java.util.List;

PImage backgroundImage;

PImage brushMid, brushBorder;

// Off-screen texture for building up our territory highlights
PGraphics overlay;

boolean debugDraw = false;

float borderBrushSpacing = 40f;
float borderBrushJitter = 10f;

List<Territory> territories = new ArrayList<Territory>(2);

void setup() {
  size(900, 800);

  // Load images
  backgroundImage = loadImage("background.png");
  brushMid = loadImage("brush_mid.png");
  brushBorder = loadImage("brush_border.png");

  // Create render target for building up territory highlight
  overlay = createGraphics(width, height);

  /*
   * Define territories
   */

  // Territory 1
  Territory t1 = new Territory();
  t1.mask = loadImage("mask_t1.png");

  t1.border.add(new PVector(125f, 106f, 0f));
  t1.border.add(new PVector(205f, 106f, 0f));
  t1.border.add(new PVector(235f, 233f, 0f));
  t1.border.add(new PVector(355f, 340f, 0f));
  t1.border.add(new PVector(322f, 388f, 0f));
  t1.border.add(new PVector(121f, 385f, 0f));

  territories.add(t1);

  // Territory 2
  Territory t2 = new Territory();
  t2.r = 0;
  t2.g = 78;
  t2.b = 158;
  t2.mask = loadImage("mask_t2.png");

  t2.border.add(new PVector(270f, 106f, 0f));
  t2.border.add(new PVector(647f, 106f, 0f));
  t2.border.add(new PVector(623f, 217f, 0f));
  t2.border.add(new PVector(522f, 316f, 0f));
  t2.border.add(new PVector(451f, 255f, 0f));
  t2.border.add(new PVector(395f, 315f, 0f));
  t2.border.add(new PVector(305f, 226f, 0f));

  territories.add(t2);
}

void draw() {

  // Reset - draw our map as a background image
  blendMode(NORMAL);
  tint(255, 255, 255, 255);
  imageMode(CORNER);
  image(backgroundImage, 0, 0);

  // Draw territories
  for (Territory t : territories) {
    generateAndDrawOverlay(t);
  }

  // Debug draw
  if (debugDraw) {
    blendMode(NORMAL);
    stroke(255, 255, 255);
    for (Territory t : territories) {
      for (PVector p : t.border) {
        ellipse(p.x, p.y, 5, 5);
      }

      for (int i=0; i<t.border.size(); ++i) {
        PVector p1 = t.border.get(i);
        PVector p2 = t.border.get((i+1) % t.border.size());
        line(p1.x, p1.y, p2.x, p2.y);
      }
    }
  }
}

void generateAndDrawOverlay(Territory t) {
  /*
    * Build up our highlight overlay
   */
  overlay.beginDraw();
  overlay.clear();
  overlay.imageMode(CENTER);
  t.mask.loadPixels();

  // Scan through every pixel of the map
  for (int x=0; x<width; ++x) {
    for (int y=0; y<height; ++y) {
      // Determine if this pixel is inside our territory
      int pixelHere = t.mask.pixels[x + y*width];
      float alphaHere = alpha(pixelHere);

      if (alphaHere > 0f) {
        // Part of the territory! Apply soft fill brush
        if (random(100f) < 5f) { // 5% chance to draw
          overlay.image(brushMid, x, y);
        }
      }
    }
  }


  // Walk along the border of the territory
  // NOTE: This has been cleaned up a bit compared to the version in the video  
  float walkProgress = 0f;

  for (int i=0; i<t.border.size(); ++i) {
    PVector p1 = t.border.get(i);
    PVector p2 = t.border.get((i+1) % t.border.size());
    PVector segmentVector = PVector.sub(p2, p1);
    float segmentLength = segmentVector.mag();

    while (walkProgress < segmentLength) {
      // Calculate the position of this point, based on how far along the segment we have walked
      float ratioAlongThisSegment = walkProgress/segmentLength;
      PVector walkedToPoint = PVector.add(p1, PVector.mult(segmentVector, ratioAlongThisSegment));

      overlay.pushMatrix();
      overlay.translate(walkedToPoint.x + random(-borderBrushJitter, borderBrushJitter), walkedToPoint.y + random(-borderBrushJitter, borderBrushJitter));
      overlay.rotate(random(0f, PI*2f));
      overlay.image(brushBorder, 0f, 0f);
      overlay.popMatrix();

      walkProgress += borderBrushSpacing;
    }

    // We need to carry any progress made beyond the end of this segment into the next segment
    walkProgress -= segmentLength;
  }

  // Cleanup
  t.mask.updatePixels();
  overlay.endDraw();

  // Draw territory highlight overlay
  blendMode(MULTIPLY);
  tint(t.r, t.g, t.b, t.a);
  image(overlay, 0, 0);
}

void keyPressed() {
  if (key == ' ') {
    debugDraw = !debugDraw;
  }
}
