//
// You are free to modify or use this code however you would like!
// Images and other assets are copyright Stray Basilisk Ltd., and for personal / non-commercial / educational use only.
//

import java.util.Collections;

// Gameplay constants
final int COST_PER_ROUND = 75;
final int MISSIONS_PER_ROUND = 2;

// UI constants
final int ROSTER_START_X = 45;
final int ROSTER_START_Y = 140;
final int ROSTER_SPACING = 80;

final int MISSION_START_X = 450;
final int MISSION_START_Y = 245;
final int MISSION_SPACING = 325;

PImage backgroundImage;
PImage gameoverImage;
PImage missionImage;
PImage cursor;

BoardState boardState;

ArrayList<Mission> missionDeck = new ArrayList<Mission>();

void setup() {
  size(900,800);
  
  backgroundImage = loadImage("background.png");
  gameoverImage = loadImage("gameover.png");
  missionImage = loadImage("mission.png");
  cursor = loadImage("hand.png");
  
  resetGame();
}

void resetGame() {
  boardState = new BoardState();
  boardState.roster.add(new Steamhound("Warrior", Tag.COMBAT, Tag.COMBAT));
  boardState.roster.add(new Steamhound("Ranger", Tag.COMBAT, Tag.OBSERVATION));
  boardState.roster.add(new Steamhound("Engineer", Tag.OBSERVATION, Tag.ANIMAL_HANDLING));
  boardState.roster.add(new Steamhound("Chemist", Tag.COMBAT, Tag.FIRST_AID));
  
  missionDeck.add(new Mission("Steal the McGuffin",
                              50,
                              new Challenge("Scope out the target", Tag.OBSERVATION, 3),
                              new Challenge("Sneak in to the facility", Tag.STEALTH, 4),
                              new Challenge("Defeat the guards", Tag.COMBAT, 4),
                              new Challenge("Sneak back out of the facility", Tag.STEALTH, 3))
                              );
                                      
  missionDeck.add(new Mission("Steal the McGuffin again",
                              50,
                              new Challenge("Scope out the target", Tag.OBSERVATION, 3),
                              new Challenge("Sneak in to the facility", Tag.STEALTH, 4),
                              new Challenge("Defeat the guards", Tag.COMBAT, 4),
                              new Challenge("Sneak back out of the facility", Tag.STEALTH, 3))
                              );
                              
  missionDeck.add(new Mission("Steal the McGuffin a third time",
                              50,
                              new Challenge("Scope out the target", Tag.OBSERVATION, 3),
                              new Challenge("Sneak in to the facility", Tag.STEALTH, 4),
                              new Challenge("Defeat the guards", Tag.COMBAT, 4),
                              new Challenge("Sneak back out of the facility", Tag.STEALTH, 3))
                              );
                              
  dealMissions();
}

void draw() {
  imageMode(CORNER);
  image(backgroundImage, 0,0);
    
  // Draw money
  textSize(30);
  text("Money: " + boardState.money, 20, 40);
  
  // Draw missions
  imageMode(CENTER);
  float y = MISSION_START_Y;
  for (Mission m : boardState.missions) {
    image(missionImage, MISSION_START_X, y);
    
    textSize(20);
    text(m.description + "\nReward: " + m.rewardMoney, MISSION_START_X-250, y-70);
    
    y += MISSION_SPACING;
  }
  
  // Draw characters
  imageMode(CENTER);
  for (Steamhound c : boardState.roster) {
    PVector pos = getCharacterPos(c); 
    
    if (c.isInjured) {
      tint(200,0,0);
    }
    else {
      tint(255,255,255);
    }
    image(c.img, pos.x, pos.y);
  }
  
  tint(255,255,255);
  
  if (boardState.money < 0) {
    imageMode(CORNER);
    image(gameoverImage, 0,0);
  }
}

void mousePressed() {
  if (boardState.money < 0) {
    resetGame();
    return;
  }
  
  if (boardState.activeMission != null) {
    // Mission is active - clicking will step through it
    stepMission();
    return;
  }
  
  // Mission is not active - normal UI interaction!
  
  PVector mousePos = new PVector(mouseX, mouseY);
  
  // Try to pick up a character
  for (Steamhound c : boardState.roster) {
    if (c.isInjured) continue;
    
    PVector pos = getCharacterPos(c);
    float distFromMouse = PVector.dist(mousePos, pos);
    if (distFromMouse <= c.img.width / 2f) {
      // If they're currently assigned to a mission, make sure to remove them from it
      if (c.assignment == Assignment.IN_MISSION) {
        for (Mission m : boardState.missions) {
          int i = m.assignedCharacters.indexOf(c);
          if (i != -1) { m.assignedCharacters.remove(i); }
        }
      }
      
      c.assignment = Assignment.DRAGGED;
      return;
    }
  }
  
  // Did we click a "deploy" button on a mission?
  for (Mission m : boardState.missions) {
    if (m.assignedCharacters.size() == 0) continue;
    
    PVector pos = getMissionPos(m);
    if (mouseX >= pos.x+61 && mouseX <= pos.x+240 && mouseY >= pos.y-77 && mouseY <= pos.y-22) {
      startMission(m);
      return;
    }
  }
  
  // Did we click "proceed" button to move to the next round?
  if (mouseX >= 648 && mouseX <= 891 && mouseY >= 744 && mouseY <= 792) {
    proceedToNextRound();
  }
}

