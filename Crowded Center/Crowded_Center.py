#Crowded Center
#Created by Patrick Wilson on 11/22/2019 
#Github.com/patrickmwilson
#Created for the Elegant Mind Collaboration at UCLA under Professor Katsushi Arisaka
#Copyright © 2019 Elegant Mind Collaboration. All rights reserved.

from __future__ import absolute_import, division

import psychopy
psychopy.useVersion('latest')

from psychopy import locale_setup, prefs, sound, gui, visual, core, data, event, logging, clock, monitors
from psychopy.constants import (NOT_STARTED, STARTED, PLAYING, PAUSED,
                                STOPPED, FINISHED, PRESSED, RELEASED, FOREVER)
from psychopy.hardware import keyboard

import numpy as np  
from numpy import (sin, cos, tan, log, log10, pi, average,
                   sqrt, std, deg2rad, rad2deg, linspace, asarray)
from numpy.random import random, randint, normal, shuffle

import os, sys, time, random, math, csv

#CSVWRITER FUNCTION
def csvOutput(output):
    with open(filename,'a', newline ='') as csvFile:
        writer = csv.writer(csvFile)
        writer.writerow(output)
    csvFile.close()

#CLOSE WINDOW, FLUSH LOG, STOP SCRIPT EXECUTION
def endExp():
    win.flip()
    logging.flush()
    win.close()
    core.quit()

#Y/N INPUT DIALOGUE FOR DATA RECORDING
datadlg = gui.Dlg(title='Record Data?', pos=None, size=None, style=None, labelButtonOK=' Yes ', labelButtonCancel=' No ', screen=-1)
ok_data = datadlg.show()
recordData = datadlg.OK

if recordData:
    #OUTPUT FILE PATH
    PATH = 'C:\\Users\\chand\\OneDrive\\Desktop\\VA Scripts\\Crowded Center'
    OUTPATH = '{0:s}\\Data\\'.format(PATH)
    
    #CD TO SCRIPT DIRECTORY
    _thisDir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(_thisDir)
    #STORE INFO ABOUT EXPERIMENT SESSION
    expName = 'Crowded Center'
    date = data.getDateStr(format='%m-%d') 
    expInfo = {'Participant': ''}
    
    #DIALOGUE WINDOW FOR PARTICIPANT NAME
    dlg = gui.DlgFromDict(dictionary=expInfo, sortKeys=False, title=expName)
    if dlg.OK == False:
        core.quit()
    
    #CREATE FILE NAME, PRINT HEADER IF FILE DOESN'T EXIST
    filename = OUTPATH + u'%s_%s_%s' % (expInfo['Participant'], date, expName) + '.csv'
    if not os.path.isfile(filename):
        csvOutput(["Direction","Letter Height (degrees)","Eccentricity (degrees)"])

#WINDOW CREATION
mon = monitors.Monitor('TV')
mon.setWidth(200)
win = visual.Window(
    size=(3840, 2160), fullscr=False, screen=-1, 
    winType='pyglet', allowGUI=True, allowStencil=False,
    monitor= mon, color='white', colorSpace='rgb',
    blendMode='avg', useFBO=True, 
    units='cm')

#INITIALIZE KEYBOARD
defaultKeyboard = keyboard.Keyboard()
keyPress = keyboard.Keyboard()

#EXPERIMENTAL VARIABLES
letters = list("EPB")
sizes = [0.25, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4]
directions = [0, 1, 2, 3]

#SPACING ADJUSTMENTS FOR TEXT DISPLAY
dirXMult = [1.62, 0, -1.68, 0]
dirYMult = [0, -1.562, 0, 1.748]
yOffset = [0.2, 0, 0.2, 0]
iAngle = [9, 9, 9, 9, 9, 9, 9, 10]
maxAngles = [61, 42, 61, 42]
dirSpacer = [0.1, 0.5, 0, 0]

#GENERATE TEXT STIM 
def genDisplay(text, xPos, yPos, height, colour):
    displayText = visual.TextStim(win=win,
    text= text,
    font='Arial',
    pos=(xPos, yPos), height=height, wrapWidth=500, ori=0, 
    color=colour, colorSpace='rgb', opacity=1, 
    languageStyle='LTR',
    depth=0.0);
    return displayText

#STAIRCASE ALGORITHM TO DETERMINE MAXIMUM LEGIBLE ANGLE
def stairCase(thisResponse, numReversals, angle, stairCaseCompleted, lastResponse, responses, baseAngle, maxAngle):
    responses += 1
    #IF TWO SEQUENTIAL IN/CORRECT ANSWERS, RESET NUMREVERSALS
    if numReversals > 0 and lastResponse == thisResponse:
        numReversals = 0
    #IF CORRECT, MOVE CHARACTER OUTWARD
    if thisResponse:
        if numReversals == 0:
            angle += 3
        else:
            angle += 1
    #IF INCORRECT, MOVE CHARACTER INWARD, INCREMENT NUMREVERSALS
    else:
        if angle -1 > baseAngle:
            angle -= 1
        numReversals += 1
    #COMPLETE STAIRCASE IF THE MAX ANGLE IS REACHED, OR 3 REVERSALS OR 25 RESPONSES OCCUR
    if numReversals >= 3 or responses >= 25 or angle >= maxAngle:
        stairCaseCompleted = True
        
    return stairCaseCompleted, angle, numReversals, thisResponse, responses

