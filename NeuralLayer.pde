class NeuralLayer{
  Neuron[] neurons;
  NeuralLayer(int numNeurons, int numInputsPerNeuron){
    neurons = new Neuron[numNeurons];
    for (int i=0; i<numNeurons; i++){
      neurons[i] = new Neuron(numInputsPerNeuron);
    }
  }
}