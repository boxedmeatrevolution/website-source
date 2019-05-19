
class SpriteSheet {
  
  PImage[] sprites;
  
  SpriteSheet (PImage[] _sprites) {
    sprites = _sprites;
  }
  
  void drawSprite (int index, float xPos, float yPos, float xRad, float yRad) {
    image(sprites[index], xPos, yPos, xRad, yRad);
  }
}

// A class for automaticaly animating 
class Animation {
  SpriteSheet sheet;
  int[] sprites;
  float time;
  
  int curr;
  float timeElapsed;
  
  boolean loop = true;
  
  Animation (SpriteSheet _sheet, float _time, int... _sprites) {
    sheet = _sheet;
    time = _time;
    sprites = _sprites;
    timeElapsed = 0;
    curr = 0;
  }
  
  //Draws and updates the animation.
  void drawAnimation (float xPos, float yPos, float xRad, float yRad) {
    sheet.drawSprite(sprites[curr], xPos, yPos, xRad, yRad);
  }
  
  void update(float delta) {
    timeElapsed += delta;
    // Only move to the next frame when enough time has passed
    if (timeElapsed >= time) {
      curr++;
      if (loop) {
        curr %= sprites.length;
      }
      else {
        if (curr >= sprites.length) {
          curr = sprites.length - 1;
        }
      }
      timeElapsed = 0.0f;
    }
  }
  
  void reset () {
    curr = 0;
  }
}

/* Loads a SpriteSheet from image at filename with x columns of sprites and y rows of sprites. */
SpriteSheet loadSpriteSheet (String filename, int x, int y, int w, int h) {
  PImage img = loadImage(filename);
  
  PImage[] sprites = new PImage[x*y];
  
  int xSize = w;
  int ySize = h;
  
  int a = 0;
  for (int j = 0; j < y; j++) {
    for (int i = 0; i < x; i++) {
      sprites[a] = img.get(i*xSize,j*ySize, xSize, ySize);
      a++;
    }
  }
  return new SpriteSheet(sprites);
}