void mouseReleased() {
  for (Steamhound c : boardState.roster) {
    if (c.assignment != Assignment.DRAGGED) continue;
    
    // First, see if we are dropping the character onto a mission
    for (Mission m : boardState.missions) {
      if (m.assignedCharacters.size() == 3) continue;
      
      PVector pos = getMissionPos(m);
      if (mouseX >= pos.x-(missionImage.width/2) && mouseX <= pos.x+(missionImage.width/2)
          && mouseY >= pos.y-(missionImage.height/2) && mouseY <= pos.y+(missionImage.height/2)) {
            
        // Mouse position is within the bounding box of the mission
        m.assignedCharacters.add(c);
        c.assignment = Assignment.IN_MISSION;
        return;
      }
    }
    
    // Otherwise, put them back into the roster
    c.assignment = Assignment.IN_ROSTER;
  }
}

PVector getMissionPos(Mission m) {
  float y = MISSION_START_Y;
  for (Mission mission : boardState.missions) {
    if (m == mission) return new PVector(MISSION_START_X, y);
    y += MISSION_SPACING;
  }
  
  return null;
}

PVector getCharacterPos(Steamhound c) {
  switch (c.assignment) {
    case IN_ROSTER: {
      int y = ROSTER_START_Y;
      for (Steamhound charInRoster : boardState.roster) {
        if (c == charInRoster) return new PVector(ROSTER_START_X, y);
        y += ROSTER_SPACING;
      }
      return null;
    }
    
    case DRAGGED: {
      return new PVector(mouseX, mouseY);
    }
    
    case IN_MISSION: {
      for (Mission m : boardState.missions) {
        int i = m.assignedCharacters.indexOf(c);
        if (i == -1) continue;
        
        // Character is assigned to this mission - find the position of their slot
        PVector missionPos = getMissionPos(m);
        if (i == 0) return missionPos.add(21f, 42f);
        if (i == 1) return missionPos.add(114f, 42f);
        if (i == 2) return missionPos.add(207f, 42f);
      }
      return null;
    }
  }
 
  return null;
}


void startMission(Mission m) {
  println("Starting mission - " + m.description);
  boardState.activeMission = m;
  boardState.activeChallengeIndex = 0;
  
  stepMission();
}

// Returns true if the mission is failed/completed, and false if there are more challenges still to go
void stepMission() {
  Challenge challenge = boardState.activeMission.challenges[boardState.activeChallengeIndex];
  
  println("  " + challenge.description + " [" + challenge.tag + ", difficulty " + challenge.difficulty + "]");
  int targetNumber = challenge.difficulty;
  for (Steamhound character : boardState.activeMission.assignedCharacters) {
    if (!character.isInjured && character.hasTag(challenge.tag)) {
      println("    " + character.name + " has " + challenge.tag);
      --targetNumber;
    }
  }
  println("    Target number is " + targetNumber);
  int dieRoll = (int)random(1,7);
  println("    Die roll " + dieRoll);
  if (dieRoll >= targetNumber) {
    println("    SUCCESS!");
  }
  else {
    println("    FAILURE =(");
    
    // Randomly injure a character!
    ArrayList<Steamhound> uninjuredCharacters = new ArrayList<Steamhound>();
    for (Steamhound c : boardState.activeMission.assignedCharacters) {
      if (!c.isInjured) {
        uninjuredCharacters.add(c);
      }
    }
    
    int characterIndexToInjure = (int)random(0, uninjuredCharacters.size());
    Steamhound injuredCharacter = uninjuredCharacters.get(characterIndexToInjure);
    injuredCharacter.isInjured = true;
    println("      " + injuredCharacter.name + " was injured!");
    
    if (uninjuredCharacters.size() == 1) {
      endMission(false);
      return;
    }
  }
  
  ++boardState.activeChallengeIndex;
  
  if (boardState.activeChallengeIndex == boardState.activeMission.challenges.length) {
    endMission(true);
  }
}

void endMission(boolean success) {
  if (success) {
    println("Mission was a success!\n");
    boardState.money += boardState.activeMission.rewardMoney;
  }
  else {
    println("All characters have been taken out - mission failed!\n");
  }
  
  // Return characters who were assigned to the mission into the pool
  for (Steamhound c : boardState.activeMission.assignedCharacters) {
    c.assignment = Assignment.IN_ROSTER;
  }
  boardState.activeMission.assignedCharacters.clear();
  
  boardState.missions.remove(boardState.activeMission);
  
  boardState.activeMission = null;
}

void proceedToNextRound() {
  for (Steamhound c : boardState.roster) {
    c.assignment = Assignment.IN_ROSTER;
    c.isInjured = false;
  }
  
  for (Mission m : boardState.missions) {
    m.assignedCharacters.clear();
  }
  boardState.missions.clear();
  
  println("The tax man comes to collect " + COST_PER_ROUND);
  boardState.money -= COST_PER_ROUND;
  if (boardState.money < 0) {
    println("GAME OVER!! You ran out of money =(");
  }
  else {
    dealMissions();
  }
}

void dealMissions() {
  Collections.shuffle(missionDeck);
  for (int i=0; i<MISSIONS_PER_ROUND; ++i) {
    boardState.missions.add(missionDeck.get(i));
  }
}
