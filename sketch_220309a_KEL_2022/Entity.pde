
final int MEDIPACK_CHANCE=20;
final int MISSILE_CHANCE=10;

class Entity extends AABB {
  
  public int health=MAX_INT;
  public boolean isEnemy=false;
  public boolean isReinforced=false; // Reinforced-Gegner können nur mit Raketen angegriffen werden
  
  public void behavior() {}
  public void collision() {} // Wenn die Entity mit dem Spieler kollidiert
  public void killed() {}
  
}

class EntityBasicEnemy extends Entity {
  
  public float speed=2.6;
  
  public boolean flipped=true;
  
  public EntityBasicEnemy(int x, int y) {
    posX = x;
    posY = y;
    sizeX = 40;
    sizeY = 80;
    health = 14;
    isEnemy= true;
  }
  
  public void behavior() {
    
    pushMatrix();
    translate(posX, posY);
    if(flipped) {
      translate(sizeX, 0);
      scale(-1, 1);
    }
    image(imgPlayerZombie, 0, 0, sizeX, sizeY);
    popMatrix();
    
    // In eine Richtung bewegen...
    if(flipped) {
      posX -= speed;
    } else {
      posX += speed;
    }
    
    // bis der Gegner das Ende der Plattform erreicht
    // oder das der welt
    if(int(posX/40)<0 || int((posX+sizeX)/40) >= world.length) {
      flipped = !flipped;
    
    // oder eine wand
    } else if(flipped && (world[int(posX/40)][int((posY)/40)] != EMPTY || world[int(posX/40)][int((posY+sizeY-1)/40)] != EMPTY)) {
      flipped = false;
      
    } else if(flipped && world[int(posX/40)][int((posY+sizeY+1)/40)] == EMPTY) {
      flipped = false;
      
    } else if(!flipped && (world[int((posX+sizeX)/40)][int((posY)/40)] != EMPTY || world[int((posX+sizeX)/40)][int((posY+sizeY-1)/40)] != EMPTY)) {
      flipped=true;
    
    } else if(!flipped && world[int((posX+sizeX)/40)][int((posY+sizeY+1)/40)] == EMPTY) {
      flipped = true;
    }
    
  }
  
  public void collision() {
    
    player.hit(6);
  }
  
  public void killed() {
    
    // Mit 20% Chance ein Medipack spawnen
    if(int(random(100)) < MEDIPACK_CHANCE) {
      entitiesToSpawn.add(new EntityMediPack(posX,posY));
    }
    
    // Mit geringer Chance eine Rakete spawnen
    if(int(random(100)) < MISSILE_CHANCE) {
      entitiesToSpawn.add(new EntityMissile(posX,posY));
    }
  }
  
}

class EntityFlyingEnemy extends Entity {
  
  final int CIRCLE=0;
  final int ATTACK=1;
  final int RETURN=2;
  
  public int mode=CIRCLE;
  public int modeTimer=120;
  public float homeX;
  public float homeY;
  
  public EntityFlyingEnemy(float x, float y) {
    homeX = x;
    homeY = y;
    posX = x + 40;
    posY = y + 40;
    
    sizeX=30;
    sizeY=30;
    health=8;
    
    isEnemy=true;
    
    mode=CIRCLE;
  }
  
