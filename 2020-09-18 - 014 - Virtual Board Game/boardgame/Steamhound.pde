class Steamhound {
  
  String name;
  Tag[] tags;
  boolean isInjured;
  Assignment assignment = Assignment.IN_ROSTER;
  
  PImage img;
  
  
  public Steamhound(String name, Tag... tags) {
    this.name = name;
    this.tags = tags;
    
    img = loadImage(name + "_icon.png");
  }
  
  public boolean hasTag(Tag t) {
    for (Tag myTag : tags) {
      if (t == myTag) return true;
    }
    return false;
  }
}
