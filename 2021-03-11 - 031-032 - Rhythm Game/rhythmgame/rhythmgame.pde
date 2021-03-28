import processing.sound.*;

// Timing / gameplay-related constants
final int NUM_NOTE_TYPES = 3;
final float PERFECT_TOLERANCE_SECONDS = 0.05f;
final float GREAT_TOLERANCE_SECONDS = 0.1f;
final float OK_TOLERANCE_SECONDS = 0.2f;

final int PERFECT_SCORE = 100;
final int GREAT_SCORE = 50;
final int OK_SCORE = 20;

final int COMBO_UP_INTERVAL = 10;
final int COMBO_MAX_MULTIPLIER = 10;

// Audio-visual-related constants
final float BAR_LENGTH_PIXELS = 400f;
final float LANE_SPACING_PIXELS = 175f;

final float NOTE_FADE_TIME_SECONDS = 0.5f;


final color[] NOTE_COLORS = new color[]{
  color(255,0,0),
  color(0,255,0),
  color(80,80,255),
};

// Assets
SoundFile musicTrack;
TrackData trackData;

PImage hitMarkerImage, hitMarkerFailureImage, hitMarkerSuccessImage;

// State
int score = 0;
int comboMultiplier = 1;
int comboUpCounter = 0;

void setup() {
  size(1012,700,P3D);
  hint(ENABLE_DEPTH_SORT);
  
  // Load images  
  hitMarkerImage = loadImage("hitMarker.png");
  hitMarkerFailureImage = loadImage("hitMarker_failure.png");
  hitMarkerSuccessImage = loadImage("hitMarker_success.png");
  
  // Load audio file
  musicTrack = new SoundFile(this, "music.wav");
  
  // Load track metadata
  trackData = new TrackData("F:/Koofr/Stray Basilisk/Media/streaming/episodes/2021-03-11 - 031 - Rhythm Game/rhythmgame/data/trackinfo.txt");
  
  //musicTrack.jump(30);
  // Start the music!
  musicTrack.play();
}

void draw() {
  background(0);

  detectFailedHits();
  
  textSize(30);
  textAlign(LEFT);
  text("Score: " + score, 10, 30);
  textAlign(RIGHT);
  text(comboMultiplier+"x", width-10, 30);
  
  drawTrack();
}

void detectFailedHits() {
  float playbackPos = musicTrack.position() - trackData.introLength;
  
  // Scan through the track to find notes/hits matching the input
  float barLengthSeconds = 60f / (trackData.bpm/4f);
  for (int barIndex = 0; barIndex < trackData.bars.size(); ++barIndex) {
    TrackData.Bar bar = trackData.bars.get(barIndex);
    
    float barStartSeconds = barIndex*barLengthSeconds;
    
    // Skip considering bars which are entirely out of range of the current playback position
    if (barStartSeconds > playbackPos + OK_TOLERANCE_SECONDS) break;  // Bar starts too late to be considered
    if (barStartSeconds+barLengthSeconds < playbackPos - OK_TOLERANCE_SECONDS*2.0f) continue;  // Bar starts too early to be considered
    
    // Bar metadata can contain different numbers of beats, but they are always evenly divided throughout the bar
    float beatStepSeconds = barLengthSeconds / bar.numBeats;
    
    for (TrackData.Hit hit : bar.hits) {
      if (hit.state != TrackData.Hit.HIT_PENDING) continue; // Already triggered this hit
      
      float hitTimeSeconds = barStartSeconds + hit.beat*beatStepSeconds;
      
      if (playbackPos - hitTimeSeconds > OK_TOLERANCE_SECONDS) {
        println("Missed hit!");
        hit.state = TrackData.Hit.HIT_FAILURE;
        hit.stateTime = musicTrack.position();
        comboMultiplier = 1;
        comboUpCounter = 0;
      }
    }
  }
}

