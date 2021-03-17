import processing.sound.*;

final int NUM_NOTE_TYPES = 3;

final float PERFECT_TOLERANCE_SECONDS = 0.05f;
final float GREAT_TOLERANCE_SECONDS = 0.1f;
final float OK_TOLERANCE_SECONDS = 0.2f;

final float BAR_LENGTH_PIXELS = 400f;
final float LANE_SPACING_PIXELS = 175f;

color[] NOTE_COLORS;

SoundFile musicTrack;
TrackData trackData;
PImage hitMarkerImage;

void setup() {
  size(1012,700,P3D);
  
  NOTE_COLORS = new color[]{
    color(255,0,0),
    color(0,255,0),
    color(80,80,255),
  };
  
  hitMarkerImage = loadImage("hitMarker.png");
  musicTrack = new SoundFile(this, "music.wav"); 
  trackData = new TrackData("data/trackinfo.txt");
  
  //musicTrack.jump(8);
  musicTrack.play();
}

void draw() {
  background(0);
  
  float playbackPos = musicTrack.position();
  text("Pos: " + playbackPos, 10, 10);
  
  drawTrack();
}

void drawTrack() {
  pushMatrix();
  
  translate(width/2, height*0.75f);
  rotateX(0.75f);
  
  float barStartX = -LANE_SPACING_PIXELS*(NUM_NOTE_TYPES-1)*0.5f;
    
  float barLengthSeconds = 60f / (trackData.bpm/4f);
  float playbackPos = musicTrack.position();
  float offsetY = ((playbackPos-trackData.introLength)/barLengthSeconds) * BAR_LENGTH_PIXELS;
  
  for (int barIndex = 0; barIndex < trackData.bars.size(); ++barIndex) {
    TrackData.Bar bar = trackData.bars.get(barIndex);
    float beatStepY = -BAR_LENGTH_PIXELS / bar.numBeats;
    float barStartY = -BAR_LENGTH_PIXELS * barIndex + offsetY;
    if (barStartY > height*0.75f) continue; // Bar has already scrolled off-screen
    if (barStartY < -height*2.5f) break; // Bar is not yet on-screen 
    
    noFill();
    stroke(255,255,255,128);
    strokeWeight(1);
    line(-width, barStartY, width, barStartY);

    imageMode(CENTER);
    for (TrackData.Hit hit : bar.hits) {
      if (hit.triggered) continue;
      float hitX = barStartX + hit.note*LANE_SPACING_PIXELS;
      float hitY = barStartY + hit.beat*beatStepY;
      
      pushMatrix();
      translate(hitX, hitY);
      tint(NOTE_COLORS[hit.note]);
      image(hitMarkerImage, 0, 0);
      popMatrix();      
    }
  }
  
  stroke(255);
  strokeWeight(2);
  line(-width, 0, width, 0);
  
  popMatrix();
}

void keyPressed() {
  if (key != CODED) return;
  
  int note;
  if (keyCode  == LEFT) note = 0;
  else if (keyCode  == DOWN) note = 1;
  else if (keyCode  == RIGHT) note = 2;
  else return;
  
  float playbackPos = musicTrack.position() - trackData.introLength;
  
  float barLengthSeconds = 60f / (trackData.bpm/4f); //<>//
  for (int barIndex = 0; barIndex < trackData.bars.size(); ++barIndex) {
    TrackData.Bar bar = trackData.bars.get(barIndex);
    
    float barStartSeconds = barIndex*barLengthSeconds;
    
    if (barStartSeconds > playbackPos + OK_TOLERANCE_SECONDS) break;  // Bar starts too late to be considered
    if (barStartSeconds+barLengthSeconds < playbackPos - OK_TOLERANCE_SECONDS) continue;  // Bar starts too early to be considered
    
    float beatStepSeconds = barLengthSeconds / bar.numBeats;
    
    for (TrackData.Hit hit : bar.hits) {
      if (hit.triggered) continue; // Already triggered this hit
      if (hit.note != note) continue; // Note doesn't match
      
      float hitTimeSeconds = barStartSeconds + hit.beat*beatStepSeconds;
      float timeDiff = abs(hitTimeSeconds - playbackPos);
      
      if (timeDiff < PERFECT_TOLERANCE_SECONDS) {
        println("Perfect!");
        hit.triggered = true;
        return;
      }
      else if (timeDiff < GREAT_TOLERANCE_SECONDS) {
        println("Great!");
        hit.triggered = true;
        return;
      }
      else if (timeDiff < OK_TOLERANCE_SECONDS) {
        println("OK!");
        hit.triggered = true;
        return;
      }
    }
  }
  
  // No note matched
  println("Bad hit!");
}
