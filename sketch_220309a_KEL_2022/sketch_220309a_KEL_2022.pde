// Keybinds
final int MOVE_LEFT = 0;
final int MOVE_RIGHT = 1;
final int MOVE_UP = 2;
final int MOVE_DOWN = 3;
final int BUTTON1 = 4;
final int BUTTON2 = 5;

// Screens
final int MENU_SCREEN = 0;
final int GAME_SCREEN = 1;
final int HELP_STORY = 2;
final int HELP_BALL = 3;
final int HELP_BOMB = 4;
final int HELP_SUPERGUN = 5;
final int CANT_LEAVE_YET = 6;
final int YOU_WIN = 7;
final int GAME_OVER = 8;

final String[] HELPTEXT = new String[] {
  "PLANTOID\n A TINY METROID CLONE\n Controls: LEFT/RIGHT move. Y shoot. X shoot missile",
  "A plant-based parasite has taken over the human colony\n You have been sent to destroy the center of the infestation,\n which lies within the planet's core\n Defeat the plant brain and make it out alive",
  "You have acquired the Morphball\n Press DOWN to curl up and enter pathways too narrow for your normal suit",
  "You have acquired the Bombs\n Press Y while curled up to place a bomb\n Bombs will explode in 4 seconds and destroy fragile blocks and enemies around them",
  "You have acquired the Supergun\n Your standard ammunition has increased in speed and overall effectiveness",
  "I can't leave yet.\n The plant infestation needs to be defeated",
  "Congratulations\n You have defeated the plantoids",
  "Game over\n The entire human species will be converted into\n plant-based zombies. Well done"
};

// Tiles
final int EMPTY=0;
final int BLUE_BLOCK=1;
final int GREEN_BLOCK=2;
final int FRAGILE_BLUE_BLOCK=3;
final int FRAGILE_GREEN_BLOCK=4;
final int INVISIBLE_BLOCK=5;

PImage imgBlueBlock;

PImage imgFragileBlueBlock;

PImage imgGreenBlock;

PImage imgFragileGreenBlock;

PImage imgPlayer;

PImage imgBatEnemy;

PImage imgPlayerZombie;

PImage imgPlantoidSmall;

PImage imgPlantoidBoss;

PImage imgPlantoidProjectile;

PImage imgMedipack;

PImage imgMissileBox;

PImage imgUpgrade;

PImage imgDoor;

PImage imgDoorReinforced;

PImage imgBomb;

PImage imgMiniboss;

boolean[] keys = new boolean[6];

int[][] world;

int screen=MENU_SCREEN;

Player player = new Player();

// Entities = Gegner, Upgrades und sonstige Gegenstände
ArrayList<Entity> entities = new ArrayList<Entity>();
ArrayList<Entity> entitiesToSpawn = new ArrayList<Entity>(); // Entities die im nächsten frame gespawnt werden sollen
ArrayList<Entity> entitiesToRemove = new ArrayList<Entity>(); // Entities die im nächsten Frame entfernt werden sollen (Tot oder unloaded)

// Projektile
ArrayList<Bullet> bullets = new ArrayList<Bullet>();

void setup() {
  size(800, 600);
  loadImages();
  loadLevel("levelentry.png");
  
  player.posX = 23*40;
  player.posY = 1*40;
}

