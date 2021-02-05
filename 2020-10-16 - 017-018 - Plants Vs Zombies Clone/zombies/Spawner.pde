class Spawner {
  Wave wave;
  Map<EnemyType, Integer> numEnemiesSpawned;
  float spawnIntervalSeconds, secondsSinceLastSpawn;
  int enemiesRemaining;
  
  public void init(Wave w) {
    this.wave = w;
    
    numEnemiesSpawned = new HashMap<EnemyType, Integer>();
    
    // Count total number of enemies in this wave
    int totalEnemies = 0;
    for (Map.Entry<EnemyType, Integer> e : w.numEnemiesToSpawn.entrySet()) {
      totalEnemies += e.getValue();
      
      numEnemiesSpawned.put(e.getKey(), 0);
    }
    this.enemiesRemaining = totalEnemies;
    
    // Derive time-between-spawns
    spawnIntervalSeconds = w.durationSeconds / totalEnemies;
    
    secondsSinceLastSpawn = 0;
    
    println("Starting " + w.name);
  }
  
  public void update(float secondsElapsed) {
    secondsSinceLastSpawn += secondsElapsed;
     //<>//
    while (secondsSinceLastSpawn > spawnIntervalSeconds) {
      secondsSinceLastSpawn -= spawnIntervalSeconds;
      doSpawn();
    }
  }
  
  private void doSpawn() {
    // Figure out which enemy classes we're eligible to spawn
    List<EnemyType> eligibleTypes = new ArrayList<EnemyType>();
    
    for (Map.Entry<EnemyType, Integer> e : wave.numEnemiesToSpawn.entrySet()) {
      EnemyType enemyType = e.getKey();
      int numToSpawn = e.getValue();
      
      if (numEnemiesSpawned.get(enemyType) < numToSpawn) {
        eligibleTypes.add(enemyType);
      }
    }
    
    if (eligibleTypes.isEmpty()) {
      // We've spawned the specified number of enemies of each type already!
      return;
    }
    
    // Pick a random enemy type from the set of eligible types
    EnemyType typeToSpawn = eligibleTypes.get((int)random(0, eligibleTypes.size()));
    
    // Pick a random lane
    int lane = (int)random(0, World.NUM_ROWS);
    
    // Instantiate an enemy of the desired type
    Enemy e;
    switch (typeToSpawn) {
      case WALKER: e = new WalkerEnemy(World.ENEMY_SPAWN_X, lane, 20, 0.1f); break;
      case FAST_WALKER: e = new WalkerEnemy(World.ENEMY_SPAWN_X, lane, 20, 0.3f); break;
      default: throw new RuntimeException("UHOH!");
    }
  
    // Add to enemy collection for the appropriate lane
    enemies.get(lane).add(e);
    
    // Increment spawned-counter for this enemy type
    numEnemiesSpawned.put(typeToSpawn, numEnemiesSpawned.get(typeToSpawn)+1);
    --enemiesRemaining;
  }
}
