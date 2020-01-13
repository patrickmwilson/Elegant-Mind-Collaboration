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
from psychopy.visual import ShapeStim, Circle

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
    PATH = 'C:\\Users\\chand\\OneDrive\\Documents\\GitHub\\Elegant-Mind-Collaboration\\Crowded Center'
    OUTPATH = '{0:s}\\Data\\'.format(PATH)
    
    #CD TO SCRIPT DIRECTORY
    _thisDir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(_thisDir)
    #STORE INFO ABOUT EXPERIMENT SESSION
    expName = 'Crowded Center Flipped'
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
anglesH = [10, 20, 30, 40, 50]
anglesV = [0, 10, 20, 30, 40]
directions = [0, 1, 2, 3]
foveaRadius = 7 #cm
distToScreen = 35 #cm

#SPACING ADJUSTMENTS FOR TEXT DISPLAY
dirXMult = [1.62, 0, -1.68, 0]
dirYMult = [0, -1.562, 0, 1.748]
yOffset = [0.2, 0, 0.2, 0]
iAngle = [9, 9, 9, 9, 9, 9, 9, 10]
dirSpacer = [0.1, 0.5, 0, 0]

#GENERATE TEXT STIM 
def genDisplay(text, xPos, yPos, height, colour):
    displayText = visual.TextStim(win=win,
    text= text,
    font='Arial',
    pos=(xPos, yPos), height=height, wrapWidth=500, ori=0, 
    color=colour, colorSpace='rgb', opacity=1, 
    languageStyle='LTR',
    depth=0.0)
    return displayText

#STAIRCASE ALGORITHM TO DETERMINE MINIMUM LEGIBLE SIZE
def stairCase(thisResponse, numReversals, totalReversals, size, angle, stairCaseCompleted, lastResponse, responses):
    responses += 1
    #IF TWO SEQUENTIAL IN/CORRECT ANSWERS, RESET NUMREVERSALS
    if numReversals > 0 and lastResponse == thisResponse:
        totalReversals += numReversals
        numReversals = 0
    #IF CORRECT, MOVE CHARACTER OUTWARD
    if thisResponse:
        if numReversals == 0 and size > 1:
            size -= 0.5
        elif(size > 0.5 and angle > 0):
            size -= 0.2
        else:
            size -= 0.1
    #IF INCORRECT, MOVE CHARACTER INWARD, INCREMENT NUMREVERSALS
    else:
        numReversals += 1
        if size > 0.5:
            size += 0.2
        else:
            size += 0.1
    #COMPLETE STAIRCASE IF THE MAX ANGLE IS REACHED, OR 3 REVERSALS OR 25 RESPONSES OCCUR
    if numReversals >= 3 or responses >= 25 or totalReversals > 15:
        stairCaseCompleted = True
        
    return stairCaseCompleted, size, numReversals, totalReversals, thisResponse, responses

#CONVERT DEGREE INPUT TO DISTANCE IN CENTIMETERS
def angleCalc(angle):
    radians = math.radians(angle)
    spacer = (math.tan(radians)*35)
    return spacer

#ROUND NUMBER OF ROWS OR COLUMNS TO AN ODD NUMBER THAT MOST CLOSELY FITS THE RADIUS OF THE FOVEA
def rounder(num):
    if ( (num >= 1) and ( (num % int(num)) > 0.5) ):
        if((int(num) % 2) == 0):
            num = int(num) + 3
        else:
            num = int(num) + 1
    else:
        if((int(num) % 2) == 0):
            num = int(num) + 1
        else:
            num = int(num)
    return num

def spacer(size, heightCm):
    #TODO: add in some y=mx+b bullshit right here
    
    spacerH = size + (size*0.6)
    spacerV = heightCm*1.18
    
    return spacerH, spacerV

#CALCULATE THE NUMBER OF ROWS TO FILL THE FOVEA (radius of 7°) AT THIS LETTER SIZE
def grid(size, heightCm):
    spacerH, spacerV = spacer(size, heightCm)
    diameter = angleCalc(foveaRadius)*2
    rows = rounder(diameter/spacerV)
    print("Rows (from grid function): ", rows)
    return rows, spacerV, spacerH

