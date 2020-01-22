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

#Y/N INPUT DIALOGUE FOR GLASSES
datadlg = gui.Dlg(title='Does the subject wear glasses?', pos=None, size=None, style=None, labelButtonOK=' Yes ', labelButtonCancel=' No ', screen=-1)
ok_data = datadlg.show()
glasses = datadlg.OK

if recordData:
    #OUTPUT FILE PATH
    PATH = 'C:\\Users\\chand\\OneDrive\\Desktop\\Visual-Acuity\\Crowded Center'
    OUTPATH = '{0:s}\\Data\\'.format(PATH)
    
    #CD TO SCRIPT DIRECTORY
    _thisDir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(_thisDir)
    #STORE INFO ABOUT EXPERIMENT SESSION
    expName = 'Crowded Center Circle'
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
    monitor= mon, color='grey', colorSpace='rgb',
    blendMode='avg', useFBO=True, 
    units='cm')

#INITIALIZE KEYBOARD
defaultKeyboard = keyboard.Keyboard()
keyPress = keyboard.Keyboard()

#EXPERIMENTAL VARIABLES
letters = list("EPB")
anglesH = [10, 15, 20, 25, 30, 35, 40]
anglesV = [10, 15, 20, 25, 30]
directionsG = [0, 2]
directionsNG = [0, 1, 2, 3]
foveaRadius = 7 #cm
distToScreen = 50 #cm

if glasses:
    directions = directionsG
    dirCap = 2
else:
    directions = directionsNG
    dirCap = 4

#SPACING ADJUSTMENTS FOR TEXT DISPLAY
dirXMult = [1.62, 0, -1.68, 0]
dirYMult = [0, -1.562, 0, 1.748]
yOffset = [0.2, 0, 0.2, 0]
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

#CONVERT DEGREE INPUT TO DISTANCE IN CENTIMETERS
def angleCalc(angle):
    radians = math.radians(angle)
    spacer = (math.tan(radians)*50)
    return spacer
    
#CALCULATE DISPLAY COORDINATES AND HEIGHT OF STIMULI
def displayVariables(angle, dir, size):
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
    
def genArray(size, heightCm, centerChar):
    spacer = (size*1.4)*1.3
    diameter = angleCalc(foveaRadius) * 2
    
    rows = int(diameter/heightCm) * 2
    if rows%2 == 0:
        rows = rows+1
    cols = (rows*2)+1
    
    centerRow = int((rows-1)/2)
    centerCol = int((cols-1)/2)
    
    for i in range(rows):
        yCoord = spacer*(centerRow - i)
        
        line = list(range(0))
        for j in range(cols):
            if((i == centerRow) and j == centerCol):
                char = centerChar
            else:
                char = random.choice(letters)
            line.append(char)
        line = ''.join(line)
        lineDisplay = genDisplay(line, 0, yCoord, heightCm, 'white')
        lineDisplay.draw()

def findQuadrant(i, points, interval, slice):
    slice = slice + 1
    xSign = ySign = 1
    if slice == 3 or slice == 4:
        xSign = -1
    if slice == 2 or slice == 3:
        ySign = -1
    if i in range(int(interval*(slice-1)), int(interval*slice)):
        return slice, interval, xSign, ySign
    else:
        return findQuadrant(i, points, interval, slice)

def genMask(points):
    radius = angleCalc(foveaRadius)
    
    maskVerts = list(range(0))
    interval = points/4
    
    for i in range(2):
        
        vertices = list(range(0))
        count = 0
        
        for i in range(points):
            
            quadrant, interval, xSign, ySign = findQuadrant(i, points, interval, 0)
            
            x = ((radius/interval)*count)
            y = (math.sqrt((radius**2)-(x**2)))
            if int(x) == 0:
                x = 0.01
            if int(y) == 0:
                y = 0.01
            x = round(x,2)*xSign
            y = round(y,2)*ySign
            
            vertex = tuple([x,y])
            vertices.append(vertex)
            
            if quadrant == 1 or quadrant == 3:
                count = count + 1
            else:
                count = count - 1
                
        maskVerts.append(vertices)
        radius = radius*15
        
    mask = ShapeStim(win, vertices = maskVerts, fillColor = 'grey', lineWidth = 0, size = 1, units = 'cm', pos = (0,0))
    
    return mask

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

