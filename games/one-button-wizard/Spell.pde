class Spell {
  
  public abstract String name() {
  }
  
  public abstract void invoke(Wizard owner) {
  }
  
  public abstract float getManaCost() {
    return 1.0;
  }
  
  public abstract int[] getCombination() {
    return null;
  }
  
}
