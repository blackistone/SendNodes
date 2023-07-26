// Buttons.pde
// a part of: Send_Nodes.pde
// (c) 2023 Kevin Blackistone
// Released for non-commercial use under MIT license 
// With additional restriction that no part of this code may be used 
// commercially without expressed written consent of the author.

class Button {
  float x, y, w, h;
  boolean on, selected;
  String name;
  boolean circle;
  float bright = 0.75;
  color fill = color(255);

  // simple constructor
  Button(float x_, float y_, String name_, boolean go) {
    x = x_;
    y = y_;
    w = h = 20;
    name = name_;
    circle = true;
    on = go;
  }

  // fancy constructor
  Button(int x_, int y_, int w_, int h_, String name_, boolean type, boolean go, color col_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    name = name_;
    circle = type; // true - circle, false rectangle;
    on = go;
    selected = false;
    fill = col_;
  }

  // Mouse methods
  void click() {
    on = !on;
  }
  boolean isOver() {
    if ( (within(mouseX, x-w/2, x+w/2)) && 
      (within(mouseY, y-h/2, y+h/2) ) )  return true;
    else return false;
  }

  // data methods
  void make(boolean b_) {
    on = b_;
  }
  void select(boolean b_) {
    selected = b_;
  }  
  void setColor(color c_) {
    fill = c_;
  }

  // display
  void render() {

    pushMatrix();
    {
      translate(x, y);
      ellipseMode(CENTER);
      stroke(0);
      strokeWeight(0.5);
      noFill();
      if (on) fill(fill, bright*255);      // RENDER ON
      textSize(12);
      
      
      if (circle) {                        // RENDER CIRCLE VERSION
        ellipse(0, 0, w, h);
        textAlign(CENTER, TOP);
        fill(255);
        text(name, 0, h/2+2);
      } else {                             // RENDER RECTANGLE VERSION
        rectMode(CENTER);        
        rect(0, 0, w, h);    
        textAlign(CENTER, CENTER);
        fill(0);
        textSize(12);
        text(name, 0, -2);
      }
      
      if (selected) {                      // HIGHLIGHT SELECTED
        rectMode(CENTER);
        noFill();
        strokeWeight(3);
        stroke(255, 255, 0, 64);
        rect(0, 0, w-6, h-6, 6, 6, 6, 6);
        fill(0);
        textAlign(CENTER, CENTER);
        textSize(14);
        text(name, 0, -2);
      }
      if ( within(mouseX, x+w/2, x-w/2) && within(mouseY, y+h/2, y-h/2) ) {
        rectMode(CENTER);
        fill(highlight);
        noStroke();
        rect(0, 0, w+2, h+2, 6,6,6,6);
      }
    }
    popMatrix();
  }
}

class Multi {
  float x, y, w, h;
  boolean on, selected;
  String name;
  String tru, fals;
  float bright = 0.75;
  color fill = color(255);

  // simple constructor
  Multi(float x_, float y_, float w_, float h_, String name_, String on_, String off_, color col_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    name = name_;
    tru = on_;
    fals = off_;
    on = true;
    fill = col_;
  }

  // Mouse methods
  void click() {
    on = !on;
  }
  boolean isOver() {
    if ( (within(mouseX, x-w/2, x+w/2)) && 
      (within(mouseY, y-h/2, y+h/2) ) )  return true;
    else return false;
  }

  // data methods
  void make(boolean b_) {
    on = b_;
  }
  void select(boolean b_) {
    selected = b_;
  }  
  void setColor(color c_) {
    fill = c_;
  }
  void setOnTitel(String s_){
    tru = s_;
  }

  // display
  void render() {

    pushMatrix();
    {
      translate(x, y);
      ellipseMode(CENTER);
      stroke(0);
      strokeWeight(0.5);
      noFill();
      textSize(12); 
      // RENDER RECTANGLE VERSION
      if (on) fill(fill, bright*255);      // RENDER ON
      rectMode(CENTER);        
      rect(0, 0, w, h);    
      textAlign(LEFT, CENTER);
      fill(255);
      textSize(12);
      if (on) text(tru, 5-w/2, -1.5);
      else text(fals, 2, -2);

      textAlign(RIGHT, CENTER);
      text(name, -w/2-2,0);

      if (selected) {                      // HIGHLIGHT SELECTED
        rectMode(CENTER);
        noFill();
        strokeWeight(3);
        stroke(255, 255, 0, 64);
        rect(0, 0, w-6, h-6, 6, 6, 6, 6);
        fill(0);
        textAlign(CENTER, CENTER);
        textSize(14);
        text(name, 0, -2);
      }
      if ( within(mouseX, x+w/2, x-w/2) && within(mouseY, y+h/2, y-h/2) ) {
        rectMode(CENTER);
        fill(highlight);
        noStroke();
        rect(0, 0, w+3, h+3, 6,6,6,6);
      }
    }
    popMatrix();
  }
}

class Switch {
  float x, y, w, h;
  boolean on;
  String name, name2="";

  Switch(int x_, int y_, int w_, String name_, String name2_, boolean go) {
    x = x_;
    y = y_;
    w = w_;
    h = w * 1.5;
    name = name_;
    name2 = name2_;
    on = go;
  }

  void click() {
    on = !on;
  }
  boolean isOver() {
    if ( (within(mouseX, x-w/2, x+w/2)) && 
      (within(mouseY, y-h/2, y+h/2) ) )  return true;
    else return false;
  }
  void make(boolean b_) {
    on = b_;
  }

  void render() {
    pushMatrix();
    {
      translate(x, y);
      rectMode(CENTER);
      stroke(0);
      noFill();
      rect(0, 0, w, h, 3, 3, 3, 3);
      fill(255, 196);
      noStroke();

      if (!on) rect(.5, w/2-3, w-6, h/2-3);
      else rect(.5, -w/2+4.5, w-6, h/2-3);

      textAlign(CENTER, TOP);
      fill(255);
      text(name2, 0, h/2+2);
      textAlign(CENTER, BOTTOM);
      fill(255);
      text(name, 0, -h/2-2);

      if ( within(mouseX, x+w/2, x-w/2) && within(mouseY, y+h/2, y-h/2) ) {
        rectMode(CENTER);
        fill(highlight);
        noStroke();
        rect(0, 0, w, h, 4, 4, 4, 4);
      }
    }
    popMatrix();
  }
}