#CONVERT DEGREE INPUT TO DISTANCE IN CENTIMETERS
def angleCalc(angle):
    radians = math.radians(angle)
    spacer = (math.tan(radians)*35)
    return spacer

#GENERATE AND DRAW CENTER DISPLAY
chars = [3, 6, 8, 10, 8, 6, 3]
yCoords = [9, 6, 3, 0, -3, -6, -9]
def genCenter():
    centerLines =[]
    for i in range(7):
        thisLine = ''
        thisList = ['']*chars[i]
        for j in range(chars[i]):
            thisList[j] = random.choice(letters)
        #CONVERT LIST TO ARRAY
        thisLine = ''.join(thisList)
        #GENERATE AND DRAW TEXT STIM
        lineDisplay = genDisplay(thisLine, 0, yCoords[i], 3, 'black')
        lineDisplay.draw()

#CALCULATE DISPLAY COORDINATES AND HEIGHT OF STIMULI
def displayVariables(angle, dir):
    #DISPLAY HEIGHT AND DISTANCE FROM CENTER IN CENTIMETERS
    heightCm = (angleCalc(size)*2.3378)
    angleCm = angleCalc(angle)
    #X AND Y DISPLAY COORDINATES
    xPos = (dirXMult[dir]*angleCm) 
    yPos = (dirYMult[dir]*angleCm) + yOffset[dir]
    #ADJUSTMENT TO CENTER CHARACTER
    if angle == 0 and dir%2 != 0:
        yPos += 0.2
    return heightCm, angleCm, xPos, yPos
    
#DISPLAY INSTRUCTIONS FOR CHINREST ALIGNMENT
instructions = genDisplay('  Align the edge of the headrest stand \nwith the edge of the tape marked 35cm \n\n       Press Spacebar to continue', 0, 0, 5, 'black')
instructions.draw()
win.flip()
theseKeys = event.waitKeys(keyList = ['space', 'escape'], clearEvents = False)
if theseKeys[0] == 'escape':
    endExp()

#GENERATE CENTER DOT
dot = genDisplay('.', 0, 1.1, 3, 'red')

#RANDOMIZE SIZES, LOOP THROUGH 
shuffle(sizes)
for size in sizes:
    
    #RANDOMIZE DIRECTIONS, LOOP THROUGH
    shuffle(directions)
    for dir in directions:
        
        #SET MAX AND MIN ANGLES
        maxAngle = maxAngles[dir]
        #baseAngle = iAngle[int((size-0.5)*2)]
        baseAngle = 11
        angle = baseAngle
        
        #INITIALIZE TRIAL VARIABLES
        numReversals = 0
        responses = 0
        lastResponse = False
        stairCaseCompleted = False
        
        while not stairCaseCompleted:
            
            #CHOOSE RANDOM STIM LETTER, CALCULATE COORDINATES AND HEIGHT, GENERATE STIM
            letter = random.choice(letters)
            heightCm, angleCm, xPos, yPos = displayVariables(angle, dir)
            displayText = genDisplay(letter, xPos, yPos, heightCm, 'black')
            
            #DISPLAY BLANK SCREEN WITH DOT ON FIRST FLIP
            if responses == 0:
                dot.draw()
                win.flip()
            
            time.sleep(0.5)
            
            #DRAW STIMULI, DOT, AND CENTER ARRAY, CLEAR KEYPRESS LOG
            dot.draw()
            genCenter()
            displayText.draw()
            win.callOnFlip(keyPress.clearEvents, eventType='keyboard')
            win.flip()
            
            #SUSPEND EXECUTION UNTIL KEYPRESS
            theseKeys = event.waitKeys(keyList = ['e', 'p', 'b', 'escape'], clearEvents = False)
            
            #STOP SCRIPT IF ESCAPE IS PRESSED
            if theseKeys[0] == 'escape':
                endExp()
            
            #CHECK KEYPRESS AGAINST TARGET LETTER
            thisResponse = (theseKeys[0] == letter.lower())
            
            #CALL STAIRCASE ALGORITHM
            stairCaseCompleted, angle, numReversals, lastResponse, responses = stairCase(thisResponse, numReversals, angle, stairCaseCompleted, lastResponse, responses, baseAngle, maxAngle)
            
            if stairCaseCompleted:
                #ADVANCE DIRECTION
                direction = dir+1
                #CSV OUTPUT
                if recordData:
                    csvOutput([direction, size, angle])

endExp()