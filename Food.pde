// Fred Limouzin
// Food Class
// v1 - 20170216

class Food {
  PVector pos;
  float diam;
  boolean empty;
  
  // default: position chosen randomly
  Food (float tDiam) {
    float angle = random(-PI, PI);
    float rn1 = random(0.8, 1);
    float rn2 = random(0.8, 1);
    this.pos = new PVector(width/2 * (1 + rn1 * cos(angle)), height/2 * (1 + rn2 * sin(angle)));
    this.diam = tDiam;
    this.empty = false;
  }
  
  // Can force position
  Food (float tDiam, PVector tPos) {
    this.pos = tPos.copy();
    this.diam = tDiam;
    this.empty = false;
  }
  
  boolean isEmpty() {
    return this.empty;
  }
  
  float getDiam() {
    return this.diam;
  }
  
  PVector getPos() {
    return this.pos.copy();
  }
  
  void update() {
    if (this.diam < 1) {
      this.diam = 0;
      this.empty = true;
    }  
  }
  
  void show() {
    if (!(this.isEmpty())) {
      strokeWeight(2);
      stroke(0, 128, 0);
      fill(0, 255, 0);
      ellipse(this.pos.x, this.pos.y, this.diam, this.diam);
    }
  }
  
  void run() {
    this.update();
    this.show();
  }

}