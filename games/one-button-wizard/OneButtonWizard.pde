/* @pjs preload="./assets/enemy7.png, ./assets/mirror.png, ./assets/tutorial_boss.png, ./assets/tutorial_text.png, ./assets/poof_strip.png, ./assets/enemy0.png, ./assets/enemy1.png, ./assets/enemy2.png, ./assets/enemy3.png, ./assets/enemy4.png, ./assets/enemy5.png, ./assets/enemy6.png, ./assets/menu_background.png, ./assets/character_spritesheet.png, ./assets/ui.png, ./assets/reflector.png, ./assets/lose_text.png, ./assets/win_text.png, ./assets/p1wins_text.png, ./assets/p2wins_text.png, ./assets/background0.png, ./assets/background1.png, ./assets/background2.png, ./assets/mana_suck.png, ./assets/mana_steal.png, ./assets/zapper.png, ./assets/zap.png, ./assets/shield.png, ./assets/desert_background.png, ./assets/blueFireball.png, ./assets/meteor.png, ./assets/gravityWell.png, ./assets/healthOrb.png, ./assets/manaOrb.png, ./assets/spinningFireball.png, ./assets/piercer.png, ./assets/wind.png, ./assets/spellOrb.png, ./assets/123go.png; */

class Entity {
  // Called when the entity is added to the game
  void create() {}
  // Called when the entity is removed from the game
  void destroy() {}
  // Called whenever the entity is to be rendered
  void render() {}
  // Called when the entity is to be updated
  void update(int phase, float delta) {}
  // The order in the render and update list of the entity
  int depth() {
    return 0;
  }
  boolean exists = false;
}

PImage userInterface;
PImage loseText;
PImage winText;
PImage p1WinsText;
PImage p2WinsText;
PImage menuBackground;
PImage[] backgrounds;

ArrayList<InputProcessor> inputProcessors = new ArrayList<InputProcessor>();

int MENU_STATE = 0, GAME_START_STATE = 1, IN_GAME_STATE = 2, GAME_OVER_STATE = 3;

ArrayList<Entity> entities = new ArrayList<Entity>();
ArrayList<Entity> entitiesToBeAdded = new ArrayList<Entity>();
ArrayList<Entity> entitiesToBeRemoved = new ArrayList<Entity>();
ArrayList<Collider> colliders = new ArrayList<Collider>();

int firstUpdatePhase = 0;
int lastUpdatePhase = 0;

int lastUpdate = millis();
float timeDelta;

SpriteSheet spellOrbSpritesheet;
SpriteSheet readySetGoSpritesheet;

Animation dotOrbAnimation;
Animation dashOrbAnimation;

void addEntity(Entity entity) {
  entitiesToBeAdded.add(entity);
}

void removeEntity(Entity entity) {
  entitiesToBeRemoved.add(entity);
}

void sortEntities() {
  for (int i = 1; i < entities.size(); ++i) {
    Entity x = entities.get(i);
    int j = i;
    while (j > 0 && entities.get(j - 1).depth() < x.depth()) {
      entities.set(j, entities.get(j - 1));
      j -= 1;
    }
    entities.set(j, x);
  }
}

Wizard player1;
Wizard player2;

float player1HealthGradual;
float player2HealthGradual;
float player1ManaGradual;
float player2ManaGradual;

int STATE_PRE_DUEL = -1, STATE_DUEL = 0, STATE_POST_DUEL = 1, STATE_MAIN_MENU = 2, STATE_PRE_FIGHT = 3, STATE_FIGHT = 4, STATE_POST_FIGHT_LOSE = 5, STATE_POST_FIGHT_WIN = 6;

int state = STATE_MAIN_MENU;

void cleanState() {
  entities.clear();
  entitiesToBeAdded.clear();
  entitiesToBeRemoved.clear();
  colliders.clear();
  inputProcessors.clear();
}

