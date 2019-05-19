class Collider extends Moving {
  
  Collider(float x_, float y_, float radius_, float friction_) {
    super(x_, y_, friction_);
    radius = radius_;
  }
  
  void onCollision(Collider other, boolean wasHandled) {}
  
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
  }
  
  int depth() {
    return 0;
  }
  
  boolean collides(Collider other) {
    float deltaX = x - other.x;
    float deltaY = y - other.y;
    float distanceSqr = deltaX * deltaX + deltaY * deltaY;
    float totalRadius = radius + other.radius;
    return distanceSqr <= totalRadius * totalRadius;
  }
  
  boolean intersects(float pointX, float pointY) {
    float deltaX = pointX - x;
    float deltaY = pointY - y;
    float distanceSqr = deltaX * deltaX + deltaY * deltaY;
    return distanceSqr <= radius * radius;
  }
  
  float radius;
}
