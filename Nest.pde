// Fred Limouzin
// Nest Class
// v1 - 20170216

class Nest {
  PVector pos;
  float diam;

  // currently the nest is at the center, but should eventually be random
  Nest (float tDiam) {
    this.pos = new PVector(width/2, height/2);
    this.diam = tDiam;
  }

  void show() {
    strokeWeight(2);
    stroke(64, 32, 32);
    fill(128, 64, 64);
    ellipse(this.pos.x, this.pos.y, this.diam, this.diam);
  }

  PVector getPos () {
    return this.pos.copy();
  }
}
