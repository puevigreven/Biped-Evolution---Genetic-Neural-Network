class Genome implements Comparable<Genome>{
  float[] weights;
  float fitness;
  
  Genome(int numWeights){
    weights = new float[numWeights];
    fitness = 0;
  }
  
  Genome(float[] w, float f){
    weights = w;
    fitness = f;
  }
  
  int compareTo(Genome g2){
    if (this.fitness > g2.fitness) return 1;
    else if (this.fitness <g2.fitness) return -1;
    else return 0;
  }
}