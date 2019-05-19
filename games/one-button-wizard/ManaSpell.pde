class ManaOrb extends Collider{
  Wizard owner;
  float distY = 150.0;
  float manaRegen = 2.0; //mana regenerated per second
  float timer = 8.0;
  
  public ManaOrb(Wizard owner_) {
    super(owner_.x + 50, owner_.y - distY, 20, 0.0);
    this.velocityX = 25;
    this.velocityY = 15;
    owner = owner_;
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    manaOrbAnimation.update(delta);
    accelToPoint(owner.x, owner.y - distY);
    
    if (!owner.phased) {
      owner._mana += manaRegen * delta;
    }
    if (owner._mana > owner._maxMana) {
      owner._mana = owner._maxMana;
    }
    timer -= delta;
    if (timer <= 0) {
      removeEntity(this);
    }
  }
  
  void create() {
    super.create();
    if (manaOrbSpritesheet == null) {
      manaOrbSpritesheet = loadSpriteSheet("./assets/manaOrb.png", 2, 1, 60, 60);
    }
    manaOrbAnimation = new Animation(manaOrbSpritesheet, 0.5, 0, 1);
  }
  
  void destroy() {
    super.destroy();
    addEntity(new Poof(x, y, 64));
  }
  
  void render() {
    super.render();
    float xr = x - 30;
    float xy = y - 30;
    float size = 60;
    
    manaOrbAnimation.drawAnimation(xr, xy, size, size);
  }
  
  void accelToPoint(float px, float py) {
    float mag = sqrt(sq(this.x - px) + sq(this.y - py));
    if (mag == 0) {
      return;
    }
    float dirX = (px - this.x) / mag;
    float dirY = (py - this.y) / mag;
    this.accelX = dirX * 500;
    this.accelY = dirY * 500;
  }
} 

class ManaSpell extends Spell {
  int[] combination = new int[] { 1 };
 
  public ManaSpell() {
    super();
  }
  
  String name() {
    return "Mana Orb";
  }
  
  void invoke(Wizard owner) {
    playSound("orb");
    ManaOrb manaOrb = new ManaOrb(owner);
    addEntity(manaOrb);
  }
  
  float getManaCost() {
    return 0.0f;
  }
  
  int[] getCombination() {
    return combination;
  }
  
  Animation manaOrbAnimation;
}

SpriteSheet manaOrbSpritesheet;
