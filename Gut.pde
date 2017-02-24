class Gut{
  Body body;
  float w, h;
  
  Gut(float x, float y, float w_, float h_){
    w = w_;
    h = h_;
    
    BodyDef bd = new BodyDef();
    bd.position.set(box2d.coordPixelsToWorld(new Vec2(x,y)));
    bd.type = BodyType.DYNAMIC;
    
    body = box2d.createBody(bd);
    
    PolygonShape sd = new PolygonShape();
    float box2dw = box2d.scalarPixelsToWorld(w/2);
    float box2dh = box2d.scalarPixelsToWorld(h/2);
    sd.setAsBox(box2dw, box2dh);
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    fd.density = 4;
    fd.friction = 0.9;
    fd.filter.categoryBits = 0x0002;
    fd.filter.maskBits = ~0x0002;
    body.createFixture(fd);
  }
  
  public void killBody(){
    box2d.destroyBody(body);
  }
  
  public void display(){
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float a = body.getAngle();
    
    rectMode(PConstants.CENTER);
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(-a);
    fill(175);
    stroke(0);
    rect(0,0,w,h);
    fill(255,0,0);
    stroke(0);
    ellipse(0, 0, 4, 4);
    popMatrix();
  }
}