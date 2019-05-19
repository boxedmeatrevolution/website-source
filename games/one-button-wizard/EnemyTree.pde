class EnemyTree extends Wizard {
  
  EnemyTree(float x_, float y_, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, 100.0f, 100.0f, leftFacing, inputProcessor);
  }
  
  void create() {
    super.create();
    if (enemyTreeSpritesheet == null) {
      enemyTreeSpritesheet = loadSpriteSheet("./assets/enemy5.png", 3, 1, 250, 250);
    }
    wizardStandingAnimation = new Animation(enemyTreeSpritesheet, 0.25, 0, 1);
    wizardCastPrepAnimation = wizardStandingAnimation;
    wizardCastingAnimation = wizardStandingAnimation;
    wizardHurtAnimation = wizardStandingAnimation;
    wizardWinAnimation = wizardStandingAnimation;
    wizardLoseAnimation = new Animation(enemyTreeSpritesheet, 0.25, 2);
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
    
    if (lastSpellTime > 7 && _health / _maxHealth >= 0.2) {
      lastSpellTime = 0;
      int d10 = floor(random(10));
      
      if (d10 == 0 || d10 == 1 || d10 == 2 || d10 == 8) {
        boolean hasSuck = false;
        for (Entity entity : entities) {
          if (entity.owner == player2 && entity instanceof ManaSucker) {
            hasSuck = true;
            break;
          }
        }
        if (!hasSuck && manaSuckSpell.getManaCost() < this._mana) {
          manaSuckSpell.invoke(this);
          this._mana -= manaSuckSpell.getManaCost();
        } else if (hasSuck && fireballSpell.getManaCost() < this._mana) {
//          fireballSpell.invoke(this);
//          this._mana -= fireballSpell.getManaCost();
        }
      }else if (d10 == 3 || d10 == 4 || d10 == 5 || d10 == 7) {
        boolean hasZap = false;
        for (Entity entity : entities) {
          if (entity.owner == player2 && entity instanceof ZappyOrb) {
            hasZap = true;
            break;
          }
        }
        if (!hasZap && zapSpell.getManaCost() < this._mana) {
          zapSpell.invoke(this);
          this._mana -= zapSpell.getManaCost();
        } else if (zapSpell && piercerSpell.getManaCost() < this._mana) {
          piercerSpell.invoke(this);
          this._mana -= piercerSpell.getManaCost();
        }
      } 
    }
    
    if (_health / _maxHealth < 0.2 && lastSpellTime > 4) {
      lastSpellTime = 0;
      if (rapidShotSpell.getManaCost() < this._mana) {
        rapidShotSpell.invoke(this);
        this._mana -= rapidShotSpell.getManaCost();
      }
    } 
    
    if (shieldTimer > 5) {
      shieldTimer = 0;
      for (Entity entity : entities) {
        if (entity instanceof Fireball || entity instanceof HighFireball || entity instanceof MeteorShower) {
          if (entity.owner == player1) {
            if (random(1) > 0.6) {
              
              int d3 = floor(random(3));
              
              if (d3 == 0) {
                if (reflectorSpell.getManaCost() < this._mana) {
                  reflectorSpell.invoke(this);
                  this._mana -= reflectorSpell.getManaCost();
                }
              } else if (d3 == 1) {
                if (shieldSpell.getManaCost() < this._mana) {
                  shieldSpell.invoke(this);
                  this.mana -= shieldSpell.getManaCost();
                }
              } else if (d3 == 2) {
                if (windSpell.getManaCost() < this._mana) {
                  windSpell.invoke(this);
                  this.mana -= windSpell.getManaCost();
                }
              }                
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
  
  
  float shieldTimer = 5;
  float lastSpellTime = 3;
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

SpriteSheet enemyTreeSpritesheet;