Wizard getFight(int n) {
  if (n == 0) {
    return new EnemyTutorial(width - 100, 500, true, new InputProcessor('.'));
  }
  n -= 1;
  switch(n % 9) {
    case 0:
    return new EnemyAlien(width - 100, 500, true, new InputProcessor('.'));
    case 1:
    return new EnemyTree(width -100, 500, true, new InputProcessor('.'));
    case 2:
    return new EnemyBlob(width - 100, 500, true, new InputProcessor('.'));
    case 3:
    return new EnemyEgg(width - 100, 500, true, new InputProcessor('.'));
    case 4:
    return new EnemyEyeball(width - 100, 500, true, new InputProcessor('.'));
    case 5:
    return new EnemyMirror(width - 100, 500, true, new InputProcessor('.'));
    case 6:
    return new EnemySquid(width - 100, 500, true, new InputProcessor('.'));
    case 7:
    return new EnemyWizard(width - 100, 500, true, new InputProcessor('.'));
    case 8:
    return new EnemyFly(width - 100, 500, true, new InputProcessor('.'));
  }
}

int currentFight = 0;

float timer = 10.0f;

void gotoMainMenuState() {
  state = STATE_MAIN_MENU;
  lastBackground = backgroundImage;
  while (backgroundImage == lastBackground) {
    backgroundImage = backgrounds[int(random(backgrounds.length))];
  }
}

void gotoPreDuelState() {
  
  readyStage = 0;
  
  state = STATE_PRE_DUEL;
  
  lastBackground = backgroundImage;
  while (backgroundImage == lastBackground) {
    backgroundImage = backgrounds[int(random(backgrounds.length))];
  }
  
  InputProcessor input1 = new InputProcessor('z');
  InputProcessor input2 = new InputProcessor('m');
  
  inputProcessors.add(input1);
  inputProcessors.add(input2);
  
  player1 = new Wizard(100, 500, 50, 100, false, inputProcessors.get(0));
  player2 = new Wizard(width - 100, 500, 50, 100, true, inputProcessors.get(1));
  
  player1HealthGradual = player1._maxHealth;
  player2HealthGradual = player2._maxHealth;
  player1ManaGradual = player1._maxMana;
  player2ManaGradual = player2._maxMana;
  
  addEntity(player1);
  addEntity(player2);
  
  timer = 3.0f;
}

void gotoDuelState() {
  state = STATE_DUEL;
  
  player1._inputProcessor.reset();
  player2._inputProcessor.reset();
  
  player1.preFight = false;
  player2.preFight = false;
}

void gotoPostDuelState() {
  state = STATE_POST_DUEL;
  
  player1.loser = player1._health < 0;
  player1.winner = !player1.loser;
  
  player2.loser = player2._health < 0;
  player2.winner = !player2.loser;
  
  timer = 3.0f;
}

void gotoPreFightState() {
  
  readyStage = 0;
  
  state = STATE_PRE_FIGHT;
  
  lastBackground = backgroundImage;
  while (backgroundImage == lastBackground) {
    backgroundImage = backgrounds[int(random(backgrounds.length))];
  }
  
  InputProcessor input1 = new InputProcessor('z');
  
  inputProcessors.add(input1);
  
  player1 = new Wizard(100, 500, 50, 100, false, inputProcessors.get(0));
  player2 = getFight(currentFight);
  
  player1HealthGradual = player1._maxHealth;
  player2HealthGradual = player2._maxHealth;
  player1ManaGradual = player1._maxMana;
  player2ManaGradual = player2._maxMana;
  
  addEntity(player1);
  addEntity(player2);
  
  timer = 3.0f;
}

void gotoFightState() {
  state = STATE_FIGHT;
  player1._inputProcessor.reset();
  
  player1.preFight = false;
  player2.preFight = false;
}

void gotoPostFightWinState() {
  state = STATE_POST_FIGHT_WIN;
  player1.winner = true;
  player1.loser = false;
  player2.winner = false;
  player2.loser = true;
  timer = 3.0f;
}

