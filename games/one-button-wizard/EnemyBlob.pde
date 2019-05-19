class EnemyBlob extends Wizard {
  
  EnemyBlob(float x_, float y_, boolean leftFacing, InputProcessor inputProcessor) {
    super(x_, y_, 100.0f, 100.0f, leftFacing, inputProcessor);
    copiedSpells = new ArrayList<Spell>();
  }
  
  float spellTimer = 0.0f;
  
  void create() {
    super.create();
    if (enemyBlobSpritesheet == null) {
      enemyBlobSpritesheet = loadSpriteSheet("./assets/enemy6.png", 3, 1, 250, 250);
    }
    wizardStandingAnimation = new Animation(enemyBlobSpritesheet, 0.25, 0, 1);
    wizardCastPrepAnimation = wizardStandingAnimation;
    wizardCastingAnimation = wizardStandingAnimation;
    wizardHurtAnimation = wizardStandingAnimation;
    wizardWinAnimation = wizardStandingAnimation;
    wizardLoseAnimation = new Animation(enemyBlobSpritesheet, 0.25, 2);
    wizardFadeAnimation = wizardStandingAnimation;
    wizardStunAnimation = wizardStandingAnimation;
    
    MANA_REGEN_RATE = 5.0f;
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    if (preFight || phased || stunned || winner || loser) {
      return;
    }
    
    if (!copiedSpells.contains(player1.lastSpell) && player1.lastSpell != null) {
      copiedSpells.add(player1.lastSpell);
      if (copiedSpells > 3) {
        copiedSpells.remove(0);
      }
    }
    
    spellTimer += delta;
    if (spellTimer >= 3.0f && copiedSpells.size() > 0) {
      Spell spell = copiedSpells.get(int(random(copiedSpells.size())));
      if (_mana > spell.getManaCost()) {
        spell.invoke(this);
        _mana -= spell.getManaCost();
      }
      spellTimer = 0.0f;
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
  
  ArrayList<Spell> copiedSpells;
  
}

SpriteSheet enemyBlobSpritesheet;
