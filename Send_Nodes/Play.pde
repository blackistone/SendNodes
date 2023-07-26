// Play.pde
// a part of: Send_Nodes.pde
// (c) 2023 Kevin Blackistone
// Released for non-commercial use under MIT license 
// With additional restriction that no part of this code may be used 
// commercially without expressed written consent of the author.


// PLAY
void play(boolean _trig) {
  float volume;
  float env = (_trig ? getEnvelope() : 1.);
  float edgeAdj = 0.5 / sqrt((float)edgeCount); // lowers volume based on edge number


  float mix = edgeAdj * env * lvlUI.getValue();
  
  for (int i = 0; i < _voces; i++) {
    if (mix > 0.001) {
      if (freqs[i] > 20) {
        if (oscUI.weights[0] > 0.01) {
          volume =  oscUI.weights[0] * mix * 0.9 ;
          tris[i].pan(pans[i]);
          tris[i].play(freqs[i], volume);
        } else tris[i].stop();

        if (oscUI.weights[1] > 0.01)
        {
          volume =  oscUI.weights[1] * mix ;
          sins[i].pan(pans[i]);
          sins[i].play(freqs[i], volume);
        
        } else sins[i].stop();
        if (oscUI.weights[2] > 0.01)
        {
          volume =  oscUI.weights[2] * mix * 0.4;
          saws[i].pan(pans[i]);
          saws[i].play(freqs[i], volume);
        } else saws[i].stop();
        if (oscUI.weights[3] > 0.01)
        {
          volume =  oscUI.weights[3] * mix * 0.30 ;
          puls[i].pan(pans[i]);
          puls[i].play(freqs[i], volume);
        } else puls[i].stop();
      } else {
        tris[i].stop();
        sins[i].stop();
        saws[i].stop();
        puls[i].stop();
      }
    }
    freqs[i] = 0;
  }
}

// ***********************************************************
// ENVELOPE TRIGGERING
void trigger() {
  if (!drone.on) {

    trig = true;
    adsrInit = true;
  }
}

// GET ENVELOPED VOLUME ADJUSTMENT
float getEnvelope() {
  float _adsr;
  if (adsrInit) {
    // trigger.on = true;
    timeTotal = int(a + d + r);
    startTime = millis();
    adsrInit = false;
  }
  progress = millis()-startTime;
  if (progress < envMax) {
    if (progress < a) {
      _adsr = lerp(0., 1., progress/a);
    } else if (progress < a+d) {
      _adsr = lerp(1., s, (progress-a)/d);
    } else if (progress <= timeTotal) {
      _adsr = lerp(s, 0., (progress-(a+d))/r );
    } else _adsr = 0.;
  } else {
    _adsr = 0.;
    trig = false;
    // trigger.on = false;
  }

  drawADSR(a, d, s, r, 105, 540, 150, 30, float(progress)/envMax);
  return _adsr;
}

// ***********************************************************
// DRAW THE ENVELOPE
void drawADSR(float a, float d, float s, float r, float x, float y, float w, float h, float prog_) {

  float aw = a/7500*w;
  float dw = d/7500*w;
  float rw = r/7500*w;
  float sh = h - s*h;
  pushMatrix();
  {
    translate(x, y);
    rectMode(CORNERS);

    noStroke();
    fill(blu);
    rect(-2, -2, w+3, h+3, 6, 6, 6, 6);

    stroke(255);
    strokeWeight(1.5);
    line(0, h, aw, 0);
    line(aw, 0, aw+dw, sh);
    line(aw+dw, sh, aw+dw+rw, h);

    strokeWeight(0.5);
    line(prog_*w, 0, prog_*w, h);
  }
  popMatrix();
}

// ************************************************************
// QUANTIZED RANDOMIZER
int autoIncrement(int prior) {

  if (nodes.size() > 0) {
    int ticksSince = clock.ticks() % randomDivider;
    if (ticksSince < prior) {
      activeIndex = (int)random(nodes.size()-1);
      int rando = (int)random(randomizerMods.length);
      randomDivider = int(beatDiv[divisionIndex] * randomizerMods[rando]);
      if (randomDivider < 2) randomDivider = beatDiv[divisionIndex];        // PREVENTS FREEZING FROM DIVIDER OF or LESS THAN 1
    }

    return ticksSince;
  } else return 0;
}
