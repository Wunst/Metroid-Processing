
class AABB {
  
  public float posX;
  public float posY;
  public float sizeX;
  public float sizeY;
  
  public boolean collidePoint(float otherX, float otherY) {
    return otherX>=posX && otherX<=posX+sizeX &&
      otherY>=posY && otherY<=posY+sizeY;
  }
  
  public boolean collideBox(AABB otherBox) {
    return collidePoint(otherBox.posX, otherBox.posY) ||
      collidePoint(otherBox.posX+otherBox.sizeX, otherBox.posY) ||
      collidePoint(otherBox.posX, otherBox.posY+sizeY) ||
      collidePoint(otherBox.posX+otherBox.sizeX, otherBox.posY+otherBox.sizeY) ||
      otherBox.collidePoint(posX, posY) ||
      otherBox.collidePoint(posX+sizeX, posY) ||
      otherBox.collidePoint(posX, posY+sizeY) ||
      otherBox.collidePoint(posX+sizeX, posY+sizeY);
  }
}
