#Reaction Time
#Created by Patrick Wilson on 12/2/2019 
#Created for the Elegant Mind Collaboration at UCLA under Professor Katsushi Arisaka
#Copyright © 2019 Elegant Mind Collaboration. All rights reserved.

from __future__ import absolute_import, division

import psychopy
psychopy.useVersion('latest')


from psychopy import locale_setup
from psychopy import prefs
from psychopy import sound, gui, visual, core, data, event, logging, clock, monitors
from psychopy.constants import (NOT_STARTED, STARTED, PLAYING, PAUSED,
                                STOPPED, FINISHED, PRESSED, RELEASED, FOREVER)

import numpy as np  # whole numpy lib is available, prepend 'np.'
from numpy import (sin, cos, tan, log, log10, pi, average,
                   sqrt, std, deg2rad, rad2deg, linspace, asarray)
from numpy.random import random, randint, normal, shuffle
import os  # handy system and path functions
import sys  # to get file system encoding

from psychopy.hardware import keyboard

import random
import math
import csv

PATH = 'C:\\Users\\chand\\OneDrive\\Desktop\\VA Scripts\\Reaction Time\\Reaction Time (Letters)'
OUTPATH = '{0:s}\\Data\\'.format(PATH)

recordData = False
datadlg = gui.Dlg(title='Record Data?', pos=None, size=None, style=None, labelButtonOK=' Yes ', labelButtonCancel=' No ', screen=-1)
ok_data = datadlg.show()
if datadlg.OK:
    recordData = True
    

runsPerAngle = 5
timedlg = gui.Dlg(title='Experiment Length (approx)', pos=None, size=None, style=None, labelButtonOK=' 25 Mins ', labelButtonCancel=' 12.5 Mins ', screen=-1)
ok_data = timedlg.show()
if timedlg.OK:
    runsPerAngle = 10

if recordData:
    
    # Ensure that relative paths start from the same directory as this script
    _thisDir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(_thisDir)

    # Store info about the experiment session
    expName = 'Reaction Time'  # from the Builder filename that created this script
    expInfo = {'Participant': ''}
    dlg = gui.DlgFromDict(dictionary=expInfo, sortKeys=False, title=expName)
    if dlg.OK == False:
        core.quit()  # user pressed cancel
    expInfo['date'] = data.getDateStr(format='%m-%d')  # add a simple timestamp
    expInfo['expName'] = expName

    filename = OUTPATH + u'%s_%s' % (expInfo['Participant'], expInfo['date']) + '.csv'

    printHeader = True

    if os.path.isfile(filename):
        printHeader = False
    
    if printHeader:
        with open(filename, 'a', newline = '') as csvFile:
            writer = csv.writer(csvFile)
            writer.writerow(["Letter Height (degrees)","Eccentricity (degrees)","Position","Delay Time (s)","Reaction Time (ms)", "Correct"])
        csvFile.close()

    # save a log file for detail verbose info
    #logFile = logging.LogFile(filename+'.log', level=logging.EXP)
    logging.console.setLevel(logging.WARNING)  # this outputs to the screen, not a file

endExpNow = False  # flag for 'escape' or other condition => quit the exp
frameTolerance = 0.001  # how close to onset before 'same' frame

# Start Code - component code to be run before the window creation
win = visual.Window(
    size=[3840, 2160], fullscr=False, screen=-1, 
    winType='pyglet', allowGUI=True, allowStencil=False,
    monitor='TV', color='white', colorSpace='rgb',
    blendMode='avg', useFBO=True, 
    units='cm')
# store frame rate of monitor if we can measure it
if recordData:
    expInfo['frameRate'] = win.getActualFrameRate()
    if expInfo['frameRate'] != None:
        frameDur = 1.0 / round(expInfo['frameRate'])
    else:
        frameDur = 1.0 / 60.0  # could not measure, so guess
    
dot = visual.TextStim(win=win, name='dot',
text= '.',
font='Arial',
pos=(0, 1.1), height=3, wrapWidth=None, ori=0, 
color='red', colorSpace='rgb', opacity=1, 
languageStyle='LTR',
depth=0.0);

# create a default keyboard (e.g. to check for escape)
defaultKeyboard = keyboard.Keyboard()

# Initialize components for Routine "trial"
trialClock = core.Clock()
keyPress = keyboard.Keyboard()

# Create some handy timers
globalClock = core.Clock()  # to track the time since experiment started
routineTimer = core.CountdownTimer()  # to track time remaining of each (non-slip) routine 


letters = list("EPB")
keyPresses = list("epb")
#sizes = [0.2, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4]
sizes = [0.4363, 0.8727, 1.3093, 1.746, 2.183, 2.62, 3.058, 3.50]
#0, 5, 10, 15, 20
angles = [5, 10, 15, 20, 25, 30]
positionXMult = [0, 1, 0, -1, 0]
positionYMult = [0, 0, -1, 0, 1]
angleSpacer = [4.374, 8.816, 13.397, 18.199, 23.32, 28.867]
correctLetter = 'e'


positions = [0, 0, 1, 2, 3, 4]



shuffle(sizes)

