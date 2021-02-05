class BoardState {
  ArrayList<Steamhound> roster;
  ArrayList<Mission> missions;
  int money;
  
  Mission activeMission;
  int activeChallengeIndex;
  
  public BoardState() {
    roster = new ArrayList<Steamhound>();
    missions = new ArrayList<Mission>();
    money = 100;
  }
}
