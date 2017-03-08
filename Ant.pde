// Fred Limouzin
// Ant Class
// v2 - 20170222

class Ant {
  PVector pos;
  float angle;
  PVector vel;
  //PVector acc;
  float diam;
  boolean leftie;
  float theta; // direction
  int slices = 16;
  float anglestep = (2.0*PI/slices);

  boolean searchFood;   // 'true' if seeking food (doesn't leave phero), 'false' if food found (leaves Phero)
  boolean diffusePhero; // always equals to NOT(searchFood) but makes the understanding easier
  boolean onPheroTrail; // 'true' if sensed a pheromone trail, else 'false'
  boolean avoiding;     // 'true' if in the process of avoiding an obstacle

  float[] prob = {550.0, 250.0, 100.0, 50.0, 20.0, 5.0, 3.0, 1.0, 1.0, 1.0, 3.0, 5.0, 20.0, 50.0, 100.0, 250.0};
  float[] cumulProb = new float[slices];

  Ant (float tDiam, int tSeed, PVector tPos) {
    randomSeed(tSeed);
    this.pos = tPos.copy();
    this.vel = new PVector(0, 0);
    //this.acc = new PVector(0, 0);
    this.diam = tDiam;
    this.theta = anglestep * int(random(slices));
    this.leftie = (random(2) < 1);

    this.searchFood = true;
    this.diffusePhero = !this.searchFood;
    this.onPheroTrail = false;
    this.avoiding = false;

    // fill the cumulative probability table
    genCumulativeProbaTable();
  }

  void genCumulativeProbaTable() {
    float cumulMax = 0.0;
    for (int i = 0; i < prob.length; i++) {
      cumulMax += prob[i];
    }
    cumulProb[0] = prob[0] * 100.0 / cumulMax;
    for (int i = 1; i < cumulProb.length; i++) {
      cumulProb[i] = cumulProb[i-1] + (prob[i] * 100.0 / cumulMax);
    }
  }

  void pickNewGaussDir () {
    float angle;
    float rval = random(100);
    int nextdir = 0;
    while (rval >= cumulProb[nextdir]) {
      nextdir ++;
    }
    angle = this.theta + (nextdir * anglestep);
    this.theta = (angle % (2.0*PI)); // modulo 2.pi
  }

  boolean isOnFood(Food other) {
    if (other.isEmpty()) {
      return false;
    } else {
      float d = PVector.dist(this.pos, other.pos);
      float rtot = (this.diam + other.getDiam()) / 2.0;
      return (d <= rtot);
    }
  }

  boolean isHome(Nest other) {
    float d = PVector.dist(this.pos, other.pos);
    float rtot = 1.0; // must reach the center of the nest ; else can use : rtot = (this.diam + other.diam) / 2;
    return (d <= rtot);
  }

  void hasFoundAnyFood () {
    for (int i = 0; i < food.length; i++) {
      if (isOnFood(food[i]) && this.searchFood) {
        food[i].diam -= 0.5;
        this.searchFood = false;
        break;
      }
    }
  }

  void hasReachedNest () {
    for (int i = 0; i < nest.length; i++) {
      if (isHome(nest[i]) && !(this.searchFood)) {
        this.searchFood = true;
        break;
      }
    }
  }

  boolean isOnObstLine (PVector p1, PVector p2, PVector pm) {
    // in a triangle P1,PM,P2, the closest the distance (P1PM)+(PMP2) is from
    // the distance (P1P2), the closest the point Pm is from the line (P1P2).
    float l1 = PVector.dist(p1, pm);
    float l2 = PVector.dist(pm, p2);
    float ll = PVector.dist(p1, p2);
    float d = l1 + l2 - (ll + 5.0); // ll "+ <amount>" due to strokeWeigth on obstacle line
    return (d < 1);
  }

  boolean isInObstCircle (PVector po, float diameter, PVector p) {
    // A point 'P' is within a Circle of origin 'Po' if the following is true:
    // length[Po,P] <= radius
    float ll = PVector.dist(po, p);
    float d = ll - ((diameter/2.0) + 3.0); // r "+ <amount>" 
    return (d < 1);
  }

  PVector willItHit(PVector desired) {   
    PVector hit;
    this.avoiding = false;
    for (int i = 0; i < obst.length; i++) {
      if (obst[i].isObstTypeLine()) {
        if (isOnObstLine(obst[i].aPoint, obst[i].bPoint, this.pos)) {
          hit = obst[i].getDir();
          if (!(this.leftie)) { // this 'leftie" thing eventually will have to be removed as it's an awful solution...
            hit.mult(-1);
          }
          this.avoiding = true;
          return hit;
        }
      } else {
        if (isInObstCircle(obst[i].oPoint, obst[i].diam, this.pos)) {
          hit = PVector.sub(this.pos, obst[i].oPoint);
          float jitterx = random(-1, 1);
          float jittery = random(-1, 1);
          hit.add(new PVector(jitterx, jittery));
          hit.normalize();
          this.avoiding = true;
          return hit;
        }
      }
    }
    return desired;
  }

  float scorePhero(PVector testpos, float r) {
    PVector ppos;
    float pd;
    float score = 0.0;
    for (int i = phero.size()-1; i >= 0; i--) {
      ppos = phero.get(i).getPos();
      pd = PVector.dist(testpos, ppos);
      if ((pd <= r) && (pd > 1)) {
        score += phero.get(i).lifespan;
      }
    }
    return score;
  }