for size in sizes:
    
    for i in range(runsPerAngle):
        
        #GENERATE RANDOM ANGLE ORDER
        shuffle(angles)
        
        for angle in angles:
            angleNum = (int(angle/5) -1 )
            #PICK RANDOM POSITION, CENTER OR RANDOM PERIPHERY
            thisPos = random.choice(positions)
            thisLetter = random.choice(letters)
            
            eccentricity = 0
            
            if thisPos > 0:
                eccentricity = angle
            
            #RANDOM STIMULUS ONSET TIME
            delayTime = random.uniform(1,5)
            
            #SET ANGLE, DISPLAY COORDINATES
            
            thisXPos = (0 + ((positionXMult[thisPos])*angleSpacer[angleNum]))
            thisYPos = (0 + ((positionYMult[thisPos])*angleSpacer[angleNum]))
            
            #PICK RANDOM LETTER, SET CORRECT KEY
            
            
            correctKeyPress = thisLetter.lower()
            
            #SET UP DISPLAY TEXT
            displayText = visual.TextStim(win=win, name='displayText',
            text= thisLetter,
            font='Arial',
            pos=(thisXPos, thisYPos), height=size, wrapWidth=None, ori=0, 
            color='black', colorSpace='rgb', opacity=1, 
            languageStyle='LTR',
            depth=0.0);
            
            # ------Prepare to start Routine "trial"-------
            # update component parameters for each repeat
            keyPress.keys = []
            keyPress.rt = []
            # keep track of which components have finished
            trialComponents = [displayText, keyPress, dot]
            for thisComponent in trialComponents:
                thisComponent.tStart = None
                thisComponent.tStop = None
                thisComponent.tStartRefresh = None
                thisComponent.tStopRefresh = None
                thisComponent.status = NOT_STARTED
            # reset timers
            t = 0
            _timeToFirstFrame = win.getFutureFlipTime(clock="now")
            trialClock.reset(-_timeToFirstFrame)  # t0 is time of first possible flip
            frameN = -1
            continueRoutine = True
            
            drawLetter = False
            while continueRoutine:
                
                correct = 0
                
                
                
                # get current time
                t = trialClock.getTime()
                tThisFlip = win.getFutureFlipTime(clock=trialClock)
                tThisFlipGlobal = win.getFutureFlipTime(clock=None)
                frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
                # update/draw components on each frame
                # *displayText* updates
                if tThisFlip >= 1 + delayTime:
                    break
                
                if dot.status == NOT_STARTED:
                    dot.setAutoDraw(True)
                    dot.status = STARTED
                    
                
                if (tThisFlip < (.5 + delayTime) and tThisFlip >= delayTime-frameTolerance):
                    drawLetter = True
                
                if (tThisFlip >= (.5 + delayTime)):
                    drawLetter = False
                
                if displayText.status == NOT_STARTED and drawLetter == True:
                    # keep track of start time/frame for later
                    displayText.frameNStart = frameN  # exact frame index
                    displayText.tStart = t  # local t and not account for scr refresh
                    displayText.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(displayText, 'tStartRefresh')  # time at next scr refresh
                    displayText.setAutoDraw(True)
                    displayText.status = STARTED
                    
                    
                    
                if displayText.status == STARTED and drawLetter == False:
                    displayText.setAutoDraw(False)
                    displayText.status = FINISHED
               

                waitOnFlip = False
                if keyPress.status == NOT_STARTED and displayText.status == STARTED:
                    # keep track of start time/frame for later
                    keyPress.frameNStart = frameN  # exact frame index
                    keyPress.tStart = t  # local t and not account for scr refresh
                    keyPress.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(keyPress, 'tStartRefresh')  # time at next scr refresh
                    keyPress.status = STARTED
                    # keyboard checking is just starting
                    waitOnFlip = True
                    win.callOnFlip(keyPress.clock.reset)  # t=0 on next screen flip
                    win.callOnFlip(keyPress.clearEvents, eventType='keyboard')  # clear events on next screen flip

                if keyPress.status == STARTED and not waitOnFlip:
                    theseKeys = keyPress.getKeys(keyList=['space'], waitRelease=False)
                    if len(theseKeys):
                        theseKeys = theseKeys[0]  # at least one key was pressed
                        # check for quit:
                        if "escape" == theseKeys:
                            endExpNow = True
                            break
                        keyPress.keys = theseKeys.name  # just the last key pressed
                        keyPress.rt = theseKeys.rt
                        reactionTime = (keyPress.rt*1000)
                        # was this 'correct'?
                        if (keyPress.keys == 'space'):
                            if(correctLetter == thisLetter.lower()):
                                correct = 1
                            continueRoutine = False
                        else:
                            correct = 0
                            continueRoutine = False
                        # a response ends the routine
                        
                
                # check for quit (typically the Esc key)
                if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
                    core.quit()
        
                # check if all components have finished
                if not continueRoutine:  # a component has requested a forced-end of Routine
                    break
                continueRoutine = False  # will revert to True if at least one component still running
                for thisComponent in trialComponents:
                    if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                        continueRoutine = True
                        break  # at least one component has not yet finished
        
                # refresh the screen
                if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                    win.flip()
            
            # -------Ending Routine "trial"-------
            for thisComponent in trialComponents:
                if hasattr(thisComponent, "setAutoDraw"):
                    thisComponent.setAutoDraw(False)
            
            
            if recordData and correct:
                letterHeight = math.degrees(math.atan(size/50))
                with open(filename,'a', newline ='') as csvFile:
                    writer = csv.writer(csvFile)
                    writer.writerow([letterHeight,eccentricity,thisPos,delayTime,reactionTime, correct])
                csvFile.close()
            
            
            
            # the Routine "trial" was not non-slip safe, so reset the non-slip timer
            routineTimer.reset()
            






# Flip one final time so any remaining win.callOnFlip() 
# and win.timeOnFlip() tasks get executed before quitting
win.flip()

# these shouldn't be strictly necessary (should auto-save)

logging.flush()
# make sure everything is closed down

win.close()
core.quit()