  public void behavior() {
    
    // Den Gegner zeichnen
    image(imgBatEnemy, posX, posY, sizeX, sizeY);
    
    if(mode==CIRCLE) {
      // Im Kreis um den Anfang bewegen
      float circleAngle = atan2(posY-homeY, posX-homeX);
      circleAngle += 0.1;
      posX = homeX + 40*cos(circleAngle);
      posY = homeY + 40*sin(circleAngle);
      
    } else if(mode==ATTACK) {
      // Zum Spieler hin fliegen
      // Richtungsvektor bestimmen
      float dx = player.posX - posX;
      float dy = player.posY - posY;
      // Richtungsvektor normalisieren & auf Geschwindigkeit skalieren
      float f =  sqrt(dx*dx + dy*dy);
      dx = dx*4/f;
      dy = dy*4/f;
      // Bewegen
      posX += dx;
      posY += dy;
      
    } else if(mode==RETURN) {
      // Zum Anfang zurück fliegen
      // Richtungsvektor bestimmen
      float dx = homeX + 40 - posX;
      float dy = homeY + 40 - posY;
      // Richtungsvektor normalisieren & auf Geschwindigkeit skalieren
      float f =  sqrt(dx*dx + dy*dy);
      dx = dx*4/f;
      dy = dy*4/f;
      // Bewegen
      posX += dx;
      posY += dy;
    }
    
    // Nach einer bestimmten Zeit den Modus wechseln
    modeTimer--;
    if(modeTimer == 0) {
      if(mode==CIRCLE) {
        changeMode(ATTACK);
        
      } else if(mode==ATTACK) {
        changeMode(RETURN);
        
      } else if(mode==RETURN) {
        homeX = posX-40;
        homeY = posY-40;
        changeMode(CIRCLE);
      }
    }
    
  }
  
  public void collision() {
    
    player.hit(4);
    changeMode(RETURN);
  }
  
  public void killed() {
    
    // Mit 20% Chance ein Medipack spawnen
    if(int(random(100)) < MEDIPACK_CHANCE) {
      entitiesToSpawn.add(new EntityMediPack(posX,posY));
    }
    
    // Mit geringer Chance eine Rakete spawnen
    if(int(random(100)) < MISSILE_CHANCE) {
      entitiesToSpawn.add(new EntityMissile(posX,posY));
    }
  }
  
  public void changeMode(int newmode) {
    mode=newmode;
    modeTimer=120;
  }
  
}

class EntityMiniboss extends Entity {
  
  public int attackTimer;
  
  public EntityMiniboss(float x, float y) {
    posX=x;
    posY=y;
    sizeX=80;
    sizeY=80;
    health=40;
    isEnemy=true;
    isReinforced=true;
  }
  
  public void behavior() {
    
    image(imgMiniboss, posX, posY, sizeX, sizeY);
    
    if(player.hasDefeatedMiniboss) {
      health=0;
      return;
    }
    
    // Auf zufälliger Höhe Projektile abfeuern
    if(attackTimer == 0) {
      entitiesToSpawn.add(new EntityPlantoidProjectile(posX, posY+random(80), 0));
      attackTimer=20;
    }
    
    attackTimer--;
  }
  
  public void collision() {
    
    player.hit(6);
  }
  
  public void killed() {
    
    player.hasDefeatedMiniboss = true;
  }
}

class EntitySmallPlantoid extends Entity {
  
  public float randomAngle;
  public float targetAngle;
  
  public int attackTimer;
  
  public EntitySmallPlantoid(float x, float y) {
    posX=x;
    posY=y;
    sizeX=60;
    sizeY=60;
    health=16;
    isEnemy=true;
  }
  
  public void behavior() {
    
    image(imgPlantoidSmall, posX, posY, sizeX, sizeY);
    
    // In die aktuelle Richtung bewegen
    posX += 0.6*cos(randomAngle);
    posY += 0.6*sin(randomAngle);
    
    // Winkel zufällig, aber stetig verändern
    if(randomAngle<targetAngle) randomAngle += 0.1;
    if(randomAngle>targetAngle) randomAngle -= 0.1;
    if(abs(targetAngle-randomAngle)<0.1) targetAngle = random(-PI, PI);
    
    if(attackTimer==0) {
      // In vier richtungen (nur Geraden) Projektile schießen
      for(int i=0; i<4; i++) {
        float angle = 2*i*PI/4;
        
        entitiesToSpawn.add(new EntityPlantoidProjectile(posX+sizeX/2+40*cos(angle), posY+sizeY/2+40*sin(angle), angle));
      }
    
      attackTimer=120;
    }
    
    attackTimer--;
    
  }
  
  public void collision() {
    
    player.hit(6);
  }
  
  public void killed() {
    
    // Mit 20% Chance ein Medipack spawnen
    if(int(random(100)) < MEDIPACK_CHANCE) {
      entitiesToSpawn.add(new EntityMediPack(posX,posY));
    }
    
    // Mit geringer Chance eine Rakete spawnen
    if(int(random(100)) < MISSILE_CHANCE) {
      entitiesToSpawn.add(new EntityMissile(posX,posY));
    }
  }
}

