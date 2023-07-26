// keys.pde
// a part of: Send_Nodes.pde
// (c) 2023 Kevin Blackistone
// Released for non-commercial use under MIT license 
// With additional restriction that no part of this code may be used 
// commercially without expressed written consent of the author.


void keyPressed() {

  // println(key + ":" + (char(key+32))+ ":" + char(key+48) + "\tn:" + int(key)+"\tsteps: "+halfSteps.get(key));
  if (rec.on) {
    if (within(int(key), 48, 57) ) {  // RECORD NODES

      // PLAY IT
      if (numTrigs.get(key) != null) {
        activeIndex = numTrigs.get(key);
        nodeSeq.assigned[nodeSeq.thisStep] = key;
      } 
      trigger();
    } else if (halfSteps.get(key) != null) {    // 
      int halves = halfSteps.get(key);
      char number = char(halves+48); // CONVERT SHIFT LETTER NOTE TO HALF STEPS NUMBER
      pitchSeq.assigned[pitchSeq.thisStep] = number;
    }
  } 
  {
    // TYPED SHIFTED NUMBER
    if (numbers.get(key) != null) {    // 
      char number = char(numbers.get(key)+48); // CONVERT SHIFT SYMBOL TO NUMBER

      // ASSIGN TO SEQUENCER
      if ( biasToSeq && (nodeSeq.selected != -1) ) {
        nodeSeq.assigned[nodeSeq.selected] = number;
      } 

      // ASSIGN TO NODES
      else if (activeIndex != -1) {

        // # NOT ASSIGNED
        if (numTrigs.get(number) == null) {
          nodes.get(activeIndex).setCtrl(number);
          numTrigs.put(number, activeIndex);
        } 
        // PRIOR ASSIGNMENT
        else {
          nodes.get(numTrigs.get(number)).setCtrl(char(0)); // CLEAR PRIOR USE ¿¿ numTrigs.remove(number) maybe better ??
          nodes.get(activeIndex).setCtrl(number);
          numTrigs.put(number, activeIndex);
        }
      }
    } 

    // TYPED NUMBER
    else if ( within(int(key), 48, 57) ) {

      // PLAY IT
      // println("num: " + key + " Twiger node: " + numTrigs.get(key));
      if (numTrigs.get(key) != null) {
        //if (activeIndex != -1) {
        activeIndex = numTrigs.get(key);
        trigger();
        //} else {
        //  activeIndex = -1;
        //}
      }
    }

    // PLAY NOTES
    else if (notes.get(key) != null) {
      if (justIntonation) noteAdj = just.get(key);
      else noteAdj = notes.get(key);
    }

    // ASSIGN NOTES TO SEQUENCE
    else if (halfSteps.get(char(key+32)) != null) {    // 

      int halves = halfSteps.get(char(key + 32));
      char number = char(halves+48); // CONVERT SHIFT LETTER NOTE TO HALF STEPS NUMBER

      // ASSIGN TO SEQUENCER
      if (pitchSeq.selected != -1) {
        pitchSeq.assigned[pitchSeq.selected] = number;
      }
    }

    // OTHER
    else if (key == CODED) {
      if (keyCode == SHIFT) {
        shiftDn = true;
      }

      // NEXT / PRIOR NODE
      if ((keyCode == LEFT) && (nodes.size() >0)) {
        activeIndex += 1;
        if (activeIndex > nodes.size() - 1) activeIndex = 0;
        nodes.get(activeIndex).selected = true;
        trigger();
      } else if ((keyCode == RIGHT) && (nodes.size() >0)) {
        activeIndex -= 1;
        if (activeIndex < 0) activeIndex = nodes.size()-1;
        trigger();
      } 

      // ACTIVATE / DEACTIVATE NODE
      else if (keyCode == UP) {
        if (activeIndex != -1) nodes.get(activeIndex).enabled = true;
      } else if (keyCode == DOWN) {
        if (activeIndex != -1) nodes.get(activeIndex).enabled = false;
      }
    } else if (key == ' ') {
      play.on = !play.on;
      beatDisp.on = !beatDisp.on;
      if (play.on) clock.reset();
    } 

    // CHANGE QUANTIZATION
    else if (key == '[') {

      if (nodeSeq.overAll) nodeSeq.moveDivision(-1);
      else if (pitchSeq.overAll) pitchSeq.moveDivision(-1);
      else if (divisionIndex - 1 >= 0) {
        divisionIndex--;
      }
    } else if (key == ']') {

      if (nodeSeq.overAll) nodeSeq.moveDivision(1);
      else if (pitchSeq.overAll) pitchSeq.moveDivision(1);
      else if (divisionIndex + 1 <= beatDiv.length-1) {
        divisionIndex++;
      }
    }

    // CHANGE SEQUENCER ACTIVE STEPS
    else if (key == '-') {
      if (nodeSeq.overAll) {
        if (nodeSeq.activeSteps - 1 > 0) nodeSeq.activeSteps--;
      } else if (pitchSeq.overAll) {
        if (pitchSeq.activeSteps - 1 > 0) pitchSeq.activeSteps--;
      }
    } else if (key == '=') {
      if (nodeSeq.overAll) {
        if (nodeSeq.activeSteps + 1 <= nodeSeq.steps) nodeSeq.activeSteps++;
      } else if (pitchSeq.overAll) {
        if (pitchSeq.activeSteps + 1 <= pitchSeq.steps) pitchSeq.activeSteps++;
      }
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      shiftDn = false;
    }
  }
}
