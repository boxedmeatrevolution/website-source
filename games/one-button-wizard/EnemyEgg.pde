class EnemyEgg extends Wizard {
  
  EnemyEgg(float x_, float y_, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, 100.0f, 100.0f, leftFacing, inputProcessor);
  }
  
  void create() {
    super.create();
    if (enemyEggSpritesheet == null) {
      enemyEggSpritesheet = loadSpriteSheet("./assets/enemy7.png", 5, 1, 250, 250);
    }
    wizardStandingAnimation = new Animation(enemyEggSpritesheet, 0.25, 0, 1);
    wizardCastPrepAnimation = wizardStandingAnimation;
    wizardCastingAnimation = wizardStandingAnimation;
    wizardHurtAnimation = wizardStandingAnimation;
    wizardWinAnimation = wizardStandingAnimation;
    wizardLoseAnimation = new Animation(enemyEggSpritesheet, 0.25, 4);
    wizardFadeAnimation = wizardStandingAnimation;
    wizardStunAnimation = wizardStandingAnimation;
    
    windSpell = new GustSpell();
    fireballSpell = new FireballSpell();
    rapidShotSpell = new RapidShotSpell();
    shieldSpell = new ShieldSpell();
    zapSpell = new ZappyOrbSpell();
    manaSuckSpell = new ManaSuckerSpell();
    piercerSpell = new PiercerSpell();
    meteorSpell = new MeteorShowerSpell();
    reflectorSpell = new ReflectorSpell();
    MANA_REGEN_RATE = 3.0f;
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (preFight || phased || stunned || winner || loser) {
      return;
    }
    
    
    if (eggMode) {
      //EGG MODE
      if (shieldTimer > 3.5) {
        shieldTimer = 0;
        boolean hasShield = false;
//        for (Entity entity : entities) {
//          if (entity.owner == player2 && entity instanceof Shield) {
//            hasShield = true;
//          }
//        }
        if (!hasShield && _mana > shieldSpell.getManaCost()) {
          shieldSpell.invoke(this);
          _mana -= shieldSpell.getManaCost();
        }
      }
      
      if (lastSpellTime > 6) {
        lastSpellTime = 0;
        if (piercerSpell.getManaCost < _mana) {
          piercerSpell.invoke(this);
          _mana -= piercerSpell.getManaCost();
        }
      }
      
      
    } else {
      //DINO MODE
      if (lastSpellTime > 2) {
        lastSpellTime = 0;
        meteorSpell.invoke(this);
        meteorSpell.invoke(this);
      }
    }
    
    
    shieldTimer += delta;
    lastSpellTime += delta;
  }
  
  void render() {
    super.render();
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void hurt(float damage) {
    super.hurt(damage);
    
    if (eggMode) {
      _health -= damage * 4;
    } else {
      _health -= damage * 2;
    }
    
    if (eggMode && _health < 0) {
      _health = _maxHealth;
      _mana = _maxMana;
      eggMode = false;
      wizardStandingAnimation = new Animation(enemyEggSpritesheet, 0.25, 2, 3);
    }
  }
  
  boolean eggMode = true;
  float shieldTimer = 0;
  float lastSpellTime = 0;
  FireballSpell fireballSpell;
  RapidShotSpell rapidShotSpell;
  ShieldSpell shieldSpell;
  GustSpell windSpell;
  ZappyOrbSpell zapSpell;
  ManaSuckerSpell manaSuckSpell;
  PiercerSpell piercerSpell;
  MeteorShowerSpell meteorSpell;
  ReflectorSpell reflectorSpell;
  
}

SpriteSheet enemyEggSpritesheet;
