import java.util.List;

final color SNOW_COLOR = color(255);
final color AIR_COLOR = color(0,0,0,0);

static final float SNOW_FLOW_RATE = 0.25f;

static final int SCALE_FACTOR = 3;
static int SCENE_WIDTH, SCENE_HEIGHT;


PImage backgroundImage;
PImage sceneryImage;

ParticleSystem particles;

void setup() {
  size(600, 600, P3D);
  SCENE_WIDTH = width/SCALE_FACTOR;
  SCENE_HEIGHT = height/SCALE_FACTOR;

  // Hacky! Sets texture scaling filter to GL_NEAREST, giving us nice chunky pixel art
  // Does Processing give us a nicer way to do this?
  ((PGraphicsOpenGL)g).textureSampling(2);

  backgroundImage = loadImage("background.png");
  sceneryImage = loadImage("scenery2.png");
  
  particles = new ParticleSystem(1000);
}


float millisLastFrame = millis();

void draw() {
  // Determine how long has passed since last frame
  float millisNow = millis();
  float millisElapsedSinceLastFrame = millisNow - millisLastFrame;
  float secondsSinceLastFrame = millisElapsedSinceLastFrame / 1000f;
  millisLastFrame = millisNow;
  scale(SCALE_FACTOR);
  
  image(backgroundImage, 0, 0);

  sceneryImage.loadPixels();
  
  particles.update(secondsSinceLastFrame);
  particles.draw();

  // Settled snow physics
  // Iterate from bottom-up, to avoid updating falling pixels multiple times per-frame, which would cause them to "teleport"
  for (int y=SCENE_HEIGHT-1; y>0; --y) {
    for (int x=0; x<SCENE_WIDTH; ++x) {
      color pixel = sceneryImage.pixels[x + y*sceneryImage.width];
      if (pixel != SNOW_COLOR) continue;
      if (random(0,1) > SNOW_FLOW_RATE) continue;
      
      if (canSnowFlowInto(x, y+1)) {
        // Flow downwards
        sceneryImage.pixels[x + (y+1)*sceneryImage.width] = SNOW_COLOR;
        sceneryImage.pixels[x + y*sceneryImage.width] = AIR_COLOR;
      }
      else {
        // Try to flow down and left/right
        // Randomly try either left or right first, so we're less biased
        int firstDirection = random(0,100) < 50 ? -1 : 1;
        int secondDirection = -firstDirection;
        
        if (canSnowFlowInto(x+firstDirection, y+1) && canSnowFlowInto(x+firstDirection, y)) {
          sceneryImage.pixels[x+firstDirection + (y+1)*sceneryImage.width] = SNOW_COLOR;
          sceneryImage.pixels[x + y*sceneryImage.width] = AIR_COLOR;
        }
        else if (canSnowFlowInto(x+secondDirection, y+1) && canSnowFlowInto(x+secondDirection, y)) {
          sceneryImage.pixels[x+secondDirection + (y+1)*sceneryImage.width] = SNOW_COLOR;
          sceneryImage.pixels[x + y*sceneryImage.width] = AIR_COLOR;
        }
      }
    }
  }
  
  sceneryImage.updatePixels();
  
  image(sceneryImage, 0, 0);
}

boolean isSceneryPixelSet(int x, int y) {
  if (x<0 || x>=sceneryImage.width || y<0 || y>=sceneryImage.height) return false; // Out-of-bounds
  color pixel = sceneryImage.pixels[x + y*sceneryImage.width];
  return alpha(pixel) > 0;
}

boolean canSnowFlowInto(int x, int y) {
  if (x<0 || x>=sceneryImage.width || y<0 || y>=sceneryImage.height) return false; // Out-of-bounds
  color pixel = sceneryImage.pixels[x + y*sceneryImage.width];
  return alpha(pixel) == 0;
}
