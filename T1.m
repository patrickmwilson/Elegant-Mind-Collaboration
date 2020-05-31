% Fully Crowded Protocol
% 
% Covers the screen in a block of text, while the subject is instructed to
% read outward from a center green dot. To see an image of the task, open
% 'fc.png' within the 'Protocol Pictures' subfolder. To adapt this code to
% your own monitor will require you to edit all the hardcoded coordinate
% and size information contained here (line ~26 -> line ~83). I would 
% advise the use of PsychoPy rather than Psychtoolbox if you would like to 
% recreate this experiment, due to PsychoPy's ability to accept size and
% position parameters for stimulus display in centimeters.

% Clear the workspace and the screen
close all hidden; clear variables; clear mex; clear all; sca;

% Skip screen timing tests, fine temporal resolution is unimportant for
% this experiment.
Screen('Preference', 'SkipSyncTests', 1);

% Create a serial object for the port connected to the arduino controlling
% the push button input.
ser = serialport("COM3",9600);

% Number of times to test each letter height/direction combination (3)
trials=3;

% Hardcoded text sizes (in font units)
tS = [6, 13, 26, 39, 51, 64, 78, 91, 103, 130, 155, 181, 208, 235, 260];

% Letter heights in degrees (assuming the subject sits exactly 50cm from 
% the screen)
heights = [ 0.23, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 5, 6, 7, 8, 9, 10];

% Number of columns for the text array for each size
cols = [200, 150, 151, 99, 76, 60, 51, 43, 38, 30, 25, 22, 19, 17, 15];

% The index of the center character of the array for each size
center = [7582, 5092, 4513, 1969, 1209, 775, 556, 427, 340, 208, 148, ...
    108, 73, 66, 76];

% The number of characters required to fill the screen at each text size
charactersPerSize = [15074, 9966, 8850, 3850, 2400, 1500, 1050, 800, 625, ...
    375, 259, 206, 151, 125, 127];

letters = 'EPB'; % Letters with which to fill the text array
green = [0 1 0]; % Defining green and red
red = [1 0 0];

% Hardcoded coordinates for the display of the text array
arrayHorizontalStart = [850, 601, -4, -8, -30, -31, -46, -32, -66, -70, ...
    -7, -115, -43, -60, -20];
arrayVerticalStart = [500, 296, -24, -7, -27, -24, -31, -66, -66, -13, 2, ...
    63, 174, 102, -224]; 

% Hardcoded measurements in centimeters for each text size (measured by
% hand on the monitor)
distToScreen = 50; %centimeters
letterHeight = [0.2, 0.44, 0.89, 1.31, 1.75, 2.18, 2.62, 3.06, 3.5, 4.39, ...
    5.255, 6.14, 7.03, 7.92, 8.79];

% Distance in centimeters between the center of a character and the center
% of the adjacent horizontal & vertical characters
distPerCharH = [0.3, 0.41, 0.8, 1.22, 1.6, 2.02, 2.48, 2.9, 3.26, 4.15, ...
    4.85, 5.65, 6.5, 7.4, 8.2];
distPerCharV = [0.3, 0.6, 1.22, 1.82, 2.4, 3.02, 3.68, 4.3, 4.88, 6.15, ...
    7.3, 8.6, 9.8, 11.1, 12.4];

% Hardcoded coordinated for the rectangular mask in the center, which hides 
% the character at the direct center so the green dot can be displayed
centerRectXStart = [0, 1276, 1270, 1268, 1260, 1258, 1256, 1254, 1252, ...
    1243, 1239, 1224, 1210, 1200, 1210];
centerRectYStart = [0, 715, 710, 705, 700, 695, 690, 685, 680, 670, 660, ...
    650, 640, 630, 620];
centerRectXEnd = [0, 1286, 1290, 1290, 1294, 1302, 1310, 1318, 1323, ...
    1330, 1330, 1340, 1350, 1360, 1355];
centerRectYEnd = [0, 728, 730, 735, 740, 745, 750, 755, 760, 770, 780, ...
    790, 800, 810, 825];

% Hardcoded size of the center dot in pixels, and coordinates for its
% display
dotSizePix = [5, 8, 12, 13, 15, 17, 18, 19, 20, 22, 22, 22, 22, 22, 22];
dotXPos = [1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, ...
    1280, 1280, 1280, 1280, 1280];
dotYPos = [720, 720, 720, 720, 720, 720, 720, 720, 720, 720, 720, 720, ...
    720, 720, 720];

% Hardcoded text size and display coordinates for the direction indicator
% that is displayed atop the center green dot
dirText = '>v<^';
dirTS = [7, 10, 13, 15, 17, 19, 20, 20, 20, 20, 20, 20, 20, 20, 20];
dirTextXPos = [1278, 1277, 1275, 1275, 1274, 1274, 1274, 1274, 1274, ...
    1274, 1274, 1274, 1274, 1274, 1274];
