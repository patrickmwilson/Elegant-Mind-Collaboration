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

import serial

ser = serial.Serial(port='COM3', baudrate = 9600, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE, bytesize=serial.EIGHTBITS, timeout=None)

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
    PATH = 'C:\\Users\\chand\\OneDrive\\Desktop\\Visual-Acuity\\Data'
    OUTPATH = '{0:s}\\Three Lines\\'.format(PATH)
    
    #CD TO SCRIPT DIRECTORY
    _thisDir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(_thisDir)
    #STORE INFO ABOUT EXPERIMENT SESSION
    expName = 'Three Lines'
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
sizes = [0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4]
distH = [0.425, 0.85, 1.275, 1.7, 2.125, 2.55, 2.975, 3.4] 
distV = [0.475, 0.95, 1.425, 1.9, 2.375, 2.85, 3.325, 3.8] 
directionsG = [0, 2]
directionsNG = [0, 1, 2, 3]
foveaRadius = 7 #cm
distToScreen = 50 #cm
green = [.207,1,.259]

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
    spacer = (math.tan(radians)*distToScreen)
    return spacer

#CONVERT DEGREE INPUT TO DISTANCE IN CENTIMETERS
def eccentricityCalc(size, responses, dir):
    if dir == 0 or dir == 2:
        dist = distH[int((size*2)-1)]
    else:
        dist = distV[int((size*2)-1)]
    angleCm = dist*responses
    radians = math.atan(angleCm/distToScreen)
    angle = math.degrees(radians)
    eccentricity = round(angle, 2)
    return eccentricity
    
    
def rowsColsPerSize(size, dir):
    totalDistH = 120
    totalDistV = 68
    
    hDist = (size)*0.8
    vDist = (size)*0.9
    
    if dir == 0 or dir == 2:
        rows = 3
        cols = (round(totalDistV/vDist))*2
    else:
        rows = (round(totalDistH/hDist))*2
        cols = 3
        
    if rows % 2 == 0:
        rows += 1
    if cols % 2 == 0:
        cols += 1
        
    return rows, cols
    
def checkCopy(row, centerRow, col, centerCol, dir):
    copy = False
    if row == centerRow:
        if dir == 0 and col > centerCol:
            copy = True
        elif dir == 2 and col < centerCol:
            copy = True
    if col == centerCol:
        if dir == 1 and row > centerRow:
            copy = True
        elif dir == 3 and row < centerRow:
            copy = True
    return copy
    
def genMask(size, dir):
    xOne = -300
    yOne = 300
    yTwo = -300
    xThree = 300

    if dir == 0:
        xThree = 0 + ((size*0.75)*2)
    elif dir == 1:
        yTwo = 0 - ((size*0.85)*2)
    elif dir == 2:
        xOne = 0 - ((size*0.75)*2)
    elif dir == 3:
        yOne = 0 + ((size*0.85)*1.5)
        
    xFour = xThree
    yThree = yTwo
    xTwo = xOne
    yFour = yOne
    
    verts = [(xOne,yOne), (xTwo,yTwo), (xThree,yThree), (xFour,yFour)]
    mask = ShapeStim(win, vertices=verts, fillColor='grey', size=.5, lineColor='grey')
    mask.draw()

def genArray(size, dir):
    heightCm = (angleCalc(size)*2.3378)
    spacer = (size*1.54)
    
    rows, cols = rowsColsPerSize(size, dir)
    centerRow = int((rows-1)/2)
    centerCol = int((cols-1)/2)
    
    targetLine = list(range(0))
    for i in range(rows):
        yCoord = spacer*(centerRow - i)
        
        line = list(range(0))
        for j in range(cols):
            char = random.choice(letters)
            copy = checkCopy(i, centerRow, j, centerCol, dir)
            if copy:
                targetLine.append(char)
            line.append(char)
        line = ''.join(line)
        lineDisplay = genDisplay(line, 0, yCoord, heightCm, 'white')
        lineDisplay.draw()
    if dir == 2 or dir == 3:
        targetLine.reverse()
    return targetLine
    
def checkResponse(button, letter):
    key = '0'

    if button == 1:
        key = 'e'
    elif button == 2:
        key = 'b'
    elif button == 3:
        key = 'p'
    elif button == 4:
        key = 'space'
    
    return (key == letter.lower())

#DISPLAY INSTRUCTIONS FOR CHINREST ALIGNMENT
instructions = genDisplay('  Align the edge of the headrest stand \nwith the edge of the tape marked 50cm \n\n       Press Any Button to continue', 0, 0, 5, 'white')
instructions.draw()
win.flip()
while(1):
    if ser.in_waiting:
        a = ser.readline()
        break
    else:
        time.sleep(0.05)
    
#DISPLAY INSTRUCTIONS FOR CHINREST ALIGNMENT
instructions = genDisplay('Read the center line of text in the direction away from the center \nand press the corresponding button,\n and black button if you can not read it \n\n      Press Any Button to continue', 0, 0, 5, 'white')
instructions.draw()
win.flip()
while(1):
    if ser.in_waiting:
        a = ser.readline()
        break
    else:
        time.sleep(0.05)

dot = genDisplay('.', 0, 1.1, 4, [.207,1,.259])

sizeIndex = 0
shuffle(sizes)
for size in sizes:
    dotPos = 1 + ((4-size)/10)
    
    shuffle(directions)
    for dir in directions:
        
        dot.draw()
        win.flip()
        time.sleep(0.5)
        
        genMask(size, dir)
        targetLine = genArray(size, dir)
        genMask(size, dir)
        
        responses = 0
        while(1):
            print(responses)
            letter = targetLine[responses]
            
            flash = 0
            while 1:
                flash = (flash == 0)
                if flash:
                    dot = genDisplay('.', 0, dotPos, 4, green)
                else:
                    dot = genDisplay('.', 0, dotPos, 4, 'grey')
                dot.draw()
                win.flip(clearBuffer = False)
                
                if ser.in_waiting:
                    value = float(ser.readline().strip())
                    button = int(value)
                    break
                else:
                    time.sleep(0.05)
            
            if checkResponse(button, letter):
                responses += 1
                continue
            
            direction = dir+1
            #CSV OUTPUT
            if recordData:
                angle = eccentricityCalc(size, responses, dir)
                csvOutput([direction, size, angle])
            break
    
    sizeIndex += 1
    if sizeIndex != 7:
        for i in range(15):
            win.clearBuffer()
            seconds = str(15-i)
            breakText = genDisplay('Break', 0, 0, 5, 'white')
            secondText = genDisplay('Seconds', +2, -5, 5, 'white')
            numText = genDisplay(seconds, -11, -5, 5, 'white')
            breakText.draw()
            secondText.draw()
            numText.draw()
            win.flip()
            if ser.in_waiting:
                value = float(ser.readline().strip())
                break
            time.sleep(1)
    
endExp()