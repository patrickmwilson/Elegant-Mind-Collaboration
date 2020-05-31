# Three Lines
#
# Displays three horizontal lines of text beginning at the center of the screen 
# and stretching to the edge. The subject is tasked with reading towards the 
# edge of the screen along the center line. To see a photo of this experiment, 
# open the '3l.png' file within the 'Protocol Pictures' folder
from __future__ import absolute_import, division
import psychopy
psychopy.useVersion('latest')
from psychopy import locale_setup, prefs, sound, gui, visual, core, data, event, logging, clock, monitors
from psychopy.constants import (NOT_STARTED, STARTED, PLAYING, PAUSED,
                                STOPPED, FINISHED, PRESSED, RELEASED, FOREVER)
from psychopy.visual import ShapeStim, Circle
import numpy as np  
from numpy import (sin, cos, tan, log, log10, pi, average,
                   sqrt, std, deg2rad, rad2deg, linspace, asarray)
from numpy.random import random, randint, normal, shuffle
import os, sys, time, random, math, csv, serial

# Create a serial object to read subject input from the arduino controlling the 
# push buttons. Change the port parameter to the port your arduino is 
# connected to.
ser = serial.Serial(port='COM3', baudrate = 9600, parity=serial.PARITY_NONE,\
     stopbits=serial.STOPBITS_ONE, bytesize=serial.EIGHTBITS, timeout=None)

# Opens the csvFile and writes the output argument specified by to the file
def csvOutput(output):
    with open(fileName,'a', newline ='') as csvFile:
        writer = csv.writer(csvFile)
        writer.writerow(output)
    csvFile.close()

# End the experiment: close the window, flush the log, and quit the script
def endExp():
    win.flip()
    logging.flush()
    win.close()
    core.quit()

# Input dialogue: record data to csv file?
datadlg = gui.Dlg(title='Record Data?', pos=None, size=None, style=None,\
     labelButtonOK=' Yes ', labelButtonCancel=' No ', screen=-1)
ok_data = datadlg.show()
recordData = datadlg.OK

if recordData:
    # Change directory to script directory
    _thisDir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(_thisDir)
    
    # Store info about experiment, get date
    expName = 'Three Lines'
    date = time.strftime("%m_%d")
    expInfo = {'Session Type': '','Subject Code': ''}
    
    # Input dialogue: session type, subject code
    dlg = gui.DlgFromDict(dictionary=expInfo, sortKeys=False, title=expName)
    if dlg.OK == False:
        core.quit()
    
    # Create folder for data file output (cwd/Analysis/Data/<type>/<subject code>)
    OUTPATH = os.path.join(os.getcwd(), 'Analysis', 'Data',\
         expInfo['Session Type'], expInfo['Subject Code'])
    os.mkdir(OUTPATH) 
    
    # Output file name: <OUTPATH>/<subject code_data_expName.csv>
    fileName = os.path.join(OUTPATH, (expInfo['Subject Code'] + '_' + date +\
         '_' + expName + '.csv'))
    
    # Print column headers if the output file does not exist
    if not os.path.isfile(fileName):
        csvOutput(["Direction","Letter Height (degrees)",\
            "Eccentricity (degrees)"]) 

# Input dialogue: test horizontal angles only?
datadlg = gui.Dlg(title='Horizontal angles only?', pos=None, size=None,
                  style=None, labelButtonOK=' Yes ', labelButtonCancel=' No ', screen=-1)
ok_data = datadlg.show()
horizontalOnly = datadlg.OK

# Create visual window - monitor setup is required beforehand, can be found in
# psychopy monitor tab. Set window size to the resolution of your display monitor
mon = monitors.Monitor('TV')  # Change this to the name of your display monitor
mon.setWidth(200)
win = visual.Window(
    size=(3840, 2160), fullscr=False, screen=-1,
    winType='pyglet', allowGUI=True, allowStencil=False,
    monitor=mon, color='grey', colorSpace='rgb',
    blendMode='avg', useFBO=True,
    units='cm')

