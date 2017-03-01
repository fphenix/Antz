// Fred Limouzin
// Pheromone Class
// A pheromone is a (blue) point that faints as time goes by
// An ant can leave it as they carry food or follow it as they look for food
// v1 - 20170216

class Phero {
  PVector pos;
  float lifespan;
  float radius;
  
  Phero (PVector tPos, float tRadius, float tLifespan) {
      this.pos = tPos;
      this.lifespan = tLifespan;
      this.radius = tRadius;
  }
  
  void show () {
    stroke(0, 0, 255, this.lifespan);
    point(this.pos.x, this.pos.y);
  }
  
  PVector getPos() {
    return this.pos.copy();
  }
  
  boolean hasFaded() {
    return (this.lifespan <= 0);  
  }
  
  void update (float step) {
    this.lifespan -= step;
    this.lifespan = constrain(this.lifespan, 0, pheroLifespanMax);
  }
  
  void run(int idx) {
    this.show();
    this.update(pheroLifespanStep);
    if (this.hasFaded()) {
      phero.remove(idx);
    }
  }
  
}