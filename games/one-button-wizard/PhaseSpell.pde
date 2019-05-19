class PhaseSpell extends Spell {
  int[] combination = new int[] { 1, 1 };
  
  public PhaseSpell() {
  }
  
  public String name() {
    return "Phase Shift";
  }
  
  public void invoke(Wizard owner) {
    playSound("phase");
    owner.phased = true;
    owner.phaseTimer = 2.0f;
  }
  
  public float getManaCost() {
    return 10.0f;
  }
  
  public int[] getCombination() {
    return combination;
  }
}
