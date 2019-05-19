class EnemyEyeball extends Wizard {
  int timer = 0;
  
  int comboChain;
  int rechargeOrbs;
  
  EnemyEyeball(float x_, float y_, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, 50.0f, 50.0f, leftFacing, inputProcessor);
    comboChain = 0;
    rechargeOrbs = 0;
  }
  
  void create() {
    super.create();
    if (eyeballSpritesheet == null) {
      eyeballSpritesheet = loadSpriteSheet("./assets/enemy0.png", 3, 1, 250, 250);
    }
    wizardStandingAnimation = new Animation(eyeballSpritesheet, 0.25, 0, 1);
    wizardCastPrepAnimation = wizardStandingAnimation;
    wizardCastingAnimation = wizardStandingAnimation;
    wizardHurtAnimation = wizardStandingAnimation;
    wizardWinAnimation = wizardStandingAnimation;
    wizardLoseAnimation = new Animation(eyeballSpritesheet, 0.25, 2);
    wizardFadeAnimation = wizardStandingAnimation;
    wizardStunAnimation = wizardStandingAnimation;
    
    shieldSpell = new ShieldSpell();
    fireballSpell = new FireballSpell();
    manaSpell = new ManaSpell();
    gustSpell = new GustSpell();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (preFight || phased || stunned || winner || loser) {
      return;
    }
    timer += delta;
    if (timer > 1.0) {
      timer = 0;
      if (spellBook.size() > 0) {
        boolean spellInvoked = false;
        if(comboChain == 0) {
          if (_mana > fireballSpell.getManaCost()) {
            fireballSpell.invoke(this);
            _mana -= fireballSpell.getManaCost();
            spellInvoked = true;
            comboChain = 1;
          }
        } else if (comboChain == 1) {
          if (_mana > gustSpell.getManaCost()) {
            gustSpell.invoke(this);
            _mana -= gustSpell.getManaCost();
            spellInvoked = true;
            comboChain = 2;
          }
        } else if (comboChain != -1){
          if (_mana > shieldSpell.getManaCost()) {
            shieldSpell.invoke(this);
            _mana -= shieldSpell.getManaCost();
            spellInvoked = true;
            comboChain = 0;
          }
        }
        if(!spellInvoked) {
          comboChain = -1;
          manaSpell.invoke(this);
          rechargeOrbs++;
          
          if(rechargeOrbs > 6) {
            rechargeOrbs = 0;
            comboChain = 0;
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
  
  ShieldSpell shieldSpell;
  ManaSpell manaSpell;
  GustSpell gustSpell;
  FireballSpell fireballSpell;
  
}

SpriteSheet eyeballSpritesheet;
