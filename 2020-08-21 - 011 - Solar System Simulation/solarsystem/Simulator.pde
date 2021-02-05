public class Simulator {
  
  public void step(List<Body> bodies, boolean isPrediction) {
    List<Body> toDestroy = new ArrayList<Body>(bodies.size());
    
    for (Body b : bodies) {
      if (b.accumulateGravityForces(bodies)) {
        toDestroy.add(b);
      }
    }
    
    for (Body b : toDestroy) {
      bodies.remove(b);
      if (isPrediction) continue;
      int numChunks = min(20, (int)(b.mass / chunkPrototype.mass));  
      for (int i=0; i<numChunks; ++i) {
        PVector chunkPos = PVector.add(b.pos, PVector.random2D().mult(5f));
        PVector chunkVel = PVector.add(b.vel, PVector.random2D().mult(25f));
        Body chunk = new Body(chunkPrototype, chunkPos, chunkVel);
        chunk.noAttract = true;
        bodies.add(chunk);
      }
    }
    
    for (Body b : bodies) {
      b.update(TIMESTEP, isPrediction);
    }
  }
  
  public List<PVector> predictPath(List<Body> bodies, Body bodyOfInterest, int numSteps) {
    List<PVector> result = new ArrayList<PVector>(numSteps); //<>//
    
    // *DEEP*-Copy "bodies" (so we don't interfere with the state of the simulation)
    Body clonedBodyOfInterest = null;
    
    List<Body> clonedBodies = new ArrayList<Body>(bodies.size());
    for (Body b : bodies) {
      if (b.noAttract) continue;
      
      Body clonedBody = b.clone();
      clonedBodies.add(clonedBody);
      
      if (b == bodyOfInterest) {
        clonedBodyOfInterest = clonedBody;
      }
    }
    
    if (clonedBodyOfInterest == null) {
      clonedBodies.add(bodyOfInterest);
      clonedBodyOfInterest = bodyOfInterest;
    }
    
    for (int i=0; i<numSteps; ++i) {
      step(clonedBodies, true);
      result.add(clonedBodyOfInterest.pos.copy());
    }
    
    return result;
  }
}
