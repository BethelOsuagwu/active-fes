

# Active FES system for hand/wrist rehabilitation following neurological injury
The Active FES system uses a software signal processing approach to extract voluntary EMG from a pair of muscles under electrical stimulation; and uses the extracted EMG as a control signal to modulate the intensity of the stimulation. It is used to augment intended movement with functional electrical stimulation (FES). 
## Apparatus
1. Hasomed Rehastim stimulator
2. Two channel EMG recorder with analogue input to MATLAB ([Biometrics DATALink system](http://www.biometricsltd.com/datalink.htm) (with [Surface EMG Sensor (SX230)](http://www.biometricsltd.com/surface-emg-sensor.htm) ) is the only tested and trusted device for this application)
2. Goniometer with analogue input to MATLAB.
3. MATLAB (tested on 32bit Version: 8.3.0.532 (R2014a) on 64bit Windows 7 Pro): with
    1. Simulink (Version 8.3 (R2014a))
    2. DSP System Toolbox (Version 8.6(R2014a))
    3. Data Acquisition Toolbox (Version 3.5(R2014a))

## Setup
1. Open the Simulink file ***EMG_FES2.slx***. 
2. And find the stimulator block (*EMG_FES2/Voluntary +passive movement/Motor to FES*) and configure it for two channels.(If by chance you are using the Hasomed Rehastim stimulator 1, the simulink are available at //sourceforge.net/projects/sciencestim/)
3. Find the Analogue input block (*EMG_FES2/Voluntary +passive movement*) and setup 2 EMG channels ( one for wrist flexor 
and the other for extensor), and also set up a goniometer input on to measure wrist angle.
4. Attach FES electrods on the flexor and extensor of the hand/wrist
5. Also make space on the extensor and flexor of the hand/wrist to attache EMG electrodes
6. Attach the goniometer to measure wrist angle.


## Initialization
You should make changes to settings in 'init_emgfes.m' in the root folder.
1. Open 'init_emgfes.m' from the project root and change the following variables ***'aFES.subjectNo', 'aFES.sessionN', aFES.hand' and 'saveDir'*** and others as required.
2. Run *'init_emgfes.m*'
The EMG-FES gui should appear

## Frequencies
The default frequencies are set in init_emgfes.m:
- *FES stimulation frequency:* 
`aFES.stimFreq=25;`
- *EMG smaple rate:* 
`aFES.Fs=1000;`
Changing these values would mean that the artefact removal would not work as aspected by default. SO to make it work at other frequencies, you will need to adjust the *FES Artifact Comb filter code/1* and *m-wave remover/1* blocks (found in main Simulink blcok *EMG_FES2/Voluntary +passive movement*) accordingly.


## Calibration
1. Using the EMG-FES gui ( available from *init_emgfes.m*), set currents to ED and FDS to 1mA or 0mA.
2. Click the start button on the bottom left and wait for the Active FES feedback gui to appear
3. Perform Max wrist extension and flexion, max hand extension and flexion (for able-bodied, perform sub-max flexion and extension in order to simulate injury)
4. Click stop.
5. From the main menu, click *'Settings>Calibration>Calibrate ALL with last run'*
6. Set the currents for ED and FDS to about 10mA. And repeat step 2-5.
7. Repeat step 6 until adequate control can be achieved by observing the the Active FES gui bars
8. Adjust parameters like Currents, *Pw* factor, *Pw* Thresh and Double Thresh until a good control can be observed. Repeat step 6 if required.

## Tracing
The tracing is a feedback following of trapezoidal shape. The feedback is the proportion FES pulsewidth the subjects is receiving
To activate tracing, do the following:
1. From the EMG-FES window, select *View>'Tracing feedback window'* from the main menu, to open the tracing feedback window.
2. Set the Mode to Tracing from the EMG-FES gui (This makes sure that files are saved with identifiable tags).
3. Start the system from the EMG-FES gui.
4. Click on the button, 'Connect trace' on the bottom right of the EMG-FES gui, and use wrist and finger extension and flexion to control the cross sign to follow closely as possible the circular sign on the Feedback window.
5. Click stop when the markers vanish or when the tracing cycle is completed. Recorded data will be saved automatically according to ***saveDir*** setting.

## Wrist tracing
The wrist tracing is a feedback following of trapezoidal shape using variation of wrist angle.
To do wrist tracing, do the following:
1. From the EMG-FES window, select *View>'Tracing feedback window'* from the main menu, to open the tracing feedback window.
2. Set the Mode to 'Wrist Tracing' from the EMG-FES gui (This makes sure that files are saved with identifiable tags).
3. Start the system from the EMG-FES gui.
4. Click on the button, 'Connect wrist trace' on the bottom right of the EMG-FES gui, and use wrist extension and flexion to control the cross sign to follow closely as possible the circular sign on the Feedback window.
5. Click stop when the markers vanish or when the wrist tracing cycle is completed. Recorded data will be saved automatically.


## Other experiments
1. Set the desired Mode from the EMG-FES gui.
2. Click on start button from the EMG-FES gui.
3. Use wrist and finger extension and flexion to control FES intensity

### Note
Note you can understand more what is going on as regards to threshold and controllability of the system by stopping the system and using the *Plot* menu on the EMG-FES gui to plot the last trial data. By examining the plots you can see if e.g the thresholds needs adjusting. The plots can also be used offline to examine pre-recorded data by just importing the desired session trial data into MATLAB first before using the Plot menu.

## Paramters
- **Current:** The current in mA for each of ED and FDS
- **Pw factor:** A factor used to multiply the extracted intention to get pulsewidth.
- **Pw Thresh:** A value (offset) added to the extracted intention multiplied by Pw factor. This is to avoid having the pulsewidth starting from low values
- **Double thresh:** This is the double threshold.

---------------------------------------------------------------
---------------------------------------------------------------
## New example new experimental protocol guide [25/04/2019 at 16:56]
1. Calibrate system with single thresh active.
2. Ask participant to do tracing with FES telling them to overshoot the target if they can without hurting themselves
3. Calibrate the wrist with the new record (*EMG-FES gui:'Settings>Calibration>Calibrate Wrist with last run'*);
4. Repeat 2 and 3 until participant can no longer over shoot target.
5. Setup FES at confortable intensity that augments movement in the intended direction. Also make sure the FES can be turned OFF by relaxation; otherwise adjust FDS and EDC activation thresholds and other parameters on the EMF-FES gui accordingly.
6. Now change mode to 'Wrist tracing' and perform the tracing without stimulation a couple of times. Tell them they can overshoot the target if they can.
7. With mode still on *'Wrist tracing'*, perform the tracing with stimulation a couple of times. Tell them they can overshoot the target if they can.
8. Change the mode to Tracing and do the tracing with stimulation EMG (single thresh) a couple of times
9. Change the mode to Tracing and do the tracing with stimulation EMG using double thresh a couple of times
10. Do the Toronto test with Active FES and SEM Glove, with Mode set to Normal.
DONE

NB:
There is really no reason to compare single and double thresh for wrist tracing, it should be done for only EMG tracing for all participants.

## Extras
### Stimulation artefact remover
A stimulation artefact remover simulink block implemented with a online comb filter is located in *'extras/stim_remover.slx'*.

### mWave remover
#### Implementation 
A Simulink mWave remover block that can be used in any model is located in *'extras/mwave_remover.xls'*.
#### Original
A Simulink solution of the adaptive filter defined by Sennels et al. 1997 (DOI:10.1109/86.593293) can be found in *'extras/Sennels_mWave.slx'*
