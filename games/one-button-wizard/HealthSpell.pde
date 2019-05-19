class HealthOrb extends Collider{
  Wizard owner;
  float distY = 200.0;
  float healthRegen = 0.5; //health regenerated per second
  float timer = 10.0;
  
  public HealthOrb(Wizard owner_) {
    super(owner_.x + 50, owner_.y - distY, 20, 0.0);
    this.velocityX = 25;
    this.velocityY = 15;
    owner = owner_;
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    healthOrbAnimation.update(delta);
    accelToPoint(owner.x, owner.y - distY);
    
    if (!owner.phased) {
      owner._health += healthRegen * delta;
    }
    if (owner._health > owner._maxHealth) {
      owner._health = owner._maxHealth;
    }
    timer -= delta;
    if (timer <= 0) {
      removeEntity(this);
    }
  }
  
  void create() {
    super.create();
    if (healthOrbSpritesheet == null) {
      healthOrbSpritesheet = loadSpriteSheet("./assets/healthOrb.png", 2, 1, 60, 60);
    }
    healthOrbAnimation = new Animation(healthOrbSpritesheet, 0.5, 0, 1);
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
    
    healthOrbAnimation.drawAnimation(xr, xy, size, size);
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

class HealthSpell extends Spell {
  int[] combination = new int[] {0};
 
  public HealthSpell() {
  }
  
  String name() {
    return "Health Orb";
  }
  
  void invoke(Wizard owner) {
    playSound("orb");
    HealthOrb healthOrb = new HealthOrb(owner);
    addEntity(healthOrb);
  }
  
  float getManaCost() {
    return 10.0f;
  }
  
  int[] getCombination() {
    return combination;
  }
  
  Animation healthOrbAnimation;
}

SpriteSheet healthOrbSpritesheet;
