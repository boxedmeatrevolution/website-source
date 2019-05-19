class Fireball extends Hazard {
  
  float ACCELX = 50;
  
  public Fireball(float x_, float y_, float velocityX_, float velocityY_, Wizard owner) {
    super(x_, y_, 42.0, 0.0, 1.0, owner);
    this.damage = 9.0f;
    this.velocityX = velocityX_;
    this.velocityY = velocityY_;
    ACCELX = (owner._leftFacing ? -ACCELX : ACCELX);
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (triggered) {
      removeEntity(this);
    }
  }
  
  void create() {
    super.create();
    if (fireballSpritesheet == null) {
      fireballSpritesheet = loadSpriteSheet("./assets/blueFireball.png", 4, 1, 150, 150);
    }
    playSound("fireball");
    fireballAnimation = new Animation(fireballSpritesheet, 0.05, 0, 1, 2, 3);
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
    
    if(velocityX < 0) {
      scale(-1, 1);
      xr = -((x - 75) + 150);
    }
    
    fireballAnimation.drawAnimation(xr, xy, size, size);
     
    if (velocityX < 0) {
      scale(-1, 1);
    }
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    fireballAnimation.update(delta);
    velocityX += delta * ACCELX;
  }
  
  int depth() {
    return 0;
  }
  
  Animation fireballAnimation;
}

class FireballSpell extends Spell {
  
  int[] combination = new int[] { 0, 0, 0 };
  
  public FireballSpell() {
  }
  
  public String name() {
    return "Fireball";
  }
  
  public void invoke(Wizard owner) {
    Fireball fireball = new Fireball(owner.x, owner.y, 100, 0, owner);
    if (owner.x < width / 2) {
      fireball.x += 10;
    }
    else {
      fireball.x -= 10;
      fireball.velocityX *= -1;
    }
    addEntity(fireball);
  }
  
  public float getManaCost() {
    return 10.0f;
  }
  
  public int[] getCombination() {
    return combination;
  }
}

SpriteSheet fireballSpritesheet;
