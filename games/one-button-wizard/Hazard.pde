class Hazard extends Collider {
  
  float damage;
  Wizard owner;
  boolean triggered = false;
  
  public Hazard(float x_, float y_, float radius_, float friction_, float damage_, Wizard owner_) {
    super(x_, y_, radius_, friction_);
    this.damage = damage_;
    this.owner = owner_;
  }
  
  void onCollision(Collider other, boolean wasHandled) {
    super.onCollision(other, wasHandled);
    if (other instanceof Wizard) {
      if ((Wizard) other != owner) {
        if(other instanceof EnemyMirror && velocityX > 1.5 * velocityY) {          
          owner = (Wizard) other;
          velocityX *= -1;
        } else {          
          ((Wizard) other).hurt(damage);
          triggered = true;
        }
      }
    }
    if (other instanceof Summon) {
      if (other.owner != owner) {
        other.hurt(damage);
        triggered = true;
      }
    }
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
    if (x < -200 || x > width + 200 || y < -200 || y > height + 200) {
      removeEntity(this);
    }
  }
  
  int depth() {
    return 0;
  }
  
}
