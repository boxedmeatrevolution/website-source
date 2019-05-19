class Poof extends Moving {
  
  float timer = 0.0;
  float lifetime = 0.25f;
  float size;
  
  Poof(float x_, float y_) {
    super(x_, y_, 0.0f);
    size = 128;
  }
  
  Poof(float x_, float y_, float size_) {
    super(x_, y_, 0.0f);
    size = size_;
  }
  
  void create() {
    super.create();
    if (poofSpriteSheet == null) {
      poofSpriteSheet = loadSpriteSheet("./assets/poof_strip.png", 3, 1, 128, 128);
    }
    animation = new Animation(poofSpriteSheet, 0.05, 0, 1, 2);
    playSound("poof");
  }
  
  void destroy() {
    super.destroy();
  }
  
  void render() {
    super.render();
    animation.drawAnimation(x - size / 2, y - size / 2, size, size);
  }
  
  void update(int phase, float delta) {
    super.update(phase, delta);
    timer += delta;
    if (timer > lifetime) {
      removeEntity(this);
    }
    animation.update(delta);
  }
  
  Animation animation;
  
}

SpriteSheet poofSpriteSheet;
