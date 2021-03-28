import java.util.List;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

class TrackData {
   
  public class Hit {
    public static final int HIT_PENDING = 0;
    public static final int HIT_SUCCESS = 1;
    public static final int HIT_FAILURE = 2;
    
    int beat;
    int note;
    int duration;
    
    int state = HIT_PENDING;
    float stateTime;
    
    public Hit(int beat, int note, int duration) {
      this.beat = beat;
      this.note = note;
      this.duration = duration;
    }
  }
  
  public class Bar {
    int numBeats;
    List<Hit> hits;
    
    public Bar(int numBeats, List<Hit> hits) {
      this.numBeats = numBeats;
      this.hits = hits;
    }
  }
  
  float introLength;
  float bpm;
  
  List<Bar> bars;
  
  public TrackData(String filename) {
    try {
      String fileAsString = new String(Files.readAllBytes(Paths.get(filename)));
      String[] lines = fileAsString.split("\n");
      
      int i=0;
      introLength = Float.parseFloat(lines[i++]);
      bpm = Float.parseFloat(lines[i++]);
      bars = new ArrayList<Bar>();
      
      while (i < lines.length) {
        String line = lines[i++];
        
        if (line.startsWith("#")) continue;  // Comment - do nothing

        // Line represents one bar
        String[] beats = line.split(",");
        
        List<Hit> hits = new ArrayList<Hit>(beats.length);
        
        for (int beatIndex = 0; beatIndex < beats.length; ++beatIndex) {
          String beatSpec = beats[beatIndex].trim();
          if (beatSpec.equals("-")) continue;  // No hits on this beat
          
          // Several characters may be listed, each indicating a different hit
          for (char c : beatSpec.toCharArray()) {
            // A->0, B->1, etc...
            int note = c-'A';
            if (note < 0 || note >= NUM_NOTE_TYPES) throw new RuntimeException("Invalid note! " + c);
            hits.add(new Hit(beatIndex, note, 1));
          }
        }
        
        bars.add(new Bar(beats.length, hits));
      }
    }
    catch (IOException e) {
      e.printStackTrace();
      throw new RuntimeException("Failed to load track data", e);
    }

  }
}