void draw() {
  if(screen==MENU_SCREEN) {
    background(0, 128, 0);
    
    helpText(0);
    
    if(keys[BUTTON1]) {
      keys[BUTTON1] = false;
      screen=HELP_STORY;
    }
  }
  if(screen>=HELP_STORY && screen<=CANT_LEAVE_YET) {
    background(0, 0, 128);
    
    helpText(screen-1);
    
    if(keys[BUTTON1]) {
      keys[BUTTON1] = false;
      screen=GAME_SCREEN;
    }
  }
  if(screen==YOU_WIN) {
    background(0, 128, 0);
    
    helpText(6);
  }
  if(screen==GAME_OVER) {
    background(128, 0, 0);
    
    helpText(7);
  }
  if(screen==GAME_SCREEN) {
    background(0);
    
    pushMatrix();
    
    // Kamera mit dem Spieler mit bewegen
    translate(-player.posX+width/2, -player.posY+height/2);
    
    // Wenn der Spieler den Boss besiegt hat Erdbeben simulieren
    if(player.hasDefeatedBoss) {
      translate(0, random(-3, 3));
      
      // und Projektile von unten hineinfeuern
      if(int(random(100)) < 10) {
        entitiesToSpawn.add(new EntityPlantoidProjectile(random(40, world.length*40-40), world[0].length*40-40, -PI/2));
      }
    }
    
    // Die Tile-Map zeichnen (Unbewegliches Zeug, Blöcke, Wände etc.)
    // Zeug außerhalb der Welt und außerhalb des Sichtfelds wird weggelassen
    int startX = max(0, int(player.posX/40) - width/80);
    int startY = max(0, int(player.posY/40) - height/80);
    int endX = min(startX + width/40 + 1, world.length);
    int endY = min(startY + height/40 + 1, world[0].length);
    
    pushMatrix();
    scale(40, 40);
    for(int x=startX; x<endX; x++) {
      for(int y=startY; y<endY; y++) {
        if(world[x][y]==BLUE_BLOCK) {
          image(imgBlueBlock, x, y, 1, 1);
          
        } else if(world[x][y]==FRAGILE_BLUE_BLOCK) {
          image(imgFragileBlueBlock, x, y, 1, 1);
          
        } else if(world[x][y]==GREEN_BLOCK) {
          image(imgGreenBlock, x, y, 1, 1);
          
        } else if(world[x][y]==FRAGILE_GREEN_BLOCK) {
          image(imgFragileGreenBlock, x, y, 1, 1);
          
        }
      }
    }
    popMatrix();
    
    /*fill(255);
    rect(player.posX, player.posY, player.sizeX, player.sizeY);*/
    
    player.behavior();
      
    // Projektile behandeln
    ArrayList<Bullet> bulletsToRemove = new ArrayList<Bullet>();
    
    for(Bullet bullet : bullets) {
      bullet.fly();
      
      if(bullet.life <= 0) {
        bulletsToRemove.add(bullet);
      }
    }
    
    bullets.removeAll(bulletsToRemove);
    
    
    
    // Neue Entities spawnen
    entities.addAll(entitiesToSpawn);
    entitiesToSpawn.clear();
    
    // Entities behandeln
    for(Entity entity : entities) {
        
      entity.behavior();
      
      // Kollision mit Spieler
      if(entity.collideBox(player)) {
        
        entity.collision();
      }
      
      // Entity entfernen wenn sie stirbt
      if(entity.health <= 0) {
        
        entity.killed();
        entitiesToRemove.add(entity);
      }
    }
    
    // Entities entfernen
    entities.removeAll(entitiesToRemove);
    entitiesToRemove.clear();
    
    popMatrix();
    
    // Game Over behandeln
    if(player.health <= 0) {
      screen = GAME_OVER;
    }
    
    // Lebensanzeige
    barGraph(float(player.health)/player.maxHealth, color(255,0,0), 20, 20, 100, 20);
    //textAlign(LEFT, TOP);
    //text("LIFE: " + playerHealth + "/100", 125, 20);
    
    // Energieanzeige
    barGraph(float(player.energy)/player.maxEnergy, color(0,0,255), 20, 50, 60, 20);
    //textAlign(LEFT, TOP);
    //text("ENERGY: " + playerEnergy + "/20", 125, 50);
    
    // Verbleibende Raketen
    fill(255);
    textSize(24);
    textAlign(LEFT, TOP);
    text(player.missiles, 130, 20);
  }
}