#DISPLAY INSTRUCTIONS FOR CHINREST ALIGNMENT
instructions = genDisplay('  Align the edge of the headrest stand \nwith the edge of the tape marked 50cm \n\n       Press Spacebar to continue', 0, 0, 5, 'white')
instructions.draw()
win.flip()
theseKeys = event.waitKeys(keyList = ['space', 'escape'], clearEvents = False)
if theseKeys[0] == 'escape':
    endExp()
    
#DISPLAY INSTRUCTIONS FOR CHINREST ALIGNMENT
instructions = genDisplay('  Press M if the character matches \n  the green center character, Z\n if they do not match, and Spacebar \n    if you can not read it \n\n      Press Spacebar to continue', 0, 0, 5, 'white')
instructions.draw()
win.flip()
theseKeys = event.waitKeys(keyList = ['space', 'escape'], clearEvents = False)
if theseKeys[0] == 'escape':
    endExp()

dot = genDisplay('.', 0, 1.1, 4, [.207,1,.259])

directionIndex = 0
shuffle(directions)
for dir in directions:
    
    if(dir == 0 or dir == 2):
        angles = anglesH
    else:
        angles = anglesV
    
    shuffle(angles)
    for angle in angles:
        
        #INITIALIZE TRIAL VARIABLES
        size = angle/10
        size = 3
        if(size == 0):
            size = 1
            
        numReversals = 0
        totalReversals = 0
        responses = 0
        lastResponse = False
        stairCaseCompleted = False
        
        while not stairCaseCompleted:
            
            win.clearBuffer()
            #CHOOSE RANDOM STIM LETTER, CALCULATE COORDINATES AND HEIGHT, GENERATE STIM
            letter = random.choice(letters)
            
            matching = random.randint(0,1)
            
            if matching == 1:
                centerChar = letter
            else:
                centerChar = random.choice(letters)
                
            if centerChar == letter:
                match = True
            else:
                match = False
            
            heightCm, angleCm, xPos, yPos = displayVariables(angle, dir, size)
            displayText = genDisplay(letter, xPos, yPos, heightCm, 'white')
            
            if responses == 0:
                dot.draw()
                win.flip()
                win.clearBuffer()
            
            time.sleep(0.5)
            
            genArray(size, heightCm, centerChar)
            
            mask = genMask(60)
            mask.draw()
            displayText.draw()
            
            win.flip()
            
            theseKeys = event.waitKeys(keyList = ['z', 'm', 'space', 'escape'], clearEvents = False)
            
            #STOP SCRIPT IF ESCAPE IS PRESSED
            if theseKeys[0] == 'escape':
                endExp()
            
            #IF TARGET LETTER == CENTER LETTER, ENTER = CORRECT; IF TARGET LETTER != CENTER LETTER, SPACE = CORRECT
            match = (letter == centerChar)
            if match:
                thisResponse = (theseKeys[0] == 'm')
            else:
                thisResponse = (theseKeys[0] == 'z')
            
            #CALL STAIRCASE ALGORITHM
            stairCaseCompleted, size, numReversals, totalReversals, lastResponse, responses = stairCase(thisResponse, numReversals, totalReversals, size, angle, stairCaseCompleted, lastResponse, responses)
            
            if stairCaseCompleted:
                #INCREMENT DIR FOR DATA OUTPUT
                direction = dir+1
                #CSV OUTPUT
                if recordData:
                    csvOutput([direction, size, angle])
                    
    directionIndex += 1
    if directionIndex != dirCap:
        for i in range(30):
            win.clearBuffer()
            seconds = str(30-i)
            breakText = genDisplay('Break', 0, 0, 5, 'white')
            secondText = genDisplay('Seconds', +2, -5, 5, 'white')
            numText = genDisplay(seconds, -11, -5, 5, 'white')
            breakText.draw()
            secondText.draw()
            numText.draw()
            win.flip()
            time.sleep(1)
        

endExp()