
final int NORMAL_BULLET = 0;
final int SUPER_BULLET = 1;
final int MISSILE = 2;

final float NORMAL_BULLET_SPEED = 4.8;
final float SUPER_BULLET_SPEED = 5.8;
final float MISSILE_START_SPEED = 0.05;
final float MISSILE_MAX_SPEED = 20;
final float MISSILE_ACCELERATION = 0.4;

final int NORMAL_BULLET_DAMAGE = 2;
final int SUPER_BULLET_DAMAGE = 5;
final int MISSILE_DAMAGE = 20;

class Bullet {
  
  public float posX;
  public float posY;
  public float dx;
  
  public int damage;
  
  public int life=120;
  
  public int type;
  
  public Bullet(float x, float y, float directionIn, int typeIn) {
    posX=x;
    posY=y;
    dx=directionIn;
    type=typeIn;
    
    if(typeIn==NORMAL_BULLET) {
      dx *= NORMAL_BULLET_SPEED;
      damage=NORMAL_BULLET_DAMAGE;
      
    } else if(typeIn==SUPER_BULLET) {
      dx *= SUPER_BULLET_SPEED;
      damage=SUPER_BULLET_DAMAGE;
      
    } else if(typeIn==MISSILE) {
      dx *= MISSILE_START_SPEED;
      damage=MISSILE_DAMAGE;
    }
  }
  
  public void fly() {
    
    // Zeichnen (Normale Kugeln = weiß, Super-Kugeln = hellblau, Raketen = orange)
    if(type==NORMAL_BULLET) {
      fill(255);
      
    } else if(type==SUPER_BULLET) {
      fill(0, 128, 255);
      
    } else if(type==MISSILE) {
      fill(255, 128, 0);
    }
    
    rect(posX, posY, 4, 4);
    
    posX += dx;
    
    // Raketen beschleunigen mit der Zeit
    if(type==MISSILE && abs(dx)<MISSILE_MAX_SPEED) {
      dx += Math.signum(dx) * MISSILE_ACCELERATION;
    }
    
    // Außerhalb der Map despawnen
    if(int(posX/40)<0 || int(posX/40)>=world.length || int(posX/40)<0 || int(posY/40)>=world[0].length) {
      life=0;
      return;
    }
    
    // Mit Wänden kollidieren
    if(world[int(posX/40)][int(posY/40)] != EMPTY && world[int(posX/40)][int(posY/40)] != INVISIBLE_BLOCK) {
      // life=0 signalisiert der Update-Schleife, dass dieses Projektil zerstört werden soll
      life=0;
      return;
    }
    
    // Mit Gegnern kollidieren
    for(Entity entity : entities) {
      if(entity.isEnemy) {
        if(entity.collidePoint(posX, posY)) {
          life=0;
          // Nur Raketen können reinforced-Gegner treffen
          if(entity.isReinforced && type != MISSILE) {
            break;
          }
          entity.health -= damage;
          break;
        }
      }
    }
    
    life--;

    
  }
}