void gotoPostFightLoseState() {
  state = STATE_POST_FIGHT_LOSE;
  player1.winner = false;
  player1.loser = true;
  player2.winner = true;
  player2.loser = false;
  timer = 3.0f;
}

PImage backgroundImage, lastBackground;

void setup () {  
  size(1000, 680);
  
  spellOrbSpritesheet = loadSpriteSheet("./assets/spellOrb.png", 2, 2, 64, 64);  
  dotOrbAnimation = new Animation(spellOrbSpritesheet, 0.25, 2, 3);
  dashOrbAnimation = new Animation(spellOrbSpritesheet, 0.25, 0, 1);
  
  readySetGoSpritesheet = loadSpriteSheet("./assets/123go.png", 4, 1, 300, 300);  
  
  userInterface = loadImage("./assets/ui.png");
  backgrounds = new PImage[] {
    loadImage("./assets/background0.png"),
    loadImage("./assets/background1.png"),
    loadImage("./assets/background2.png") };
    
  backgroundImage = backgrounds[int(random(backgrounds.length))];
  menuBackground = loadImage("./assets/menu_background.png");
  
  loseText = loadImage("./assets/lose_text.png");
  winText = loadImage("./assets/win_text.png");
  p1WinsText = loadImage("./assets/p1wins_text.png");
  p2WinsText = loadImage("./assets/p2wins_text.png");
  
  loadAudio("fireball", "./assets/music/fireball2.wav");
  loadAudio("gravityWell", "./assets/music/gravityWellSFX.ogg");
  loadAudio("meteor", "./assets/music/meteorSFX.ogg");
  loadAudio("miniFireball", "./assets/music/miniFireballSFX.ogg");
  loadAudio("reflector", "./assets/music/reflectorSFX.ogg");
  loadAudio("shieldBreaker", "./assets/music/shieldBreakerSFX.ogg");
  loadAudio("shieldDeactivate", "./assets/music/shieldBreakerSFX.ogg");
  loadAudio("shield", "./assets/music/shieldSFX.ogg");
  loadAudio("hit", "./assets/music/hit.ogg");
  loadAudio("orb", "./assets/music/orb.ogg");
  loadAudio("stun", "./assets/music/stun.ogg");
  loadAudio("phase", "./assets/music/phase.ogg");
  loadAudio("music", "./assets/music/ld34.ogg");
  loadAudio("invoke", "./assets/music/invoke.wav");
  loadAudio("dot_orb", "./assets/music/dot_orb.wav");
  loadAudio("meteor", "./assets/music/meteor.wav");
  loadAudio("summonBlackHole", "./assets/music/summon_black_hole.wav");
  loadAudio("blackHole", "./assets/music/black_hole.wav");
  loadAudio("poof", "./assets/music/poof.wav");
  loadAudio("manaSteal0", "./assets/music/mana_steal_0.wav");
  loadAudio("manaSteal1", "./assets/music/mana_steal.wav");
  loadAudio("zappyShoot", "./assets/music/zappy_shoot.wav");
  loadAudio("piercer", "./assets/music/piercer.wav");
  loadAudio("rapidFire", "./assets/music/rapid_fire.wav");
  sounds["music"].loop = true;
  //sounds["music"].play();
  
  gotoMainMenuState();
}

float clamp(float min, float value, float max) {
  if (value < min) {
    return min;
  }
  else if (value > max) {
    return max;
  }
  else {
    return value;
  }
}

int readyStage = 0;