void drawTrack() {
  pushMatrix();
  
  // Apply centering and perspective
  translate(width/2, height*0.75f);
  rotateX(0.75f);
  
  /*
   * Draw the tracks / bars / notes
   */
  float playbackPos = musicTrack.position();
    
  // Figure out spacing / layout
  float barStartX = -LANE_SPACING_PIXELS*(NUM_NOTE_TYPES-1)*0.5f;  
  float barLengthSeconds = 60f / (trackData.bpm/4f);
  float offsetY = ((playbackPos-trackData.introLength)/barLengthSeconds) * BAR_LENGTH_PIXELS;
  
  for (int barIndex = 0; barIndex < trackData.bars.size(); ++barIndex) {
    TrackData.Bar bar = trackData.bars.get(barIndex);
    float beatStepY = -BAR_LENGTH_PIXELS / bar.numBeats;
    float barStartY = -BAR_LENGTH_PIXELS * barIndex + offsetY;
    
    // Cull bars which are not on-screen
    if (barStartY > height*0.75f) continue; // Bar has already scrolled off-screen
    if (barStartY < -height*2.5f) break; // Bar is not yet on-screen 
    
    noFill();
    
    // Draw horizontal lines at the start of each bar
    stroke(255,255,255,128);
    strokeWeight(1);
    line(-width, barStartY, width, barStartY);

    // Draw each hit / note
    imageMode(CENTER);
    blendMode(ADD);
    hint(DISABLE_DEPTH_TEST);
    for (TrackData.Hit hit : bar.hits) {
      float hitX = barStartX + hit.note*LANE_SPACING_PIXELS;
      float hitY = barStartY + hit.beat*beatStepY;
      
      pushMatrix();
      translate(hitX, hitY);
            
      switch (hit.state) {
        case TrackData.Hit.HIT_PENDING:
          tint(NOTE_COLORS[hit.note]);
          image(hitMarkerImage, 0, 0);
          break;
          
        case TrackData.Hit.HIT_FAILURE: {
          float timeSinceHit = playbackPos - hit.stateTime;
          float alpha = Math.max(1f - timeSinceHit / NOTE_FADE_TIME_SECONDS, 0f);
          color noteColor = NOTE_COLORS[hit.note];
          tint(red(noteColor), green(noteColor), blue(noteColor), alpha*255);
          image(hitMarkerFailureImage, 0, 0);
          break;
        }
        case TrackData.Hit.HIT_SUCCESS: {
          float timeSinceHit = playbackPos - hit.stateTime;
          float alpha = Math.max(1f - timeSinceHit / NOTE_FADE_TIME_SECONDS, 0f);
          color noteColor = NOTE_COLORS[hit.note];
          tint(red(noteColor), green(noteColor), blue(noteColor), alpha*255);
          image(hitMarkerSuccessImage, 0, 0);
          break;
        }
      }
      hint(ENABLE_DEPTH_TEST);
      blendMode(NORMAL);
      popMatrix();      
    }
  }
  
  // Draw line to indicate current
  stroke(255);
  strokeWeight(2);
  line(-width, 0, width, 0);
  
  popMatrix();
}

void keyPressed() {
  if (key != CODED) return;
  
  // Determine which note this key corresponds to (if any)
  int note;
  if (keyCode  == LEFT) note = 0;
  else if (keyCode  == DOWN) note = 1;
  else if (keyCode  == RIGHT) note = 2;
  else return;
  
  float playbackPos = musicTrack.position() - trackData.introLength;
  
  // Scan through the track to find notes/hits matching the input
  TrackData.Hit matchedHit = null;
      
  float barLengthSeconds = 60f / (trackData.bpm/4f); //<>//
  for (int barIndex = 0; barIndex < trackData.bars.size(); ++barIndex) {
    TrackData.Bar bar = trackData.bars.get(barIndex);
    
    float barStartSeconds = barIndex*barLengthSeconds;
    
    // Skip considering bars which are entirely out of range of the current playback position
    if (barStartSeconds > playbackPos + OK_TOLERANCE_SECONDS) break;  // Bar starts too late to be considered
    if (barStartSeconds+barLengthSeconds < playbackPos - OK_TOLERANCE_SECONDS) continue;  // Bar starts too early to be considered
    
    // Bar metadata can contain different numbers of beats, but they are always evenly divided throughout the bar
    float beatStepSeconds = barLengthSeconds / bar.numBeats;
        
    for (TrackData.Hit hit : bar.hits) {
      if (hit.state != TrackData.Hit.HIT_PENDING) continue; // Already triggered this hit
      if (hit.note != note) continue; // Note doesn't match
      
      float hitTimeSeconds = barStartSeconds + hit.beat*beatStepSeconds;
      float timeDiff = abs(hitTimeSeconds - playbackPos);
      
      if (timeDiff < PERFECT_TOLERANCE_SECONDS) {
        println("Perfect!");
        score += PERFECT_SCORE * comboMultiplier;
        matchedHit = hit;
        break;
      }
      else if (timeDiff < GREAT_TOLERANCE_SECONDS) {
        println("Great!");
        score += GREAT_SCORE * comboMultiplier;
        matchedHit = hit;
        break;
      }
      else if (timeDiff < OK_TOLERANCE_SECONDS) {
        println("OK!");
        score += OK_SCORE * comboMultiplier;
        matchedHit = hit;
        break;
      }
    }
  }
  
  if (matchedHit == null) {
    // No note matched
    println("Bad hit!");
    comboMultiplier = 1;
    comboUpCounter = 0;
  }
  else {
    matchedHit.state = TrackData.Hit.HIT_SUCCESS;
    matchedHit.stateTime = musicTrack.position();
    ++comboUpCounter;
    if (comboUpCounter == COMBO_UP_INTERVAL) {
      comboMultiplier = min(COMBO_MAX_MULTIPLIER, comboMultiplier + 1);
      comboUpCounter = 0;
    }
  }
 }
