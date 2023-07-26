// utils.pde
// a part of: Send_Nodes.pde
// (c) 2023 Kevin Blackistone
// Released for non-commercial use under MIT license 
// With additional restriction that no part of this code may be used 
// commercially without expressed written consent of the author.


//this function will be called when raw MIDI data arrives
void rawMidi(byte[] data) {  

  // println(data + "\t" + int(data));
  if (data[0] == (byte)0xFA) {         // START.

    // reset timing when clock stops to stay in sync for the next start
    clock.extRestart();
    extResync = false;
    // println("STARTS");
  } else if (data[0] == (byte)0xF8) {  // MIDI clock pulse

    //we need to increase timing every pulse to get the total count
    clock.addTick();
  } else if (data[0] == (byte)0xFC) {    // STOP
  } else if (data[0] == (byte)0xFB) {    // CONTINUE
  }
}

void noteOn(int channel, int pitch, int velocity) {
  int octave = 0;
  int note;
  float mult;
  // Receive a noteOn from your midi device
  //println(6.875 * ( 
  //  pow(2.0, ( 
  //  (3.0 + ( pitch*1 )) / 12.0)))
  //  + "\t" + pitch);
  // pitch 48 = root c
  //if (pitch > 48) {
    octave = floor((pitch)/12) -2 ;
    note = pitch % 12;
  // println(octave + "\t" + note);
  //}
  mult = pow(2, octave) * justMIDI.get(note);
  // println(mult);
  noteAdj = mult;

  // 1 was level.value() from https://ponnuki.net/2011/05/diy-soft-synth-midi-controller-processing/
  // The calculation of the midi note to frequency is 6.875 * 2 exp ((3+note)/12)
  // I added one knob value in order to go trough all the note in the scale,
  // if your midi controller has a octave up and down that knob is not needed
}

PrintWriter preset;
String path = "Send_Nodes.app/Contents/Presets/";

void addLine(String line) {
  preset.println(line);
  println(line);
  delay(10);
}

// ***********************************************************
void savePre(int pre) {


  preset = createWriter(path+"preset"+pre+".txt");
  // SWITCHES/BUTTONS (w\o play, trig, reset)
  addLine("!SEND,HOT,NODES!,PRESET,SETTINGS,TABLE");
  addLine("WOBL," + int(oscWob.on)     + ",,,,"); //addLine("WOBL,"+int(oscWob.on)+",,,,");
  addLine("RAND," + int(randomizer.on)      + ",,,,");
  addLine("ADSR," + int(drone.on) + ",,,,");
  addLine("JUST," + int(justEt.on)     + ",,,,");


  // SLIDERS (w\o level)
  addLine("MIN," + minUI.getValue() + ",,,,");
  addLine("MAX," + maxUI.getValue() + ",,,,");
  addLine("BPM," + bpmUI.getValue() + ",,,,");
  addLine("SHK," + shkUI.getValue() + ",,,,");
  addLine("A,"   + aUI.getValue()   + ",,,,");
  addLine("D,"   + dUI.getValue()   + ",,,,");
  addLine("S,"   + sUI.getValue()   + ",,,,");
  addLine("R,"   + rUI.getValue()   + ",,,,");
  addLine("BEND,"+ pitch.getValue() + ",,,,");

  // OSC  
  addLine("OSC," + oscUI.getPos().x + "," + oscUI.getPos().y + ",,,");


  addLine("bpm_Division," + divisionIndex + ",,,,");

  // NODE SEQUENCER  
  addLine("NODESEQ-" + nodeSeq.readSettingsTable() + ",,,," );
  for (int i = 0; i < nodeSeq.stepCount(); i++) {
    addLine(nodeSeq.printStepTable(i) );
  }

  // PITCH SEQUENCER  
  addLine("PITCHSEQ-" + pitchSeq.readSettingsTable() + ",,,,");
  for (int i = 0; i < pitchSeq.stepCount(); i++) {
    addLine( pitchSeq.printStepTable(i) );
  }

  addLine("PitchSmooth," + int(smooth.on)     + ",,,,");
  addLine("SmoothType,"  + int(smoothType.on) + ",,,,");

  // NODES
  addLine("NODES," + nodes.size() + ",,,,");
  for (Node node : nodes) {
    addLine(node.getNodeTable()+",," );
  }

  preset.flush(); 
  preset.close();
}