class EntityBossPlantoid extends Entity {
  
  final int MAX_HEALTH=50;
  
  final int SPAWN=0;
  final int SHOOT=1;
  final int HEAL=2;
  
  public int attackTimer;
  public int attackType;
  
  public EntityBossPlantoid(float x, float y) {
    posX=x;
    posY=y;
    
    sizeX=160;
    sizeY=160;
    
    health=MAX_HEALTH;
    
    isEnemy = true;
    isReinforced = true;
  }
  
  public void behavior() {
    
    image(imgPlantoidBoss, posX, posY, sizeX, sizeY);
    
    // Wenn man den Boss schon besiegt hat und man in den Raum zurückkehrt ist er nicht mehr da
    if(player.hasDefeatedBoss) {
      health=0;
      return;
    }
    
    // Boss fängt erst an zu kämpfen wenn man nahe dran ist (sonst zu schwierig)
    if(dist(player.posX, player.posY, posX, posY) > 400) {
      return;
    }
    
    if(attackTimer == 0) {
      attackTimer = 120;
      
      if(attackType==SPAWN) spawn();
      if(attackType==SHOOT) shoot();
      if(attackType==HEAL) heal();
      
      // Neue zufällige Attacke aussuchen
      attackType = int(random(3));
    }
    
    attackTimer--;
  }
  
  public void collision() {
    
    player.hit(20);
  }
  
  public void killed() {
    
    player.hasDefeatedBoss = true;
  }
  
  public void spawn() {
    println("Boss used SPAWN attack");
    
    entitiesToSpawn.add(new EntitySmallPlantoid(posX, posY));
  }
  
  public void shoot() {
    println("Boss used SHOOT attack");
    
    // In acht richtungen (Geraden und Diagonalen) Projektile schießen
    for(int i=0; i<8; i++) {
      float angle = 2*i*PI/8;
      
      entitiesToSpawn.add(new EntityPlantoidProjectile(posX+sizeX/2+40*cos(angle), posY+sizeY/2+40*sin(angle), angle));
    }
  }
  
  public void heal() {
    println("Boss used HEAL attack");
    
    health += 10;
    health = min(health, MAX_HEALTH);
    
  }
}

class EntityPlantoidProjectile extends Entity {
  
  public float angle;
  
  public EntityPlantoidProjectile(float x, float y, float angleIn) {
    posX=x;
    posY=y;
    sizeX=6;
    sizeY=6;
    angle = angleIn;
  }
  
  public void behavior() {
    // Das Bild in die Flugrichtung drehen
    pushMatrix();
    imageMode(CENTER); // Dadurch wird das Projektil nicht ganz so gezeichnet wie alle anderen Sprites, aber die Abweichung durch die Rotation wird gleichmäßig
    translate(posX, posY);
    rotate(angle);
    image(imgPlantoidProjectile, 0, 0, sizeX, sizeY);
    imageMode(CORNER);
    popMatrix();
    
    // In eine konstante Richtung bewegen
    posX += 5*cos(angle);
    posY += 5*sin(angle);
  }
  
  public void collision() {
    player.hit(1);
    health=0; // Verschwinden bei Treffer
  }
}

class EntityMediPack extends Entity {
  
  public EntityMediPack(float x, float y) {
    posX=x;
    posY=y;
    sizeX=30;
    sizeY=30;
  }
  
  public void behavior() {
    
    image(imgMedipack, posX, posY, sizeX, sizeY);
  }
  
  public void collision() {
    player.healthMod(20);
    health=0;
  }
}

class EntityMissile extends Entity {
  
  public EntityMissile(float x, float y) {
    posX=x;
    posY=y;
    sizeX=30;
    sizeY=30;
  }
  
  public void behavior() {
    
    image(imgMissileBox, posX, posY, sizeX, sizeY);
  }
  
