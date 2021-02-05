import java.util.Map;

class Wave {
  String name;
  Map<EnemyType, Integer> numEnemiesToSpawn = new HashMap<EnemyType, Integer>();
  float durationSeconds;
}
