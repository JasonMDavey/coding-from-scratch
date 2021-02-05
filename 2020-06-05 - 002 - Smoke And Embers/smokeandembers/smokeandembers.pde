//
// Changes since video:
//
// • Fixed some errors with the mass / gravity calculation
// • Tweaked calculation of angle from perlin noise
// • Limited max particle velocity
//
// You are free to modify or use this code however you would like!
// Images and other assets are for personal / non-commercial / educational use only.
//

PImage backgroundImage, engiImage;

PImage smokeParticleImage, emberParticleImage;
PImage smokeLookupImage, emberLookupImage;

ParticleSystem psRear, psFront, psEmber;

boolean debugDraw = false;

float noiseScale = 0.015f;
float noiseZ;

void mousePressed() {
  debugDraw = !debugDraw;
}

/*
 * Called once, at start of program
 */
void setup() {
  size(506, 690, P3D);
  
  // Load assets
  backgroundImage = loadImage("background.png");
  engiImage = loadImage("engi.png");
  
  smokeParticleImage = loadImage("smoke_particle.png");
  emberParticleImage = loadImage("ember_particle.png");
  
  smokeLookupImage = loadImage("smoke_lookup.png");
  emberLookupImage = loadImage("ember_lookup.png");
  
  /*
   * Set up particle systems
   */
  psRear = new ParticleSystem();
  
  // Define spawn box
  psRear.minX = 0;
  psRear.maxX = width;
  psRear.minY = height + 64;
  psRear.maxY = height + 200;
  
  // Define initial velocity bounds
  psRear.minVX = -20;
  psRear.maxVX = 20;
  psRear.minVY = -20;
  psRear.maxVY = -50;
  
  // Define mass
  psRear.gravityIntensity = -0.1f;
  psRear.noiseFieldIntensity = 20f;
  
  // Define lifetime and spawn rate
  psRear.pLifetime = 8;
  psRear.spawnRatePerSecond = 30;
  
  // Define appearance
  psRear.pColorLookup = smokeLookupImage;
  psRear.pImage = smokeParticleImage;
  
  
  
  psFront = new ParticleSystem();
  
  // Define spawn box
  psFront.minX = 0;
  psFront.maxX = width;
  psFront.minY = height + 64;
  psFront.maxY = height + 200;
  
  // Define initial velocity bounds
  psFront.minVX = -20;
  psFront.maxVX = 20;
  psFront.minVY = -20;
  psFront.maxVY = -50;
  
  // Define mass
  psFront.gravityIntensity = -0.1f;
  
  // Define lifetime and spawn rate
  psFront.pLifetime = 12;
  psFront.spawnRatePerSecond = 50;
  
  // Define appearance
  psFront.pColorLookup = smokeLookupImage;
  psFront.pImage = smokeParticleImage;
  
  
  
  psEmber = new ParticleSystem();
  
  // Define spawn box
  psEmber.minX = 0;
  psEmber.maxX = width;
  psEmber.minY = height + 10;
  psEmber.maxY = height + 200;
  
  // Define initial velocity bounds
  psEmber.minVX = -20;
  psEmber.maxVX = 20;
  psEmber.minVY = -40;
  psEmber.maxVY = -80;
  
  // Define reaction to gravity / noise field
  psEmber.gravityIntensity = -10f;
  psEmber.noiseFieldIntensity = 100f;
  
  // Define lifetime and spawn rate
  psEmber.pLifetime = 5f;
  psEmber.spawnRatePerSecond = 8;
  
  // Define appearance
  psEmber.pColorLookup = emberLookupImage;
  psEmber.pImage = emberParticleImage;
  
  
  /*
   * "Warm up" particle systems
   */
  for (int i=0; i<1000; ++i) {
    psFront.update(0.01f);
    psRear.update(0.01f);
    psEmber.update(0.01f);
  }
  
  imageMode(CORNER);
  tint(255, 255, 255, 255);
  image(backgroundImage, 0, 0);
}


/*
 * Called for every frame
 */
float millisLastFrame = 0;

void draw() {
  // Determine how long has passed since last frame
  float millisNow = millis();
  float millisElapsedSinceLastFrame = millisNow - millisLastFrame;
  float secondsSinceLastFrame = millisElapsedSinceLastFrame / 1000f;
  millisLastFrame = millisNow;
  secondsSinceLastFrame = 1f/20f;
  
  // Draw background layer
  imageMode(CORNER);
  tint(255, 255, 255, 50);
  image(backgroundImage, 0, 0);
  
  // Particles!
  imageMode(CENTER);
  psRear.update(secondsSinceLastFrame);
  psRear.draw();
  
  // Draw Engineer character
  imageMode(CORNER);
  tint(255, 255, 255, 255);
  image(engiImage, -70, 0);
  
  // Particles!
  imageMode(CENTER);
  psFront.update(secondsSinceLastFrame);
  psFront.draw();
  
  psEmber.update(secondsSinceLastFrame);
  psEmber.draw();
  
  // "Scroll through" perlin noise field
  noiseZ += noiseScale * secondsSinceLastFrame * 50f;
  
  if (debugDraw) {
    // Visualise perlin noise
    stroke(255,0,0,255);
    for (int x=0; x<width; x += 20) {
      for (int y=0; y<height; y += 20) {
        float noiseValue = noise(x*noiseScale, y*noiseScale, noiseZ);
        
        float angle = noiseValue * 2f * (float)PI;

        // NOTE: Perlin noise is biased towards producing values clustered around 0.5
        // So, the angles we generate tend to point in the direction corresponding to that more than others
        // We'll just rotate this so that these arrows tend to point upwards, rather than being biased towards left or right
        angle += (PI/2f);
        
        line(x,y, x+cos(angle)*20f, y+sin(angle)*20f);
      }
    }
  }
  
 // saveFrame("fr#####.png");
}