void keyPressed() {
  if(keyCode==LEFT) {
    keys[MOVE_LEFT] = true;
    
  } else if(keyCode==RIGHT) {
    keys[MOVE_RIGHT] = true;
    
  } else if(keyCode==UP) {
    keys[MOVE_UP] = true;
    
  } else if(keyCode==DOWN) {
    keys[MOVE_DOWN] = true;
    
  } else if(key=='y') {
    keys[BUTTON1] = true;
    
  } else if(key=='x') {
    keys[BUTTON2] = true;
  }
}

void keyReleased() {
  if(keyCode==LEFT) {
    keys[MOVE_LEFT] = false;
    
  } else if(keyCode==RIGHT) {
    keys[MOVE_RIGHT] = false;
    
  } else if(keyCode==UP) {
    keys[MOVE_UP] = false;
    
  } else if(keyCode==DOWN) {
    keys[MOVE_DOWN] = false;
    
  } else if(key=='y') {
    keys[BUTTON1] = false;
    
  } else if(key=='x') {
    keys[BUTTON2] = false;
  }
}

void loadImages() {
  
  imgBlueBlock = loadImage("blue_block.png");
  imgFragileBlueBlock = loadImage("fragile_blue_block.png");
  imgGreenBlock = loadImage("green_block.png");
  imgFragileGreenBlock = loadImage("green_block.png"); // Zerstörbare Blöcke genauso aussehen lassen wie normale. Secret-Durchgang
  imgPlayer = loadImage("player.png");
  imgBatEnemy = loadImage("bat_enemy.png");
  imgPlayerZombie = loadImage("player_zombie.png");
  imgPlantoidSmall = loadImage("plantoid_small.png");
  imgPlantoidBoss = loadImage("plantoid_boss.png");
  imgPlantoidProjectile = loadImage("plantoid_projectile.png");
  imgMedipack = loadImage("medipack.png");
  imgMissileBox = loadImage("missile_box.png");
  imgUpgrade = loadImage("upgrade.png");
  imgDoor = loadImage("door.png");
  imgDoorReinforced = loadImage("door_reinforced.png");
  imgBomb = loadImage("bomb.png");
  imgMiniboss = loadImage("miniboss.png");
}

