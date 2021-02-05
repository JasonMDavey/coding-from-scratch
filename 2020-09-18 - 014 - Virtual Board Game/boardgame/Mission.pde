class Mission {
  String description;
  Challenge[] challenges;
  int rewardMoney;
  
  ArrayList<Steamhound> assignedCharacters = new ArrayList<Steamhound>();
  
  public Mission(String description, int rewardMoney, Challenge... challenges) {
    this.description = description;
    this.rewardMoney = rewardMoney;
    this.challenges = challenges;
  }
}
