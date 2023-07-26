// mouse.pde
// a part of: Send_Nodes.pde
// (c) 2023 Kevin Blackistone
// Released for non-commercial use under MIT license 
// With additional restriction that no part of this code may be used 
// commercially without expressed written consent of the author.


void mousePressed() {
  empty = true;

  // NODES
  if (mouseX > _uiWidth) {

    float dist = 0;
    for (int i = 0; i < nodes.size(); i++) {

      float x = nodes.get(i).x();
      float y = nodes.get(i).y();
      dist = dist(x, y, mouseX, mouseY);

      if (dist < _rad) {
        empty = false;

        if (!shiftDn) {
          // println("idx: " +i+"\tassigned: "+nodes.get(i).getCtrl()+ "\ttriggy: " + numTrigs.get(nodes.get(i).getCtrl()) );
          activeIndex = i;
          nodeSeq.selected = -1; 
          biasToSeq = false;
        }
      }
    }

    if (empty) {
      nodes.add(new Node(mouseX, mouseY, ' '));
    }
  } else {

    // SEQUENCERS
    if (nodeSeq.over) {
      if (nodeSeq.selected != nodeSeq.overStep) {
        nodeSeq.selected = nodeSeq.overStep;
        biasToSeq = true;
      } else 
      {
        nodeSeq.selected = -1;
        biasToSeq = false;
      }
    } else if (pitchSeq.over) {
      if (pitchSeq.selected != pitchSeq.overStep) {
        pitchSeq.selected = pitchSeq.overStep;
      } else 
      {
        pitchSeq.selected = -1;
      }
    }

    // BUTTONS
    if (oscWob.isOver() ) oscWob.on = !oscWob.on;
    else if (play.isOver()) play.on = !play.on;
    else if (drone.isOver() ) {
      if (drone.on) {
        for (int i = 0; i < _voces; i++) {

          tris[i].stop();
          sins[i].stop();
          saws[i].stop();
          puls[i].stop();
        }
      }
      drone.on = !drone.on;
    } else if (randomizer.isOver()) {        // SEQUENCER ON/OFF
      randomizer.on = !randomizer.on;
      // auto = randomizer.on;
    } else if (justEt.isOver()) {      // JUST INTONATION
      justEt.on = !justEt.on;
      justIntonation = justEt.on;
    } else if (reset.isOver()) {       // RESET
      if (shiftDn) reset.on = true;
    } else if (within(mouseX, 78, 252) && within(mouseY, 900, height) ) {   // PRESETS ZONE

      if (load.isOver() && shiftDn && (preIndex != -1) ) {
        for (Button b : pre) {
          b.select(false);
        }
        loadPre(preIndex);      
        pre[preIndex].select(true);
      } else if (save.isOver() && shiftDn && (preIndex != -1) ) {
        savePre(preIndex);
        for (Button b : pre) {
          b.select(false);
        }
        pre[preIndex].select(true);
      }

      for ( int i = 0; i < pre.length; i++) {
        if (pre[i].isOver()) {
          pre[i].make(true);
          preIndex = i;
        } else pre[i].make(false);
      }
    } else if (rec.isOver()) {
      rec.on = !rec.on;
      if (rec.on) {
        nodeSeq.setColor(red);
        pitchSeq.setColor(red);
        beatDisp.setColor(red);
      } else { 
        nodeSeq.setColor(wht);
        pitchSeq.setColor(wht);
        beatDisp.setColor(wht);
      }
    } else if (smooth.isOver()) {
      smooth.on = !smooth.on;
      pitchSeq.smoothing = smooth.on;
    } else if (smoothType.isOver()) {
      smoothType.on = !smoothType.on;
      if (smoothType.on) smoothType.name = "EASED";
      else smoothType.name = "LINEAR";
    } else if (sync.isOver()) {
      midiDevice += 1;
      if (midiDevice > syncDevs.length) midiDevice = 0;
      if (midiDevice == syncDevs.length) {
        sync.setOnTitel("INTERNAL");
        sync.setColor(grn);
        sync.on = true;
        extSync = false;
        extResync = false;
        myBus.removeInput(midiDevice-1);
        clock.reset();
      } else {
        if (syncDevs[midiDevice].length() > 14) sync.setOnTitel(syncDevs[midiDevice].substring(0, 14) + "...");
        else sync.setOnTitel(syncDevs[midiDevice]);
        sync.setColor(highlight);
        if (midiDevice > 0) myBus.removeInput(midiDevice-1);
        myBus.addInput(midiDevice);
        extResync = true;
        extSync = true;
      }
    }
  }
} 

void mouseDragged() {

  if (mouseX > _uiWidth)
  {
    if (newDrag) {
      for (int i = 0; i < nodes.size(); i++) {
        float dist = dist(nodes.get(i).x(), nodes.get(i).y(), mouseX, mouseY);
        if (dist < _rad) {

          dragNode = i;
          newDrag = false;
        }
      }
    }
    if (dragNode != -1) nodes.get(dragNode).set(mouseX, mouseY);
  }
}

void mouseReleased() {
  newDrag = true;
  dragNode = -1;
}

void mouseClicked(MouseEvent evt) {

  if (evt.getCount() == 2) {

    // CLEAR SEQUENCE STEP
    if (nodeSeq.isOver()) {
      nodeSeq.assigned[nodeSeq.overStep] = char(0);
      if (shiftDn) {
        nodeSeq.clearMod(nodeSeq.overStep);
      }
      biasToSeq = false;
    } 
    // CLEAR SEQUENCE STEP
    else if (pitchSeq.isOver()) {
      pitchSeq.assigned[pitchSeq.overStep] = char(0);
      if (shiftDn) {
        pitchSeq.clearMod(pitchSeq.overStep);
      }
      biasToSeq = false;
    } 
    // REMOVE NODE
    else {
      for (int i = 0; i < nodes.size(); i++) {

        float distance = sqrt(sq(mouseX - nodes.get(i).x()) + sq(mouseY - nodes.get(i).y()));
        if (distance < _rad) {

          // CLEAR PRIOR ASSIGNMENT OF THE NODE TO A KEY
          if ( within((int)nodes.get(i).getCtrl(), 48, 58) ) numTrigs.remove(nodes.get(i).getCtrl());

          // SHIFT OTHER KEY ADDRESSES
          for (char trig : numTrigs.keySet()) {
            if (numTrigs.get(trig) > i) {
              // println("replacing: " + numTrigs.get(trig) + " @: " + char(trig) + " with: " + (numTrigs.get(trig) - 1) );
              numTrigs.put(trig, numTrigs.get(trig) - 1);
            }
          }

          // NOW CLEAR
          nodes.remove(i);
          activeIndex = -1;
        }
      }
    }
  }
}