dirTextYPos = [722, 724, 725, 725, 727, 727, 727, 727, 727, 727, 727, ...
    727, 727, 727, 727];

% Input dialogue: Record the data to a csv file?
dataAnswer = questdlg('Record Data?', '', 'Yes', 'No', 'Cancel', 'Yes');
recordData = (char(dataAnswer(1)) == 'Y');
if(recordData)
    % Input dialogue: Session type
    type = string(inputdlg({'Type (Study/Mock/Pilot)'}, ...
    'Session Info', [1 70], {'Pilot'}));
    
    % Input dialogue: Subject name
    subjectName = string(inputdlg({'Subject code (all caps)'}, ...
    'Session Info', [1 70], {''}));
    
    % Get the current date for the title of the csv file
    c = clock; month = num2str(c(2)); day = num2str(c(3)); 
    year = num2str(c(1)); minute = num2str(c(5)); 
    
    % Create a folder to save the data file,  
    % Analysis/Data/<type>/<subjectName>
    folderName = fullfile(pwd, 'Analysis', 'Data', type, subjectName);
    csvName = fullfile(folderName, sprintf('%s_%s-%s-%s.csv', ...
        subjectName, month, day, minute));
    mkdir(folderName);
    
    % Create the csv file and print column headers
    if(exist(csvName, 'file') ~= 2)
        fileID = fopen(csvName, 'a');
        fprintf(fileID, '%s, %s, %s, %s\n', ...
            'Direction', ...
            'Characters Read', ...
            'Eccentricity (degrees)', ...
            'Letter Height (degrees)');
    end
end

% Input dialogue: Test horizontal directions only?
dataAnswer = questdlg('Horizontal directions only?', '', 'Yes', 'No', ...
    'Cancel', 'Yes');
horizontalOnly = (char(dataAnswer(1)) == 'Y');

% Set the directions to test based on previous input dialogue
directionsH = [1, 3]; % 1 = Right (0°), 3 = Left (180°)
directionsHV = [1, 2, 3, 4]; % 2 = Down (270°), 4 = Up (90°)
if horizontalOnly
    directions = directionsH;
else
    directions = directionsHV;
end

% Generate a randomized array of size and direction pairs to be tested
pairs = [];
for m = 1:trials
    for i = 1:15
        for j = 1:length(directions)
            pair = ((i*10)+directions(j));
            pairs = [pairs;pair];
        end
    end
end
pairs = pairs(randperm(length(pairs)));

% Initialize Psychotoolbox with default settings
PsychDefaultSetup(2);

% Get the screen numbers, 2 = TV monitor
screens = Screen('Screens');
screenNumber = 2;

% Define black, white, and grey color
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
gray=GrayIndex(screenNumber,0.3);
grey = [.39 .39 .39];

% Open a grey on-screen window with anti-aliasing enabled
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
Screen('TextFont', window, 'Arial'); % Arial font

% Determine the coordinates of the center of the screen in pixels
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
halfX = 0.5 * screenXpixels;
halfY = 0.5 * screenYpixels;

