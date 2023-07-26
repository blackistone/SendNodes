// Clock.pde
// a part of: Send_Nodes.pde
// (c) 2023 Kevin Blackistone
// Released for non-commercial use under MIT license 
// With additional restriction that no part of this code may be used 
// commercially without expressed written consent of the author.

class Clock {
  int _bpm;     
  int _beat;        // length of one beat
  int _start;       // start time
  int _ppb = 24;    // p.ulses p.er b.eat (default 24 is MIDI standard)
  int t;            // current time
  int delta;        // time change
  int beatHit;      
  float progress;   // % of time through a beat  

  int measures;     // total measures
  int beats;        // current beat
  int extra;        // remaining ticks

  //int clock;        // clock pulse number per beat
  int ticks;        // total clock ticks since start

  Clock(int bpm) {
    _bpm = bpm;
    _beat = 60000 / _bpm;
    _start = millis();
    //priorClock=0;
    ticks = 0;
    //clock = 0;
  }

  void countTime() {
    t = millis();
    delta = t - _start;
    beatHit = t % _beat;
    progress = (float)beatHit / _beat;
    ticks = int((float)delta/_beat*_ppb);

    measures = floor(float(ticks / (_ppb*4))) + 1;
    beats = floor(float(ticks / _ppb)) % 4 +1;
    extra = ticks % _ppb;
  }

  void renderStats(float x, float y) {

    fill(255);    
    textAlign(LEFT, TOP);
    textSize(15);
    text(measures + ":"+beats+":" +nf(extra, 2), x, y);
  }
  void renderStats(float x, float y, color col) {

    fill(col);    
    textAlign(RIGHT, TOP);
    textSize(15);
    text(measures + ":"+beats+":" +nf(extra, 2), x, y);
  }

  void reTime(int bpm) {
    _bpm = bpm;
    _beat = 60000 / _bpm;
  }

  void reset() {        // reset for internal clock
    _start = millis();
  }

  int ticks() {
    return ticks;
  }
  void extRestart() {    // reset for external clock
    //_start = millis();
    ticks = 0;
  }

  void addTick() {
    ticks += 1;
    measures = floor(float(ticks / (_ppb*4))) + 1;
    beats = floor(float(ticks / _ppb)) % 4 +1;
    extra = ticks % _ppb;
  }
}
