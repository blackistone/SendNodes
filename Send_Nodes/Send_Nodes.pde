// Send_Nodes.pde
// (c) 2023 Kevin Blackistone
// Released for non-commercial use under MIT license 
// With additional restriction that no part of this code may be used 
// commercially without expressed written consent of the author.
//
//
// Written in Processing v. 3.5.4 [some error with midi bus in processing 4]
// Tested only on Mac OS.
// TO DO?
// cleanup methods/variable access
// pause sound
// Delay if possible
// Make length filters have fade instead of cutoff


import processing.sound.*;
import java.util.Map; 
import themidibus.*;
MidiBus myBus;
int midiDevice = 0;          // CHOICE OF INPUT(S) OR INTERNAL CLOCK
String[] syncDevs;           // LIST OF MIDI INPUTS
boolean extSync = false;      // IS CLOCK EXTERNAL
boolean extResync = false;    // IS CLOCK IN SYNC - NEEDED WHEN CHANGING DEVICES


void setup() {

  println("\nFinding MIDI Devices...");
  syncDevs = MidiBus.availableInputs(); // for some reason putting up top prevents timeout failure?
  println("Found:");

  size(1280, 960, P2D);


  frameRate(60);
  hint(ENABLE_KEY_REPEAT);    // Required for key repeat in P2D
  smooth(8);
  //noSmooth();
  strokeCap(SQUARE);
  background(0);

  maxUI.noBar = true;                   // cheat method since there are two overlapping UIs for length

  println("Starting Clock...");
  clock = new Clock(bpm);               // make a clock

  println("Initializing Oscillators...");
  for (int i = 0; i < _voces; i++) {    // Initize all thems oscillators
    freqs[i] = 0;
    saws[i] = new SawOsc(this);
    tris[i] = new TriOsc(this);
    puls[i] = new Pulse(this);
    sins[i] = new SinOsc(this);
    println( "saw #" + (i+1) + "\ttri #" + (i+1) + "\tsqr #" + (i+1) + "\tsin #" + (i+1));
  }

  // Build the hashmaps used to find notes and frequency ratios from keys
  keyNotes(); 
  shiftNums();

  smoothType.bright = 0;

  // Assign the midi devices
  printArray(syncDevs);
  midiDevice = syncDevs.length;

  myBus = new MidiBus(this, 1, 0);
}

