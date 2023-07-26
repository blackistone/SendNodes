// hep.pde
// a part of: Send_Nodes.pde
// (c) 2023 Kevin Blackistone
// Released for non-commercial use under MIT license 
// With additional restriction that no part of this code may be used 
// commercially without expressed written consent of the author.

String help = 
"MIDI: Select MIDI and clock source at the top\n" +
"      Clock will turn red if not in beat until play is re-triggered by the MIDI source\n" +
"NODES: \n" +
"    CLICK: [EMPTY] Create new node    [NODE] Selects, Activate, Drag (+SHIFT to drag without selecting).\n" +
"    SHIFT + NUMBER: assign number trigger to active node.\n" +
"    NUMBER: Trigger / Activate assigned node\n" +
"DRAGGING OFF SCREEN or DOUBLE CLICK: to delete\n" +
"LEFT & RIGHT: Select and Trigger previous/next node (hold key to cycle through all nodes)\n"+ 
"UP & DOWN: Activate / Deactivate selected node\n"+
"\n" +
"LENGTH FILTER: Removes tones beyond length limits between nodes (high / lo pass)\n" +
"SHAKE: Add motion noise to nodes\n" +
"RAND: Randomized node activation - quantization randomized to .5x, x, 2x quantization multiplier.\n" +
"    '[' and ']' change quantization multiplier.\n" +
"PLAY: [spacebar] Play / Stop\n" +
"DRONE/ENV: Continuous play or triggered envelope\n" +
"REC: Live input sequencer data and automation \n" +
"JUST/ET: Select just intonation or equeal temperment ...for, y'know, delays and reverbs harmonizin'\n"+
"TUNE: +/- One Octave\n" +
"\n" +
"PLAYING 'NOTES': The keyboard can be played as a 12-note scaled in typical format with 'A' as base note\n" + 
"    Accepts MIDI note in from MIDI source\n" +
"    Notes shift the pitch, but do not trigger envelopes if active\n"+
"SEQUENCERS:\n" +
"    CLICK STEP to select/deselect\n" + 
"    WHEN HOVERING OVER THE SEQUENCER\n" +
"          '[' and ']' change quantization multiplier.\n" +
"          '-' amd '=' remove or add how many steps are played\n" +
"    DOUBLE CLICK: eliminate the assignmetn.\n" +
"          +SHIFT: eliminate all control data for step\n" +
"    SHIFT + SLIDER: Record sequencer affiliated automations.\n"+
"    OR PRESS REC TO RECORD AUTOMATIONS LIVE\n"+
"\n" +
"NODE & ENV: Selects/triggers nodes, Automates envelope settings\n" +
"    SHIFT + NUMBER: assigns number to active step\n" +
"    In ENV mode, nodes trigger the envelope\n" +
"      If no note is assigned to the number, the active node will re-trigger\n" +
"\n" +
"TONE: Records keyboard 'notes' and automates length cutoffs, shake and oscillator shape\n"+
"    SHIFT + NOTE KEY: assign note\n"+
"    SHIFT & DRAG LENGTHS: record length adjustments\n"+
"    SMOOTH: Interpolate between automation messages (linear of eased in/out)\n"+
"\n" +
"PRESETS: Select a preset, then SHIFT + [LOAD/SAVE]. Highlighted preset is last one loaded or saved\n"+
"RESET: Clears sequencers and nodes";

String startText = "CLICK ON GRID\n"+
"TO ADD NODES\n\n" +
"Select nodes to move and play sound\n\n" +
"(roll mouse over \"?\" box at top for further details)";

boolean firstRun =  true;
