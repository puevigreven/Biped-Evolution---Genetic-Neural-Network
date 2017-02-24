class Droid{
  RevoluteJoint jBLB, jBLH, jBLF, jFLB, jFLH, jFLF;
  Gut body, upperBL, lowerBL, footBL, upperFL, lowerFL, footFL;
  NeuralNet brainF, brainB;
  Vec2 offsetBLB, offsetFLB, offsetBLH, offsetFLH, offsetBLF, offsetFLF, vTemp;
  
  float upperAngleB = 0.75f * PI;
  float lowerAngleB = -0.25f* PI;
  float upperAngleH = 0.0f  * PI;
  float lowerAngleH = -0.8f * PI;
  float upperAngleF = PI/6f;
  float lowerAngleF = -1*PI/3f;
  float motTor = 1000.0f;
  float xVelNet = 0;
  
  float h1 = 40; //hBody
  float h2 = 40; //hUpperL
  float h3 = 40; //hLowerL
  float w4 = 20; //wfoot
  float breadthFactor = 15; //breadth factor of all guts
  
  Droid(float x, float y){

    body = new Gut(x, y, 2*breadthFactor, h1);
    upperBL = new Gut(x, y+h1/2-10+h2/2, breadthFactor, h2);
    lowerBL = new Gut(x, y+h1/2-10+h2-10+h3/2, breadthFactor, h3);
    footBL = new Gut(x+w4/2-7, y+h1/2-10+h2-10+h3-7, w4, breadthFactor);
    upperFL = new Gut(x, y+h1/2-10+h2/2, breadthFactor, h2);
    lowerFL = new Gut(x, y+h1/2-10+h2-10+h3/2, breadthFactor, h3);
    footFL = new Gut(x+w4/2-7, y+h1/2-10+h2-10+h3-7, w4, breadthFactor);
    
    RevoluteJointDef rjdBLB = new RevoluteJointDef();
    offsetBLB = box2d.vectorPixelsToWorld(new Vec2(0, h1/2-5));
    rjdBLB.upperAngle = upperAngleB;
    rjdBLB.lowerAngle = lowerAngleB;
    rjdBLB.enableLimit = true;
    rjdBLB.maxMotorTorque = motTor;
    rjdBLB.initialize(body.body, upperBL.body, body.body.getWorldCenter().add(offsetBLB));
    jBLB = (RevoluteJoint) box2d.world.createJoint(rjdBLB);
    
    
    RevoluteJointDef rjdFLB = new RevoluteJointDef();
    offsetFLB = box2d.vectorPixelsToWorld(new Vec2(0, h1/2-5));
    rjdFLB.upperAngle = upperAngleB;
    rjdFLB.lowerAngle = lowerAngleB;
    rjdFLB.enableLimit = true;
    rjdFLB.maxMotorTorque = motTor;
    rjdFLB.initialize(body.body, upperFL.body, body.body.getWorldCenter().add(offsetFLB));
    jFLB = (RevoluteJoint) box2d.world.createJoint(rjdFLB);



    RevoluteJointDef rjdBLH = new RevoluteJointDef();
    offsetBLH = box2d.vectorPixelsToWorld(new Vec2(0, h2/2-5));
    rjdBLH.upperAngle = upperAngleH;
    rjdBLH.lowerAngle = lowerAngleH;
    rjdBLH.enableLimit = true;
    rjdBLH.maxMotorTorque = motTor;
    rjdBLH.initialize(upperBL.body, lowerBL.body, upperBL.body.getWorldCenter().add(offsetBLH));
    jBLH = (RevoluteJoint) box2d.world.createJoint(rjdBLH);



    RevoluteJointDef rjdFLH = new RevoluteJointDef();
    offsetFLH = box2d.vectorPixelsToWorld(new Vec2(0, h2/2-5));
    rjdFLH.upperAngle = upperAngleH;
    rjdFLH.lowerAngle = lowerAngleH;
    rjdFLH.enableLimit = true;
    rjdFLH.maxMotorTorque = motTor;
    rjdFLH.initialize(upperFL.body, lowerFL.body, upperFL.body.getWorldCenter().add(offsetFLH));
    jFLH = (RevoluteJoint) box2d.world.createJoint(rjdFLH);


    RevoluteJointDef rjdBLF = new RevoluteJointDef();
    offsetBLF = box2d.vectorPixelsToWorld(new Vec2(0, h3/2-breadthFactor/2));
    rjdBLF.upperAngle = upperAngleF;
    rjdBLF.lowerAngle = lowerAngleF;
    rjdBLF.enableLimit = true;
    rjdBLF.maxMotorTorque = motTor;
    rjdBLF.initialize(lowerBL.body, footBL.body, lowerBL.body.getWorldCenter().add(offsetBLF));
    jBLF = (RevoluteJoint) box2d.world.createJoint(rjdBLF);
    
    RevoluteJointDef rjdFLF = new RevoluteJointDef();
    offsetFLF = box2d.vectorPixelsToWorld(new Vec2(0, h3/2-breadthFactor/2));
    rjdFLF.upperAngle = upperAngleF;
    rjdFLF.lowerAngle = lowerAngleF;
    rjdFLF.enableLimit = true;
    rjdFLF.maxMotorTorque = motTor;
    rjdFLF.initialize(lowerFL.body, footFL.body, lowerFL.body.getWorldCenter().add(offsetFLF));
    jFLF = (RevoluteJoint) box2d.world.createJoint(rjdFLF);
    
    brainF = new NeuralNet();
    brainB = new NeuralNet();
  }
  
  void killBody(){
    body.killBody();
    upperBL.killBody();
    lowerBL.killBody();
    footBL.killBody();
    upperFL.killBody();
    lowerFL.killBody();
    footFL.killBody();
  }
  
  void display(){
    footBL.display();
    lowerBL.display();
    upperBL.display();
    body.display();
    lowerFL.display();
    upperFL.display();
    footFL.display();
  }
  
  void update(){
    float[] inputs = new float[brainF.numInputs];
    
    //Input Body angle
    inputs[0] = map(normalRelativeAngle(body.body.getAngle()), -1*PI, PI, 0, 1);
    //Input Joint angles
    inputs[1] = map(normalRelativeAngle(jBLB.getJointAngle()), lowerAngleB, upperAngleB, 0, 1);
    inputs[2] = map(normalRelativeAngle(jBLH.getJointAngle()), lowerAngleH, upperAngleH, 0, 1);
    inputs[3] = map(normalRelativeAngle(jBLF.getJointAngle()), lowerAngleF, upperAngleF, 0, 1);
    inputs[4] = map(normalRelativeAngle(jFLB.getJointAngle()), lowerAngleB, upperAngleB, 0, 1);
    inputs[5] = map(normalRelativeAngle(jFLH.getJointAngle()), lowerAngleH, upperAngleH, 0, 1);
    inputs[6] = map(normalRelativeAngle(jFLF.getJointAngle()), lowerAngleF, upperAngleF, 0, 1);
    //Input Feet touch angle response
    float l = box2d.scalarPixelsToWorld(breadthFactor/2+2);
    float theta = lowerBL.body.getAngle();
    Vec2 temp = new Vec2(l*sin(theta), -1*l*cos(theta));
    Vec2 feetPointBL = footBL.body.getWorldCenter().add(temp);
    theta = lowerFL.body.getAngle();
    temp = new Vec2(l*sin(theta), -1*l*cos(theta));
    Vec2 feetPointFL = lowerFL.body.getWorldCenter().add(temp);
    boolean in1bool = boundaries[0].b.getFixtureList().testPoint(feetPointBL);
    boolean in2bool = boundaries[0].b.getFixtureList().testPoint(feetPointFL);
    float in1, in2;
    if (in1bool) in1 = 1;
    else in1 = 0;
    if (in2bool) in2 = 1;
    else in2 = 0;
    inputs[7] = in1;
    inputs[8] = in2;
    
    float[] outputsB = brainB.update(inputs);
    float[] outputsF = brainF.update(inputs);
    float s = 20.0f;
    
    RevoluteJoint[] jointsB = new RevoluteJoint[]{jBLB, jBLH, jBLF};
    RevoluteJoint[] jointsF = new RevoluteJoint[]{jFLB, jFLH, jFLF};
    float[] limits = new float[]{lowerAngleB, lowerAngleH, lowerAngleF, upperAngleB, upperAngleH, upperAngleF};
    
    for (int i=0; i<outputsB.length; i++){
      float o = outputsB[i];
      //if (o>=-0.5 && o<=0.5){
        //o*=2;
        //print(o+",");
        jointsB[i].setMotorSpeed(s*(map(o,0,1,limits[i], limits[i+3])-normalRelativeAngle(jointsB[i].getJointAngle())));
        //joints[i].setMotorSpeed(s*o);
        jointsB[i].enableMotor(true);
      //}else jointsB[i].enableMotor(false);
    }
    
    for (int i=0; i<outputsF.length; i++){
      float o = outputsF[i];
      //if (o>=-0.5 && o<=0.5){
        //o*=2;
        //print(o+",");
        jointsF[i].setMotorSpeed(s*(map(o,0,1,limits[i],limits[i+3])-normalRelativeAngle(jointsF[i].getJointAngle())));
        jointsF[i].enableMotor(true);
      //}else jointsF[i].enableMotor(false);
    }
    
    //print("\n");
  }
  
  float normalRelativeAngle(float angle) {
    return (angle %= TWO_PI) >= 0 ? (angle < PI) ? angle : angle - TWO_PI : (angle >= -PI) ? angle : angle + TWO_PI;
  }
  
  int signum(float x){
    if (x>0) return 1;
    else if (x<0) return -1;
    else return 0;
  }
}