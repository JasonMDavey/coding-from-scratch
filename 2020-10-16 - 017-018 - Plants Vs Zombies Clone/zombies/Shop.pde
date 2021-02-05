static class Shop {
  static PVector getPosition(HeroType t) {
    if (t == HeroType.MONEY_GENERATOR) return new PVector(92, 690);
    if (t == HeroType.MELEE) return new PVector(192, 690);
    if (t == HeroType.RANGED) return new PVector(292, 690);
    throw new RuntimeException("UHOH!");
  }
  
  static PImage getIcon(HeroType t) {
    if (t == HeroType.MONEY_GENERATOR) return engiIcon;
    if (t == HeroType.MELEE) return warriorIcon;
    if (t == HeroType.RANGED) return rangerIcon;
    throw new RuntimeException("UHOH!");
  }
  
  static int getPrice(HeroType t) {
    if (t == HeroType.MONEY_GENERATOR) return 50;
    if (t == HeroType.MELEE) return 150;
    if (t == HeroType.RANGED) return 250;
    throw new RuntimeException("UHOH!");
  }
}
