// slider.pde
// a part of: Send_Nodes.pde
// (c) 2023 Kevin Blackistone
// Released for non-commercial use under MIT license 
// With additional restriction that no part of this code may be used 
// commercially without expressed written consent of the author.


class UISlider {
  PVector loc;        // fader center
  int w, h, l;        // knob w/h & channel length
  float value;        // current value
  float pos;          // computed position from value
  float min, max;     // unadjusted low and high end
  float offset;       // x or y offset
  float shift=0;      // ammount of change
  String name, sub;        
  Boolean isVertical = true;
  Boolean over, locked, shifted;
  Boolean noBar = false;

  UISlider(float x, float y, int w_, int h_, int l_, float min_, float max_, String title, String affect) {
    loc = new PVector(x, y);
    w = w_;
    h = h_;
    l = l_;
    min = min_;
    max = max_;
    name = title;
    sub = affect;
    offset = loc.y - l/2;
  }

  UISlider(float x, float y, int w_, int h_, int l_, float min_, float max_, String title, String affect, boolean V_, float val) {
    loc = new PVector(x, y);
    w = w_;
    h = h_;
    l = l_;
    min = min_;
    max = max_;
    name = title;
    sub = affect;
    isVertical = V_;
    value = val;
    pos = map(value, min, max, 0, l);

    if (isVertical) offset = loc.y - l/2;
    else offset = loc.x - l/2;
  }

  void place(float newValue) {

    if (within(newValue, min, max)) { // SAFETY
      //if (isVertical) {
        value = newValue;
        pos = map(value, min, max, 0, l);
      //}
    }
  }

  void update() {
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
      float old = pos;
      if (isVertical) {

        pos = mouseY;

        if (pos < loc.y - l/2) pos = loc.y-l/2;
        else if (pos > loc.y + l/2) pos = loc.y + l/2;

        value = map(pos, loc.y-l/2, loc.y+l/2, min, max);
        pos -= offset;
        shift = pos - old;
      } else {

        pos = mouseX;

        if (pos < loc.x - l/2) pos = loc.x-l/2;
        else if (pos > loc.x + l/2) pos = loc.x + l/2;

        value = map(pos, loc.x-l/2, loc.x+l/2, min, max);
        pos -= offset;
        shift = pos - old;
      }
    }
  }

  boolean isOver() {

    if (isVertical) {

      if (within(mouseX, loc.x - w/2, loc.x + w/2) &&
        within(mouseY, pos - h/2 + offset, pos + h/2 + offset) ) return true;
      else return false;
    } else {

      if (within(mouseX, pos - w/2 + offset, pos + w/2 + offset) &&
        within(mouseY, loc.y - h/2, loc.y + h/2 ) ) return true;
      else return false;
    }
  }

  float getValue() {
    return value;
  }
  float getPos() {
    return pos;
  }

  void render() {

    pushMatrix();
    {
      translate(loc.x, loc.y);

      stroke(0);
      strokeWeight(0.5);
      fill(255, 164);
      textSize(12);
      rectMode(CENTER);
      textAlign(CENTER, TOP);

      if (isVertical) {
        // CHANNEL MARK
        if (!noBar) {            // EXTRA BULLSHIT FOR THE MAX/MIN OVERLAP
          stroke(255,16);
          strokeWeight(w/2);
          line(0, -l/2, 0, l/2);
          stroke(0);
          strokeWeight(0.5);
          line(0, -l/2, 0, l/2);
        }

        // FADER MARKS
        line(-w/3, pos-l/2-h/2, w/3, pos-l/2-h/2);
        line(-w/3, pos-l/2+h/2, w/3, pos-l/2+h/2);
        stroke(255);
        line(-w/2, pos-l/2, w/2, pos-l/2);

        // TITLE
        fill(255);
        textLeading(12);
        text(name, 0, l/2);
        textAlign(LEFT, BOTTOM);

        // VALUE
        if (value >= 10) text(int(value), 3, pos-l/2-h/2-2);
        else if (value >= 1) text(nf(value, 1, 1), 3, pos-l/2-h/2-2);
        else text(nf(value, 1, 2), 3, pos-l/2-h/2-2);
        textAlign(RIGHT, BOTTOM);
        text(sub, -3, pos-l/2-h/2-2);

        if (over) {
          rectMode(CENTER);
          fill(highlight);
          noStroke();
          rect(0, pos-l/2, w, h);
        }
      } else {

        // CHANNEL MARK
        stroke(255,16);
        strokeWeight(h/2);
        line(-l/2, 0, l/2, 0);
        stroke(0);
        strokeWeight(0.5);
        line(-l/2, 0, l/2, 0);

        //FADER MARKS
        line(pos-l/2-w/2, -h/3, pos-l/2-w/2, h/3);
        line(pos-l/2+w/2, -h/3, pos-l/2+w/2, h/3);
        stroke(255);
        line(pos-l/2, -h/2, pos-l/2, h/2) ;

        // TITLE
        fill(255);
        text(name, 0, h/2+3);
        textAlign(LEFT, BOTTOM);

        //VALUE
        if (value >= 10) text(int(value), pos-l/2+w/2+2, 0);
        else if (value >= 1) text(nf(value, 1, 1), pos-l/2+w/2+2, 0);
        else text(nf(value, 1, 2), pos-l/2+w/2+2, 0);
        textAlign(RIGHT, BOTTOM);
        text(sub, -3, pos-l/2-h/2-2);

        if (over) {
          rectMode(CENTER);
          fill(highlight);
          noStroke();
          rect(pos-l/2, 0, w, h);
        }
      }
    }
    popMatrix();
  }

  /*
  void slide() {
   if (isVertical) {
   pos = mouseY;
   if (pos < loc.y - l/2) pos = loc.y-l/2;
   else if (pos > loc.y + l/2) pos = loc.y + l/2;
   value = map(pos, loc.y-l/2, loc.y+l/2, min, max);
   } else {
   pos = mouseX;
   if (pos < loc.x - l/2) pos = loc.x-l/2;
   else if (pos > loc.x + l/2) pos = loc.x + l/2;
   value = map(pos, loc.x-l/2, loc.x+l/2, min, max);
   }
   }
   */
}
