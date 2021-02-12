class ParticleSystem {
  Particle[] particles;
  
  public ParticleSystem(int capacity) {
    particles = new Particle[capacity];
    
    for (int i=0; i<capacity; ++i) {
      particles[i] = new Particle();
      particles[i].spawn();
    }
  }
  
  public void update(float deltaSeconds) {
    for (Particle p : particles) {
      p.update(deltaSeconds);
    }
  }
  
  public void draw() {
    for (Particle p : particles) {
      p.draw();
    }
  }
}
