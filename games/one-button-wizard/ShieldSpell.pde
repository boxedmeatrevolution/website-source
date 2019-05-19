class Shield extends Hazard {
  
  float lifetime = 3.0;
  float initialRadius = 132.0;
  float finalRadius = 160.0;
  float timer = 0.0;
  
  public Shield(float x_, float y_, float velocityX_, float velocityY_, Wizard owner) {
    super(x_, y_, initialRadius, 20.0, 10.0, owner);
    velocityX = velocityX_;
    velocityY = velocityY_;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (other instanceof Hazard) {
      if (other.owner != owner) {
        removeEntity(other);
      }
    }
  }
  
  void create() {
    super.create();
    if (shieldSpritesheet == null) {
      shieldSpritesheet = loadSpriteSheet("./assets/shield.png", 4, 1, 400, 400);
    }
    shieldAnimation = new Animation(shieldSpritesheet, 0.2, 0, 1, 2, 3);
  }
  
  void destroy() {
    super.destroy();
    addEntity(new Poof(x, y, 192, 192));
  }
  
  void render() {
    super.render();
    if (owner.x < 500) {    
      shieldAnimation.drawAnimation(x - 200, y - 250 , 400, 400);
    } else {
      scale(-1, 1);
      shieldAnimation.drawAnimation(- (x + 200), y - 250, 400, 400);
      scale(-1, 1);
    }
//    fill(255, 255, 0);
//    ellipse(x, y, 2 * radius, 2 * radius);
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    shieldAnimation.update(delta);
    timer += delta;
    if (timer > lifetime) {
      playSound("shieldDeactivate");
      removeEntity(this);
    }
    radius = (finalRadius - initialRadius) * timer / lifetime + initialRadius;
  }
  
  int depth() {
    return 0;
  }
  
}

class ShieldSpell extends Spell {
  
  int[] combination = new int[] { 0, 0 };
  
  public ShieldSpell() {
  }
  
  public String name() {
    return "Bubble Shield";
  }
  
  public void invoke(Wizard owner) {
    for (Entity entity : entities) {
      if (entity instanceof Reflector || entity instanceof Shield) {
        if (entity.owner == owner) {
          removeEntity(entity);
        }
      }
    }
    playSound("shield");
    Shield shield = new Shield(owner.x, owner.y, 0, 0, owner);
    addEntity(shield);
  }
  
  public float getManaCost() {
    return 10.0f;
  }
  
  public int[] getCombination() {
    return combination;
  }
  
  Animation shieldAnimation;
}
SpriteSheet shieldSpritesheet;
