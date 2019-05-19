class GustSpell extends Spell {
  
  int[] combination = new int[] { 0, 1 };
  
  public GustSpell() {
  }
  
  public String name() {
    return "Gust";
  }
  
  public void invoke(Wizard owner) {    
    addEntity(new Gust(owner));
  }
  
  public float getManaCost() {
    return 10.0f;
  }
  
  public int[] getCombination() {
    return combination;
  }
}

class Gust extends Entity {
    
  float GUST_ACCEL = 3;
  int TOTAL_PARTICLES = 8;
  
  int particleCount;
  float timer;
  Wizard _owner;
  
  public Gust(Wizard owner) {
    particleCount = 0;
    timer = 0;
    _owner = owner;
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
    
    for(Entity entity : entities) {
      if(entity instanceof GravityWell || entity instanceof Shield || entity instanceof HealthOrb || entity instanceof ManaOrb || entity instanceof Reflector ) {
        continue;
      }
      if(entity instanceof Hazard) {
        Hazard hazard = (Hazard) entity;
        float factor = 0.0f;
        if (_owner.x >= width / 2) {
          factor = 1.0f;
        }
        else {
          factor = -1.0f;
        }
        if (hazard.velocityX > 10.0) {
          hazard.velocityX *= 1.0 - factor * GUST_ACCEL * delta;
        }
        else if (hazard.velocityX < -10.0) {
          hazard.velocityX *= 1.0 + factor * GUST_ACCEL * delta;
        }
        else {
          hazard.velocityX -= 200 * factor * delta;
        }
      }
    }
    
    timer += delta;
    if(timer > 0.25) {
      timer = 0;
      particleCount ++;      
      if(!_owner._leftFacing) {
        addEntity(new GustParticle(_owner.x + ((width - 240) / TOTAL_PARTICLES)*particleCount, height * random(1), _owner._leftFacing)); 
      } else {
        addEntity(new GustParticle(_owner.x - ((width - 240) / TOTAL_PARTICLES)*particleCount, height * random(1), _owner._leftFacing)); 
      }  
    }
    if(particleCount >= TOTAL_PARTICLES) {
      removeEntity(this);
    }
  }
  
  int depth() {
    return 0;
  }
  
}

class GustParticle extends Moving {
  
  float LIFETIME = 0.75;
  
  float timer;
  boolean leftFacing;
  
  public GustParticle(float x_, float y_, boolean leftFacing_) {
    super(x_, y_, 0);
    leftFacing = leftFacing_;
    timer = 0;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
  }
  
  void create() {
    super.create();
    if (windSpritesheet == null) {
      windSpritesheet = loadSpriteSheet("./assets/wind.png", 4, 1, 240, 240);
    }
    windAnimation = new Animation(windSpritesheet, LIFETIME/4, 0, 1, 2, 3);
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
    float size = 240;
    
    pushMatrix();
    translate(x, y);
    
    if(leftFacing) {
      scale(-1, 1);
    }
    windAnimation.drawAnimation(-size/2, -size/2, size, size);
     
    popMatrix();
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    windAnimation.update(delta);
    timer += delta;
    
    if(timer > LIFETIME) {
      removeEntity(this);
    }
  }
  
  int depth() {
    return 0;
  }
  
  Animation windAnimation;
}

SpriteSheet windSpritesheet;
