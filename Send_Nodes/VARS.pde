// VARS.pde
// a part of: Send_Nodes.pde
// (c) 2023 Kevin Blackistone
// Released for non-commercial use under MIT license 
// With additional restriction that no part of this code may be used 
// commercially without expressed written consent of the author.


// ArrayList<Character> keys = new ArrayList<Character>();

static final int _w = 1280;
static final int _h = 960;


// TIME
// **********************************
int bpm = 120;
Clock clock;

// BEAT DIVISIONS
final int[]  beatDiv =       { 192,  144,  96,  72,    48,    32,    24,    16,     12,     8,      6,      4,       3,      2};
final String[] beatDivName = {"2o", "o.", "o","1/2.", "1/2","1/2T","1/4", "1/4T", "1/8", "1/8T", "1/16", "1/16T", "1/32", "1/32T"};
int divisionIndex = 6;   // INDEX if beatDiv[], DEFAULT 1/4note

// RANDOMIZER
final float[] randomizerMods = {0.5,1,2};
int randomDivider = 24;  // TIME DIVIDER for RANDOMIZER, DEFAULT 
int autoPrior = 0;       // KEEPS COUNT to DETERMINE NEXT RANDOM NODE ADVANCE

// SEQUENCERS
char seqTrig = char(0);  // TRIGGERED NOTE or NODE of a STEP
int currentStep = -1;    // ACTIVE STEP for NOTING TO TRIGGER CONTROLS - ONLY AT BEGINNING OF EACH STEP
boolean biasToSeq = false; // if the last activation was a node(f) or seq step(t)


// OSCILLATORS
// ***************************************************
final int _voces = 20;                  // MAX ACTIVE VOICES, EACH VOICE USES UP TO FOUR OSCILLATORS
float[] freqs = new float[_voces];      // FREQUENCIES OF ACTIVE VOICES PER FRAME
float[] pans = new float[_voces];       // PANS OF ACTIVE VOICES PER FRAME
SawOsc[] saws = new SawOsc[_voces];
TriOsc[] tris = new TriOsc[_voces];
Pulse[] puls = new Pulse[_voces];
SinOsc[] sins = new SinOsc[_voces];

// PITCH 
boolean justIntonation = true;
HashMap<Character, Float> notes = new HashMap<Character, Float>();                // CONVERT KEYBOARD NOTE INTO EQUAL TEMPERMENT FREQUENCY MULTIPLIER
HashMap<Character, Float> just = new HashMap<Character, Float>();                 // CONVERT KEYBOARD NOTE INTO JUST INTONATION FREQUENCY MULTIPLIER
HashMap<Integer, Float> justMIDI = new HashMap<Integer, Float>();                 // CONVERT HALF STEPS INTO JUST INTONATION MULTIPLIERS
HashMap<Character, Integer> halfSteps = new HashMap<Character, Integer>();        // CONVERT KEYBOARD NOTE INTO # of HALF STEPS UP FROM ROOT
final char[] keyLookup = {'a','w','s','e','d','f','t','g','y','h','u','j','k','o','l'}; // REVERSE LOOKUP KEY FROM # of HALF STEPS UP FROM ROOT
float noteAdj = 1;                                                                // CURRENT FREQUENCY MULTIPLIER

// INTERACTIVITY CONTROLS
boolean newDrag, empty, shiftDn; 

// NODE SPECIFICS
ArrayList<Node> nodes = new ArrayList<Node>();
HashMap<Character, Integer> numbers = new HashMap<Character, Integer>();     // SYMBOL ASSIGNMENTS OF SHIFT + NUMBER
HashMap<Character, Integer> numTrigs = new HashMap<Character, Integer>();    // NODE TRIGGERS BY ASSIGNED NUMBER
final static float _rad = 10.;     // VISUAL RADIUS OF NODE DOTS, kinda redundant with value within nodes class
int dragNode = -1;    // CURRENTLY DRAGGED NODE INDEX
int activeIndex = -1; // CURRENTLY PLAYING NODE
int edgeCount = 0;    // COUNTER FOR NUMBER OF ACTIVE/VOICED CONNECTIONS


// USER INTERFACE
// ***************************************

// PALETTE
color wht = color(255);
color blu = color(120, 120, 132);
color red = color(196, 72, 72);
color grn = color(92,160,92);
color grnLt = color(127,255,127);
color orng = color(196, 127, 64);
color highlight = color(255, 255, 0, 96);

// CONTROLS
final int _uiWidth = 280;
final float _minLength=10;
final float _maxLength=_h-80;
UISlider   minUI = new UISlider(27, _h/2, 30, 15, _h-80, _minLength, _maxLength, "", "MIN", true, 100.);
UISlider   maxUI = new UISlider(27, _h/2, 30, 15, _h-80, _minLength, _maxLength, "LENGTH\nFILTER", "MAX", true, 600.);

Button    beatDisp = new Button(27, 15, 15, 15, "", true, true, wht);
Multi      sync = new Multi(185, 15, 120, 15, "", "INTERNAL", "", grn);

Button    oscWob = new Button(85, 175., "WOBBLE", false);
DiscUI    oscUI = new DiscUI(180, 110, 75, "OSC BALANCE", new String[] {"TRI", "SIN", "SAW", "PULSE"});

Switch    randomizer = new Switch(75, 295, 20, "", "RAND", true);  
UISlider  bpmUI = new UISlider(120, 285, 30, 15, 120, 240, 60, "BPM", "", true, 120);
UISlider  lvlUI = new UISlider(240, 285, 30, 15, 120, 1, 0, "LeVeL", "", true, 0.5);
UISlider  shkUI = new UISlider(180, 285, 30, 15, 120, 50, 0, "SHAKE", "", true, 3.);