  PVector scoreFood (PVector testpos, float r) {
    float d;
    float pd;
    PVector fvec;

    for (Food currf : food) {
      if (currf.isEmpty()) {
        continue; // skip empty stack of food
      }
      d = r + (currf.getDiam() / 2.0);
      pd = PVector.dist(testpos, currf.pos);
      if (d > pd) {
        fvec = PVector.sub(currf.pos, this.pos);
        return fvec;
      }
    }
    return new PVector(0, 0);
  }

  void sensePheroOrFood () {
    PVector tvec;
    PVector tpos;
    PVector fvec;
    boolean found = false;
    float score;
    float bestangle = 0.0;
    float bestscore = 0.0;
    int radius = 10;
    float astep = PI/8.0;

    fvec = new PVector (0, 0);

    for (float angle = -PI/2.0; angle <= PI/2.0; angle += astep) {
      score = 0.0;
      tvec = this.vel.copy();
      tvec.mult(radius);
      tvec.rotate(angle);
      tpos = this.pos.copy();
      tpos.add(tvec);

      score = scorePhero(tpos, radius);
      fvec = scoreFood(tpos, radius).copy();
      if (fvec.mag() > 0) {
        score += 5000.0;
      }

      if (score > bestscore) {
        bestscore = score;
        bestangle = angle;     
        found = true;
      }
    }

    if (found) {
      this.vel.rotate(bestangle);
      this.vel.add(fvec);
      this.vel.normalize();
      this.onPheroTrail = true;
    } else {
      this.onPheroTrail = false;
    }
  }

  int hasPhero (PVector testpos) {
    PVector ppos;
    for (int i = phero.size()-1; i >= 0; i--) {
      ppos = phero.get(i).getPos();
      if (PVector.dist(testpos, ppos) < 0.1) {
        return i;
      }
    }
    return -1;
  }

  void incrPhero(int tidx, float amt) {
    float currls = phero.get(tidx).lifespan;
    currls += amt;
    phero.get(tidx).lifespan = currls;
  }

  void leavePhero() {
    float ls;
    PVector apos;
    int idx;

    // leave a phero spot at current ant position but also around that position
    // with a gradient function of the distance from center spot.
    for (int dx = -pheroRadius; dx <= pheroRadius; dx++) {
      for (int dy = -pheroRadius; dy <= pheroRadius; dy++) {
        apos = new PVector(round(dx+this.pos.x), round(dy+this.pos.y));
        ls = pheroLifespanMax / (1.0 + abs(dx*dy));
        if (ls < 1.0) {
          continue; // if lifespan too small, don't bother creating a pheromone spot
        }
        idx = hasPhero(apos);
        if (idx >= 0) {
          incrPhero(idx, ls);
        } else {
          phero.add(new Phero(apos, ls));
        }
      }
    }
  }

  void changeDir() {
    PVector desired = new PVector(1, 0);
    desired.rotate(this.theta);
    this.vel = this.willItHit(desired);
  }

  void moveRnd() {
    this.pickNewGaussDir();
  }

  void goHome (Nest other) {
    // find the vector from the ant to the nest
    // normalize it so it goes back home step by step (of 1)
    // check if it will cross an obstacle; if so avoid it else step towards the nest
    PVector gohome = PVector.sub(other.pos, this.pos);
    gohome.normalize();
    this.vel = this.willItHit(gohome);
  }

  void move () {
    if (this.searchFood) {
      sensePheroOrFood();
      if (!this.onPheroTrail) {
        this.moveRnd();
        this.changeDir();
      }
    } else {
      this.goHome(nest[0]);
    }

    if (this.diffusePhero) {
      this.leavePhero();
    }
  }

  void bound() {
    // turn around if on edges of the canvas
    if (this.pos.x < 0) {
      this.pos.x = 0;
      this.vel.mult(-1);
    } else if (this.pos.x >= width) {
      this.pos.x = width-1;
      this.vel.mult(-1);
    }
    if (this.pos.y < 0) {
      this.pos.y = 0;
      this.vel.mult(-1);
    } else if (this.pos.y >= height) {
      this.pos.y = height-1;
      this.vel.mult(-1);
    }
  }

  void update () {
    this.pos.add(this.vel);
    //this.vel.add(this.acc);
    this.bound();

    this.hasFoundAnyFood();
    this.hasReachedNest();
    this.diffusePhero = !this.searchFood;
  }

  void show () {
    strokeWeight(1);
    stroke(64, 16, 0);
    ellipseMode(CENTER);
    if (this.avoiding) {
      fill(127, 127, 127);         // gray: being rerouted to avoid an obstacle
    } else if (this.searchFood) {
      if (this.onPheroTrail) {
        fill(255, 128, 0);         // orange: following a phero trail looking for food
      } else {
        fill(255, 0, 0);           // red looking for food or phero trail randomly
      }
    } else {
      fill(255, 255, 0);           // yellow: found food, go back home directly
    }
    pushMatrix();
    translate(this.pos.x, this.pos.y);
    line(0, 0, (6*this.vel.x), (6*this.vel.y));
    rotate(this.vel.heading());
    ellipse(0, 0, this.diam, this.diam/2);
    popMatrix();
  }

  void run() {
    this.update();
    this.move();
    this.show();
  }
}