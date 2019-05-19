int TOTAL_SHOTS = 10;

class RapidShot extends Hazard {
  
  float ACCELX = 800;
  
  boolean _leftFacing;
  
  public RapidShot(float x_, float y_, float velocityX_, float velocityY_, Wizard owner) {
    super(x_, y_, 20.0, 0.0, 1.0, owner);
    this.damage = 12.0f/TOTAL_SHOTS;
    this.velocityX = velocityX_;
    this.velocityY = velocityY_;
    ACCELX = (owner._leftFacing ? -ACCELX : ACCELX);
    _leftFacing = owner._leftFacing;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (triggered) {
      removeEntity(this);
    }
  }
  
  void create() {
    super.create();
    if (rapidShotSpritesheet == null) {
      rapidShotSpritesheet = loadSpriteSheet("./assets/blueFireball.png", 4, 1, 150, 150);
    }
    rapidShotAnimation = new Animation(rapidShotSpritesheet, 0.05, 0, 1, 2, 3);
    playSound("rapidFire");
  }
  
  void destroy() {
    super.destroy();
    addEntity(new Poof(x, y, 64, 64));
  }
  
  void render() {
    super.render();
    float xr = x - 25;
    float xy = y - 25;
    float size = 50;
    
    if(_leftFacing) {
      scale(-1, 1);
      xr = -((x - 25) + 50);
    }
    
    rapidShotAnimation.drawAnimation(xr, xy, size, size);
     
    if (_leftFacing) {
      scale(-1, 1);
    }    
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    rapidShotAnimation.update(delta);
    velocityX += delta * ACCELX;
  }
  
  int depth() {
    return 0;
  }
  
  Animation rapidShotAnimation;
}

class RapidShooter extends Entity {
  
  int shotCount;
  float timer;
  Wizard owner;
  
  public RapidShooter(Wizard _owner) {
    shotCount = 0;
    timer = 0;
    owner = _owner;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void create() {
    super.create();
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    timer += delta;
    if(timer > 0.25) {
      //playSound("miniFireball");
      RapidShot rapidShot = new RapidShot(owner.x, owner.y + 50 - 100 * random(1), 500, 0, owner);
      if (owner.x < width / 2) {
        rapidShot.x += 10;
      }
      else {
        rapidShot.x -= 10;
        rapidShot.velocityX *= -1;
      }
      timer = 0;
      shotCount ++;
      addEntity(rapidShot);
    }
    if(shotCount >= TOTAL_SHOTS) {
      removeEntity(this);
    }
  }
  
  int depth() {
    return 0;
  }
  
}

class RapidShotSpell extends Spell {
  
  int[] combination = new int[] { 0, 1, 0 };
  
  public RapidShotSpell() {
  }
  
  public String name() {
    return "Rapid Shot";
  }
  
  public void invoke(Wizard owner) {
    addEntity(new RapidShooter(owner));
  }
  
  public float getManaCost() {
    return 10.0f;
  }
  
  public int[] getCombination() {
    return combination;
  }
}

SpriteSheet rapidShotSpritesheet;
