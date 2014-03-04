// First come the global variables

flock f;

ArrayList<PVector> net;
boolean netDisplay;

predator pete;
boolean peteInit;
int   peteVR;          // vision radius
float peteMV, peteMA; // max vel. and accel.

int torusBuffer;
int bodyLen;
float maxV;
float maxA;
int cohR, aliR, sepR;    // impulse radii
float cohW, aliW, sepW;  // impulse weights

int spacePop; 

void setup() {
  size(1270,775);
  bodyLen = 8;
  maxV    = bodyLen/2.0;
  maxA    = maxV/32.0;
  
  // radii of awareness
  cohR = 8*bodyLen;
  sepR = 4*bodyLen;
  aliR = 8*bodyLen;
  
  // weighing factors for the impulses
  cohW = 1;
  sepW = 1.8;
  aliW = 1.2;
  
  f = new flock(bodyLen, maxV, maxA,
                cohR, sepR, aliR);
                
  // The amount of the world that is off-screen on each side
  torusBuffer = cohR; 
  
  peteInit = false; // the predator is not spawned at first
  
  netDisplay = false; // changes display styles
  spacePop = 80;  // how many boids spawn when you press space
}



void draw() {
  background(255,255,255);
  f.swarm();
  if (peteInit) {
    pete.hunt(f);
    pete.update(torusBuffer);
    pete.render();
  }
  
  
  f.update();
  if (!netDisplay) f.render();
  else {
  stroke(0,0,0);
  for (int i = 0; i < net.size() - 2; i = i+2) {
    line(net.get(i).x, net.get(i).y, net.get(i+1).x, net.get(i+1).y);
  }
  }
    
  f.torusCorrect(torusBuffer);

    
}

void mousePressed() {
  f.boids.add(new boid(mouseX, mouseY, mouseX - pmouseX, mouseY - pmouseY));
}


void keyPressed() {
  if (key == 'r') {
    f = new flock(bodyLen, maxV, maxA,
                  cohR, sepR, aliR);
  }
  if (key == ' ') {
   for(int i = 0; i < spacePop; i++) {
    f.boids.add(new boid(mouseX+random(20)-10, mouseY+random(20)-10, 
                         mouseX - pmouseX+random(20)-10, 
                         mouseY - pmouseY+random(20)-10));
   }
  }

  if (key == 'p') {
                        //   x,      y,         viewR,   maxV,   maxA,      size
    if (netDisplay) { 
      pete = new predator(mouseX, mouseY, f.cohereR * 3, maxV*1.3, maxA*1.3, (int)(cohR*0.4));
    }
    else {
      pete = new predator(mouseX, mouseY, f.cohereR * 3, maxV*1.1, maxA*1.75, (int)(bodyLen*1.5));
    }
    peteInit = true;
  }
  
  
  if (key == 'P') {
    peteInit = false;
    }
  }


// a predatorator class: it will ~cohere towards the boids,
// who will ~separate from the predatorator
class predator {
  PVector pos;
  PVector vel;
  PVector acc;
  int viewR; // radius of vision
  float maxV;
  float maxA;
  int bodyLen;
  
  predator(int x, int y, int vR, float mV, float mA, int bL) {
    pos = new PVector(x,y);
    vel = new PVector(random(mV/4) - mV/8,random(mV/4) - mV/8);
    acc = new PVector(0,0);
    viewR = vR;
    maxV = mV;
    maxA = mA;
    bodyLen = bL;
  }
  
  // chases the boids, who in response run away
  void hunt(flock f) {
    float d;
    PVector prey = new PVector(0,0);  // becomes "target point" (centroid of prey)
    PVector preyPull;                 // for math
    for(boid b : f.boids) {
     d = PVector.dist(b.pos, pos);
     
     // "notice" all boids within viewR, weighed by 1/r^2
     if(d < viewR) {
       preyPull = PVector.sub(b.pos, pos);
       preyPull.setMag(sq((viewR/2.0)/d));
       prey.add(preyPull);
     
     
      // I use cohereR because it is generally the largest "awareness radius"
      // I assume cohereR is less than viewR
      if(d < f.cohereR * 2) {
       // I'll try making the boid as afraid of the predator
       // wants the boid
       b.acc.add(PVector.div(preyPull,8));
      }
     }
    }
    acc.add(prey);
  }
  
  void update(int buffer) {
    acc.limit(maxA);
    vel.add(acc);
    vel.limit(maxV);
    pos.add(vel);
    acc.mult(0);
    
    if (pos.x < -buffer) pos.x = width  + buffer;
    if (pos.y < -buffer) pos.y = height + buffer;
    if (pos.x > width + buffer)  pos.x = -buffer;
    if (pos.y > height + buffer) pos.y = -buffer;
  }
  
  void render() {
    pushMatrix(); // gets ahold of coordinate origin
    translate(pos.x, pos.y);
    rotate(vel.heading());     // orients axes
    stroke (color(64,0,0));
    fill   (color(0,0));        // so predators are solid in the boids' outline color
    triangle(bodyLen/2, 0, -bodyLen/2, -bodyLen/4, -bodyLen/2, bodyLen/4);
    popMatrix();
  }
  
  
  
}

class boid {
  PVector pos;
  PVector vel;
  PVector velPrev;
  PVector acc;
  // acc is used as the boid's "desired acceleration" vector: at each 
  // update step, acc is used to accumulate the boid's various impulses. 
  float effectiveA;
  
