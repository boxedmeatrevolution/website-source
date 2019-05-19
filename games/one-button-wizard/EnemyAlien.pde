class EnemyAlien extends Wizard {
  
  EnemyAlien(float x_, float y_, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, 100.0f, 100.0f, leftFacing, inputProcessor);
  }
  
  void create() {
    super.create();
    if (enemyAlienSpritesheet == null) {
      enemyAlienSpritesheet = loadSpriteSheet("./assets/enemy4.png", 3, 1, 250, 250);
    }
    wizardStandingAnimation = new Animation(enemyAlienSpritesheet, 0.25, 0, 1);
    wizardCastPrepAnimation = wizardStandingAnimation;
    wizardCastingAnimation = wizardStandingAnimation;
    wizardHurtAnimation = wizardStandingAnimation;
    wizardWinAnimation = wizardStandingAnimation;
    wizardLoseAnimation = new Animation(enemyAlienSpritesheet, 0.25, 2);
    wizardFadeAnimation = wizardStandingAnimation;
    wizardStunAnimation = wizardStandingAnimation;
    
    fireballSpell = new FireballSpell();
    rapidShotSpell = new RapidShotSpell();
    shieldSpell = new ShieldSpell();
    MANA_REGEN_RATE = 3.0f;
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (preFight || phased || stunned || winner || loser) {
      return;
    }
    
    if (lastSpellTime > 6.5) {
      lastSpellTime = 0;
      int d6 = floor(random(7));
      
      if (d6 == 1 || d6 == 2 || d6 == 3) {
        if (fireballSpell.getManaCost() < this._mana) {
          fireballSpell.invoke(this);
          this._mana -= fireballSpell.getManaCost();
        }
      } else if (d6 == 4) {
        if (rapidShotSpell.getManaCost() < this._mana) {
          rapidShotSpell.invoke(this);
          this._mana -= rapidShotSpell.getManaCost();
        }
      }
    }
    
    if (shieldTimer > 3) {
      shieldTimer = 0;
      for (Entity entity : entities) {
        if (entity instanceof Fireball || entity instanceof RapidShot) {
          if (entity.velocityX > 0) {
            if (random(1) > 0.75 && shieldSpell.getManaCost() < this._mana) {
              shieldSpell.invoke(this);
              this._mana -= shieldSpell.getManaCost();
              break;
            }
          }
        }
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
  }
  
  
  float shieldTimer = 3;
  float lastSpellTime = 3;
  FireballSpell fireballSpell;
  RapidShotSpell rapidShotSpell;
  ShieldSpell shieldSpell;
}

SpriteSheet enemyAlienSpritesheet;
