// Sequencer.pde
// a part of: Send_Nodes.pde
// (c) 2023 Kevin Blackistone
// Released for non-commercial use under MIT license 
// With additional restriction that no part of this code may be used 
// commercially without expressed written consent of the author.


class Sequencer32 {
  int x, y;                     // TOP LEFT PLACEMENT
  String name;                  // TITLE
  int w, h, bs;                 // full w,h & box size
  int steps = 32;               // TOTAL STEPS AVAILABLE [IMMUATABLE]
  int activeSteps = 32;         // CURRENT STEPS PLAYING
  int rows = 4;                 // NUMBER OF ROWS TO DIVIDE STEPS INTO
  int thisStep = 0;             // CURRENT PLAY LOCATION STEP
  int selected = -1;            // SELECTED STEP

  boolean over = false;         // MOUSE IS OVER A STEP
  int overStep = 15;            // MOUSEOVER STEP
  boolean overAll = false;      // MOUSE ANYWHERE OVER THE GRID, FOR KEY MANIPULATIONS

  int _ppb = 24;
  int[]  beatDiv =     { 192, 144, 96, 72, 48, 32, 24, 16, 12, 8, 6, 4, 3, 2};
  String[] beatDivName = {"2o", "o.", "o", "1/2.", "1/2", "1/2T", "1/4", "1/4T", "1/8", "1/8T", "1/16", "1/16T", "1/32", "1/32T"};
  int overFlow = 0;             // Keep time > 1/4 note
  int divisionIndex = 6;
  boolean play = false;         // ON/OFF
  float progress;               // 0.0 - 1.0 how far through the active beat 
  float divisor;                // BEAT DIVISION DIVISOR

  color active = color(255);                // color when active

  char[] assigned = new char[steps]; // CHARACTER TRIGGER ASSIGNED TO STEP
  int modCount = 4;
  float[][] modulators = new float[steps][modCount];
  boolean reTriggers = true;     // DOES A STEP TRIGGER A NEW ENVELOPE

  boolean smoothing = false;

  Sequencer32(int x_, int y_, int w_, String name_, int steps_, int rows_) {
    x = x_;
    y = y_;
    w = w_;

    steps = steps_;
    activeSteps = steps;
    rows = rows_;

    h = (w / (steps/rows)) * rows;
    bs = h / rows;
    name = name_;


    for (int i = 0; i < steps; i++) {
      assigned[i] = char(0);
    } 
    for (int i = 0; i < steps; i++) {
      for (int j = 0; j < modCount; j++) {
        modulators[i][j] = -1;
      }
    }
  }

  char update(boolean play_, int clock_) {
    over = isOver();
    if (play_) advance(clock_);
    return assigned[thisStep];
  }


  // TIMING ETC
  void advance(int ticks) {
    int steps = floor(ticks / beatDiv[divisionIndex]);
    thisStep = steps % activeSteps;
  }
  void moveDivision(int inc) {
    divisionIndex += inc;
    if (divisionIndex > beatDiv.length-1) divisionIndex = beatDiv.length - 1;
    else if (divisionIndex < 0) divisionIndex = 0;
  }

  // MODULATORS
  float getData(int n) {

    if (n > modCount) return -1;
    return modulators[thisStep][n];
  }
  void setData(int n, float data) {
    modulators[selected][n] = data;
  }
  void setData(int n, float data, boolean recording) {
    if (recording) modulators[thisStep][n] = data;
  }
  void setSmooth(boolean b_) {
    smoothing = b_;
    smooth.on = b_;
  }
  boolean overSmooth() {
    return smooth.isOver();
  }
  Step findNext(int modulator) { // returns count to next element when smoothing in clock ticks

    for (int i = 1; i < activeSteps; i++) {
      int checkStep = (thisStep + i) % activeSteps;
      // println(i +"->" + checkStep + "modHere:" + modulators[checkStep][modulator]);
      if (modulators[checkStep][modulator] != -1) {
        int stepsBetween = checkStep;
        int ticksPerStep = beatDiv[divisionIndex];
        int totalTicks = i * ticksPerStep;
        Step step = new Step(checkStep, modulators[checkStep][modulator], totalTicks);
        return step;
      }
    }
    Step none = new Step(-1, 0, 0);
    return none;
  }

  void clearMod(int step) {
    for (int i = 0; i < modCount; i++) {
      modulators[step][i] = -1;
    }
  }
  void clearAll() {
    for (int i = 0; i < steps; i++) {
      assigned[i] = char(0);
    } 
    for (int i = 0; i < steps; i++) {
      for (int j = 0; j < modCount; j++) {
        modulators[i][j] = -1;
      }
    }
    activeSteps=steps;
  }

  void setColor(color c) {
    active = c;
  }