// ***********************************************************
Table table;
ArrayList<String> lines = new ArrayList();

void loadPre(int pre) {

  modsHere =new boolean[]{false, false, false, false};

  println("READING TABLE");
  table = loadTable(path+"preset"+pre+".txt", "csv");
  float[] seqSet = new float[4]; 


  println(table.getStringRow(0));
  println(table.getStringRow(1));
  oscWob.make(table.getInt(1, 1) != 0);
  println(table.getStringRow(2));
  randomizer.make(table.getInt(2, 1) != 0);
  println(table.getStringRow(3));
  drone.make(table.getInt(3, 1) != 0);
  println(table.getStringRow(4));
  justEt.make(table.getInt(4, 1) != 0);

  println(table.getStringRow(5));
  minUI.place( table.getFloat(5, 1) );
  println(table.getStringRow(6));
  maxUI.place( table.getFloat(6, 1) );
  println(table.getStringRow(7));
  bpmUI.place( table.getFloat(7, 1) );
  println(table.getStringRow(8));
  shkUI.place( table.getFloat(8, 1) );
  println(table.getStringRow(9));
  aUI.place( table.getFloat(9, 1) );
  println(table.getStringRow(10));
  dUI.place( table.getFloat(10, 1) );
  println(table.getStringRow(11));
  sUI.place( table.getFloat(11, 1) );
  println(table.getStringRow(12));
  rUI.place( table.getFloat(12, 1) );
  println(table.getStringRow(13));
  pitch.place( table.getFloat(13, 1) );

  println(table.getStringRow(14));
  oscUI.place( table.getFloat(14, 1), table.getFloat(14, 2) );

  println(table.getStringRow(15));
  divisionIndex = table.getInt(15, 1);

  println(table.getStringRow(16) );
  nodeSeq.writeSettingsTable( table.getInt(16, 1), table.getInt(16, 2) );

  int row = 17;
  for (int i = 0; i < nodeSeq.steps; i++) {

    println(table.getStringRow(row+i));
    String ch = table.getString(row+i, 1);
    char c = ch.charAt(0);
    seqSet[0] = table.getFloat(row+i, 2);
    seqSet[1] = table.getFloat(row+i, 3);
    seqSet[2] = table.getFloat(row+i, 4);
    seqSet[3] = table.getFloat(row+i, 5);
    nodeSeq.writeStepTable(i, c, seqSet);
  }

  println(table.getStringRow(49));
  pitchSeq.writeSettingsTable( table.getInt(49, 1), table.getInt(49, 2) );

  row += 33;
  for (int i = 0; i < pitchSeq.steps; i++) {

    println(table.getStringRow(row+i));
    String ch = table.getString(row+i, 1);
    char c = ch.charAt(0);
    seqSet[0] = table.getFloat(row+i, 2);
    seqSet[1] = table.getFloat(row+i, 3);
    seqSet[2] = table.getFloat(row+i, 4);
    seqSet[3] = table.getFloat(row+i, 5);
    pitchSeq.writeStepTable(i, c, seqSet);
  } // 65

  println(table.getStringRow(66));
  smooth.make(table.getInt(66, 1) != 0);
  pitchSeq.setSmooth(smooth.on);
  println(table.getStringRow(67));
  smoothType.make(table.getInt(67, 1) != 0);
  smoothType.name = (smoothType.on ? "EASED" : "LINEAR");

  nodes.clear();
  row += 18;
  println(table.getStringRow(row));
  int nds = table.getInt(row, 1) + 1;
  for (int i = 1; i < nds; i++) {
    println(table.getStringRow(row+i));
    String ch = table.getString(row+i, 0);
    char c =  ch.charAt(0); 
    nodes.add( new Node(table.getFloat(row+i, 1), table.getFloat(row+i, 2), c, (table.getInt(row+i, 3) != 0) ) );
    if (c != ' ') numTrigs.put(c, i-1);
  }

  println("DONE");
  if (!extSync) clock.reset();
  activeIndex = -1;
}