Button    play =   new Button(75, 400, 20, 20, "PLAY", true, true, wht);
Switch    drone = new Switch(75, 480, 20, "DRONE", "ENV", true);
UISlider  aUI = new UISlider(120, 450, 30, 15, 140, 2000, 0, "A", "", true, 100);
UISlider  dUI = new UISlider(160, 450, 30, 15, 140, 500, 0, "D", "", true, 30);
UISlider  sUI = new UISlider(200, 450, 30, 15, 140, 1., 0., "S", "", true, .9);
UISlider  rUI = new UISlider(240, 450, 30, 15, 140, 5000, 0, "R", "", true, 1000);
final int envMax = (2000+50+5000);
Button    rec = new Button(75, 548, 16, 16, "REC", true, false, red);

Sequencer32 nodeSeq = new Sequencer32(165, 640, 200, "NODES & ENV", 32, 4);
Sequencer32 pitchSeq = new Sequencer32(165, 760, 200, "TONE", 16, 2);
Button      smooth = new Button(_uiWidth - 27, 810, 55, 16, "SMOOTH", false, false, highlight);
Button      smoothType = new Button(80, 810, 51, 16, "EASED", false, true, wht);

Switch   justEt = new Switch(95, 855, 20, "JUST", "ET", true);
UISlider  pitch = new UISlider(185, 855, 15, 30, 140, -1, 1, "BEND", "", false, 0);

Button[] pre = {
  new Button(90, 910, 25, 25, "A", false, false, wht),
  new Button(115, 910, 25, 25, "B", false, false, wht),
  new Button(140, 910, 25, 25, "C", false, false, wht),
  new Button(165, 910, 25, 25, "D", false, false, wht),
  new Button(190, 910, 25, 25, "E", false, false, wht),
  new Button(215, 910, 25, 25, "F", false, false, wht),
  new Button(240, 910, 25, 25, "G", false, false, wht)
};
int preIndex = -1;

Button load = new Button(97, 940, 40, 15, "LOAD", false, false, wht);
Button save = new Button(230, 940, 40, 15, "SAVE", false, false, wht);

Button reset = new Button(_uiWidth-12, 910, 25, 25, "X", false, false, wht);


// ENVELOPE
float a=50;
float d=10;
float s=1.0;
float r=2000;
float adsr = 1.0;      // ADSR VOLUME MULTIPLIER
boolean adsrInit = false;
boolean trig = false;
int progress, startTime, timeTotal;


// Might be cleaner and more 'correct' as enums but also slower and this is working
void keyNotes() {
  notes.put('a', 1.0);
  notes.put('w', 1.0593271);
  notes.put('s', 1.1223241);
  notes.put('e', 1.1896025);
  notes.put('d', 1.2599388);
  notes.put('f', 1.3351681);
  notes.put('t', 1.4140673);
  notes.put('g', 1.4984709);
  notes.put('y', 1.5877675);
  notes.put('h', 1.6513761); // ?1.6818
  notes.put('u', 1.7822629); 
  notes.put('j', 1.8880734);
  notes.put('k', 2.0);
  notes.put('o', 2.119266);
  notes.put('l', 2.2446482);

  just.put('a', 1.0);        //
  just.put('w', (16./15.));  // ?12/11
  just.put('s', (9./8.));    //
  just.put('e', (6./5.));    //
  just.put('d', (5./4.));    // 
  just.put('f', (4./3.));    // 
  just.put('t', (45./32.));  // ?7/5
  just.put('g', (3./2.));    // 
  just.put('y', (8./5.));    //  
  just.put('h', (5./3.));    //
  just.put('u', (9./5.));    // ?7/4
  just.put('j', (15./8.));   // ?11/6
  just.put('k', (2.0));   
  just.put('o', (32./15.));  // 24/11
  just.put('l', (18./8.));   //

  justMIDI.put(0, 1.0);        //
  justMIDI.put(1, (16./15.));  // ?12/11
  justMIDI.put(2, (9./8.));    //
  justMIDI.put(3, (6./5.));    //
  justMIDI.put(4, (5./4.));    // 
  justMIDI.put(5, (4./3.));    // 
  justMIDI.put(6, (45./32.));  // ?7/5
  justMIDI.put(7, (3./2.));    // 
  justMIDI.put(8, (8./5.));    //  
  justMIDI.put(9, (5./3.));    //
  justMIDI.put(10, (9./5.));    // ?7/4
  justMIDI.put(11, (15./8.));   // ?11/6

  halfSteps.put('a', 0);
  halfSteps.put('w', 1);
  halfSteps.put('s', 2);
  halfSteps.put('e', 3);
  halfSteps.put('d', 4);
  halfSteps.put('f', 5);
  halfSteps.put('t', 6);
  halfSteps.put('g', 7);
  halfSteps.put('y', 8);
  halfSteps.put('h', 9);
  halfSteps.put('u', 10);
  halfSteps.put('j', 11);
  halfSteps.put('k', 12);
  halfSteps.put('o', 13);
  halfSteps.put('l', 14);

}

void shiftNums() {        // Used to assign number keys to nodes
  numbers.put('!', 1);
  numbers.put('@', 2);
  numbers.put('#', 3);
  numbers.put('$', 4);
  numbers.put('%', 5);
  numbers.put('^', 6);
  numbers.put('&', 7);
  numbers.put('*', 8);
  numbers.put('(', 9);
  numbers.put(')', 0);
}
