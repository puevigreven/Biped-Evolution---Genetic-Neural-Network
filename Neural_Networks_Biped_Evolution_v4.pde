import shiffman.box2d.*; 
import org.jbox2d.common.*; 
import org.jbox2d.collision.shapes.*; 
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.dynamics.*; 
import org.jbox2d.dynamics.joints.*; 
import org.jbox2d.dynamics.contacts.*; 
import java.util.Arrays;


//NeuralNetwork constants
float BIAS = -1;
float ACTIVATION_RESPONSE = 0.8;

//Genetic Algorithm constants
float MUTATION_RATE = 0.1f;
float CROSSOVER_RATE = 0.7f;
float MAX_PERTURBATION = 0.3f;
int NUM_ELITE = 4;
int NUM_COPIES_ELITE = 1;
int NUM_GEN_TICKS = 3000;

boolean change = false;
int inactivityTime = 0;
int inacTotFitness = 0;
int graphW = 750;
int graphH = 130;

Box2DProcessing box2d;
Droid[] droids;
Boundary[] boundaries;
int iTicks = 0;
int numDroids = 80;
int numWeightsInNN;
GeneticAlgo genAlg;
Genome[] thePopulation;
PGraphics graph;
PrintWriter saveOut;

boolean display = true;

void setup(){
  size(8640, 400);
  graph = createGraphics(750,130);
  graph.beginDraw();
  graph.background(255);
  graph.line(0,0,0,graphH);
  graph.line(0,graphH-1,graphW,graphH-1);
  graph.endDraw();
  saveOut = createWriter("savedNetworkd.txt");
  box2d = new Box2DProcessing(this, 20);
  box2d.createWorld();
  box2d.setGravity(0,-30);
  droids = new Droid[numDroids];
  boundaries = new Boundary[]{
    new Boundary(width/2, height-50, width, 10, 0),
    new Boundary(width-5, height/2, 10, height, 0),
    new Boundary(5, height/2, 10, height, 0)
  };
  
  for (int i=0; i<numDroids; i++){
    droids[i] = new Droid(100,height-140);
  }
  
  numWeightsInNN = 2*droids[0].brainF.totalWeights;
  
  genAlg = new GeneticAlgo(numDroids, numWeightsInNN);
  thePopulation = new Genome[numDroids];
  arrayCopy(genAlg.population, thePopulation);
  
  
  for (int i=0; i<numDroids; i++){
    float[] weightsB = subset(thePopulation[i].weights, 0, numWeightsInNN/2);
    float[] weightsF = subset(thePopulation[i].weights, numWeightsInNN/2, numWeightsInNN/2);
    droids[i].brainB.putWeights(weightsB);
    droids[i].brainF.putWeights(weightsF);
  }
}

void draw(){
  box2d.step();
  
  if((iTicks++ < NUM_GEN_TICKS) && (!change)){
    for (int i=0; i<numDroids; i++){
      long initTime = System.nanoTime();
      droids[i].update();
      System.out.println(System.nanoTime() - initTime);

      float xVel = box2d.vectorWorldToPixels(droids[i].body.body.getLinearVelocity()).x;
      if (xVel<0) xVel = 0;
      droids[i].xVelNet += xVel;
      float x = box2d.coordWorldToPixels(droids[i].body.body.getWorldCenter()).x;
      if (x<100) x = 100;
      thePopulation[i].fitness = sq((x-100)/10);
    }
  }else {
    genAlg.generation++;
    iTicks = 0;
    Genome[] newPop = genAlg.epoch(thePopulation);
    arrayCopy(newPop, thePopulation);
    for (int i=0; i<numDroids; i++){
      droids[i].killBody();
      Droid d = new Droid(100, height-140);
      float[] weightsB = subset(thePopulation[i].weights, 0, numWeightsInNN/2);
      float[] weightsF = subset(thePopulation[i].weights, numWeightsInNN/2, numWeightsInNN/2);
      d.brainB.putWeights(weightsB);
      d.brainF.putWeights(weightsF);
      droids[i] = d;
    }
    change = false;
    graph.beginDraw();
    graph.stroke(255,0,0);
    graph.point(genAlg.generation*graphW/1500 + 1, graphH - genAlg.bestFitness*graphH/sq((width-100)/10) - 2);
    graph.stroke(0,255,0);
    graph.point(genAlg.generation*graphW/1500 + 1, graphH - genAlg.averageFitness*graphH/sq((width-100)/10) - 2);
    graph.stroke(0,0,255);
    graph.point(genAlg.generation*graphW/1500 + 1, graphH - genAlg.worstFitness*graphH/sq((width-100)/10) - 2);
    graph.endDraw();
  }
  
  genAlg.calculateBestWorstAvTot();
  if (inacTotFitness == (int) genAlg.totalFitness){
    inactivityTime++;
  }else {
    inactivityTime = 0;
    inacTotFitness = (int) genAlg.totalFitness;
  }
  
  if (inactivityTime >= 600){
    change = true;
    inactivityTime = 0;
    inacTotFitness = 0;
  }
  
  background(255);
  image(graph, 200, 10);
  text("Generation: "+str(genAlg.generation+1), 30, 30);
    text("Ticks: "+str(iTicks), 30, 40);
    text("inactivityTime: "+str(inactivityTime), 30, 50);
    text("TotalFitness: "+str(genAlg.totalFitness), 30, 60);
  if (display){
    for (Boundary wall : boundaries) {
      wall.display();
    }

    for (Droid droid : droids) {
      droid.display();
    }
  }
}

void keyPressed(){
  if (key == 'd'){
    display = !display;
  }
}