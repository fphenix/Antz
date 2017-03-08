// Fred Limouzin
// Pheromone Class
// A pheromone is a (blue) point that faints as time goes by
// An ant can leave it as they carry food or follow it as they look for food
// v1 - 20170216

class Phero {
  PVector pos;
  float lifespan;

  Phero (PVector tPos, float tLifespan) {
    this.pos = tPos;
    this.lifespan = tLifespan;
  }

  void show () {
    float lifeAlpha = map(this.lifespan, 0, pheroLifespanMax, 0, 255);
    strokeWeight(2);
    stroke(0, 0, 255, lifeAlpha);
    point(this.pos.x, this.pos.y);
  }

  PVector getPos() {
    return this.pos.copy();
  }

  boolean hasFaded() {
    return (this.lifespan <= 0);
  }

  void update (float step) {
    this.lifespan = (this.lifespan > (2*pheroLifespanMax)) ? (2*pheroLifespanMax) : this.lifespan;
    this.lifespan -= step;
  }

  boolean run() {
    this.update(pheroLifespanStep);
    boolean ret = !this.hasFaded();
    this.show();
    return ret;
  }
}