#CALCULATE THE NUMBER OF CHARACTERS ON A SPECIFIC ROW OF THE CENTER GRID
def charsThisRow(height, row, yCoord, spacerH):
    radius = angleCalc(foveaRadius)
    adjacent = abs(yCoord)
    print("Radius: ", radius, "adjacent: ", adjacent, "spacerH: ", spacerH)
    
    length = (math.sqrt(abs((radius**2) - (adjacent**2)))*2)
    
    print("Length (from charsThisRow function: ",length)
    chars = rounder(length/spacerH)
    print("Chars (from charsThisRow function): ",chars)
    return chars

#GENERATE AND DRAW CENTER DISPLAY
def genCenter(size, heightCm, centerChar):

    rows, spacerV, spacerH = grid(size, heightCm)
    rows = (rows*2)-1
    centerRow = (rows-1)/2
    
    for row in range(rows):
        #FLIP IS 1 IF ROW < CENTER ROW, 0 IF ROW = CENTER ROW, AND 1 IF ROW > CENTER ROW
        flip = -1 + (2 * (row > centerRow)) + (1 * (row == centerRow))
        #DISPLAY COORDINATE FOR THAT ROW IS CALCULATED BY MULTIPLYING THE ROW NUMBER BY THE VERTICAL SPACER, AND THE SIGN IS DETERMINED BY FLIP
        yCoord = (flip * ( spacerV * abs(centerRow - row) ) )
        print("yCoord: ", yCoord)
        chars = charsThisRow(heightCm, row, yCoord, spacerH)
        chars = chars*2
        print("row: ", row, "chars: ", chars, "flip: ", flip)
        #POPULATES A LIST OF LENGTH (CHARS) WITH RANDOM LETTERS (E/P/B)
        thisLine = ''
        thisList = ['']*chars
        for char in range(chars):
            letter = random.choice(letters)
            thisList[char] = letter
            if(row == centerRow and char == (((chars-1)/2))):
                centerChar = letter
        #CONVERT LIST TO ARRAY
        thisLine = ''.join(thisList)
        thisLine.strip()
        #GENERATE AND DRAW TEXT STIM
        lineDisplay = genDisplay(thisLine, 0, yCoord, heightCm, 'black')
        lineDisplay.draw()
        #time.sleep(1)
    #OVERLAY THE CENTER CHARACTER OF THE ARRAY WITH A GREEN COPY
    centerDisplay = genDisplay(centerChar, 0, 0, heightCm, 'green')
    centerDisplay.draw()
    return centerChar
    

#CALCULATE DISPLAY COORDINATES AND HEIGHT OF STIMULI
def displayVariables(angle, dir, size):
    #DISPLAY HEIGHT AND DISTANCE FROM CENTER IN CENTIMETERS
    #*2.3378
    heightCm = (angleCalc(size)*2.3378)
    angleCm = angleCalc(angle)
    #X AND Y DISPLAY COORDINATES
    xPos = (dirXMult[dir]*angleCm) 
    yPos = (dirYMult[dir]*angleCm) + yOffset[dir]
    #ADJUSTMENT TO CENTER CHARACTER
    if angle == 0 and dir%2 != 0:
        yPos += 0.2
    return heightCm, angleCm, xPos, yPos
    
def genMask():
    radius = angleCalc(foveaRadius)
    
    vertices = list(range(0))
    count = 0
    for i in range(60):
        
        x = radius/(15-count)
        y = math.sqrt((radius**2) - (x**2))
        xS = 1 - (2*(i > 29))
        yS = 1 - (2*((i >= 15) and (i < 45)))
        count = count+1
        if count == 15:
            count = 0
        vertex = tuple([(xS*x),(yS*y)])
        vertices.append(vertex)
        
    edges = [(-100, 100),(100,100),(100,-100),(-100,-100)]
    maskVerts = list(range(0))
    maskVerts.append(vertices)
    maskVerts.append(edges)
    #maskVerts = [vertices, edges]
    print(maskVerts[1])
    #mask = ShapeStim(win, vertices = maskVerts, fillColor = 'grey', lineWidth = 0, size = 1, units = 'cm', pos = (0,0))
    mask = ShapeStim(win, vertices=maskVerts, fillColor='grey', lineWidth=0, size=1, pos=(0, 0))
    #donut = ShapeStim(win, vertices=donutVert, fillColor='orange', lineWidth=0, size=.75, pos=(-.2, -.25))
    mask.draw()

