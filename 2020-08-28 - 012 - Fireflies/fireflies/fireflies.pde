//
// You are free to modify or use this code however you would like!
//
// Art assets:
// • Forest scene by ansimuz (https://opengameart.org/content/sunnyland-forest)
//

import java.util.*;
static final float MIN_PLANE_DEPTH = 250f;
static final float MAX_PLANE_DEPTH = 2000f;

static float FIREFLY_SEEK_RANGE = 200f;
static float FIREFLY_MAX_SPEED = 80f;
static float FIREFLY_ACCELERATION = 225f;

static color AMBIENT_LIGHT_COLOR;

PImage[] bgLayers;
PImage fireflyImage;

List<Firefly> fireflies = new ArrayList<Firefly>();

float cameraX = 0f;
boolean lightingEnabled = true;

PGraphics lightingLayer;
List<Image3D> drawQueue = new ArrayList<Image3D>();

void setup() {
  size(1000, 480, P3D);
  
  bgLayers = new PImage[] {
    loadImage("layer_0.png"),
    loadImage("layer_1.png"),
    loadImage("layer_2.png"),
    loadImage("layer_3.png"),
    loadImage("layer_4.png")
  };
  
  fireflyImage = loadImage("firefly.png");
  
  for (int i=0; i<100; ++i) {
    fireflies.add(new Firefly(generateRandomFireflyPosition()));
  }
  
  imageMode(CENTER);
  ortho(-width/2, width/2, -height/2, height/2, 0, 2f*MAX_PLANE_DEPTH);
  
  lightingLayer = createGraphics(width, height, P3D);
}

int previousFrameTime = millis();

void draw() {
  AMBIENT_LIGHT_COLOR = color(117,115,205);
  
  int currentTimeMillis = millis();
  float timeDeltaMillis = currentTimeMillis - previousFrameTime;
  float timeDeltaSeconds = timeDeltaMillis / 1000f;
  previousFrameTime = currentTimeMillis;

  // Camera moves left/right based on mouse position
  cameraX = map(mouseX, 0, width, -150f, 150f); //<>//
  drawQueue.clear();
    
  /*
   * Draw parallax layers
   */
  float depthStepBetweenLayers = (MAX_PLANE_DEPTH-MIN_PLANE_DEPTH) / (bgLayers.length-1);
  
  for (int i=0; i<bgLayers.length; ++i) { //<>//
    float depth = MIN_PLANE_DEPTH + (bgLayers.length-(i+1)) * depthStepBetweenLayers;
    float parallaxOffset = calculateParallaxOffset(cameraX, depth);
    
    drawQueue.add(new Image3D(bgLayers[i], new PVector(parallaxOffset, 0, -depth)));
  }
  
  
  /*
   * Draw fireflies
   */
 
  for (Firefly f : fireflies) {
    f.update(timeDeltaSeconds);
    f.draw();
  }
  
  
  /*
   * Draw everything far-to-near
   */
  drawQueue.sort(new Comparator<Image3D>() {
    public int compare(Image3D i1, Image3D i2) {
      return i1.pos.z > i2.pos.z ? 1 : -1;
    }
  });
  
  // Assemble lighting layer
  lightingLayer.beginDraw();
  lightingLayer.imageMode(CENTER);
  lightingLayer.ortho(-width/2, width/2, -height/2, height/2, 0, 2f*MAX_PLANE_DEPTH);
  lightingLayer.background(0);

  lightingLayer.pushMatrix();
  lightingLayer.translate(width/2, height/2);
    
  for (Image3D i : drawQueue) {
    if (i.type == Image3D.FIREFLY) {
      lightingLayer.tint(red(i.col), green(i.col), blue(i.col), alpha(i.col));
    }
    else if (i.type == Image3D.SCENERY) {
      lightingLayer.tint(0,0,0,255);
    }
    
    lightingLayer.pushMatrix();
      lightingLayer.blendMode(i.blendMode);
      lightingLayer.translate(i.pos.x, i.pos.y, i.pos.z);
      lightingLayer.scale(i.scale);
      lightingLayer.image(i.img, 0, 0);
    lightingLayer.popMatrix();
  }
  lightingLayer.popMatrix();
  lightingLayer.fill(red(AMBIENT_LIGHT_COLOR), green(AMBIENT_LIGHT_COLOR), blue(AMBIENT_LIGHT_COLOR));
  lightingLayer.noStroke();
  lightingLayer.hint(DISABLE_DEPTH_TEST);
  lightingLayer.rect(0,0,width,height);
  lightingLayer.hint(ENABLE_DEPTH_TEST);
 
  lightingLayer.endDraw();
  
  // Draw main scene
  background(0);
  pushMatrix();
  translate(width/2, height/2);
    
  for (Image3D i : drawQueue) {
    tint(red(i.col), green(i.col), blue(i.col), alpha(i.col));
    
    pushMatrix();
      blendMode(i.blendMode);
      translate(i.pos.x, i.pos.y, i.pos.z);
      scale(i.scale);
      image(i.img, 0, 0);
    popMatrix();
  }
  popMatrix();

  if (lightingEnabled) {
    blendMode(MULTIPLY);
    tint(255,255,255);
    hint(DISABLE_DEPTH_TEST);
    image(lightingLayer, width/2, height/2);
    hint(ENABLE_DEPTH_TEST);
    blendMode(NORMAL);
  }
}

float calculateParallaxOffset(float cameraX, float depth) {
  return -cameraX * map(depth, MIN_PLANE_DEPTH, MAX_PLANE_DEPTH, 1f, 0f);
}

PVector generateRandomFireflyPosition() {
  float x = random(-1500f, 1500f);
  float y = random(-300f, 200f);
  float z = random(0f, 500f);
  return new PVector(x,y,z);
}

void keyPressed() {
  if (key == ' ') {
    lightingEnabled = !lightingEnabled;
  }
}
