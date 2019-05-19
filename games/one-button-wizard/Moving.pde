class Moving extends Entity {
  
  Moving(float x_, float y_, float friction_) {
    x = x_;
    y = y_;
    friction = friction_;
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
    if (phase == 0) {
      velocityX += accelX * delta;
      velocityY += accelY * delta;
      x += velocityX * delta;
      y += velocityY * delta;
      velocity = sqrt(velocityX * velocityX + velocityY * velocityY);
      if (velocity > friction * delta) {
        velocityX -= velocityX / velocity * friction * delta;
        velocityY -= velocityY / velocity * friction * delta;
      }
      else {
        velocityX = 0;
        velocityY = 0;
      }
    }
  }
  
  float friction;
  float x;
  float y;
  float velocityX;
  float velocityY;
  float accelX = 0;
  float accelY = 0;
  
}
