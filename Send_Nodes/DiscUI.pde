// DiscUI.pde
// a part of: Send_Nodes.pde
// (c) 2023 Kevin Blackistone
// Released for non-commercial use under MIT license 
// With additional restriction that no part of this code may be used 
// commercially without expressed written consent of the author.


class DiscUI {
  PVector loc;        // fader center
  float r;            // knob w/h & channel length
  float knobR = 10;
  int vars;           // number of variables to move between
  float[] values;     // value per control
  float[] weights;    // weight 0-1 of control
  PVector pos;        // computed position from value
  float min, max;     // unadjusted low and high end
  float offset;       // x or y offset
  float shift=0;      // ammount of change
  String name;
  String[] subs;  
  PVector[] points;

  Boolean isVertical = true;
  Boolean over, locked, shifted;

  DiscUI(float x, float y, float r_, String title, String[] names) {
    loc = new PVector(x, y);
    pos = new PVector(0.01, 0.01); // GIVES LIGHT MAGNITUDE TO FORCE WOBBLE FUNCTION


    r = r_;
    vars = names.length;
    values = new float[vars];
    weights = new float[vars];
    points = new PVector[vars];
    for (int i=0; i < vars; i++) {
      points[i] = new PVector(x, y);
      points[i].setMag(r);
      points[i].rotate(i * TWO_PI/vars);
    }

    name = title;
    subs = names;
  }



  void update() {

    float total = 0.;    // DO NOT DELETE, PROCESSING IS LYING, USED IN FOR LOOP BELOW
    shifted = false;
    if (isOver()) over = true; 
    else over = false;

    if (mousePressed && over) {
      locked = true;
    } 
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      shifted = true;

      pos.set(mouseX, mouseY);
      pos.sub(loc);
      // println(pos.mag() + "\t" + pos.heading() + "\t"+ pos.x + "\t"+pos.y);
      if (pos.mag() > r) {
        pos.setMag(r);
      }
    }

    for (int i = 0; i < vars; i++) {
      PVector mag = new PVector();
      mag.set(points[i].x, points[i].y);
      mag.sub(pos);
      values[i] = mag.mag()/(r*2);
      total += values[i];
    }
    for (int i = 0; i < vars; i++) {
      weights[i] = 1-values[i];
    }
  }

  boolean isOver() {

    float dist = dist(pos.x, pos.y, mouseX - loc.x, mouseY - loc.y);

    if (dist < knobR)  
    {
      pushMatrix();
      {
        ellipseMode(RADIUS);
        fill(highlight);
        noStroke();
        ellipse(mouseX, mouseY, knobR + 4, knobR + 4);
      }
      popMatrix();
      return true;
    } else return false;
  }

  boolean within(float v, float min, float max) {
    if ((v >= min) && (v <= max)) {
      return true;
    } else return false;
  }

  void wobble(float level) {

    float mag = map(noise((float)millis()/1000+5000), 0, 1, -r, r);
    float rot = map(noise((float)millis()/10000), 0, 1, -.2, .2); 

    pos.setMag(mag);
    pos.rotate(rot);
  }

  PVector getPos() {
    return pos;
  }
  float getPosAsMergedFloat() {
    float magnit = floor(pos.mag())*10;
    // println(pos.mag() + "\t" + magnit + "\tx:" + pos.x + "\ty:" + pos.y);

    float magAngle = magnit + pos.heading() + PI;
    // println(magAngle);
    return magAngle;
  }


  void place(float x_, float y_) {
    pos.set(x_, y_);
  } 
  void place(PVector vec) {
    pos = vec;
  } 

  void render() {

    pushMatrix();
    {
      translate(loc.x, loc.y);

      stroke(0);
      fill(blu);

      ellipseMode(RADIUS);
      ellipse(0, 0, r, r);
      fill(255, 127);
      ellipse(pos.x, pos.y, knobR, knobR);
      fill(255);
      textAlign(CENTER, TOP);
      text(name, 0, r+12);

      for (int i = 0; i < vars; i++) {
        strokeWeight(10);
        float angle = ((5 * PI / 2) - points[i].heading())%TWO_PI;


        if ((angle < PI/8) || (angle > TWO_PI - PI/8))  textAlign(CENTER, TOP);
        else if (within(angle, PI/8, 3*PI/8)) textAlign(LEFT, TOP);
        else if (within(angle, 3*PI/8, 5*PI/8)) textAlign(LEFT, CENTER);
        else if (within(angle, 5*PI/8, 7*PI/8)) textAlign(LEFT, BOTTOM);
        else if (within(angle, 7*PI/8, 9*PI/8)) textAlign(CENTER, BOTTOM);
        else if (within(angle, 9*PI/8, 11*PI/8)) textAlign(RIGHT, BOTTOM);
        else if (within(angle, 11*PI/8, 13*PI/8)) textAlign(RIGHT, CENTER);
        else if (within(angle, 13*PI/8, 15*PI/8)) textAlign(RIGHT, TOP);
        text(subs[i], points[i].x, points[i].y);


        stroke(255, weights[i]*255);
        strokeWeight(10);
        point(points[i].x, points[i].y);
        strokeWeight(1);
        line(pos.x, pos.y, points[i].x, points[i].y);
      }
    }
    popMatrix();
  }
}

PVector splitCombinedVectorFloat(float f) { 

  float tempMag = floor(f/10);
  float tempAngle = f - (tempMag*10) - PI;
  // println("Read Data" + tempMag + "\t@: " + tempAngle);
  PVector pv = new PVector(0.01, 0);
  pv.setMag(tempMag);
  pv.rotate(tempAngle);
  return pv;
}
