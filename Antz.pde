// Fred Limouzin
// Ants demo and neuronal networking
// From simple rules, the ants will show complexity by quickly target the closest food source
// and find the shortest paths around obstacles.
// This kind of thinking based on pheromone trails left behind and fainting can be used
// in networks to pick up the quickest route.
// Rules are as follows:
//   1) Look for food source randomly except if a pheno trail is sensed then try to follow it.
//   2) If food is found go back to the nest as direclty as possible leaving a pheromone trace behind.
// Pheromones faint as time go by. Food source diminishes as it gets picked up.
// v1 - 20170216

int nbNest = 1;
int nbFood = 5;
int nbAnts = 100;
int nbObst = 2;

float diamNest = 30;
float diamFood = 50;
float diamAnt  = 8;
int pheroRadius = 2;

float pheroLifespanMax = 255;
float pheroLifespanStep = 0.5;

Nest[] nest = new Nest[nbNest];
Food[] food = new Food[nbFood];
Ant[]  ants = new Ant[nbAnts];
Obstacle[] obst = new Obstacle[nbObst];
ArrayList<Phero> phero = new ArrayList<Phero>();

PVector nestPos;

void setup () {
  size(500, 500, P2D);
  //frameRate(30);
  
  //for (int i = 0; i < obst.length; i++) {
  //  obst[i] = new Obstacle();
  //}
  obst[0] = new Obstacle(new PVector(150,150), new PVector(350,200));
  obst[1] = new Obstacle(new PVector(150,300), 100);
  
  nest[0] = new Nest(diamNest);
  nestPos = nest[0].getPos();
  
  //random position for food sources except the last one
  for (int i = 0; i < food.length-1; i++) {
    food[i] = new Food(diamFood);
  }
  food[food.length-1] = new Food(diamFood, new PVector(400, 100));

  for (int i = 0; i < ants.length; i++) {
    ants[i] = new Ant(diamAnt, i, nestPos.copy());
  }
}

void draw () {
  background(255);
  
  for (int i = 0; i < obst.length; i++) {
    obst[i].show();
  }
  
  nest[0].show();
  
  for (int i = 0; i < food.length; i++) {
    food[i].run();
  }
  
  for (int i = phero.size()-1; i >= 0 ; i--) {
    phero.get(i).run(i);
  }
  
  for (int i = 0; i < ants.length; i++) {
     ants[i].run();
  }
  
}