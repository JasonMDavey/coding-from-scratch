class Particle {
  float pX, pY;
  float vX, vY;
  float gravityIntensity;
  float noiseFieldIntensity;
  
  float lifetimeSeconds, lifetimeRemaining;
  
  PImage image, colorLookup;
  
  boolean isAlive;
  
  void update(float secondsSinceLastFrame) {
    float aX = 0f;
    float aY = gravityIntensity;
    
    if (noiseFieldIntensity != 0f) {
      // Sample perlin noise field, and apply corresponding force 
      float noiseValue = noise(pX*noiseScale, pY*noiseScale, noiseZ);
      float angle = noiseValue * 2f * (float)PI + (PI/2f);
      aX += cos(angle)*noiseFieldIntensity; //<>//
      aY += sin(angle)*noiseFieldIntensity;
    }
    
    // Apply acceleration to velocity
    vX = vX + aX * secondsSinceLastFrame;
    vY = vY + aY * secondsSinceLastFrame;
    
    // Limit velocity
    if (abs(vX) > 75f) { vX *= 75f / abs(vX); }
    if (abs(vY) > 75f) { vY *= 75f / abs(vY); }
    
    // Apply velocity to position
    pX = pX + vX * secondsSinceLastFrame;
    pY = pY + vY * secondsSinceLastFrame;
    
    // Age-out
    lifetimeRemaining -= secondsSinceLastFrame;
    if (lifetimeRemaining <= 0) {
      isAlive = false;
    }
  }
  
  void draw() {
    pushMatrix(); // Save translation / rotation state
    
    // Sample color from lookup texture based on lifetime 
    float progress = 1f - (lifetimeRemaining / lifetimeSeconds);
    float xLookup = progress * colorLookup.width-1;
    int xLookupRounded = min(colorLookup.width-1, (int)xLookup);
    color lookupColor = colorLookup.pixels[xLookupRounded];
    
    tint(red(lookupColor), green(lookupColor), blue(lookupColor), alpha(lookupColor));
    
    // Rotate in direction of motion
    float angle = atan2(vY, vX);
    translate(pX, pY);
    rotate(angle);
    
    image(image, 0f, 0f);
    
    popMatrix(); // Restore translation / rotation state
  }
}