void loadLevel(String fileName) {
  entitiesToRemove.addAll(entities);
  
  PImage image = loadImage(fileName);
  image.loadPixels();
  
  world = new int[image.width][image.height];
  
  EntityLoadingZone[] loadingZones = new EntityLoadingZone[5];
  int lzi=0;
  
  for(int x=0; x<image.width; x++) {
    for(int y=0; y<image.height; y++) {
      switch(image.pixels[x+y*image.width]) {
      case #000000: // -> Leerer Block
        world[x][y] = EMPTY; break;
      case #0000FF: // -> Blauer Block (Wandblock für die Startzone)
        world[x][y] = BLUE_BLOCK; break;
      case #00007F: // -> Zerstörbarer Blauer Block
        world[x][y] = FRAGILE_BLUE_BLOCK; break;
      case #00FF00: // -> Grüner Block (Wandblock für die Bosszone)
        world[x][y] = GREEN_BLOCK; break;
      case #007F00: // -> Zerstörbarer Grüner Block
        world[x][y] = FRAGILE_GREEN_BLOCK; break;
      case #FFFFFF: // -> Loading-Zone
        world[x][y] = EMPTY;
        EntityLoadingZone elz = new EntityLoadingZone(x*40, y*40);
        entitiesToSpawn.add(elz);
        loadingZones[lzi++] = elz; break;
      case #7F7F7F: // -> Normaler Gegner
        world[x][y] = EMPTY;
        entitiesToSpawn.add(new EntityBasicEnemy(x*40, y*40)); break;
      case #7F7FFF: // -> Fliegender Gegner
        world[x][y] = EMPTY;
        entitiesToSpawn.add(new EntityFlyingEnemy(x*40, y*40)); break;
      case #7F0000: // -> Miniboss
        world[x][y] = EMPTY;
        entitiesToSpawn.add(new EntityMiniboss(x*40, y*40)); break;
      case #FF00FF: // -> Pflanze
        world[x][y] = EMPTY;
        entitiesToSpawn.add(new EntitySmallPlantoid(x*40, y*40)); break;
      case #7F007F: // -> Pflanzen-Boss
        world[x][y] = EMPTY;
        entitiesToSpawn.add(new EntityBossPlantoid(x*40, y*40)); break;
      case #FF0000: // -> Kugel-Upgrade
        world[x][y] = EMPTY;
        entitiesToSpawn.add(new EntityUpgrade(x*40, y*40, BALL)); break;
      case #FF7F00: // -> Bomben-Update
        world[x][y] = EMPTY;
        entitiesToSpawn.add(new EntityUpgrade(x*40, y*40, BOMB)); break;
      case #00FFFF: // -> SuperGun-Upgrade
        world[x][y] = EMPTY;
        entitiesToSpawn.add(new EntityUpgrade(x*40, y*40, SUPERGUN)); break;
      case #007F7F: // -> Normale Tür
        world[x][y] = INVISIBLE_BLOCK;
        world[x][y+1] = INVISIBLE_BLOCK;
        entitiesToSpawn.add(new EntityDoor(x*40, y*40, false)); break;
      case #7F7F00: // -> Tür für Raketen
        world[x][y] = INVISIBLE_BLOCK;
        world[x][y+1] = INVISIBLE_BLOCK;
        entitiesToSpawn.add(new EntityDoor(x*40, y*40, true)); break;
      default:
        println("Unbekannte Farbe in Level: Bei " + x + "/" + y);
      }
    }
  }
  
  // Für jede Leveldatei die Loading-Zones richtig verbinden
  if(fileName.equals("levelentry.png")) {
    loadingZones[0].isEscape=true;
    loadingZones[1].initTo("levelshortcut.png", 6*40, 7*40);
    loadingZones[2].initTo("levelshortcut.png", 6*40, 7*40);
    loadingZones[3].initTo("levelhall.png", 2*40, 5*40);
  } else if(fileName.equals("levelhall.png")) {
    loadingZones[0].initTo("levelentry.png", 61*40, 12*40);
    loadingZones[1].initTo("levelshortcut.png", 29*40, 16*40);
    loadingZones[2].initTo("levelboss.png", 61*40, 11*40);
    loadingZones[3].initTo("levelroom1.png", 2*40, 12*40);
    loadingZones[4].initTo("levelroom2.png", 2*40, 12*40);
  } else if(fileName.equals("levelroom1.png")) {
    loadingZones[0].initTo("levelhall.png", 13*40, 5*40);
  } else if(fileName.equals("levelroom2.png")) {
    loadingZones[0].initTo("levelhall.png", 13*40, 29*40);
    loadingZones[1].initTo("levelsecret.png", 10*40, 1*40);
    loadingZones[2].initTo("levelsecret.png", 10*40, 1*40);
  } else if(fileName.equals("levelboss.png")) {
    loadingZones[0].initTo("levelhall.png", 2*40, 29*40);
  } else if(fileName.equals("levelshortcut.png")) {
    loadingZones[0].initTo("levelentry.png", 6*40, 12*40);
    loadingZones[1].initTo("levelentry.png", 6*40, 12*40);
    loadingZones[2].initTo("levelhall.png", 2*40, 17*40);
  }
}

void helpText(int id) {
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(20);
  text(HELPTEXT[id], width/2, height/2);
}

void barGraph(float val, color col, float x, float y, float w, float h) {
  pushStyle();
  stroke(255);
  strokeWeight(2);
  fill(0);
  rect(x, y, w, h);
  fill(col);
  rect(x, y, w*val, h);
  popStyle();
}
