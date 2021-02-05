class Library {
  ArrayList<TileObject> tileObjects;
  ArrayList<CompoundObject> compoundObjects;
  
  public TileObject getTileObject(String id) {
    for (TileObject o : tileObjects) {
      if (o.id.equals(id)) return o;
    }
    return null;
  }
}