  boid(float x, float y, float vx, float vy) {
    pos = new PVector(x,y);
    vel = new PVector(vx,vy);
    velPrev = new PVector(0,0);
    acc = new PVector(0,0);
  }
  
//  float red;
  void render(int bodySize) {
    
  //  effectiveA = PVector.dist(vel, velPrev);
    //red = max(effectiveA/maxA*0.3*255,255);
    
    pushMatrix(); // gets ahold of coordinate origin
    translate(pos.x, pos.y);
    stroke(128, 0, 0);
    fill(0, 0,0,0);
    rotate(vel.heading());     // orients axes
    triangle(bodySize/2, 0, -bodySize/2, -bodySize/3, -bodySize/2, bodySize/3);
    popMatrix();
  }
  
  void torusCorrect(int buffer) {
    if (pos.x < -buffer) pos.x = width  + buffer;
    if (pos.y < -buffer) pos.y = height + buffer;
    if (pos.x > width + buffer)  pos.x = -buffer;
    if (pos.y > height + buffer) pos.y = -buffer;
  }
  
  
}

// a flock carries an array of boids as well as all of the parameters
// shared by the boids in the flock, such as body length and color
class flock {
  int bodyLength;
  color fillCol;    // for rendering
  color strokeCol;
  
  float maxVel;     // flight parameters
  float maxAcc;
  
  int cohereR, separateR, alignR;

  ArrayList<boid> boids;
  
  flock(int bodL, float maxV, float maxA, int cR, int sR, int aR) {
    bodyLength = bodL;
    fillCol    = color(166,0,0,12);
    strokeCol  = color(166,0,0);
    boids = new ArrayList<boid>();
    
    maxVel = maxV;
    maxAcc = maxA;
    cohereR   = cR;
    separateR = sR;
    alignR    = aR;
  }
  
  void render() {
    fill(fillCol);
    stroke(strokeCol); 
    for (boid b : boids) {
      b.render(bodyLength);
    }
  }
  
  // coheres, separates, and aligns the boids
  // the three functions are grouped to avoid redundant operations
  void swarm() {
    if (netDisplay) net = new ArrayList<PVector>();
    
    for (boid b : boids) {
     PVector cohere = new PVector(0,0);      // cohere becomes the centroid
     int coherePop  = 0;                     // of b's neighbors
     
     PVector separate = new PVector(0,0);
     int separatePop  = 0;
     
     PVector align = new PVector(0,0);
     int  alignPop = 0;
     
     for (boid a : boids) {
      float d = PVector.dist(a.pos, b.pos);

      // cohere: calculate the centroid of the neighbors
      if (d > 0 && d < cohereR) {       
       cohere.add(a.pos);
       coherePop++;
      }
      
      // adds the boid's and it neighbor's position to
      // the netDisplay array, so a line can be drawn
      // between them
      if (netDisplay && d > 0 && d < cohereR) {
       net.add(a.pos);
       net.add(b.pos);
      }
      
      
      if (d > 0 && d < separateR) {
        PVector avoidA = PVector.sub(b.pos, a.pos);
        // the desire to avoid a neighbor is proportional to 1 / distance^2
        avoidA.normalize();
        avoidA.div((d/10.0));       // weight by 1/distance
        separate.add(avoidA);
        separatePop++;
      }
      
      
      if (d > 0 && d < alignR) {
        align.add(a.vel);
        alignPop++;
      }
      
    }
    if (coherePop != 0) {
     cohere.div((float)coherePop); // cohere is now the centroid of its neighbors
     cohere.sub(b.pos);            // now we have a vector from the boid to the centroid of its neighbors
     cohere.setMag(maxVel);        // now cohere is an "impulse" vector in the right direction, a desired velocity
     cohere.sub(b.vel);            // now cohere points from the current velocity to the desired one
     cohere.limit(maxAcc);
     cohere.mult(cohW);            // the cohere impulse is limited by maxAcc * cohW
     b.acc.add(cohere);    
    }
       
    if (separatePop > 0) {
     //separate.div((float)separatePop);
     separate.setMag(maxVel);
     separate.sub(b.vel);
     separate.limit(maxAcc);
     separate.mult(sepW);
     b.acc.add(separate);
    }
    
    if (alignPop > 0) {
      //align.div((float)alignPop);
      align.setMag(maxVel);
      align.sub(b.vel);
      align.limit(maxAcc);
      align.mult(aliW);
      b.acc.add(align);
    }
   }
  }
  
  // updates each boid's parameters
  void update() {
    for (boid b : boids) {
     //b.acc.limit(maxAcc);
     b.velPrev = b.vel;
     b.vel.add(b.acc);
     b.vel.limit(maxVel);
     b.pos.add(b.vel);
     b.acc.mult(0);
    }
  }
  
  void torusCorrect(int buffer) {
    for (boid b : boids) {
     b.torusCorrect(buffer);
    }
  }
  
}

/*
PVector fromToTorus(PVector a, PVector b, int buffer) {
  float x, y;
  // "wrapping" around the screen is only necessary if a and
  // b are more than half the total width apart ("apart"
  // without wrapping)
  if (abs(a.x - b.x) < (width + 2*buffer) / 2) { //don't wrap
    x = b.x - a.x;
  }
  // if a is on the left half and wrapping is needed, make a 
  // virtual b to the left of the screen
  else if (a.x < width / 2) {
    x = (-1 * buffer) - (width + buffer - b.x) - a.x;
  }
  // if a is on the rigth half we make a virtual b on the
  // other side of the screen
  else {
    x = (width + b.x) - a.x;
  }
  // Repeat with y
  if (abs(a.y - b.y) < (height + 2*buffer) / 2) { //don't wrap
    y = b.y - a.y;
  }
  else if (a.y < height / 2) {
    y = (-1 * buffer) - (height + buffer - b.y) - a.y;
  }
  else {
    y = (width + b.y) - a.y;
  }
  
  return(new PVector(x, y));
}
*/
