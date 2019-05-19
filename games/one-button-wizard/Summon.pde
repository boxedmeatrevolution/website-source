class Summon extends Collider {
  
  float health;
  
  Summon(float x_, float y_, float radius_, float friction_, float health_) {
    super(x_, y_, radius_, friction_);
    health = health_;
  }
  
  public void hurt(float damage) {
    health -= damage;
    if (health < 0) {
      removeEntity(this);
    }
  }
}
