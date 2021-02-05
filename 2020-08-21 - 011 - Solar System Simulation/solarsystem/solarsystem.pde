//
// You are free to modify or use this code however you would like!
//
// Art assets:
// • Spaceship by peony (https://opengameart.org/content/space-pixel-art)
// • Starfield by darklighter_designs (https://opengameart.org/content/starfield-alpha-4k)
// • Planets by Master484 (https://opengameart.org/content/pixel-planets)
//

import java.util.*;

// We want to update the physics simulation with the same time increment each time (for stability / consistency)
public static final float TIMESTEP = 1f/20f;
public static final int PREDICT_TIMESTEPS = 1000;

public static final float THRUST_FORCE = 2f;

PImage backgroundImage;

// List of "prototype" bodies, which the user can scroll through and place with the mouse
Body chunkPrototype;
List<Body> prototypes = new ArrayList<Body>();

// State for placing bodies
int selectedPrototypeIndex = -1;
PVector placePosition = null;

// All of the bodies in our simulated universe
List<Body> bodies = new ArrayList<Body>();
Simulator sim = new Simulator();

boolean paused = false;

Body controlledBody = null;
boolean thrusting = false;
boolean braking = false;

/*
 * Runs once when the program starts
 */
void setup() {
  // Create window
  size(1536, 864, P3D);

  backgroundImage = loadImage("starfield.png");

  chunkPrototype = new Body(25f, false, true, false, "Chunk", loadImage("chunk.png"));
  
  prototypes.add(new Body(1f, false, true, false, "Rocket", loadImage("rocket.png")));
  prototypes.add(new Body(1000000f, true, false, false, "Sun", loadImage("planet_sun.png")));
  prototypes.add(new Body(1000f, false, false, true, "Earth", loadImage("planet_earth.png")));
  prototypes.add(new Body(100000f, false, false, true, "Orangey", loadImage("planet_orange.png")));

  // Create initial sun+planets
  bodies.add(new Body(prototypes.get(1), new PVector(width/2, height/2), new PVector(0, 0)));
}


// Used for calculating delta time
int previousTimeMillis;

// Used to "accumulate" time which needs to simulated, accounting for roll-over 
float secondsToSimulate = 0f;

void draw() {
  // Calculate delta time since last frame
  int currentTimeMillis = millis();
  int millisElapsed = currentTimeMillis - previousTimeMillis;
  float secondsElapsed = millisElapsed / 1000f;
  previousTimeMillis = currentTimeMillis;

  secondsToSimulate += secondsElapsed;

  if (paused) {
    secondsToSimulate = 0f;
  }

  imageMode(CORNER);
  image(backgroundImage, 0, 0);

  /*
   * Physics simulation.
   * Repeat update in time slices of length TIMESTEP, to ensure consistency
   */
  while (secondsToSimulate > TIMESTEP) {
    // Player control
    if (controlledBody != null && thrusting || braking) {
      float forceDir = thrusting ? 1f : -1f;
      
      PVector thrust = controlledBody.vel.copy().setMag(THRUST_FORCE * forceDir * TIMESTEP / controlledBody.mass);
      controlledBody.vel.add(thrust);
    }
    
    // Calculate gravity forces before updating positions, to ensure we're never looking at "future" state 
    sim.step(bodies, false);
    secondsToSimulate -= TIMESTEP;
  }

  /*
   * Rendering
   */

  // Draw all bodies
  for (Body b : bodies) {
    b.draw();
  }

  Body bodyToPredict = null;
  
  // UI for placing new bodies
  if (selectedPrototypeIndex == -1) {
    bodyToPredict = getBodyUnderMouse();
  } else {
    imageMode(CENTER);
    if (placePosition == null) {
      image(prototypes.get(selectedPrototypeIndex).img, mouseX, mouseY);
    } else {
      stroke(0, 255, 0);
      line(placePosition.x, placePosition.y, mouseX, mouseY);
      image(prototypes.get(selectedPrototypeIndex).img, placePosition.x, placePosition.y);

      PVector initialVelocity = new PVector(mouseX-placePosition.x, mouseY-placePosition.y).mult(0.25f);
      bodyToPredict = new Body(prototypes.get(selectedPrototypeIndex), placePosition.copy(), initialVelocity);
    }
  }
  
  if (bodyToPredict == null) {
    bodyToPredict = controlledBody;
  }
  
  if (bodyToPredict != null) {
    List<PVector> predictedPath = sim.predictPath(bodies, bodyToPredict, PREDICT_TIMESTEPS);

    noStroke();
    fill(0, 255, 255);
    for (PVector p : predictedPath) {
      ellipse(p.x, p.y, 3, 3);
    }
  }
}

void mouseWheel() {
  // Scroll through prototypes which can be placed
  ++selectedPrototypeIndex;
  if (selectedPrototypeIndex >= prototypes.size()) {
    selectedPrototypeIndex = -1;
  }
}

void mousePressed() {
  if (selectedPrototypeIndex != -1 && mouseButton == LEFT) {
    // Begin placing a new body
    placePosition = new PVector(mouseX, mouseY);
  } else if (mouseButton == RIGHT) {
    // Right click a body to delete it
    Body toDelete = getBodyUnderMouse();
    if (toDelete != null) {
      bodies.remove(toDelete);
      if (controlledBody == toDelete) {
        controlledBody = null;
      }
    }
  }
}

void mouseReleased() {
  if (placePosition != null && selectedPrototypeIndex != -1) {
    // Add new body
    // Place at initial placePosition, and set velocity depending on current mouse position
    PVector initialVelocity = new PVector(mouseX-placePosition.x, mouseY-placePosition.y).mult(0.25f);
    Body newBody = new Body(prototypes.get(selectedPrototypeIndex), placePosition, initialVelocity);
    bodies.add(newBody);
    
    if (selectedPrototypeIndex == 0) {
      controlledBody = newBody;
    }
    
    placePosition = null;
  }
}

void keyPressed() {
  if (key == ' ') {
    paused = !paused;
  }
  if (keyCode == UP) {
    thrusting = true;
  }
  if (keyCode == DOWN) {
    braking = true;
  }
}

void keyReleased() {
  if (keyCode == UP) {
    thrusting = false;
  }
  if (keyCode == DOWN) {
    braking = false;
  }
}

Body getBodyUnderMouse() {
  Body closeBody = null;
  for (Body b : bodies) {
    if (PVector.sub(new PVector(mouseX, mouseY), b.pos).mag() < 30f) {
      closeBody = b;
    }
  }
  return closeBody;
}
