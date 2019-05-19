class EnemySquid extends Wizard {
  
  EnemySquid(float x_, float y_, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, 100.0f, 100.0f, leftFacing, inputProcessor);
  }
  
  float goingToPhaseTimer = 0.0f;
  float comboTimer = 0.0f;
  boolean didPhase = false;
  
  void create() {
    super.create();
    if (enemySquidSpriteSheet == null) {
      enemySquidSpriteSheet = loadSpriteSheet("./assets/enemy3.png", 4, 1, 250, 250);
    }
    wizardStandingAnimation = new Animation(enemySquidSpriteSheet, 0.25, 0, 1);
    wizardCastPrepAnimation = wizardStandingAnimation;
    wizardCastingAnimation = wizardStandingAnimation;
    wizardHurtAnimation = wizardStandingAnimation;
    wizardWinAnimation = wizardStandingAnimation;
    wizardLoseAnimation = new Animation(enemySquidSpriteSheet, 0.25, 3);
    wizardFadeAnimation = new Animation(enemySquidSpriteSheet, 0.25, 2);
    wizardStunAnimation = wizardStandingAnimation;
    
    rapidShotSpell = new RapidShotSpell();
    phaseSpell = new PhaseSpell();
    piercerSpell = new PiercerSpell();
    highSpell = new HighFireballSpell();
    MANA_REGEN_RATE = 10.0f;
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (preFight || stunned || winner || loser) {
      return;
    }
    goingToPhaseTimer += delta;
    if (goingToPhaseTimer > 3.0f && _mana > phaseSpell.getManaCost() && !didPhase) {
      phaseSpell.invoke(this);
      _mana -= phaseSpell.getManaCost();
      phaseTimer = 10.0f;
      didPhase = true;
    }
    if (goingToPhaseTimer > 13.0f) {
      goingToPhaseTimer = 0.0f;
      didPhase = false;
    }
    
    comboTimer += delta;
    if (comboTimer > 13.0f && phased) {
      if (_mana > piercerSpell.getManaCost()) {
        piercerSpell.invoke(this);
        _mana -= piercerSpell.getManaCost();
      }
      if (_mana > rapidShotSpell.getManaCost()) {
        rapidShotSpell.invoke(this);
        _mana -= rapidShotSpell.getManaCost();
      }
      if (_mana > highSpell.getManaCost()) {
        highSpell.invoke(this);
        _mana -= highSpell.getManaCost();
      }
      comboTimer = 0.0f;
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
  
  RapidShotSpell rapidShotSpell;
  PiercerSpell piercerSpell;
  PhaseSpell phaseSpell;
  HighFireballSpell highSpell;
  
}

SpriteSheet enemySquidSpriteSheet;