#DISPLAY INSTRUCTIONS FOR CHINREST ALIGNMENT
instructions = genDisplay('  Align the edge of the headrest stand \nwith the edge of the tape marked 35cm \n\n       Press Spacebar to continue', 0, 0, 5, 'black')
instructions.draw()
win.flip()
theseKeys = event.waitKeys(keyList = ['space', 'escape'], clearEvents = False)
if theseKeys[0] == 'escape':
    endExp()
#DISPLAY INSTRUCTIONS FOR CHINREST ALIGNMENT
instructions = genDisplay('  Press Enter if the character matches \nthe green center character, and spacebar\nif they do not match \n\n       Press Spacebar to continue', 0, 0, 5, 'black')
instructions.draw()
win.flip()
theseKeys = event.waitKeys(keyList = ['space', 'escape'], clearEvents = False)
if theseKeys[0] == 'escape':
    endExp()

#GENERATE CENTER DOT
dot = genDisplay('.', 0, 1.1, 3, 'red')

#RANDOMIZE SIZES, LOOP THROUGH 
#shuffle(sizes)
#for size in sizes:
shuffle(directions)
for dir in directions:
    
    #RANDOMIZE DIRECTIONS, LOOP THROUGH
    #shuffle(directions)
    #for dir in directions:
    if(dir == 0 or dir == 2):
        angles = anglesH
    else:
        angles = anglesV
    
    shuffle(angles)
    for angle in angles:
        
        #INITIALIZE TRIAL VARIABLES
        #size = angle/10
        size = 4
        if(size == 0):
            size = 1
        numReversals = 0
        responses = 0
        lastResponse = False
        stairCaseCompleted = False
        
        while not stairCaseCompleted:
            
            #CHOOSE RANDOM STIM LETTER, CALCULATE COORDINATES AND HEIGHT, GENERATE STIM
            letter = random.choice(letters)
            heightCm, angleCm, xPos, yPos = displayVariables(angle, dir, size)
            displayText = genDisplay(letter, xPos, yPos, heightCm, 'black')
            print("size: ", size, "heightcm: ", heightCm)
            #DISPLAY BLANK SCREEN WITH DOT ON FIRST FLIP
            if responses == 0:
                dot.draw()
                win.flip()
            
            time.sleep(0.5)
            #mask = genMask()
            #mask.draw()
            genMask()
            #DRAW STIMULI, DOT, AND CENTER ARRAY, CLEAR KEYPRESS LOG
            dot.draw()
            centerChar = 'B'
            centerChar = genCenter(size, heightCm, centerChar)
            displayText.draw()
            win.callOnFlip(keyPress.clearEvents, eventType='keyboard')
            win.flip()
            
            #SUSPEND EXECUTION UNTIL KEYPRESS
            theseKeys = event.waitKeys(keyList = ['space', 'enter', 'escape'], clearEvents = False)
            
            #STOP SCRIPT IF ESCAPE IS PRESSED
            if theseKeys[0] == 'escape':
                endExp()
            
            #IF TARGET LETTER == CENTER LETTER, ENTER = CORRECT; IF TARGET LETTER != CENTER LETTER, SPACE = CORRECT
            match = (letter == centerChar)
            if match:
                thisResponse = (theseKeys[0] == 'enter')
            else:
                thisResponse = (theseKeys[0] == 'space')
            
            #CALL STAIRCASE ALGORITHM
            stairCaseCompleted, size, numReversals, totalReversals, lastResponse, responses = stairCase(thisResponse, numReversals, totalReversals, size, angle, stairCaseCompleted, lastResponse, responses)
            
            if stairCaseCompleted:
                #INCREMENT DIR FOR DATA OUTPUT
                direction = dir+1
                #CSV OUTPUT
                if recordData:
                    csvOutput([direction, size, angle])

endExp()