  boolean isOver() {

    overAll = false;
    if ( within(mouseX, x - w/2, x+w/2) && 
      within(mouseY, y-h/2, y+h/2) ) {
      pushMatrix();
      {
        rectMode(CENTER);
        stroke(255, 255, 0);
        noFill();
        translate(x, y);
        rect(0, 0, w+4, h+4);
      }
      popMatrix();
      overAll = true;
    }

    int row, bx, by;               // current row, box x,y,scale
    for (int i = 0; i < steps; i++) {

      row = floor(i/(steps/rows));

      bx = i * bs - (row * w);
      by = bs * row; 


      if (within(mouseX, x + bx - w/2, x + bx + bs - w/2) &&
        within(mouseY, y + by - h/2, y + by + bs - h/2) )  
      {
        overStep = i;
        return true;
      }
    } 
    overStep = -1;
    return false;
  }

  int stepCount() {
    return steps;
  }

  // FILES & TABLES
  String readSettingsTable() {
    String settings = "STEPS/DIVISION,"+activeSteps+","+divisionIndex;
    return settings;
  }
  void writeSettingsTable(int stp_, int div_) {
    activeSteps = stp_;
    divisionIndex = div_;
  }
  String printStepTable(int n) {
    String table = n+","+assigned[n]+","+modulators[n][0]+","+modulators[n][1]+","+modulators[n][2]+","+modulators[n][3];
    return table;
  }
  void writeStepTable(int n, char c_, float[] v_) {
    assigned[n] = c_;
    for (int i = 0; i < modulators[n].length; i++) {
      modulators[n][i] = v_[i];
    }
  }

  void render() {

    int row, bx, by; // current row, box x,y,scale
    pushMatrix();
    {
      textSize(12);
      textLeading(12);
      rectMode(CORNER);
      translate(x - w/2, y - h/2);
      for (int i = 0; i < steps; i++) {

        row = floor(i/(steps/rows));

        bx = i * bs - (row * w);
        by = bs * row; 

        stroke(0);
        strokeWeight(.5);
        noFill();
        if (i > activeSteps-1) fill(0, 196);
        else if (i == thisStep) fill(active, 127);
        if (i == selected) stroke(255);          


        rect(bx + 2, by + 2, bs - 4, bs - 4);
        if (assigned[i] != char(0)) {
          fill(255);
          textAlign(CENTER, CENTER);
          if (within(assigned[i], 58, 64)) text(int(assigned[i])-48, bx + bs / 2, by + bs / 2);
          else text(assigned[i], bx + bs / 2, by + bs / 2);
        }
        for (int j = 0; j < modCount; j++) {
          boolean ctrl = false;
          if (modulators[i][j] != -1) ctrl = true;
          if (ctrl) {
            strokeWeight(4);
            point(bx+(6*j+3), by+3);
            strokeWeight(.5);
          }
        }
        if (i == overStep) {
          noStroke();

          fill(highlight);
          rect(bx, by, bs, bs);
        }
      }

      fill(255);
      stroke(0);
      textAlign(LEFT, TOP);
      text("STEP: " + thisStep + " : " + activeSteps, 0, h);
      textAlign(RIGHT, TOP);
      text("DIVISION: " + beatDivName[divisionIndex], w, h);
      textAlign(CENTER, TOP);
      text("\n" + name, w/2, h);
    }
    popMatrix();
  }
}

class Step {
  public int index = 0;
  public float value = 0;
  public int duration = 0; // DURATION UNTIL VALUE IN TICKS

  Step(int i_, float v_, int d_) {
    index = i_;
    value = v_;
    duration = d_;
  }
  Step() {
  }
}


// SEQUENCER FUNCTIONS
// ************************************************************************ 

int[] ticksPerMod = {0, 0, 0, 0};
float[] initialValue = new float[4];
boolean[] modsHere = {false, false, false, false};
Step[] easeStep = new Step[4];
float oscTempFromX, oscTempFromY, oscTempToX, oscTempToY, oscMidX, oscMidY;
PVector oscNewVector;