  public void collision() {
    player.missiles++;
    health=0;
  }
}

  
final int SUPERGUN=1;
final int BALL=2;
final int BOMB=3;
  
class EntityUpgrade extends Entity {
  
  public int type;
  
  public EntityUpgrade(float x, float y, int typeIn) {
    posX=x;
    posY=y;
    
    sizeX=40;
    sizeY=40;
    
    type=typeIn;
  }
  
  public void behavior() {
    
    image(imgUpgrade, posX, posY, sizeX, sizeY);
    
    // Wenn der Spieler das Upgrade schon hat soll es verschwinden
    if(type==SUPERGUN && player.hasSupergun) health = 0;
    if(type==BALL && player.hasBall) health = 0;
    if(type==BOMB && player.hasBombs) health = 0;
  }
  
  public void collision() {
    
    if(type==SUPERGUN) {
      player.hasSupergun = true;
      println("Got SUPERGUN");
      screen=HELP_SUPERGUN;
      
    } else if(type==BALL) {
      player.hasBall = true;
      println("Got BALL");
      screen=HELP_BALL;
      
    } else if(type==BOMB) {
      player.hasBombs = true;
      println("Got BOMB");
      screen=HELP_BOMB;
    }
    
    health=0;
  }
}

class EntityDoor extends Entity {
  
  public EntityDoor(int x, int y, boolean reinforced) {
    posX=x;
    posY=y;
    sizeX=40;
    sizeY=80;
    health=1;
    isEnemy=true;
    isReinforced=reinforced;
  }
  
  public void behavior() {
    
    if(isReinforced) {
      image(imgDoorReinforced, posX, posY, sizeX, sizeY);
    } else {
      image(imgDoor, posX, posY, sizeX, sizeY);
    }
  }
  
  public void killed() {
    
    // Die Tür wird durch INVISBLE_BLOCKS dahinter getragen. Diese zerstören
    world[int(posX/40)][int(posY/40)] = EMPTY;
    world[int(posX/40)][int(posY/40)+1] = EMPTY;
  }
  
}

class EntityLoadingZone extends Entity {
  
  public boolean isEscape;
  public String levelTo;
  public float xTo;
  public float yTo;
  
  public EntityLoadingZone(int x, int y) {
    posX=x;
    posY=y;
    sizeX=40;
    sizeY=40;
  }
  
  public void initTo(String level, float x, float y) {
    levelTo=level;
    xTo=x;
    yTo=y;
    println("Initialized loading zone: To " + level + " x=" + xTo + " y=" + yTo);
  }
  
  public void collision() {
    if(isEscape) {
      if(player.hasDefeatedBoss) {
        screen=YOU_WIN;
      } else {
        screen=CANT_LEAVE_YET;
        player.posX = 80;
        player.flipped = false;
      }
    } else {
      println("Warping to level: " + levelTo);
      println(xTo);
      println(yTo);
      player.posX = xTo;
      player.posY = yTo;
      loadLevel(levelTo);
    }
  }
}

class EntityBomb extends Entity  {
  
  public int lint=240;
  
  public EntityBomb(float x, float y) {
    posX=x;
    posY=y;
    sizeX=30;
    sizeY=30;
  }
  
  public void behavior() {
    image(imgBomb, posX, posY, sizeX, sizeY);
    
    lint--;
    
    if(lint == 0) {
      health=0;
      
      // Blöcke um die Bombe herum entfernen
      int startX = max(0, int(posX-80)/40);
      int startY = max(0, int(posY-80)/40);
      int endX = min(world.length, int(posX+80)/40);
      int endY = min(world[0].length, int(posY+80)/40);
      
      for(int x=startX; x<endX; ++x) {
        for(int y=startY; y<endY; ++y) {
          if(world[x][y] == FRAGILE_BLUE_BLOCK || world[x][y] == FRAGILE_GREEN_BLOCK) {
            world[x][y] = EMPTY;
          }
        }
      }
      
      // Gegnern schaden
      for(Entity entity : entities) {
        if(entity.isEnemy && dist(entity.posX, entity.posY, posX, posY) < 80) {
          entity.health -= 10;
        }
      }
      
    }
  }
}
