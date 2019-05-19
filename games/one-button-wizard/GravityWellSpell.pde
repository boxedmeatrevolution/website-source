class GravityWell extends Collider {
  
  float timer = 0.0;
  float lifetime = 5.0;
  
  public GravityWell(float x_, float y_, float velocityX_, float velocityY_) {
    super(x_, y_, 32.0, 20.0);
    velocityX = velocityX_;
    velocityY = velocityY_;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    removeEntity(other);
  }
  
  void create() {
    super.create();
    if (gravityWellSpritesheet == null) {
      gravityWellSpritesheet = loadSpriteSheet("./assets/gravityWell.png", 2, 1, 150, 150);
    }
    gravityWellAnimation = new Animation(gravityWellSpritesheet, 0.25, 0, 1);
    //playSound("summonBlackHole");
    playSound("blackHole");
  }
  
  void destroy() {
    super.destroy();
    addEntity(new Poof(x, y));
  }
  
  void render() {
    super.render();    
    float xr = x - 75;
    float xy = y - 75;
    float size = 150;
    
    gravityWellAnimation.drawAnimation(xr, xy, size, size);
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    gravityWellAnimation.update(delta);
    timer += delta;
    if (timer > lifetime) {
      removeEntity(this);
    }
    for (Entity entity : entities) {
      if (entity instanceof HealthOrb || entity instanceof ManaOrb) {
        dist = sq(entity.x - x) + sq(entity.y - y);
        mag = pow(dist, 1.5);
        if (dist != 0) {
          entity.velocityX -= delta * 200000000.0 * (entity.x - x) / mag;
          entity.velocityY -= delta * 200000000.0 * (entity.y - y) / mag;
        }
      }
    }
  }
  
  int depth() {
    return 0;
  }
  
  Animation gravityWellAnimation;
}

class GravityWellSpell extends Spell {
  
  int[] combination = new int[] { 1, 0, 1 };
  
  public GravityWellSpell() {
  }
  
  public String name() {
    return "Black Hole";
  }
  
  public void invoke(Wizard owner) {
    playSound("gravityWell");
    GravityWell well = new GravityWell(width / 2, height / 2, 0, 0);
    if (owner.x < width / 2) {
      well.x -= 200;
    }
    else {
      well.x += 200;
    }
    addEntity(well);
    addEntity(new Poof(well.x, well.y));
  }
  
  public float getManaCost() {
    return 10.0f;
  }
  
  public int[] getCombination() {
    return combination;
  }
}

SpriteSheet gravityWellSpritesheet;
