class ParticleSystem {
  
  float minX, maxX, minY, maxY;
  float minVX, maxVX, minVY, maxVY;
  float gravityIntensity;
  float noiseFieldIntensity;
  
  float pLifetime;
  PImage pImage, pColorLookup;
  
  float spawnRatePerSecond;
 
  float secondsSinceLastSpawn = 0;
  
  Particle[] particles;
  int nextParticleIndex = 0;
 
  void init() {
    // Pre-allocate a pool of particles
    int maxParticles = ceil(spawnRatePerSecond * pLifetime);
    
    particles = new Particle[maxParticles];
    
    for (int i=0; i<particles.length; ++i) {
      particles[i] = new Particle();
      particles[i].isAlive = false;
    }
  }
  
  void spawnParticle() {
    // Recycle a particle from the pool
    Particle p = particles[nextParticleIndex];

    // Pick random position + velocity
    p.pX = random(minX, maxX);
    p.pY = random(minY, maxY);
    p.vX = random(minVX, maxVX);
    p.vY = random(minVY, maxVY);
    p.gravityIntensity = gravityIntensity;
    p.noiseFieldIntensity = noiseFieldIntensity;
    p.lifetimeSeconds = pLifetime;
    p.lifetimeRemaining = pLifetime;
    p.image = pImage;
    p.colorLookup = pColorLookup;

    // Flag as alive!
    p.isAlive = true;
    
    // Move along the pointer, so next particle will be spawned using the next slot
    ++nextParticleIndex;
    
    if (nextParticleIndex == particles.length) {
      // Reached end of list - wrap around
      nextParticleIndex = 0; //<>//
    }
  }
  
  void update(float secondsSinceLastFrame) {
    if (particles == null) {
      init();
    }
    
    // Spawning
    secondsSinceLastSpawn += secondsSinceLastFrame;
    
    float secondsBetweenSpawns = 1f / spawnRatePerSecond; 
    
    while (secondsSinceLastSpawn > secondsBetweenSpawns) {
      spawnParticle();
      secondsSinceLastSpawn -= secondsBetweenSpawns;
    }
    
    // Update
    for (Particle p : particles) {
      if (p.isAlive) {
        p.update(secondsSinceLastFrame);
      }
    }
  }
  
  void draw() {
    // Particles will be reading color data from this image - make sure it's loaded and available
    pColorLookup.loadPixels();
    
    for (Particle p : particles) {
      if (p.isAlive) {
        p.draw();
      }
    }
    
    // Done reading color data
    pColorLookup.updatePixels();
  }
}
