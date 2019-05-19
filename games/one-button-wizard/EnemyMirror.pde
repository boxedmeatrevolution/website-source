class EnemyMirror extends Wizard {
  
  EnemyMirror(float x_, float y_, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, 100.0f, 100.0f, leftFacing, inputProcessor);
  }
  
  float gustTimer = 0.0f;
  float meteorTimer = 6.7f;
  float manaSuckerTimer = 0.0f;
  float blackHoleTimer = 0.0f;
  
  void create() {
    super.create();
    if (enemyMirrorSpritesheet == null) {
      enemyMirrorSpritesheet = loadSpriteSheet("./assets/mirror.png", 3, 1, 250, 250);
    }
    wizardStandingAnimation = new Animation(enemyMirrorSpritesheet, 0.25, 0, 1);
    wizardCastPrepAnimation = wizardStandingAnimation;
    wizardCastingAnimation = wizardStandingAnimation;
    wizardHurtAnimation = wizardStandingAnimation;
    wizardWinAnimation = wizardStandingAnimation;
    wizardLoseAnimation = new Animation(enemyMirrorSpritesheet, 0.25, 2);
    wizardFadeAnimation = wizardStandingAnimation;
    wizardStunAnimation = wizardStandingAnimation;
    
    meteorSpell = new MeteorShowerSpell();
    manaSuckerSpell = new ManaSuckerSpell();
    manaOrbSpell = new ManaSpell();
    healthOrbSpell = new HealthSpell();
    MANA_REGEN_RATE = 5.0f;
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (preFight || phased || stunned || winner || loser) {
      return;
    }
    meteorTimer += delta;
    manaSuckerTimer += delta;
    
    if (meteorTimer >= 8.0f && _mana > meteorSpell.getManaCost()) {
      meteorSpell.invoke(this);
      _mana -= meteorSpell.getManaCost();
      meteorTimer = 0.0f;
    }
    if (manaSuckerTimer >= 8.0f && _mana > manaSuckerSpell.getManaCost()) {
      manaSuckerSpell.invoke(this);
      _mana -= manaSuckerSpell.getManaCost();
      manaSuckerTimer = 0.0f;
    }
    
    if (random(1) > 1 - 0.2 * delta) {
      manaOrbSpell.invoke(this);
    }
    if (_health < _maxHealth && random(1) > 1 - 0.2 * delta && _mana > healthOrbSpell.getManaCost()) {
      healthOrbSpell.invoke(this);
      _mana -= healthOrbSpell.getManaCost();
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
  
  MeteorShowerSpell meteorSpell;
  ManaSuckerSpell manaSuckerSpell;
  ManaSpell manaOrbSpell;
  HealthSpell healthOrbSpell;
  
}

SpriteSheet enemyMirrorSpritesheet;
