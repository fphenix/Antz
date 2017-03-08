// Fred Limouzin
// Obstacle Class
// Two types of obstacles can be generated : line and circle
// v1 - 20170216

class Obstacle {
  boolean type_LnotC;
  PVector aPoint;
  PVector bPoint;
  PVector oPoint;
  float diam;

  //Constructor: Random
  Obstacle () {
    float x1, x2, y1, y2;
    float regmin = 0.35;
    float regmax = 0.45;

    diam = random(30, 100);
    x1 = width*random(regmin, regmax);
    y1 = height*random(regmin, regmax);
    x2 = width * (1 - random(regmin, regmax));
    y2 = height*random(regmin, regmax);
    aPoint = new PVector(x1, y1);
    bPoint = new PVector(x2, y2);
    oPoint = new PVector(average(x1, x2), average(y1, y2));
    type_LnotC = (int(random(2)) == 0) ? false : true;
  }

  //Constructor: Line type
  Obstacle (PVector _aPoint, PVector _bPoint) {
    this.aPoint = _aPoint.copy();
    this.bPoint = _bPoint.copy();
    type_LnotC = true;
  }

  //Constructor: Circle
  Obstacle (PVector _oPoint, float _diam) {
    this.diam = _diam;
    this.oPoint = _oPoint.copy();
    type_LnotC = false;
  }

  float average (float a, float b) {
    return ((a+b)/2);
  }

  PVector getDir () {
    PVector dir = PVector.sub(this.bPoint, this.aPoint);
    return dir.normalize();
  }

  PVector getApos () {
    return this.aPoint.copy();
  }

  PVector getBpos () {
    return this.bPoint.copy();
  }

  PVector getOpos () {
    return this.oPoint.copy();
  }

  float getDiam () {
    return this.diam;
  }

  boolean isObstTypeLine () {
    return this.type_LnotC;
  }

  boolean isObstTypeCircle () {
    return !(this.type_LnotC);
  }

  void show () {
    // type line (for branches, walls, etc.)
    if (this.type_LnotC) {
      stroke(32, 32, 0);
      strokeWeight(8);
      line(this.aPoint.x, this.aPoint.y, this.bPoint.x, this.bPoint.y);
      // type circle (poodle, etc.)
    } else {
      noStroke();
      fill(0, 255, 255);
      ellipse(this.oPoint.x, this.oPoint.y, this.diam, this.diam);
    }
  }
}