# Experimental variables
# Possible stimulus characters to be displayed
letters = list("EPB")
# Letter heights in angles
sizes = [0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4]
# Distance between the center of a character and the center of the adjacent 
# character, for retinal eccentricity calculations
distH = [0.425, 0.85, 1.275, 1.7, 2.125, 2.55, 2.975, 3.4] 
distV = [0.475, 0.95, 1.425, 1.9, 2.375, 2.85, 3.325, 3.8] 
# Horizontal directions: 0 = Right (0°), 2 = Left (180°)
directionsH = [0, 2]
# Vertical directions: 1 = Down (270°), 2 = Up (90°)
directionsV = [1, 3]
# Distance between the subject and the screen in centimeters
distToScreen = 50
# Number of trials to run
trials = 1
# Defining green and red colors for dot display
green, red = [.207,1,.259] [1, 0, 0]

# Spacing adjustments for text display - These are unique to the particular
# monitor that was used in the experiment and would need to be modified
# manually for correct stimulus display
dirXMult = [1.62, 0, -1.68, 0]  # Multiply x position by this value
dirYMult = [0, -1.562, 0, 1.748]  # Multiply y position by this value
yOffset = [0.2, 0, 0.2, 0]  # Offset y position by this value
dirSpacer = [0.1, 0.5, 0, 0]

# Returns a displayText object with the given text, coordinates, height, color
def genDisplay(text, xPos, yPos, height, colour):
    displayText = visual.TextStim(win=win,
    text= text,
    font='Arial',
    pos=(xPos, yPos), height=height, wrapWidth=500, ori=0, 
    color=colour, colorSpace='rgb', opacity=1, 
    languageStyle='LTR',
    depth=0.0)
    return displayText
    
# Takes a value in the form of angle of visual opening and returns the 
# equivalent value in centimeters (based upon the distToScreen variable)
def angleCalc(angle):
    radians = math.radians(angle) # Convert angle to radians
    # tan(theta) * distToScreen ... opposite = tan(theta)*adjacent
    spacer = (math.tan(radians)*distToScreen) 
    return spacer

# Calculates the angle of visual opening in degrees of the final correctly 
# identified character based upon the size, direction, and number of correctly
# identified characters
def eccentricityCalc(size, responses, dir):
    if dir == 0 or dir == 2: # Horizontal angles
        dist = distH[int((size*2)-1)]
    else: # Vertical angles
        dist = distV[int((size*2)-1)]

    # Calculate the position of the last correctly identified character (in cm)
    angleCm = dist*responses 
    # arctan((num correct * distance per character)/(distance to screen))
    radians = math.atan(angleCm/distToScreen)
    angle = math.degrees(radians) # Convert to degrees
    eccentricity = round(angle, 2) # Round to two decimal places
    return eccentricity
    
# Calculate the number of rows and columns of characters necessary to produce 
# the three lines of text, depending upon letter height and direction
def rowsColsPerSize(size, dir):
    # Total distance of the screen
    totalDistH, totalDistV = 120, 68
    
    # Approximate distance taken up by each character
    hDist, vDist = (size)*0.8, (size)*0.9
    
    if dir == 0 or dir == 2: # Horizontal angles
        rows = 3 # Three rows in the horizontal direction
        cols = (round(totalDistV/vDist))*2 
    else: # Vertical angles
        rows = (round(totalDistH/hDist))*2
        cols = 3  # Three cols in the vertical direction
    
    # Ensure that there is not an even number of rows or columns, so that the 
    # line of text does not begin underneath the dot
    if rows % 2 == 0:
        rows += 1
    if cols % 2 == 0:
        cols += 1
        
    return rows, cols

# Return a boolean indicating whether the current row,col index is part of the
# target line of characters
def isTarget(row, centerRow, col, centerCol, dir):
    target = False
    if row == centerRow:
        # If reading right, characters to the right of the center are targets
        if dir == 0 and col > centerCol:
            target = True
        # If reading left, characters to the left of the center are targets
        elif dir == 2 and col < centerCol:
            target = True
    if col == centerCol:
        # If reading down, characters below the center are targets
        if dir == 1 and row > centerRow:
            target = True
        # If reading up, characters above the center are targets
        elif dir == 3 and row < centerRow:
            target = True
    return target

