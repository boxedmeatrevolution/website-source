class ZappyOrb extends Summon {
  
  float lifetime = 15.0;
  float timer = 0.0;
  int shotsFired = -5;
  float timePerShot = 2.0;
  Wizard target = null;
  Wizard owner;
  
  ZappyOrb(float x_, float y_, Wizard owner_) {
    super(x_, y_, 32.0f, 0.0f, 1.0f);
    
    if (zappySpritesheet == null) {
      zappySpritesheet = loadSpriteSheet("./assets/zapper.png", 3, 1, 200, 200);
    }
    zappyAnimation = new Animation(zappySpritesheet, 0.2, 0, 1, 2);
    
    owner = owner_;
    for (Entity entity : entities) {
      if (entity instanceof Wizard) {
        if (entity != owner_) {
          target = entity;
        }
      }
    }
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (other instanceof ZappyOrb) {
      if (other.timer > this.timer) {
        removeEntity(other);
      }
      else {
        removeEntity(this);
      }
    }
  }
  
  void create() {
    super.create();
    addEntity(new Poof(x, y));
  }
  
  void destroy() {
    super.destroy();
    addEntity(new Poof(x, y));
  }
  
  void render() {
    super.render();
    if (owner.x < 500) {    
      zappyAnimation.drawAnimation(x - 100, y - 100, 200, 200);
    } else {
      scale(-1, 1);
      zappyAnimation.drawAnimation(- (x + 100), y - 100, 200, 200);
      scale(-1, 1);
    }
    
//    fill(255, 255, 0);
//    ellipse(x, y, 2 * radius, 2 * radius);
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    zappyAnimation.update(delta);
    timer += delta;
    if (timer > lifetime) {
      removeEntity(this);
    }
    if (timer > (shotsFired + 1) * timePerShot && target != null) {
      if (shotsFired > 0) {
        velocityX_ = -(x - target.x) / 3;
        velocityY_ = -(y - target.y) / 3;
        int xoffset = 40;
        if (owner.x > width/2){
          xoffset *= -1;
        }
        shot = new ZappyShot(x + xoffset, y + 30, velocityX_, velocityY_, owner);
        addEntity(shot);
      }
      shotsFired += 1;
    }
  }
  
  int depth() {
    return 0;
  }
  
  Animation zappyAnimation;
}

class ZappyOrbSpell extends Spell {
  
  int[] combination = new int[] { 0, 1, 1 };
  
  public ZappyOrbSpell() {
  }
  
  public String name() {
    return "Summon Electric Orb";
  }
  
  public void invoke(Wizard owner) {
    float _x = 200.0f;
    if (owner.x > width / 2) {
      _x = 800;
    }
    addEntity(new ZappyOrb(_x, 210.0f, owner));
  }
  
  public float getManaCost() {
    return 10.0f;
  }
  
  public int[] getCombination() {
    return combination;
  }
  
}

class ZappyShot extends Hazard {
  
  public ZappyShot(float x_, float y_, float velocityX_, float velocityY_, Wizard owner) {
    super(x_, y_, 20.0, 0.0, 1.0, owner);
    this.damage = 3.0f;
    this.velocityX = velocityX_;
    this.velocityY = velocityY_;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (triggered) {
      removeEntity(this);
    }
  }
  
  void create() {
    super.create();
    if (zappyShotSpritesheet == null) {
      zappyShotSpritesheet = loadSpriteSheet("./assets/zap.png", 2, 1, 50, 50);
    }
    zappyShotAnimation = new Animation(zappyShotSpritesheet, 0.02, 0, 1);
    playSound("zappyShoot");
  }
  
  void destroy() {
    super.destroy();
    addEntity(new Poof(x, y));
  }
  
  void render() {
    super.render();
    float xr = x - 25;
    float xy = y - 25;
    float size = 50;
    
    if(velocityX < 0) {
      scale(-1, 1);
      xr = -((x - size/2) + size);
    }
    
    zappyShotAnimation.drawAnimation(xr, xy, size, size);
     
    if (velocityX < 0) {
      scale(-1, 1);
    }    
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    zappyShotAnimation.update(delta);
  }
  
  int depth() {
    return 0;
  }
  
  Animation zappyShotAnimation;
  
}

SpriteSheet zappyShotSpritesheet;
SpriteSheet zappySpritesheet;
