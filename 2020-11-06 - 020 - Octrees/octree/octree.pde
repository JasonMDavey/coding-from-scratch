import peasy.*;

static final float WORLD_WIDTH = 500;
static final float WORLD_HEIGHT = 500;

static final int MAX_OBJECTS_PER_NODE = 3;

static final float CLOSENESS_RANGE = 15f;

PeasyCam cam;

ArrayList<PVector> objects = new ArrayList<PVector>();
ArrayList<PVector> vels = new ArrayList<PVector>();
QuadTree quadtree;
boolean started;
boolean stopped;

void setup() {
  size(506, 506, P3D);
  cam = new PeasyCam(this, WORLD_WIDTH);
}

void draw() {
  background(0);
  
  noStroke();
  lights();
  
  int i=0;
  for (PVector object : objects) {
    object.x += vels.get(i).x;
    object.y += vels.get(i).y;
    if (object.x < -WORLD_WIDTH/2f || object.x > WORLD_WIDTH/2f) { vels.get(i).x *= -1; }
    if (object.y < -WORLD_WIDTH/2f || object.y > WORLD_WIDTH/2f) { vels.get(i).y *= -1; }
    ++i;
  }
  if (started && !stopped && objects.size()<90) {
    PVector randomPoint = new PVector(
        random(-WORLD_WIDTH/2f, WORLD_WIDTH/2f),
        random(-WORLD_HEIGHT/2f, WORLD_HEIGHT/2f),
        0f
      );
      
      objects.add(randomPoint);
      
      vels.add(new PVector(
        random(-3f,3f),
        random(-3f,3f),
        0f
      ));
  }
  if (stopped &&objects.size()>0) {
    objects.remove(0);
    vels.remove(0);
  }
  
  println(objects.size() + " objects");
  
  // Find any objects which are close to others
  
  ArrayList<PVector> objectsWithNeighbours = new ArrayList<PVector>();
  
  long quadtreeStart = millis();
  
  // Populate quadtree
  quadtree = new QuadTree(-WORLD_HEIGHT/2f, WORLD_HEIGHT/2f, -WORLD_WIDTH/2f, WORLD_WIDTH/2f);
  
  for (PVector object : objects) {
    quadtree.add(object);
  }
  
  for (PVector object : objects) {
    ArrayList<PVector> objectsCloseToMe = quadtree.queryRect(object.y - CLOSENESS_RANGE,
                                                             object.y + CLOSENESS_RANGE,
                                                             object.x - CLOSENESS_RANGE,
                                                             object.x + CLOSENESS_RANGE);
                                                             
    for (PVector objectCloseToMe : objectsCloseToMe) {
      if (object == objectCloseToMe) continue; // Don't consider yourself a neighbour
      
      float dist = object.dist(objectCloseToMe);
      if (dist <= CLOSENESS_RANGE) {
        objectsWithNeighbours.add(object);
        break;
      }
    }                                                           
  }
  
  println((millis()-quadtreeStart) + " ms using quadtree");
  
  /*
  
  ArrayList<PVector> objectsWithNeighboursNaive = new ArrayList<PVector>();
  
  long naiveStart = millis();
  
  for (PVector object : objects) {
                                                            
    for (PVector objectCloseToMe : objects) {
      if (object == objectCloseToMe) continue; // Don't consider yourself a neighbour
      
      float dist = object.dist(objectCloseToMe);
      if (dist <= CLOSENESS_RANGE) {
        objectsWithNeighboursNaive.add(object);
        break;
      }
    }                                                           
  }
  
  println((millis()-naiveStart) + " ms using naive");
  
  */
  

  for (PVector object : objects) {
    pushMatrix();
    translate(object.x, object.y, object.z);

    if (objectsWithNeighbours.contains(object)) {
        fill(255,0,0);
    }
    else {
        fill(255);
    }
    
    sphere(5);
    popMatrix();
  }
  
  quadtree.draw();
  
  if (started) {
    saveFrame("fr#####.png");
  }
}

void keyPressed() {
  if (key == ' ') {
    if (started) { stopped=true;}
    started=true;
    /*for (int i=0; i<10; ++i) {
      PVector randomPoint = new PVector(
        random(-WORLD_WIDTH/2f, WORLD_WIDTH/2f),
        random(-WORLD_HEIGHT/2f, WORLD_HEIGHT/2f),
        0f
      );
      
      objects.add(randomPoint);
    }*/
    
    
  }
}