# Generate a masking shape stimulus to hide the characters that the subject is
# not currently tasked with reading
def genMask(size, dir):
    # Store coordinates of the edges of the screen. Top right, bottom right, 
    # bottom left, top left
    coords = [
        [300, 300],
        [300, -300],
        [-300, -300],
        [-300, 300]
    ]

    if dir == 0: # Right (0°)
        # Reduce the x coordinates for the right of the mask to the center + the
        # distance needed to cover the characters at the center of the screen
        coords[2][0] = 0 + ((size*0.75)*2)
        coords[3][0] = 0 + ((size*0.75)*2)
    elif dir == 1:  # Down (270°)
        # Reduce the y coordinates for the bottom of the mask to the center - the
        # distance needed to cover the characters at the center of the screen
        coords[0][1] = 0 - ((size*0.85)*2)
        coords[3][1] = 0 - ((size*0.85)*2)
    elif dir == 2:  # Left (180°)
        # Reduce the x coordinates for the left of the mask to the center + the
        # distance needed to cover the characters at the center of the screen
        coords[2][0] = 0 - ((size*0.75)*2)
        coords[3][0] = 0 - ((size*0.75)*2)
    elif dir == 3:  # Up (90°)
        # Reduce the y coordinates for the top of the mask to the center + the
        # distance needed to cover the characters at the center of the screen
        coords[0][1] = 0 + ((size*0.85)*1.5)
        coords[3][1] = 0 + ((size*0.85)*1.5)

    # Convert the coords to a list of tuples
    verts = list(map(tuple,coords))

    # Generate a grey shape with the coordinates as vertices
    mask = ShapeStim(win, vertices=verts, fillColor='grey', size=.5,\
         lineColor='grey')

    # Display the mask shape
    mask.draw()

# Generate and display the three lines of text. Return a list containing the
# values of the target row/column of text
def genArray(size, dir):
    # Calculate the height in cm of the stimulus
    heightCm = (angleCalc(size)*2.3378)

    # Spacer for distance between rows of characters
    spacer = (size*1.54)
    
    # Calculate the number of rows and columns needed, as well as the centers
    rows, cols = rowsColsPerSize(size, dir)
    centerRow, centerCol = int((rows-1)/2), int((cols-1)/2)
    
    # List to store the target characters
    targetLine = list(range(0))

    for i in range(rows):
        # Set vertical position of the row based on its index
        yCoord = spacer*(centerRow - i)

        # List to store characters in the line
        line = list(range(0))

        for j in range(cols):
            # Choose a random stimulus letter
            char = random.choice(letters)

            # Check if the current row,col index is part of the target row
            target = isTarget(i, centerRow, j, centerCol, dir)

            # If the current row,col index is part of the target row, append the
            # character to the target list
            if target:
                targetLine.append(char)

            # Append the character to the current line
            line.append(char)

        # Convert the list to a string, create a display object, and draw it
        line = ''.join(line)
        lineDisplay = genDisplay(line, 0, yCoord, heightCm, 'white')
        lineDisplay.draw()

    # If the direction is left or up, reverse the order of the target list
    if dir == 2 or dir == 3:
        targetLine.reverse()
    return targetLine

# Returns a boolean indicating whether or not the subject's input matched the
# stimulus character
def checkResponse(button, letter):
    key = '0'
    if button == 1:
        key = 'e'
    elif button == 2:
        key = 'b'
    elif button == 3:
        key = 'p'
    elif button == 4: # Do not know/cannot guess button
        key = 'space'
    return (key == letter.lower())

# Display on-screen instructions
instructions = genDisplay('Read the center line of text in the direction away from the center \nand press the corresponding button,\n and black button if you can not read it \n\n      Press Any Button to continue', 0, 0, 5, 'white')
instructions.draw()
win.flip()
while(1):
    if ser.in_waiting:
        a = ser.readline()
        break
    else:
        time.sleep(0.05)

