class GeneticAlgo{
  Genome[] population;
  int popSize;
  int chromoLength;
  float totalFitness=0, bestFitness=0, averageFitness=0, worstFitness=99999999;
  int fittestGenome = 0;
  float mutationRate = MUTATION_RATE;
  float crossoverRate = CROSSOVER_RATE;
  int generation =0;
  
  GeneticAlgo(int popSize_, int numWeights){
    popSize = popSize_;
    chromoLength = numWeights;
    population = new Genome[popSize];
    for (int i=0; i<popSize; i++){
      Genome g = new Genome(numWeights);
      for (int j=0; j<chromoLength; j++){
        g.weights[j] = random(-1,1);
      }
      population[i] = g;
    }
  }
  
  void mutate(float[] chromo){
    for (int i=0; i<chromo.length; i++){
      if (random(1) <mutationRate){
        float mutationVal = random(-1-chromo[i], 1-chromo[i]) * MAX_PERTURBATION;
        //float mutationVal = random(-1, 1) * MAX_PERTURBATION;
        chromo[i] += mutationVal;
      }
    }
  }
  
  Genome getChromoRoulette(){
    float slice = random(totalFitness);
    Genome theChosenOne = null;
    float fitnessSoFar = 0;
    
    for (int i=0; i<popSize; i++){
      fitnessSoFar += population[i].fitness;
      if (fitnessSoFar >= slice){
        theChosenOne = population[i];
      }
    }
    
    return theChosenOne;
  }
  
  float[][] crossover(float[] mum, float[] dad){
    float[] baby1 = new float[mum.length];
    float[] baby2 = new float[dad.length];
    float[][] ret = new float[2][mum.length];
    
    if ((random(1)>crossoverRate) || mum.equals(dad)){
      arrayCopy(mum, baby1);
      arrayCopy(dad, baby2);
      ret[0] = baby1;
      ret[1] = baby2;
      return ret;
    }
    
    int cp = int(random(0, chromoLength-1));
    for (int i=0; i<cp; i++){
      baby1[i] = mum[i];
      baby2[i] = dad[i];
    }
    for (int i=cp; i<mum.length; i++){
      baby1[i] = dad[i];
      baby2[i] = mum[i];
    }
    
    ret[0] = baby1;
    ret[1] = baby2;
    
    return ret;
  }
  
  Genome[] epoch(Genome[] oldPop){
    arrayCopy(oldPop, population);
    totalFitness = bestFitness = averageFitness = 0;
    worstFitness = 99999999;
    
    Arrays.sort(population);
    
    calculateBestWorstAvTot();
    
    //save NeuralNets to text file
    saveOut.println("----Generation: "+generation+"----");
    if (generation%25==0){
      for (int i=0; i<popSize; i++){
        for (int j=0; j<chromoLength; j++){
          saveOut.print(population[i].weights[j]+" ");
        }
        saveOut.println("");
      }
    }else {
      for (int j=0; j<chromoLength; j++){
        saveOut.print(population[fittestGenome].weights[j]+" ");
      }
      saveOut.println("");
    }
    saveOut.println("-------------------------");
    saveOut.flush();
    
    Genome[] newPop = new Genome[popSize];
    
    /*if (!((NUM_COPIES_ELITE * NUM_ELITE) % 2 == 0)){
      grabNBest(NUM_ELITE, NUM_COPIES_ELITE, newPop); 
    }*/
    
    int offsprings = 0;
    while(offsprings < popSize){
      Genome mum = getChromoRoulette();
      Genome dad = getChromoRoulette();
      float[] baby1 = new float[chromoLength];
      float[] baby2 = new float[chromoLength];
      float[][] babies = crossover(mum.weights, dad.weights);
      arrayCopy(babies[0], baby1);
      arrayCopy(babies[1], baby2);
      
      mutate(baby1);
      mutate(baby2);
      
      offsprings+=2;
      newPop[offsprings-2] = new Genome(baby1, 0f);
      newPop[offsprings-1] = new Genome(baby2, 0f);
    }
    
    arrayCopy(newPop, population);
    return population;
  }
  
  void calculateBestWorstAvTot(){
    totalFitness = 0;
    float highestSoFar = 0;
    float lowestSoFar = 99999999;
    
    for (int i=0; i<popSize; i++){
      if (population[i].fitness>highestSoFar){
        highestSoFar = population[i].fitness;
        fittestGenome = i;
        bestFitness = highestSoFar;
      }
      
      if (population[i].fitness < lowestSoFar){
        lowestSoFar = population[i].fitness;
        worstFitness = lowestSoFar;
      }
      
      totalFitness += population[i].fitness;
    }
    
    averageFitness = totalFitness/popSize;
  }
}