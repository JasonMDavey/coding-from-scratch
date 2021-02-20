class WindParticleSystem {
  WindParticle[] particles;
  
  public WindParticleSystem(int particleCount) {
    particles = new WindParticle[particleCount];
    for (int i=0; i<particleCount; ++i) {
      particles[i] = new WindParticle();
      particles[i].respawn();
    }
  }
  
  void update(float deltaSeconds) {
    for (WindParticle p : particles) {
      p.update(deltaSeconds);
    }
  }
  
  void draw() {
    for (WindParticle p : particles) {
      p.draw();
    } 
  }
}
