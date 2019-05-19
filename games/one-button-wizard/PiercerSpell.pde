class Piercer extends Hazard {
  
  float ACCELY = 500;
  
  public Piercer(float x_, float y_, float velocityX_, float velocityY_, Wizard owner) {
    super(x_, y_, 20.0, 0.0, 1.0, owner);
    this.damage = 1.0f;
    this.velocityX = velocityX_;
    this.velocityY = velocityY_;
    _leftFacing = owner._leftFacing;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (other instanceof Shield) {
      playSound("shieldBreaker");
      removeEntity(other);
      other.owner.stunned = true;
      other.owner.stunTimer = 1.5f;
    }
    if (triggered) {
      removeEntity(this);
    }
  }
  
  void create() {
    super.create();
    if (piercerSpritesheet == null) {
      piercerSpritesheet = loadSpriteSheet("./assets/piercer.png", 4, 1, 120, 120);
    }
    playSound("piercer");
    piercerAnimation = new Animation(piercerSpritesheet, 0.3, 0, 1);
  }
  
  void destroy() {
    super.destroy();
    addEntity(new Poof(x, y));
  }
  
  void render() {
    super.render();
    float size = 120;
    
    pushMatrix();
    translate(x, y);
    
    rotate(atan(velocityY/velocityX));
    if(velocityX < 0) {
      scale(-1, 1);
    }
    piercerAnimation.drawAnimation(-size/2, -size/2, size, size);
     
    popMatrix();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    piercerAnimation.update(delta);
    velocityY += delta * ACCELY;
  }
  
  int depth() {
    return 0;
  }
  
  Animation piercerAnimation;
}

SpriteSheet piercerSpritesheet;

class PiercerSpell extends Spell {
  
  int[] combination = new int[] { 1, 0, 0 };
  
  public PiercerSpell() {
  }
  
  public String name() {
    return "Piercing Bolt";
  }
  
  public void invoke(Wizard owner) {
    Piercer piercerA = new Piercer(owner.x, owner.y, 350, -600, owner);
    Piercer piercerB = new Piercer(owner.x, owner.y, 600, -300, owner);
    if (owner.x < width / 2) {
      
    }
    else {
      piercerA.velocityX *= -1;
      piercerB.velocityX *= -1;
    }
    addEntity(piercerA);
    addEntity(piercerB);
  }
  
  public float getManaCost() {
    return 10.0f;
  }
  
  public int[] getCombination() {
    return combination;
  }
}