void draw() {

  // BACKGROUND & INACTIVE ELEMENTS 
  // ******************************
  background(127);

  stroke(255);                                    // NODE BACKGROUND
  fill(0, 127);
  rectMode(CORNERS);
  rect(_uiWidth, 0, width, height);

  for (int x = 1; x < 25; x++) {                  // DRAW GRID
    stroke(255, 32);      
    line(40*x+_uiWidth, 0, 40*x+_uiWidth, height);
  }
  for (int y = 1; y < 24; y++) {
    line(_uiWidth, 40*y, width, 40*y);
  }
  noStroke();                                      // LENGTH SLIDER BG
  fill(0, 24);
  rect(0, 00, 55, height);    
  fill(127, 145, 190, 64);                         // NODE SEQUENCER BG
  rect(55, 585, _uiWidth, 725);
  fill(200, 127, 200, 32);                         // TONE SEQUENCER BG
  rect(55, 725, _uiWidth, 820);
  line(_uiWidth, 0, _uiWidth, height);             // UI | NODE DIVIDING line
  fill(255);                                       // RANDOM QUANTIZATION
  textSize(12);
  textAlign(CENTER, TOP);
  text(beatDivName[divisionIndex], 75, 245);
  fill(0);                                         // HELP BOX
  rect(_uiWidth-15, 0, _uiWidth+15, 35);
  textAlign(LEFT, TOP);
  fill(255, 255, 0);
  textSize(30);
  text("?", _uiWidth-7, -1);

  // UPDATE CLOCK AND RENDER
  if (!extSync) {
    clock.countTime();
    clock.renderStats(120, 5, grnLt);
  } else if (extResync) clock.renderStats(120, 5, red);
  else clock.renderStats(120, 5);
  beatDisp.bright = 1-clock.progress;
  beatDisp.render();


  // UI ELEMENTS
  // ***********************************************
  minUI.update();
  maxUI.update();
  if ((minUI.shifted) && (minUI.getPos() >= maxUI.getPos() - 21)) {
    minUI.place(maxUI.getPos() - 21);
    minUI.locked = false;
  } else if ((maxUI.shifted) && (maxUI.getPos() <= minUI.getPos() + 21)) {
    maxUI.place(minUI.getPos() + 21);
    maxUI.locked = false;
  }

  sync.render();
  oscUI.update();
  if (oscWob.on) oscUI.wobble(2);
  bpmUI.update();
  if (bpmUI.shifted) clock.reTime((int)bpmUI.getValue());
  shkUI.update();
  lvlUI.update();

  aUI.update();
  dUI.update();
  sUI.update();
  rUI.update();

  playSequencers();

  pitch.update();

  minUI.render();
  maxUI.render();
  oscUI.render();
  oscWob.render();

  randomizer.render();
  bpmUI.render();
  shkUI.render();
  lvlUI.render();

  play.render();
  drone.render();
  aUI.render();
  dUI.render();
  sUI.render();
  rUI.render();

  rec.render();
  drawADSR(a, d, s, r, 105, 540, 150, 30, 0);  // a,d,s,r,x,y,w,h,progress

  nodeSeq.render();
  pitchSeq.render();
  smooth.render();
  if (smooth.on) smoothType.render();
  justEt.render();
  pitch.render();

  // PRESETS - kinduva mess
  pushMatrix();                            // DRAW ORANGE BACKGROUND
  {
    translate(165, 910);
    fill(orng);
    noStroke();
    rectMode(CENTER);
    rect(0, 0, 175, 25);
  }
  popMatrix();
  for (Button b : pre) {                  // RENDER PRESET BUTTONS
    b.bright = .25;
    b.render();
  }
  if (load.isOver()) {                    // LOAD BUTTON
    textAlign(CENTER, TOP);
    load.make(true);
    text("HOLD SHIFT", load.x, load.y+6);
  } else if (load.on) load.make(false);
  load.render();  
  if (save.isOver()) {                    // SAVE BUTTON
    textAlign(CENTER, TOP);
    save.make(true);
    text("HOLD SHIFT", save.x, save.y+6);
  } else if (save.on) save.make(false);
  save.render();  
  textSize(14);                           // PRESET TEXT
  fill(255, 196, 64); 
  text("PRESETS", 165, 938);

  pushMatrix();                           // RESET BUTTON
  { 
    translate(_uiWidth - 12, 910);
    fill(red);
    rectMode(CENTER);
    rect(0, 0, 25, 25); 
    if (reset.isOver()) {
      if (shiftDn) {
        stroke(255, 255, 0);
        fill(highlight);
        triangle( -12, 8, 0, -12, 12, 8);
      } else {

        fill(0);
        textAlign(CENTER, BOTTOM);
        text("HOLD\nSHIFT", -4, -13);
      }
    }
    popMatrix();    
    reset.render();
  }

  if ((!randomizer.on) && (play.on)) {
    autoPrior = autoIncrement(autoPrior); // RANDOMIZED PLAY
  }
  if (drone.on) play(false);
  else if (trig) play(true);

  // STORE FADE VALUES
  recordFaders();

  // NODE HANDLING
  // ***********************************************
  if (dragNode != -1) {                      // DRAG NODE
    nodes.get(dragNode).set(mouseX, mouseY);
  }
  for (int i = 0; i < nodes.size(); i++) {   // APPLY SHAKE
    nodes.get(i).vibrate(shkUI.value);
  }
  cleanUp();                                 // CLEAR OUT OF FRAME NODES
  calcAndDraw();                             // FIND FREQUENCIES TO PLAY AND DRAW NODES AND CONNECTIONS



  if (reset.on) clearAll();                  // ***RESET***

  if (within(mouseX, _uiWidth-15, _uiWidth+15) & within(mouseY, 0, 35)) {
    rectMode(CORNERS);
    fill(0, 64);
    rect(_uiWidth, 0, width, height);
    textSize(12);                                    // HELP TEXT
    textAlign(LEFT, TOP);
    fill(255);
    text(help, _uiWidth+20, 20);
  }

  if (firstRun) {
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(16);
    int cx = (width - _uiWidth)/2 + _uiWidth;
    text(startText, cx, height/2);
    if (nodes.size() != 0) {
      firstRun = false;
    }
  }

  String txt_fps = String.format(getClass().getName() + "[fps %6.2f]", frameRate);
  surface.setTitle(txt_fps);

  // textAlign(CENTER, BOTTOM);
  //text(mouseX+","+mouseY, mouseX, mouseY-5);
} // END OF DRAW