void playSequencers() {
  float percent = 0;
  float value = 0;


  // NODE SEQUENCER PLAY
  currentStep = nodeSeq.thisStep;
  seqTrig = nodeSeq.update(play.on, clock.ticks());
  if (play.on) {

    if (currentStep != nodeSeq.thisStep) {
      // MOVE CONTROLS BEFORE NODE TRIGGER
      if (nodeSeq.getData(0) != -1) {
        a = nodeSeq.getData(0);
        aUI.place(a);
      } 
      if (nodeSeq.getData(1) != -1) {
        d = nodeSeq.getData(1);
        dUI.place(d);
      } 
      if (nodeSeq.getData(2) != -1) {
        s = nodeSeq.getData(2);
        sUI.place(s);
      } 
      if (nodeSeq.getData(3) != -1) {
        r = nodeSeq.getData(3);
        rUI.place(r);
      }

      // SWITCH NODES
      if (seqTrig != char(0) ) {
        if (numTrigs.get(seqTrig) != null) activeIndex = numTrigs.get(seqTrig);        

        // TRIGGER ENVELOPE
        if (!drone.on) {
          trig = true;
          adsrInit = true;
        }
      }
    }
  }

  // PITCH SEQUENCER PLAY
  currentStep = pitchSeq.thisStep;
  seqTrig = pitchSeq.update(play.on, clock.ticks());
  if (play.on) {


    if (pitchSeq.smoothing) {
      for (int i = 0; i < pitchSeq.modulators[0].length; i++) {// Shouldn't Hard code this, # of potential modulators)
        if (i < 3) {
          if (currentStep != pitchSeq.thisStep) { // get new info for a new step with new data per mod.
            // GET NEW DISTANCE 
            if (pitchSeq.getData(i) != -1) {
              easeStep[i] = pitchSeq.findNext(i);
              initialValue[i] = pitchSeq.getData(i);
              ticksPerMod[i] = clock.ticks();
              modsHere[i] = true;
              // println(i + " indx:" + easeStep[i].index +" dur:"+ easeStep[i].duration + " v:" + easeStep[i].value + " init_V:" + initialValue[i] + " start     Ticks:" + ticksPerMod[i]);
            }
          } else {
            if (modsHere[i]) {
              percent = float(clock.ticks() - ticksPerMod[i]) / easeStep[i].duration;
              if (smoothType.on) percent = cos((percent*PI)+PI)/2 + 0.5;
              value = lerp(initialValue[i], easeStep[i].value, percent);
              // println(initialValue[i] +"/"+easeStep[i].value+"\t"+(clock.ticks() - ticksPerMod[i])+"/" + easeStep[i].duration + "\t%: " + percent + "\tlerpd:" + value);
              if (i == 0) minUI.place(value);
              else if (i == 1) maxUI.place(value);
              else if (i == 2) shkUI.place(value);
            }
          }
        } else {
          if (currentStep != pitchSeq.thisStep) { 
            if (pitchSeq.getData(i) != -1) {
              easeStep[i] = pitchSeq.findNext(i);  
              oscTempFromX = splitCombinedVectorFloat( pitchSeq.getData(i) ).x;
              oscTempFromY = splitCombinedVectorFloat( pitchSeq.getData(i) ).y;
              oscTempToX = splitCombinedVectorFloat( easeStep[i].value ).x;
              oscTempToY = splitCombinedVectorFloat( easeStep[i].value ).y;

              ticksPerMod[i] = clock.ticks();
              modsHere[i] = true;
              // println(i + " indx:" + easeStep[i].index +" dur:"+ easeStep[i].duration + " v:" + easeStep[i].value + " init_V:" + initialValue[i] + " start     Ticks:" + ticksPerMod[i]);
            }
          } else {
            if (modsHere[i]) {
              percent = float(clock.ticks() - ticksPerMod[i]) / easeStep[i].duration;
              if (smoothType.on) percent = cos((percent*PI)+PI)/2 + 0.5;
              oscMidX = lerp(oscTempFromX, oscTempToX, percent);
              oscMidY = lerp(oscTempFromY, oscTempToY, percent);
              // println(oscMidX +"/"+oscMidY+"\t"+(clock.ticks() - ticksPerMod[i])+"/" + easeStep[i].duration + "\t%: " + percent);
              oscNewVector = new PVector(oscMidX, oscMidY);
              oscUI.place(oscNewVector);
            }
          }
        }
      }
    }

    // TYPICAL UNSMOOTHED
    if (currentStep != pitchSeq.thisStep) {
      // MOVE CONTROLS BEFORE NODE TRIGGER

      if (pitchSeq.getData(0) != -1) {
        minUI.place(pitchSeq.getData(0));
      } 
      if (pitchSeq.getData(1) != -1) {
        maxUI.place(pitchSeq.getData(1));
      } 
      if (pitchSeq.getData(2) != -1) {
        shkUI.place(pitchSeq.getData(2));
      }
      if (pitchSeq.getData(3) != -1) {

        float tempPos = pitchSeq.getData(3);
        PVector tempVector = splitCombinedVectorFloat(tempPos);
        oscUI.place(tempVector);
      }

      // SWITCH NODES
      if (seqTrig != char(0) ) {
        if (seqTrig - 48 < keyLookup.length) 
        {
          char noteKey = char(keyLookup[int(seqTrig-48)]);
          if (justIntonation) noteAdj = just.get(noteKey);
          else noteAdj = notes.get(noteKey);
        }
      }
    }
  }
}
