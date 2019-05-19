class EnemyTutorial extends Wizard {
  
  int phase = 0;
  
  EnemyTutorial(float x_, float y_, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, 10000000.0f, 60.0f, leftFacing, inputProcessor);
  }
  
  void create() {
    super.create();
    if (enemyScarecrowSheet == null) {
      enemyScarecrowSheet = loadSpriteSheet("./assets/tutorial_boss.png", 4, 1, 250, 250);
    }
    if (tutorialTextSheet == null) {
      tutorialTextSheet = loadSpriteSheet("./assets/tutorial_text.png", 9, 1, 500, 250);
    }
    
    player1._mana = 0.0f;
    player1._health = 20.0f;
    
    wizardStandingAnimation = new Animation(enemyScarecrowSheet, 0.25, 0, 0);
    wizardCastPrepAnimation = wizardStandingAnimation;
    wizardCastingAnimation = wizardStandingAnimation;
    wizardHurtAnimation = wizardStandingAnimation;
    wizardWinAnimation = wizardStandingAnimation;
    wizardLoseAnimation = new Animation(enemyScarecrowSheet, 0.25, 1);
    wizardFadeAnimation = wizardStandingAnimation;
    wizardStunAnimation = wizardStandingAnimation;
    
    MANA_REGEN_RATE = 0.0f;
  }
  
  void update(int p, float delta) {
    super.update(p, delta);
    if (preFight || stunned || winner || loser) {
      return;
    }
    if (phase == 1) {
      for (Entity entity : entities) {
        if (entity instanceof ManaOrb) {
          removeEntity(entity);
        }
      }
    }
    if (phase == 2) {
      for (Entity entity : entities) {
        if (entity instanceof ManaOrb) {
          phase += 1;
        }
      }
    }
    if (phase == 3) {
      for (Entity entity : entities) {
        if (entity instanceof HealthOrb) {
          removeEntity(entity);
        }
      }
      if (player1._mana == player1._maxMana) {
        phase += 1;
      }
    }
    if (phase == 4) {
      for (Entity entity : entities) {
        if (entity instanceof HealthOrb) {
          phase += 1;
        }
        if (entity instanceof Fireball) {
          removeEntity(entity);
        }
      }
    }
    if (phase == 5) {
      for (Entity entity : entities) {
        if (entity instanceof Fireball) {
          phase += 1;
        }
        if (entity instanceof Reflector) {
          removeEntity(entity);
        }
      }
    }
    if (phase == 6) {
      for (Entity entity : entities) {
        if (entity instanceof Reflector) {
          phase += 1;
        }
      }
    }
    if (phase == 8) {
      _maxHealth = 100.0f;
      if (_health > _maxHealth) {
        _health = _maxHealth;
        player2HealthGradual = _health;
      }
    }
  }
  
  void render() {
    super.render();
    if (!preFight) {
      tutorialTextSheet.drawSprite(phase, x - 600, y - 300, 500, 250);
    }
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void hurt(float damage) {
    super.hurt(damage);
  }
  
}

SpriteSheet enemyScarecrowSheet;
SpriteSheet tutorialTextSheet;
