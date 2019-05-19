class WizardAI extends Wizard {
  int timer = 0;
  
  WizardAI(float x_, float y_, float maxHealth, float maxMana, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, maxHealth, maxMana, leftFacing, inputProcessor);
  }
  
  void create() {
    super.create();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    timer += delta;  
    if (timer > 2.0) {
      timer = 0;
      if (spellBook.size() > 0) {
        Spell spell = spellBook.get(floor(random(0, spellBook.size())));
        if (spell.getManaCost() < _mana) {
          _mana -= spell.getManaCost();
          spell.invoke(this);
        } else {
          for(Spell spell : spellBook) {
            if (spell.name() == "Mana Orb" && spell.getManaCost() < _mana) {
              spell.invoke(this);
            }
          }
        }
      }
    }
  }
  
  void render() {
    super.render();
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void hurt(float damage) {
    super.hurt(damage);
  }  
}
