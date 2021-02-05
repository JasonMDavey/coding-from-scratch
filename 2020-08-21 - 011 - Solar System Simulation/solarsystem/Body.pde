public class Body {
  static final int TRAIL_LENGTH = 255;
  
  public float mass;
  PVector pos;
  public PVector vel;
  PVector acc;
  boolean fixed;
  boolean rotate;
  boolean destroyable;
  boolean noAttract;
  
  String name;
  public PImage img;
  
  List<PVector> previousPositions = new LinkedList<PVector>();
  
  // Create a prototype Body
  public Body(float mass, boolean fixed, boolean rotate, boolean destroyable, String name, PImage img) {
    this.mass = mass;
    this.fixed = fixed;
    this.rotate = rotate;
    this.destroyable = destroyable;
    
    this.name = name;
    this.img = img;
  }
  
  // Create a body from a prototype, with the specified initial position + velocity
  public Body(Body prototype, PVector pos, PVector vel) {
    this.mass = prototype.mass;
    this.fixed = prototype.fixed;
    this.rotate = prototype.rotate;
    this.destroyable = prototype.destroyable;
    this.name = prototype.name;
    this.img = prototype.img;
    
    this.pos = pos;
    this.vel = vel;
    this.acc = new PVector();
  }
  
  public Body clone() {
    return new Body(this, this.pos.copy(), this.vel.copy());
  }
  
  // Return true if there was a collision, and this should be destroyed
  public boolean accumulateGravityForces(List<Body> allBodies) {
    // Use the gravity equation to accumulate all gravity forces from all other bodies
    
    acc.set(0,0);
    
    for (Body b : allBodies) {
      if (b == this || b.noAttract) continue;
      
      PVector vectorToB = PVector.sub(b.pos, this.pos);
      float distSquared = max(10f, vectorToB.magSq());
      
      if (this.destroyable) {
        float collisionRange = this.img.width * 0.5f + b.img.width * 0.5f; 
        if (distSquared <= collisionRange*collisionRange) return true;
      }
      
      float gravForce = (this.mass * b.mass) / distSquared;
      acc.add(vectorToB.setMag(gravForce / this.mass));
    }
    
    return false;
  }
  
  public void update(float deltaTimeSecs, boolean isPrediction) {
    if (fixed) return;
    
    if (!isPrediction && !noAttract) {
      // Remember our position (for drawing trails)
      previousPositions.add(pos.copy());
      
      // Ensure trail doesn't get too long
      if (previousPositions.size() > TRAIL_LENGTH) {
        previousPositions.remove(0);
      }
    }
        
    vel.add(acc.mult(deltaTimeSecs));
    pos.add(PVector.mult(vel, deltaTimeSecs));
  }
  
  public void draw() {
    // Draw trail
    noStroke();
    fill(255,0,0);
    for (PVector p : previousPositions) {
      ellipse(p.x, p.y, 3,3);
    }
    
    imageMode(CENTER);
    
    pushMatrix();
    translate(pos.x, pos.y);
    if (rotate) { rotate(vel.heading()); }
    image(img, 0, 0);
    popMatrix();
  }
}
