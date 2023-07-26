# SendNodes
## Nodal Distance Based Additive Synthesiser
2023 Kevin Blackistone
\
### Fatures
Dual step sequencers\
Keyboard assign and play\
Drone and Envelope play modes\
Randomizers\
In sequence playback by assign numbers\
note-based pitch-shift for tuned playback (equal temperment and just intonation)\
MIDI sync\
Present load/save\
\
### Production details
Produced using Processing 3.5.4 (some MIDIBus errors using processing 4 I haven't tried fixing)\
Requires Sound and MIDIBus libraries.\
Tested only on Mac OS, ¿may require some MIDI reconfiguration for PC?\
App in directory \
\
General functionality below, also available in-app with rollover or "?" icon\
\
## USE
MIDI: Select MIDI and clock source at the top\
-      Clock will turn red if not in beat until play is re-triggered by the MIDI source\
NODES: \
-    CLICK: [EMPTY] Create new node    [NODE] Selects, Activate, Drag (+SHIFT to drag without selecting).\
-    SHIFT + NUMBER: assign number trigger to active node.\
-    NUMBER: Trigger / Activate assigned node\
DRAGGING OFF SCREEN or DOUBLE CLICK: to delete
LEFT & RIGHT: Select and Trigger previous/next node (hold key to cycle through all nodes)\
UP & DOWN: Activate / Deactivate selected node\
\
LENGTH FILTER: Removes tones beyond length limits between nodes (high / lo pass)\
SHAKE: Add motion noise to nodes\
RAND: Randomized node activation - quantization randomized to .5x, x, 2x quantization multiplier.\
-    '[' and ']' change quantization multiplier.\
PLAY: [spacebar] Play / Stop\
DRONE/ENV: Continuous play or triggered envelope\
REC: Live input sequencer data and automation \
JUST/ET: Select just intonation or equeal temperment ...for, y'know, delays and reverbs harmonizin'\
TUNE: +/- One Octave\
\
PLAYING 'NOTES': The keyboard can be played as a 12-note scaled in typical format with 'A' as base note\
-    Accepts MIDI note in from MIDI source\
-    Notes shift the pitch, but do not trigger envelopes if active\
SEQUENCERS:\
-    CLICK STEP to select/deselect\
-    WHEN HOVERING OVER THE SEQUENCER\
-          '[' and ']' change quantization multiplier.\
-          '-' amd '=' remove or add how many steps are played\
-    DOUBLE CLICK: eliminate the assignment.\
-          +SHIFT: eliminate all control data for step\
-    SHIFT + SLIDER: Record sequencer affiliated automations.\
-    OR PRESS REC TO RECORD AUTOMATIONS LIVE\
\
NODE & ENV: Selects/triggers nodes, Automates envelope settings\
-    SHIFT + NUMBER: assigns number to active step\
-    In ENV mode, nodes trigger the envelope\
-      If no note is assigned to the number, the active node will re-trigger\
\
TONE: Records keyboard 'notes' and automates length cutoffs, shake and oscillator shape\
-    SHIFT + NOTE KEY: assign note\
-    SHIFT & DRAG LENGTHS: record length adjustments\
-    SMOOTH: Interpolate between automation messages (linear of eased in/out)\
\
PRESETS: Select a preset, then SHIFT + [LOAD/SAVE]. Highlighted preset is last one loaded or saved\
RESET: Clears sequencers and nodes";\
\
