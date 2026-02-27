# Introduction:
This lab's goal was ultimately to make a oscilliscope using our board. The goal was to plug in an audio input into our board and output a waveform centered around a trigger onto the screen, which moves in response to the frequency of the music. 

## Design/ Implementation:
For this lab, we were given a partially completed block diagram of the datapath, and partially completed code. Using these two partially completed items, I created the rest of the code to create my oscilliscope. My completed block diagram is attatched below, and it contains my updates signal names, widths, and more. Then, I had to create my datapath myself. In order to do this, I and C2C Herzog created a finite state machine in order to go between states. Using the signal wires from the datapath, as controls for the FSM, sw(0) = sw_ready, which tells me whether or not the Audio Codec Wrapper is spitting out good data. sw(1) = sw_last_address which tells me if I have reached the address that corresponds to the end of my screen, and I need to roll back around or not. sw(2) = sw_trigger tells me if there is a falling edge between the signal crossing over my trigger value, and if so, I begin to write to the BRAM. My control wire ouput table is also attatched to my FSM, and bits 0 and 1 of my cw control the counter that exists in my datapath, which counts up as I increase in address values, and compares the value to my predefined maximum value. Bit 2 controls whether I want to write or not, which is dependent on me being in my write state of my FSM or not. 
[Block_Diagram](https://usafa0-my.sharepoint.com/:p:/g/personal/c28asher_speicher_afacademy_af_edu/IQAB-J2Mpn4nQporMM1hhOdOAe_qlV-NVHrOsX0dpH4a3uA?email=james.trimble%40afacademy.af.edu&e=9t03KZ)
[Control_Unit_FSM](https://usafa0-my.sharepoint.com/:b:/g/personal/c28asher_speicher_afacademy_af_edu/IQBPxmRPZMUQSKkn_CHX8DsgASZq8vzgd3XskU6WZobjwtI?email=james.trimble%40afacademy.af.edu&e=cQNIwn)

### Test / Debug:
For this lab, there was a lot of debugging and testing. The moment that stood out the most was between Gatechecks 2 and 3, where my live signal would not work. My simulated signal was working great, however when I flipped the switch that I had tied to toggle between sim and live, I could not get a signal to show up. Troubleshooting for this took many forms. Initally, it started with me checking all of my syntax and code I had written, and finding no errors. Next I cleaned up my code, naming conventions, parenthesis, and more in an attempt to try to uncover a minor error breaking everything, however still no fix was attained. This then led me to completely changing things, like following the offical naming convention (even though I was sure it would not make a difference, and it did not) and changing from using 10 bits down to 9 bits, since everyone I knew who had working code was using 9 bits. Still no fix, and at this point it had been 2 full days. Next, I decided on a strategy to truly isolate the issue, because I was thinking the issue was with me inccorrectly imporinting a file into the project. I planned to import files one by one, until the project worked, then isolate the file that caused the issue in an attempt to find the issue. I informed Lt Col Trimble of my plan, and indicated that I was going to start with the IPs, namely the clock wizard. I sent my message at 2121 hrs on 17 February, and by 2125, Lt Col Trimble had pulled up my code and found the error in an incorrectly instatiated Clock Wizard. The fix was quite simple, and then my project worked again.
What this debugging experience reinforced for me was that the best way to debug is a systematic approach, breaking down the project and code into smaller and smaller sections until I can isolate the issue and fix it. It may be tedious and time consuming, but it is the best option towards avoiding frustration and saving time. 

#### Results:


**GateCheck #1:**
Demo'd to Lt Col Trimble on 11 February at 2209 via Teams. Achieved loading the pre defined data into the BRAM and displaying it onto the screen. The course website describes Gatecheck 1 as:
>By end of day 1 (submit by day 2), you must have started a Lab 2 Vivado project and downloaded the template files and drop in your Video, VGA, Scopeface, dvid, and tdms files from Lab 1 into your Lab 2 project in order to test your Lab 1 color_mapper works when you implement your BRAM using the two initialized BRAM components given in lab2_datapath.vhdl. This does not require that the audio wrapper (and clockwiz_1) or your control unit is working yet, so you do not need to include these vhdl files in your design yet if you don’t want to. Your color_mapper/video should continuously be reading the left and right BRAM signals displaying them on the monitor. You must implement Video entity (from Lab 1) to take the channel output from the left and right BRAMs and send it to the Channel 1 and 2 inputs to be displayed when the readL and readR values equal the row value. Implement this on the hardware and verify that your scopeface is still present and some values are being displayed for Channel 1 (at this point the scaling may be wrong).
I fully fufilled this requirement. 

**GateCheck #2:**
Demo'd to Lt Col Wyche on 17 February. Displayed the corrected signal from the pre defined data into the BRAM. The course website describes Gatecheck 2 as:
>By end of day 2 (submit by day 3), you must have implemented and connected the BRAM Address Counter to left and right BRAMs, instantiated the Audio Codec Wrapper in Simulation mode (sim_live = '0'), and your control unit, such that your control unit writes the simulated audio data to the left and right BRAM and you can see the waveforms plotted on the monitor. (at this point, since there is no trigger, the waveform may or may not be scrolling across the display and the scaling may be wrong. The simulated Audio Wrapper is continually sending out 1024 samples, and if your counter (with FSM) are in sync writing 1024 values, it will be writing the same 1024 values over and over, making the output waveforms on appear stationary. If you want the simulated waveforms to scroll as if they are not triggered, change your counter rollover to a lesser value like 640... remember there are only 640 columns on scopeface displayed. Another note about this counter: since your first column on your scopeface is column 20, should you initialize the counter at 20?).
I fully fufilled this requirement. 

**GateCheck #3:**
Demo'd to Lt Col Trimble on 22 February. Gatecheck 3 redos what was achieved in Gatecheck 2 with one key difference, being that the simulated data is no longer used. The website defines Gatecheck 3 as:
>By end of day 3 (submit by day 4), redo Gate Check 2, except with the Audio Codec Wrapper in Live mode (sim_live / is_live = '1'). (at this point, since there is no trigger, the waveform will be scrolling across the display). Also make connections to loopback the serial ADC input back out to the DAC output (i.e. send the signal back into the Codec). Once you implement the design on the board, you can verify functionality by applying an audio signal to the audio line in jack (blue) and listening to it on the audio line out jack (Green), and seeing the output on the monitor. After you finish Gate Check 3, this is a good time to implement proper triggering on the trig_volt value. Besides the hardware to create the SW to signal the trigger, you'll also need to add an initial state to "wait for trigger" in your FSM. The rest of the FSM is basically the same. If this does not work, you must create a Testbench to help debug why it is not working.
I fully fufilled this requirement. 

**Required Functionality:**
The course website describes required functionality as:
- Get a single channel of the oscilloscope to display with reliable triggering that holds the waveform at a single point on the left edge of the display (like having a fixed trigger_volt). A 220Hz waveform should display something similar to what is shown in the screenshot at the top of this page. Additionally, you must have the following done:
- The waveform displayed should be centered about the center of the grid (row 220)
- Use separate datapath and control unit.
- The Mini-C design technique can be used but is NOT required. However, your instructor will expect you create Lab2_cu using the state machine coding style used in Lesson 9, with a process for state transitions, separated from a CSA LUT section for generating the output CWs.
- Your datapath must use processes which are similar to our basic building block (counter, register, mux, etc.). I do not want to see one massive process that attempts to do all the work in the datapath.
I fully fufilled all of these requirements.

**B Functionality:**
The course website describes B-level functionality as:
- Meet all the requirements of required functionality.
- Add a second channel (in green).
- Include the flag register and exSel (and other ex___ signals) with their muxes as shown in the block diagram.
I fully fufilled all of these requirements. 

**A functionality:**
The course website describes A-level functionality as:
- Meet all the requirements of B-level functionality.
- Use the trigger voltage marker to establish the actual trigger voltage used to capture the waveform. As the trigger is moved up and down, you should see the point at which the waveform intersects the left side of the screen change. The trigger arrow marker must be calibrated with the start of the waveform at column 20.
- Integrate the button debouncing strategy in HW #7 (or an equivalent debouncing method) to debounce the buttons controlling the trigger time and trigger voltage.
- Move the trigger volt and trigger time cursors on the screen using the buttons.
I fully fufilled all of these requirements.

##### Documentation Statement
For this assignment, Lt col Trimble helped me throughout the lab, and I worked side by side with C2C Herzog for a majority of the lab, but ultimately our code was our own. No unauthorized resources were used.