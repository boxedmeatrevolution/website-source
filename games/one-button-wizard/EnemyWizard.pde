class EnemyWizard extends Wizard {
  
  EnemyWizard(float x_, float y_, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, 100.0f, 100.0f, leftFacing, inputProcessor);
  }
  
  float reflectorTimer = 0.0f;
  float blackHoleTimer = 0.0f;
  boolean hasShield = false;
  float summonTimer = 0.0f;
  
  void create() {
    super.create();
    if (enemyWizardSpriteSheet == null) {
      enemyWizardSpriteSheet = loadSpriteSheet("./assets/enemy1.png", 3, 1, 250, 250);
    }
    wizardStandingAnimation = new Animation(enemyWizardSpriteSheet, 0.25, 0, 1);
    wizardCastPrepAnimation = wizardStandingAnimation;
    wizardCastingAnimation = wizardStandingAnimation;
    wizardHurtAnimation = wizardStandingAnimation;
    wizardWinAnimation = wizardStandingAnimation;
    wizardLoseAnimation = new Animation(enemyWizardSpriteSheet, 0.25, 2);
    wizardFadeAnimation = wizardStandingAnimation;
    wizardStunAnimation = wizardStandingAnimation;
    
    reflectorSpell = new ReflectorSpell();
    manaOrbSpell = new ManaSpell();
    gravityWellSpell = new GravityWellSpell();
    MANA_REGEN_RATE = 4.0f;
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (preFight || phased || stunned || winner || loser) {
      return;
    }
    reflectorTimer += delta;
    blackHoleTimer += delta;
    if (player1._mana / player1._maxMana > 0.25) {
      blackHoleTimer += 6 * delta;
    }
    if (blackHoleTimer > 30.0f && _mana > gravityWellSpell.getManaCost()) {
      gravityWellSpell.invoke(this);
      _mana -= gravityWellSpell.getManaCost();
      blackHoleTimer = 0.0f;
    }
    if (!hasShield && reflectorTimer > 1.0f && _mana > reflectorSpell.getManaCost()) {
      reflectorSpell.invoke(this);
      _mana -= reflectorSpell.getManaCost();
      hasShield = true;
    }
    if (reflectorTimer > 5.0f) {
      reflectorTimer = 0.0f;
      hasShield = false;
    }
    if (random(1) > 1 - 0.2 * delta) {
      manaOrbSpell.invoke(this);
    }
    summonTimer += delta;
    if (summonTimer > 3.0f && _mana > 10.0f) {
      summonTimer = 0.0f;
      _mana -= 10.0f;
      addEntity(new ZappyOrb(800.0f + random(-300.0f, +100.0f), 210.0f + random(100.0f), this));
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
  
  ReflectorSpell reflectorSpell;
  ManaSpell manaOrbSpell;
  GravityWellSpell gravityWellSpell;
  
}

SpriteSheet enemyWizardSpriteSheet;