void draw () {
  
  if (audioFilesLoaded != nAudioFiles) {
    text("Loading", 64, 64);
  }
  
  if (state != STATE_MAIN_MENU) {
    image(backgroundImage, 0, 0);
  }
  else {
    image(menuBackground, 0, 0);
  }
  
  int now = millis();
  timeDelta = (now - lastUpdate) / 1000.0f;
  lastUpdate = now;

  dotOrbAnimation.update(timeDelta);
  dashOrbAnimation.update(timeDelta);

  for(InputProcessor ip : inputProcessors) {     
    ip.update(timeDelta);
  }
  
  for (Entity entity : entitiesToBeAdded) {
    entities.add(entity);
    if (entity instanceof Collider) {
      colliders.add(entity);
    }
    entity.exists = true;
    entity.create();
  }
  entitiesToBeAdded.clear();
  // Remove entities in the remove queue
  for (Entity entity : entitiesToBeRemoved) {
    entities.remove(entity);
    if (entity instanceof Collider) {
      colliders.remove(entity);
    }
    entity.exists = false;
    entity.destroy();
  }
  entitiesToBeRemoved.clear();
  // Entities are sorted by depth
  sortEntities();
  for (int updatePhase = firstUpdatePhase; updatePhase <= lastUpdatePhase; ++updatePhase) {
    // Update every entity
    for (Entity entity : entities) {
      entity.update(updatePhase, timeDelta);
    }
    // Find and handle collisions
    if (updatePhase == 0) {
      for (int i = 0; i < colliders.size() - 1; ++i) {
        Collider first = colliders.get(i);
        for (int j = i + 1; j < colliders.size(); ++j) {
          Collider second = colliders.get(j);
          if (first.collides(second)) {
            first.onCollision(second, false);
            second.onCollision(first, true);
          }
        }
      }
    }
  }
  // Render every entity
  for (Entity entity : entities) {
    entity.render();
  }
  
  timer -= timeDelta;
  
  if (timer < 0.0f) {
    if (state == STATE_PRE_DUEL) {
      gotoDuelState();
    }
    else if (state == STATE_POST_DUEL) {
      cleanState();
      gotoMainMenuState();
    }
    else if (state == STATE_PRE_FIGHT) {
      gotoFightState();
    }
    else if (state == STATE_POST_FIGHT_WIN) {
      cleanState();
      currentFight += 1;
      gotoPreFightState();
    }
    else if (state == STATE_POST_FIGHT_LOSE) {
      cleanState();
      gotoMainMenuState();
    }
  }
  
  if (state == STATE_MAIN_MENU) {
  }
  else if ((state == STATE_PRE_DUEL || state == STATE_PRE_FIGHT) && !(player2 instanceof EnemyTutorial)) {
    if (timer >= 2.25) {
      //text("3", 50, 50);
      if (readyStage == 0) {
        readyStage = 1;
        playSound("dot_orb");
      }
      readySetGoSpritesheet.drawSprite(0, width / 2 - 150, height / 2 - 150, 300, 300);
    }
    else if (timer >= 1.5) {
      //text("2", 50, 50);
      if (readyStage == 1) {
        readyStage = 2;
        playSound("dot_orb");
      }
      readySetGoSpritesheet.drawSprite(1, width / 2 - 150, height / 2 - 150, 300, 300);
    }
    else if (timer >= 0.75) {
      //text("1", 50, 50);
      if (readyStage == 2) {
        readyStage = 3;
        playSound("dot_orb");
      }
      readySetGoSpritesheet.drawSprite(2, width / 2 - 150, height / 2 - 150, 300, 300);
    }
    else {
      //text("Fight!", 50, 50);
      if (readyStage == 3) {
        readyStage = 4;
        playSound("dot_orb");
      }
      readySetGoSpritesheet.drawSprite(3, width / 2 - 150, height / 2 - 150, 300, 300);
    }
  }
  else if (state == STATE_POST_FIGHT_LOSE) {
    image(loseText, (width - loseText.width) / 2, (height - loseText.height) / 2);
  }
  else if (state == STATE_POST_FIGHT_WIN) {
    image(winText, (width - winText.width) / 2, (height - winText.height) / 2);
  }
  else if (state == STATE_POST_DUEL) {
    if (player1.winner) {
      image(p1WinsText, (width - p1WinsText.width) / 2, (height - p1WinsText.height) / 2);
    }
    else if (player2.winner) {
      image(p2WinsText, (width - p2WinsText.width) / 2, (height - p2WinsText.height) / 2);
    }
    else {
      
    }
  }
  /*
  draw the ui
  */
  if (state == STATE_DUEL || state == STATE_FIGHT || state == STATE_PRE_DUEL || state == STATE_PRE_FIGHT || state == STATE_POST_DUEL || state == STATE_POST_FIGHT_WIN || state == STATE_POST_FIGHT_LOSE) {
    
    noStroke();
    
    float player1HealthPercent;
    float player1ManaPercent;
    float player2HealthPercent;
    float player2ManaPercent;
    
    if (player1HealthGradual > player1._health) {
      player1HealthGradual -= 10 * timeDelta;
    }
    if (player1HealthGradual < player1._health) {
      player1HealthGradual = player1._health;
    }
    
    if (player2HealthGradual > player2._health) {
      player2HealthGradual -= 10 * timeDelta;
    }
    if (player2HealthGradual < player2._health) {
      player2HealthGradual = player2._health;
    }
    
    if (player1ManaGradual > player1._mana) {
      player1ManaGradual -= 10 * timeDelta;
    }
    if (player1ManaGradual < player1._mana) {
      player1ManaGradual = player1._mana;
    }
    
    if (player2ManaGradual > player2._mana) {
      player2ManaGradual -= 10 * timeDelta;
    }
    if (player2ManaGradual < player2._mana) {
      player2ManaGradual = player2._mana;
    }
    
    if ((state == STATE_PRE_FIGHT || state == STATE_PRE_DUEL) && !(player2 instanceof EnemyTutorial)) {
      player1HealthPercent = player1ManaPercent = player2HealthPercent = player2ManaPercent = 1.0f - timer / 3.0f;
      player1HealthGradualPercent = player1ManaGradualPercent = player2HealthGradualPercent = player2ManaGradualPercent = 0.0f;
    }
    else {
      player1HealthPercent = clamp(0.0f, player1._health / player1._maxHealth, 1.0f);
      player1ManaPercent = clamp(0.0f, player1._mana / player1._maxMana, 1.0f);
      player2HealthPercent = clamp(0.0f, player2._health / player2._maxHealth, 1.0f);
      player2ManaPercent = clamp(0.0f, player2._mana / player2._maxMana, 1.0f);
      
      player1HealthGradualPercent = clamp(0.0f, player1HealthGradual / player1._maxHealth, 1.0f);
      player1ManaGradualPercent = clamp(0.0f, player1ManaGradual / player1._maxMana, 1.0f);
      player2HealthGradualPercent = clamp(0.0f, player2HealthGradual / player2._maxHealth, 1.0f);
      player2ManaGradualPercent = clamp(0.0f, player2ManaGradual / player2._maxMana, 1.0f);
    }
    
    fill(100, 100, 100);
    rect(0, 0, width, 4 + 64 + 32 + 4);
    
    fill(220, 120, 40);
    rect(32 + 4, 4, (width / 2 - 32 - 4 - 4) * player1HealthGradualPercent, 64);
    rect(width / 2 + 4, 4, (width / 2 - 32 - 4 - 4) * player2HealthGradualPercent, 64);
    
    fill(40, 160, 220);
    rect(32 + 4, 4 + 64, (width / 2 - 32 - 4 - 4) * player1ManaGradualPercent, 32);
    rect(width / 2 + 4, 4 + 64, (width / 2 - 32 - 4 - 4) * player2ManaGradualPercent, 32);
    
    fill(220, 40, 40);
    rect(32 + 4, 4, (width / 2 - 32 - 4 - 4) * player1HealthPercent, 64);
    rect(width / 2 + 4, 4, (width / 2 - 32 - 4 - 4) * player2HealthPercent, 64);
    
    fill(70, 40, 220);
    rect(32 + 4, 4 + 64, (width / 2 - 32 - 4 - 4) * player1ManaPercent, 32);
    rect(width / 2 + 4, 4 + 64, (width / 2 - 32 - 4 - 4) * player2ManaPercent, 32);
    
    image(userInterface, 0, 0);
    
    ArrayList<Integer> player1Word = new ArrayList<Integer>(player1._inputProcessor.getCurrentWord());
    ArrayList<Integer> player2Word = new ArrayList<Integer>(player2._inputProcessor.getCurrentWord());
    
    int currentX = 40;
    if (player1._inputProcessor._inputState == player1._inputProcessor.WAITING_FOR_KEY_UP || player1._inputProcessor._inputState == player1._inputProcessor.WAITING_FOR_KEY_DOWN) {
      if (player1._inputProcessor._inputState == player1._inputProcessor.WAITING_FOR_KEY_UP) {
        if (player1._inputProcessor._stateTimer <= player1._inputProcessor.DOT_TIME) {
          player1Word.add(0);
        }
        else if (player1._inputProcessor._stateTimer <= player1._inputProcessor.DASH_TIME) {
          player1Word.add(1);
        }
      }
      for (Integer letter : player1Word) {
        float x = currentX, y = height - 70;
        float size = 64;
        if (letter == 0) {
          fill(0, 255, 0);
          dotOrbAnimation.drawAnimation(x - size / 2, y - size / 2, size, size);
        }
        else if (letter == 1) {
          fill(255, 0, 0);
          dashOrbAnimation.drawAnimation(x - size / 2, y - size / 2, size, size);
        }
        currentX += 80;
      }
    }
    
    if (player2._inputProcessor._inputState == player2._inputProcessor.WAITING_FOR_KEY_UP || player2._inputProcessor._inputState == player2._inputProcessor.WAITING_FOR_KEY_DOWN) {
      if (player2._inputProcessor._inputState == player2._inputProcessor.WAITING_FOR_KEY_UP) {
        if (player2._inputProcessor._stateTimer <= player2._inputProcessor.DOT_TIME) {
          player2Word.add(0);
        }
        else if (player2._inputProcessor._stateTimer <= player2._inputProcessor.DASH_TIME) {
          player2Word.add(1);
        }
      }
      currentX = width - 40 - (player2Word.size() - 1) * 80;
      for (Integer letter : player2Word) {
        float x = currentX, y = height - 70;
        float size = 64;
        if (letter == 0) {
          fill(0, 255, 0);
          dotOrbAnimation.drawAnimation(x - size / 2, y - size / 2, size, size);
        }
        else if (letter == 1) {
          fill(255, 0, 0);
          dashOrbAnimation.drawAnimation(x - size / 2, y - size / 2, size, size);
        }
        currentX += 80;
      }
      
    }
    
    if (state == STATE_DUEL) {
      if (player1._health < 0 || player2._health < 0) {
        gotoPostDuelState();
      }
    }
    else if (state == STATE_FIGHT) {
      if (player1._health < 0) {
        gotoPostFightLoseState();
      }
      else if (player2._health < 0) {
        gotoPostFightWinState();
      }
    }
  
  }
  
}

void keyPressed() {
  if (state == STATE_DUEL || state == STATE_FIGHT) {
    for(InputProcessor ip : inputProcessors) {     
      ip.keyPressed();
    }
    if (key == 'q' && state == STATE_FIGHT) {
      player2._health = -10;
    }
  }
  if (state == STATE_MAIN_MENU) {
    if (key == 'm') {
      playSound("hit");
      cleanState();
      gotoPreDuelState();
    }
    else if (key == 'z') {
      playSound("hit");
      cleanState();
      gotoPreFightState();
    }
  }
}

void keyReleased() {
  if (state == STATE_DUEL || state == STATE_FIGHT) {
    for(InputProcessor ip : inputProcessors) {     
      ip.keyReleased();
    }
    if (key == 'm') {
      if (player2 instanceof EnemyTutorial) {
        if (player2.phase <= 1 || player2.phase >= 7) {
          playSound("hit");
          player2.phase += 1;
          if (player2.phase > 8) {
            player2.phase = 8;
          }
        }
      }
    }
  }
}

void mousePressed() {
}

void mouseReleased() {
}

void mouseDragged() {
}
