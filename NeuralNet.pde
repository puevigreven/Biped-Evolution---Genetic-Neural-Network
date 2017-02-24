class NeuralNet{
  int numInputs = 9;
  int numOutputs = 3;
  int numHiddenLayers = 1;
  int numNeuronsPerHiddenLayer = 5;
  int totalWeights;
  NeuralLayer[] neuralLayers = new NeuralLayer[numHiddenLayers+1];
  
  NeuralNet(){
    createNet();
  }
  
  void createNet(){
    //First hidden layer with numInputsPerNeuron = numInputs
    neuralLayers[0] = new NeuralLayer(numNeuronsPerHiddenLayer, numInputs);
    
    for (int i=1; i<numHiddenLayers; i++){
      neuralLayers[i] = new NeuralLayer(numNeuronsPerHiddenLayer, numNeuronsPerHiddenLayer);
    }
    
    //Output Layer
    neuralLayers[numHiddenLayers] = new NeuralLayer(numOutputs, numNeuronsPerHiddenLayer);
    totalWeights = 0;
    for (int i=0; i<neuralLayers.length; i++){
      NeuralLayer nl = neuralLayers[i];
      for (int j=0; j<nl.neurons.length; j++){
        Neuron n = nl.neurons[j];
        for (int k=0; k<n.weights.length; k++){
          totalWeights++;
        }
      }
    }
  }
  
  float[] getWeights(){
    float[] weights = new float[totalWeights];
    int iWeight = 0;
    for (int i=0; i<neuralLayers.length; i++){
      NeuralLayer nl = neuralLayers[i];
      for (int j=0; j<nl.neurons.length; j++){
        Neuron n = nl.neurons[j];
        for (int k=0; k<n.weights.length; k++){
          weights[iWeight] = n.weights[k];
          iWeight++;
        }
      }
    }
    return weights;
  }
  
  void putWeights(float[] weights){
    int iWeight = 0;
    for (int i=0; i<neuralLayers.length; i++){
      Neuron[] ns = neuralLayers[i].neurons;
      for (int j=0; j<ns.length; j++){
        float[] ws = ns[j].weights;
        for (int k=0; k<ws.length; k++){
          ws[k] = weights[iWeight]; 
          iWeight++;
        }
      }
    }
  }
  
  float[] update(float[] inputs){
    assert(inputs.length == numInputs);
    float[] outputs = new float[numOutputs];
    float[] internalOutputs = new float[numNeuronsPerHiddenLayer];
    float[] internalInputs = new float[numNeuronsPerHiddenLayer];
    
    //calculate for the first layer
    for (int i=0; i<neuralLayers[0].neurons.length; i++){
      Neuron n = neuralLayers[0].neurons[i];
      float netInput = 0;
      for (int j=0; j<n.weights.length-1; j++){
        netInput+=n.weights[j]*inputs[j];
      }
      netInput+=n.weights[n.weights.length-1]*BIAS;
      internalInputs[i] = sigmoid(netInput, ACTIVATION_RESPONSE);
    }
    
    //calculate for middle layers
    for (int i=1; i<neuralLayers.length-2; i++){
      NeuralLayer nl = neuralLayers[i];
      arrayCopy(internalInputs, internalOutputs);
      for (int j=0; i<nl.neurons.length; j++){
        Neuron n = nl.neurons[j];
        float netInput = 0;
        for (int k=0; k<n.weights.length-1; k++){
          netInput+=n.weights[k]*internalOutputs[k];
        }
        netInput+=n.weights[n.weights.length-1]*BIAS;
        internalInputs[j] = sigmoid(netInput, ACTIVATION_RESPONSE);
      }
    }
    
    //calculate for output layer
    for (int i=0; i<neuralLayers[neuralLayers.length-1].neurons.length; i++){
      Neuron n = neuralLayers[neuralLayers.length-1].neurons[i];
      float netInput = 0;
      for(int j=0; j<n.weights.length-1; j++){
        netInput+=n.weights[j]*internalInputs[j];
      }
      netInput+=n.weights[n.weights.length-1]*BIAS;
      outputs[i] = sigmoid(netInput, ACTIVATION_RESPONSE);
    }
    return outputs;
  }
  
  float sigmoid(float activation, float response){
    return (1 / ( 1 + exp(-1 * activation / response)));
  }
}