# Display on-screen instructions
instructionText = '  Take some time to familiarize yourself with the buttons\n\n                       Press any button to begin'
instructions = genDisplay(instructionText, 0, 0, 5, 'white')
instructions.draw()
win.flip()
while(1):  # Wait until the subject presses a button
    if ser.in_waiting:
        a = ser.readline()  # Read in the input value to clear the buffer
        break
    else:
        time.sleep(0.05)

# Generate a randomized list of size and direction pairs. Each pair is
# represented as a single integer. The index of the size (in the sizes array)
# is multiplied by 10, and the index of the direction (in the directions array)
# is added to it. Positive values represent horizontal pairs, and negative
# represent vertical.
pairs = list(range(0))
for i in range(trials):
    for j in range(len(sizes)):  # Loop through horizontal angles
        for k in range(len(directionsH)):  # Loop through horizontal directions
            # Append (size index * 10) + direction index to pairs
            pairs.append((j*10)+k)
    if not horizontalOnly:
        for l in range(len(sizes)):  # Loop through vertical angles
            for m in range(len(directionsV)):  # Loop through vertical directions
                # Append (size index * 10) + direction index to pairs
                pairs.append(-((l*10)+m))
shuffle(pairs)  # Randomize the pairs list

# Generate display object for the green dot in the center of the screen
dot = genDisplay('.', 0, 1.1, 4, green)

run = 0  # Store the number of trials completed
for pair in pairs:  # Loop through the list of pairs
    size = sizes[int(pair/10)]  # Size index = pair/10
    if(pair >= 0):  # Horizontal pairs
        dir = directionsH[(pair % 10)]  # Direction index = pair%10
    else:  # Vertical pairs
        dir = directionsV[abs(pair % 10)]  # Direction index = pair%10

    # Clear the display buffer
    win.clearBuffer()

    # Display a blank screen with only the center dot on the first trial
    if run == 0:
        dot.draw()
        win.flip()

    time.sleep(0.5)

    # Generate and display the three lines of text. Return the center line 
    # as an array
    targetLine = genArray(size, dir)

    # Generate the mask to hide the part of the text array going in the 
    # opposite direction of the target direction.
    genMask(size, dir)

    responses = 0
    while 1:
        # Get the current target letter
        letter = targetLine[responses]

        # Display the center green dot. Every 0.05 seconds, hide/display the dot
        # to create a flashing effect
        flash = False
        while 1:
            flash = (flash == False)
            if flash:
                # Generate a display object for the green dot
                dot = genDisplay('.', 0, 1.1, 4, green)
            else:
                # Generate a display object to hide the dot
                dot = genDisplay('.', 0, 1.1, 4, 'grey')

            # Display the dot
            dot.draw()

            # Refresh the display without clearing the buffer, to preserve the
            # display of the stimulus text
            win.flip(clearBuffer=False)

            if ser.in_waiting:
                # Read the serial input buffer
                value = float(ser.readline().strip())
                # Convert input to int
                button = int(value)

                # Display a red dot in the center to indicate to the subject
                # that their response was recorded. Input is paused while the
                # red dot is displayed
                dot = genDisplay('.', 0, 1.1, 4, red)
                dot.draw()
                win.flip(clearBuffer=False)
                time.sleep(0.5)
                break
            else:
                time.sleep(0.05)
        
        # If the subject correctly identified the character, increment the 
        # number of responses and wait for further input from the subject
        if checkResponse(button, letter):
            responses += 1
            continue
        
        # If the subject incorrectly identified the character, output the 
        # stimulus direction, letter height, and the visual angle of the last
        # correctly identified character as retinal eccentricity in degrees.
        # Direction is stored in csv in the range of 1->4, rather than 0->3
        if recordData:
            # Direction is stored in csv in the range of 1->4, rather than 0->3
            direction = dir+1
            # Calculate the angle of the last correctly identified character
            angle = eccentricityCalc(size, responses, dir)
            # Output direction, letter height, and eccentricity to csv
            csvOutput([direction, size, angle])
        
        # Increment the number of runs completed
        run += 1

        # Halfway through the trial, give the subject a 30 second break and display
        # a countdown timer on the screen
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
