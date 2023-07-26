// Node.pde
// a part of: Send_Nodes.pde
// (c) 2023 Kevin Blackistone
// Released for non-commercial use under MIT license 
// With additional restriction that no part of this code may be used 
// commercially without expressed written consent of the author.


class Node {
  
  final static float r = _rad;  // Radius of node render circle
  PVector loc;
  PVector shake;
  // IntList links;
  char playKey;
  boolean enabled;
  boolean active=false;
  boolean selected;

  Node(float x, float y, char ck) {
    loc = new PVector(x, y);
    shake = new PVector(0,0);
    playKey = ck;
    enabled = true;
    selected = false;
  }
  Node(float x, float y, char ck, boolean enab_) {
    loc = new PVector(x, y);
    playKey = ck;
    enabled = enab_;
    selected = false;
  }

  void set(float x, float y) {
    loc.set(x, y);
  }

  void setCtrl(char ck) {
    playKey = ck;
  }

  float x() {
    return loc.x + shake.x;
  }
  float y() {
    return loc.y + shake.y;
  }
  
  void resetCtrl(){
    playKey = ' ';
  }
  
  char getCtrl(){
    return playKey;
  }
  
  String getNodeTable(){
    String nodeLine = playKey+","+loc.x +","+loc.y+","+int(enabled);
    return nodeLine;
  }
  void enable(boolean b_){
    enabled = b_;
  }

  void render() {
    stroke(0);
    ellipseMode(RADIUS);
    fill( (enabled ? 255 : 0), 127);
    float x = loc.x + shake.x;
    float y = loc.y + shake.y;
    circle(x, y, r);

    fill(0);
    textAlign(CENTER, CENTER);

    text(playKey, loc.x, loc.y);

    if (active) {
      noStroke();
      fill(255, 64);
      circle(x, y, r);
    } else if (selected) {     
      noFill();
      stroke(255);
      strokeWeight(5);
      point(x, loc.y);
      strokeWeight(.5);
    }
  }

  void vibrate(float level) {
    shake = new PVector(level*noise(millis()+loc.x)-level/2, level*noise(millis()+loc.y)-level/2 );
  }
}