// ***********************************************************
void calcAndDraw() {

  edgeCount = 0;                                       // reset total edges = no of voices played
  stroke(0);
  strokeWeight(.5);  
  for (int i = 0; i < nodes.size(); i++) {
    int jCount = 0;                                    // Keeps track of how many lines are drawn for current node
    for (int j = i+1; j < nodes.size(); j++) {         // skip outer iterations

      if ((i != activeIndex) && (j != activeIndex)) {  // if either node is active, don't handle yet
        float distance = dist(nodes.get(i).x(), nodes.get(i).y(), nodes.get(j).x(), nodes.get(j).y()); 
        if (within(distance, minUI.getValue(), maxUI.getValue())) {
          jCount++;
          if (jCount < _voces) line(nodes.get(i).x(), nodes.get(i).y(), nodes.get(j).x(), nodes.get(j).y());    // Only draw if the line count for node i < voices
        }
      }
    }
  }

  noFill();                             // don't let beziers fill in a line between end points
  if (activeIndex >= nodes.size()) {    // Safety vs error elsewhere not cleaning up correctly
    println("INDEX:" + activeIndex + " not in range of current arraylist of size " + nodes.size() + " with max address of " + (nodes.size()-1) + "\nFIX YOUR SHIT");
  } else {
    if (activeIndex != -1) {                                  // Handle active nodes now
      nodes.get(activeIndex).selected = true;
      for (int i = 0; i < nodes.size(); i++) {                // iterate all other nodes...

        if (i == activeIndex) continue;                       // ...but kip if the same node

        float distance = dist(nodes.get(i).x(), nodes.get(i).y(), nodes.get(activeIndex).x(), nodes.get(activeIndex).y()); // Verify distance is in play range
        if (within(distance, minUI.getValue(), maxUI.getValue())) {

          if ((nodes.get(activeIndex).enabled) && (edgeCount < _voces)) {        // play only if voices haven't been maxed out

            nodes.get(activeIndex).active = true;                                // set active, get frequencys and pans
            freqs[edgeCount] = toFreq(distance); 
            pans[edgeCount] = map( (nodes.get(i).x() + nodes.get(activeIndex).x())/2, _uiWidth, width, -1, 1); 

            stroke(255);                                                         // draw vibrating white lines
            bezier(
              nodes.get(i).x(), nodes.get(i).y(), 
              nodes.get(i).x() + 20*noise(millis())-10, nodes.get(i).y() + 20*noise(millis()+1000)-10, 
              nodes.get(activeIndex).x() + 20*noise(millis()+3000)-10, nodes.get(activeIndex).y() + 20*noise(millis()+4000)-10, 
              nodes.get(activeIndex).x(), nodes.get(activeIndex).y() ); 
            edgeCount++;
          } else {                                                              // if no voices are left, draw static white line
            //stroke(127);          
            //line(nodes.get(i).x(), nodes.get(i).y(), nodes.get(activeIndex).x(), nodes.get(activeIndex).y());
          }
        }
      }
    }
  }
  // Render dots
  stroke(0); 
  for (int i = 0; i < nodes.size(); i++) {
    nodes.get(i).render(); 
    nodes.get(i).selected = false;      // clear selected flag to be redetermined by active of next cycle
  }
}
