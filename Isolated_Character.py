#Isolated Character
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
datadlg = gui.Dlg(title='Horizontal angles only?', pos=None, size=None, style=None, labelButtonOK=' Yes ', labelButtonCancel=' No ', screen=-1)
ok_data = datadlg.show()
horizontalOnly = datadlg.OK


if recordData:
    #OUTPUT FILE PATH
    PATH = 'C:\\Users\\chand\\OneDrive\\Desktop\\Visual-Acuity\\Data'
    OUTPATH = '{0:s}\\Isolated Character\\'.format(PATH)
    
    #CD TO SCRIPT DIRECTORY
    _thisDir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(_thisDir)
    #STORE INFO ABOUT EXPERIMENT SESSION
    expName = 'Isolated Character'
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

#INITIALIZE DEFAULT KEYBOARD
defaultKeyboard = keyboard.Keyboard()
keyPress = keyboard.Keyboard()

#EXPERIMENTAL VARIABLES
letters = list("EPB")
anglesH = [0, 5, 10, 15, 20, 25, 30, 35, 40]
anglesV = [5, 10, 15, 20, 25, 30]
directionsH = [0, 2]
directionsV = [1, 3]
distToScreen = 50 #cm
trials = 1

#SPACING ADJUSTMENTS FOR TEXT DISPLAY
dirXMult = [1.62, 0, -1.68, 0]
dirYMult = [0, -1.562, 0, 1.748]
yOffset = [0.2, 0, 0.2, 0]

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
def stairCase(thisResponse, numReversals, totalReversals, size, stairCaseCompleted, lastResponse, responses):
    responses += 1
    #IF TWO SEQUENTIAL IN/CORRECT ANSWERS, RESET NUMREVERSALS
    if numReversals > 0 and lastResponse == thisResponse:
        totalReversals += numReversals
        numReversals = 0
    #IF CORRECT, MOVE CHARACTER OUTWARD
    if thisResponse:
        if numReversals == 0 and size > 1:
            size -= 0.5
        elif(size > 0.5):
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
    if size < 0.1:
        size = 0.1
        
    return stairCaseCompleted, size, numReversals, totalReversals, thisResponse, responses

#CONVERT DEGREE INPUT TO DISTANCE IN CENTIMETERS
def angleCalc(angle):
    radians = math.radians(angle)
    spacer = (math.tan(radians)*distToScreen)
    return spacer
    
#CALCULATE DISPLAY COORDINATES AND HEIGHT OF STIMULIe
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
instructions = genDisplay('  Take some time to familiarize yourself with the buttons\n\n                       Press any button to begin', 0, 0, 5, 'white')
instructions.draw()
win.flip()
while(1):
    if ser.in_waiting:
        a = ser.readline()
        break
    else:
        time.sleep(0.05)
    

#GENERATE CENTER DOT
dot = genDisplay('.', 0, 1.1, 4, [.207,1,.259])

#GENERATE RANDOM LIST OF ANGLE AND DIRECTION PAIRS
pairs = list(range(0))
for i in range(trials):
    for j in range(len(anglesH)):
        for k in range(len(directionsH)):
            pairs.append((j*10)+k)
    if not horizontalOnly:
        for l in range(len(anglesV)):
            for m in range(len(directionsV)):
                pairs.append(-((l*10)+m))
shuffle(pairs)

run = 0
for pair in pairs:
    if(pair >= 0):
        angle = anglesH[int(pair/10)]
        dir = directionsH[(pair%10)]
    else:
        angle = anglesV[abs(int(pair/10))]
        dir = directionsV[abs(pair%10)]
        
    size = angle/10
    if(size == 0):
        size = 1
    numReversals = 0
    totalReversals = 0
    responses = 0
    lastResponse = False
    stairCaseCompleted = False
        
    while not stairCaseCompleted:
            
        #GENERATE NEW STIMULI
        letter = random.choice(letters)
            
        heightCm, angleCm, xPos, yPos = displayVariables(angle, dir, size)
        displayText = genDisplay(letter, xPos, yPos, heightCm, 'white')
            
        #ON FIRST TRIAL, DISPLAY BLANK SCREEN WITH CENTER DOT
        if responses == 0:
            dot.draw()
            win.flip()
            
        time.sleep(0.5)
            
        flash = 0
        while 1:
            flash = (flash == 0)
            if flash:
                dot.draw()
            displayText.draw()
            win.flip()
            if ser.in_waiting:
                value = float(ser.readline().strip())
                button = int(value)
                break
            else:
                time.sleep(0.05)
                
        thisResponse = checkResponse(button, letter)
            
        #CALL STAIRCASE ALGORITHM
        stairCaseCompleted, size, numReversals, totalReversals, lastResponse, responses = stairCase(thisResponse, numReversals, totalReversals, size, stairCaseCompleted, lastResponse, responses)
            
        if stairCaseCompleted:
            #ADVANCE DIRECTION
            direction = dir+1
            #CSV OUTPUT
            if recordData:
                csvOutput([direction, size, angle])
                    
    run += 1
    if run == (int(len(pairs)/2)):
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