// ***********************************************************
// IS A VALUE WITHIN A HIGH AND LOW : 
boolean within(float v, float low, float high) {

  if (high < low) {  // FLIP MISSORIENTED
    float temp = high; 
    high = low; 
    low = temp;
  }

  if ((v >= low) && (v <= high)) {
    return true;
  } else return false;
}

// CONVERT LINE LENGTH TO FREQUENCY
float toFreq(float dist) {

  float scaled = map(dist, _minLength, _maxLength, 1, 0);
  float freq = pow(4950, scaled) + 50;
  freq *= pow(2, pitch.value) * noteAdj;
  return freq;
}

// ***********************************************************
// CLEAR NODES OUT OF FRAME
void cleanUp() {

  for (int i = 0; i < nodes.size(); i++) {
    nodes.get(i).active = false;
    if (!within(nodes.get(i).loc.x, _uiWidth, width) || !within(nodes.get(i).loc.y, 0, height)) {
      dragNode = -1;
      nodes.remove(i);
      activeIndex = -1;
    }
  }
}

// ***********************************************************
void recordFaders() {

  if (aUI.shifted) a = aUI.value;
  else if (dUI.shifted) d = dUI.value;
  else if (sUI.shifted) s = sUI.value;
  else if (rUI.shifted) r = rUI.value;

  // ASSIGN MANUALLY
  if (shiftDn) {
    if (aUI.shifted) {
      if (nodeSeq.selected != -1) { 
        nodeSeq.setData(0, a);
      }
    } else if (dUI.shifted) {
      if (nodeSeq.selected != -1) {  
        nodeSeq.setData(1, d);
      }
    } else if (sUI.shifted) {
      if (nodeSeq.selected != -1) {  
        nodeSeq.setData(2, s);
      }
    } else if (rUI.shifted) {
      if (nodeSeq.selected != -1) {  
        nodeSeq.setData(3, r);
      }
    } else if (minUI.shifted) {
      if (pitchSeq.selected != -1) { 
        pitchSeq.setData(0, minUI.value);
      }
    } else if (maxUI.shifted) {
      if (pitchSeq.selected != -1) {  
        pitchSeq.setData(1, maxUI.value);
      }
    } else if (shkUI.shifted) {
      if (pitchSeq.selected != -1) {  
        pitchSeq.setData(2, shkUI.value);
      }
    } else if (oscUI.shifted) {
      if (pitchSeq.selected != -1) {  
        pitchSeq.setData(3, oscUI.getPosAsMergedFloat());
      }
    }
  }

  // LIVE RECORDING
  else if (rec.on) {
    if (aUI.shifted) {
      a = aUI.value; 
      nodeSeq.setData(0, a, true);
    } else if (dUI.shifted) {
      d = dUI.value; 
      nodeSeq.setData(1, d, true);
    } else if (sUI.shifted) {
      s = sUI.value;  
      nodeSeq.setData(2, s, true);
    } else if (rUI.shifted) {
      r = rUI.value; 
      nodeSeq.setData(3, r, true);
    } else if (minUI.shifted) {
      pitchSeq.setData(0, minUI.value, true);
    } else if (maxUI.shifted) { 
      pitchSeq.setData(1, maxUI.value, true);
    } else if (shkUI.shifted) {  
      pitchSeq.setData(2, shkUI.value, true);
    } else if (oscUI.shifted) {
      pitchSeq.setData(3, oscUI.getPosAsMergedFloat(), true);
    }
  }
}

// **********************************************************
// NOT QUITE FULL RESET
void clearAll() {
  nodes.clear();
  nodeSeq.clearAll();
  pitchSeq.clearAll();
  reset.on = false;
  numTrigs.clear();
  modsHere =new boolean[]{false, false, false, false};
  smooth.make(false);
  pitchSeq.setSmooth(false);
  randomizer.on = true;
  activeIndex = -1;
  clock.reset();
}
