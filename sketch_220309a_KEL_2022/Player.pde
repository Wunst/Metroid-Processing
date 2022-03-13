
class Player extends AABB {
  
  public float gravity=0.2;
  public float maxYSpeed=7;
  public float walkingSpeed=3.2;
  public float jumpingSpeed=7;
  public int maxHealth=150;
  public int maxEnergy=20;
  
  public int health=maxHealth;
  public int energy=maxEnergy;
  public int missiles=10;
  
  public float speedY=0;
  
  public boolean grounded=false;
  public boolean flipped=false;
  
  public boolean hasGun=true,hasSupergun,hasBall,hasBombs;
  public boolean hasDefeatedMiniboss;
  public boolean hasDefeatedBoss;
  
  public boolean isBall;
  
  public int damageCooldown;
  public int energyRegenCooldown;
  public int gunCooldown;
  public int missileCooldown;
  public int bombCooldown;
  
  public Player() {
    sizeX=40;
    sizeY=80;
  }
  
  public void behavior() {
    
    drawIt();
    verticalMove(); // Vertikale Bewegung muss zuerst gemacht werden sonst bleibt der Spieler im Boden stecken
    horizontalMove();
    abilities();
    cooldowns();
  }
  
  public void drawIt() {
    
    pushMatrix();
    translate(posX, posY);
    if(flipped) {
      translate(sizeX, 0);
      scale(-1, 1);
    }
    image(imgPlayer, 0, 0, sizeX, sizeY);
    popMatrix();
  }
  
  public void verticalMove() {
    
    if(!grounded) {
      
      speedY = speedY + gravity;
    }
  
    // Springen nur wenn der Spieler auf dem Boden ist
    if(keys[MOVE_UP] && grounded) {
      
      speedY = -jumpingSpeed;
    }
    
    // Geschwindigkeit nach oben hin begrenzen
    speedY = constrain(speedY, -maxYSpeed, maxYSpeed);
    posY += speedY;
    
    // Wenn der Spieler auch nur einen Frame nicht mit dem Boden kollidiert ist ist er in der Luft
    grounded = false;
    
    // Vertikale Kollision erkennen
    // Mit der Decke, wenn der Spieler sich nach oben bewegt...
    // Rechtes und linkes Ende jeweils 1 Pixel nach innen rechnen, damit der Spieler an der Wand nicht rumbuggt
    if(speedY < 0) {
      if(world[int(posX+1)/40][int(posY)/40] != EMPTY ||
         world[int(posX+sizeX-1)/40][int(posY)/40] != EMPTY) {
        //println("collision while moving up");
        
        // Von der Decke "elastisch" abprallen
        posY = int(posY/40+1)*40;
        speedY = -speedY * 0.66;
      }
    }
    
    // ... und mit dem Boden wenn er sich nach unten bewegt
    if(speedY > 0) {
      if(world[int(posX+1)/40][int(posY+sizeY)/40] != EMPTY ||
         world[int(posX+sizeX-1)/40][int(posY+sizeY)/40] != EMPTY) {
        //println("collision while moving down");
        
        // Auf dem Boden stehen bleiben
        posY = int(posY/40)*40;//-0.1;
        speedY = 0;
        
        grounded = true;
      }
    }
  }
  
  public void horizontalMove() {
    
    if(keys[MOVE_LEFT]) {
      posX -= walkingSpeed;
      flipped = true;
      // unteres Ende 1 Pixel nach oben rechnen weil man sonst auf dem Boden nicht laufen kann
      if(world[int(posX)/40][int(posY)/40] != EMPTY ||
         world[int(posX)/40][int(posY+sizeY-1)/40] != EMPTY) {
        //println("collision while moving left");
        
        // Spieler auf die letzte Tile zurücksetzen
        posX = int((posX+sizeX)/40)*40+0.1;
        
      }
    }
    
    if(keys[MOVE_RIGHT]) {
      posX += walkingSpeed;
      flipped = false;
      if(world[int(posX+sizeX)/40][int(posY)/40] != EMPTY ||
         world[int(posX+sizeX)/40][int(posY+sizeY-1)/40] != EMPTY) {
        //println("collision while moving right");
        
        // Spieler auf die letzte Tile zurücksetzen
        posX = int(posX/40)*40-0.1;
      }
    }
  }
  
  public void abilities() {
    
    if(keys[BUTTON1] && hasGun && gunCooldown == 0 && energy >= 2 && !isBall) {
      //println("Player has shot weapoN");
      
      // Energie abziehen
      energyMod(-2);
      
      if(hasSupergun) {
        bullets.add(new Bullet(posX+20, posY+20, flipped?-1:1, SUPER_BULLET));
      } else {
        bullets.add(new Bullet(posX+20, posY+20, flipped?-1:1, NORMAL_BULLET));
      }
      
      gunCooldown = 10;
    }
    
    if(keys[BUTTON2] && missiles > 0 && missileCooldown == 0) {
      
      missiles--;
      
      bullets.add(new Bullet(posX+20, posY+20, flipped?-1:1, MISSILE));
      
      missileCooldown = 120;
    }
    
    if(keys[MOVE_DOWN] && hasBall) {
      
      if(!isBall) {
        isBall = true;
        sizeY = 40;
        posY += 40;
        
      } else if(world[int(posX)/40][int(posY-40)/40] == EMPTY && world[int(posX+sizeX)/40][int(posY-40)/40] == EMPTY) {
        isBall = false;
        sizeY = 80;
        posY -= 40;
      }
      
      keys[MOVE_DOWN]=false;
    }
    
    if(keys[BUTTON1] && hasBombs && bombCooldown == 0 && energy >= 6 && isBall) {
      
      energyMod(-2);
      
      entitiesToSpawn.add(new EntityBomb(posX, posY));
      
      bombCooldown = 300;
    }
    
  }
  
  public void cooldowns() {
    
    if(damageCooldown > 0) {
      damageCooldown--;
    }
    if(gunCooldown > 0) {
      gunCooldown--;
    }
    if(energyRegenCooldown > 0) {
      energyRegenCooldown--;
    }
    if(missileCooldown > 0) {
      missileCooldown--;
    }
    if(bombCooldown > 0) {
      bombCooldown--;
    }
    
    if(energy < maxEnergy && energyRegenCooldown == 0) {
      energyMod(+1);
      energyRegenCooldown=30;
    }
  }
  
  public void healthMod(int healthMod) {
    
    health += healthMod;
    health = constrain(health, 0, maxHealth);
  }
  
  public void energyMod(int energyMod) {
    
    energy += energyMod;
    energy = constrain(energy, 0, maxEnergy);
  }
  
  public void hit(int damage) {
    
    if(damageCooldown == 0) {
    
      healthMod(-damage);
      damageCooldown = 60;
    }
  }
  
}