% Loop through the randomly generated array of letter height and direction
% pairs. Display stimulus and wait for subject input.
for i = 1:length(pairs)
    size = int8(floor(pairs(i)/10)); % Get size index from current pair
    direction = int8(mod(pairs(i),10)); % Get direction index from current pair
    
    % Set the number of characters to be randomly generated
    characters = charactersPerSize(size); 
    
    % Create a rectangular mask with the appropriate vertice coordinates
    centerRect = SetRect(centerRectXStart(size), centerRectYStart(size), ...
        centerRectXEnd(size), centerRectYEnd(size));
    
    numCorrect = 0;
    
    if(direction == 1) % Right (0°)
        distPerChar = distPerCharH(size);
        spacer = 1; % Next character's index in the array is +1
    elseif(direction == 2) % Down (270°)
        distPerChar = distPerCharV(size);
        spacer = cols(size)+2; % Next characters index in the array is one row down
    elseif(direction == 3) % Left (180°)
        distPerChar = distPerCharH(size); 
        spacer = -1; % Next character's index in the array is -1
    else %(direction == 4) Up (90°)
        distPerChar = distPerCharV(size);
        spacer = -(cols(size)+2); % Next characters index in the array is one row up
    end
    
    % Generate the stimulus text block (a randomized array of the letters
    % 'E', 'P', and 'B')
    textArray = blanks(characters);
    for j = 1:characters    
        if(mod(j,cols(size)+1)==0) 
            % Append a newline to the array at the end of each row
            textArray = strcat(textArray,'\n');
        else
            % Pick a random character and append it to the array
            q = letters(randi(length(letters))); 
            textArray = strcat(textArray,q); 
        end
    end
    
    % Store a character array version of the stimulus text, for extraction
    % of the current target character
    charArray = char(textArray);
    
    % Set the index in the array of the starting character
    pos = center(size)+spacer;
    
    % Read subject input and continue until a character is incorrectly
    % identified
    while(1)
        % Draw the stimulus text in the screen buffer
        wrappedString=WrapString(textArray,500);
        Screen('TextSize', window, tS(size));
        DrawFormattedText(window, wrappedString, ...
            arrayHorizontalStart(size), arrayVerticalStart(size), white);
        
        % Draw the center masking rectangle, the green dot, and the
        % direction indicator in the screen buffer
        Screen('FillRect', window, gray, centerRect);
        Screen('glPoint', window, green, dotXPos(size), dotYPos(size), ...
            dotSizePix(size));
        Screen('TextSize', window, dirTS(size));
        DrawFormattedText(window, dirText(direction), dirTextXPos(size), ...
            dirTextYPos(size), black);
        
        % Flip the display to the graphics buffer, showing the stimulus
        Screen('Flip', window);
        
        % Read the subject's input to the arduino push buttons via the
        % serial object
        buttonPress = [];
        while(1) % Continue until a button is pressed
            
            % Read serial input buffer
            buttonPress = readline(ser); 
            
            if isempty(buttonPress)
                pause(.05); % Pause if the input buffer was empty
            else
                % Convert button input to integer
                button = str2num(buttonPress(1)); 
                break; % Break out of infinite input loop
            end
        end

        % Change the color of the center dot from green to red, to indicate
        % to the subject that their input has registered, and they must
        % wait before identifying the next character
        % Draw the stimulus text in the screen buffer
        wrappedString=WrapString(textArray,500);
        Screen('TextSize', window, tS(size));
        DrawFormattedText(window, wrappedString, ...
            arrayHorizontalStart(size), arrayVerticalStart(size), white);
        
        % Draw the center masking rectangle, the red dot, and the
        % direction indicator in the screen buffer
        Screen('FillRect', window, gray, centerRect);
        Screen('glPoint', window, red, dotXPos(size), dotYPos(size), ...
            dotSizePix(size));
        Screen('TextSize', window, dirTS(size));
        DrawFormattedText(window, dirText(direction), dirTextXPos(size), ...
            dirTextYPos(size), black);
        
        % Flip the display to the graphics buffer, showing the stimulus
        Screen('Flip', window);
        WaitSecs(0.5); % Pause for half a second
                
        % Convert the arduino button input to its corresponding character
        if button == 1 
            key = 'E';
        elseif button == 2  
            key = 'B';
        elseif button == 3
            key = 'P';
        elseif button == 4
            key = 'Q'; % 'I don't know/I can't guess' button
        end
                
        % Extract the target character from the stimulus array
        currentChar = charArray(pos);
        
        % Compare the subject's input to the target character
        correct = true;
        if key == currentChar
            % If the subject's input was correct, advance the current
            % position. If this new position is outside the bounds of the
            % screen, set correct = false.
            pos = pos+spacer;
            if(pos < 0 || pos > characters)
                correct = false;
            end
        else
            correct = false;
        end
                
        if(correct)
            % If the character was correctly identified, increment the 
            % current number of correctly identified characters and 
            % continue to the next iteration of the trial
            numCorrect = numCorrect + 1;
            continue;
        else
            % If the character was incorrectly identified or the current
            % position is outside of the bounds of the screen, calculate
            % the retinal eccentricity (opening angle) of the last character to be
            % correctly identified 
            % (tan^-1((distance to character)/(distance to screen))). 
            % Store this value and the current letter height.
            eccentricity = atand((numCorrect*distPerChar)/(distToScreen));
            height = heights(size);
            
            % Output the current direction, number of characters correctly
            % identified, opening angle of the final correctly identified
            % character as retinal eccentricity and its letter height to
            % the csv file
            if(recordData)
                fileID = fopen(csvName, 'a');
                fprintf(fileID, '%d, %d, %4.2f, %4.2f\n', direction, ...
                    numCorrect, eccentricity, height);
            end    
            break;
        end
    end   
    
    % Every ten trials, give the subject a 15 second break and display a
    % countdown timer for this break
    if((mod(i,10) == 0) && (i ~= length(pairs)))
        Screen('TextSize', window, 25);
        for j = 1:15
            seconds = int2str(16-j);
            DrawFormattedText(window, 'Break', halfX, (halfY-30), white);
            DrawFormattedText(window, 'Seconds', (halfX + 15), halfY, ...
                white);
            DrawFormattedText(window, seconds, (halfX-15), halfY, white);
            Screen('Flip', window);
            WaitSecs(1);
        end
    end
end

% Once the trial is over, display 'Trial complete' on the screen and wait 5
% seconds before closing the stimulus window.
Screen('TextSize', window, 25);
DrawFormattedText(window, 'Trial complete', halfX, halfY, white);
Screen('Flip', window);
WaitSecs(5);

sca; % Clear the screen
delete(ser); % Delete the serial object
clear all; % Clear the workspace variables
return; % End