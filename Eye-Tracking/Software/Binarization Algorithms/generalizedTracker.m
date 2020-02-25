function [allObjectStats, objectsLost, storedCentroids] = generalizedTracker();
    clear all;
    close all;
    fileType = '\*.tiff'; % '\*.tif' , '\*.tiff' or '\*.avi' 
    
    addpath 'X:\Database\TOJ_Study_2\arduino\EyeTrackingAnalysis\Software\Binarization Algorithms'
    
    subjectCode = input('Enter subject code: ');
    disp('Please select the data folder you wish you analyze.')
    [PathName] = uigetdir;
    dirInfo = dir(PathName);
    dirSize = length(dirInfo);

    folderName = [subjectCode '_EyeTracking'];
    mkdir(folderName);
    cd(folderName);

    numThresh = 50;
    boxCst = 20;
    resizeBox = [-boxCst, -boxCst, 2*boxCst, 2*boxCst]; 

    if strcmp(fileType, '\*.tiff') || strcmp(fileType, '\*.tif')
        subPathName = strcat(PathName, '\', dirInfo(3).name);
        subDirInfo = dir([subPathName, fileType]);
        subDirSize = length(subDirInfo);

        fileName = fullfile(subPathName, subDirInfo(1).name);
        raw = imread(fileName);
        rawOriginal = raw;
        raw = imdiffusefilt(raw);
        raw = imcomplement(raw);

        figTracking = figure;
        imshow(rawOriginal);
        title('Select objects to be tracked.');
        
        button = 1;
        ii = 1;
        
        while sum(button) <=1;
            [x, y, button] = ginput(1);
            inputLocs(:, ii) = [x, y];
            ii = ii + 1;
        end
        
        close(figTracking);
        
        inputLocs(:, end) = [];
        inputLocs = uint16(inputLocs);
        
        numObjects = length(inputLocs(1, :)); 
        [imSizeX, imSizeY] = size(raw);
        
        figRaw = figure;
        imshow(rawOriginal);
        title('Objects to be tracked.');
        
        for ii = 1:numObjects;
            [threshValues(ii), imStack(:, :, ii)] = bestThreshSelector(raw, numThresh, imSizeX, imSizeY);
            imStackLabeled(:, :, ii) = bwselect(imStack(:, :, ii), inputLocs(1, ii), inputLocs(2, ii));
            objectStats(ii) = regionprops(imStackLabeled(:, :, ii), 'Centroid', 'BoundingBox', ...
                'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'Area');
            objectStats(ii).BoundingBox = objectStats(ii).BoundingBox + resizeBox;
            rawROIs = drawrectangle('Position', objectStats(ii).BoundingBox);
            objectMasks(:, :, ii) = createMask(rawROIs);
            cst(ii) = uint16(objectStats(ii).Area*0.2);
            maskLocs(ii, :) = objectStats(ii).Centroid;
        end
       
        prevBin = imStackLabeled;
        close(figRaw);
        
    end
    
    frameIdx = 1;
    
    %% Begin Image Processing for All Data
    
    binarizedImAll = false(imSizeX, imSizeY);

    %% Processing for Individual TIFF Files
    if strcmp(fileType, '\*.tiff') || strcmp(fileType, '\*.tif')
        for jj = 3:dirSize;
            subPathName = strcat(PathName, '\', dirInfo(jj).name);
            subDirInfo = dir([subPathName, fileType]);
            subDirSize = length(subDirInfo);
            
            %% Perform Binarization and Region Properties
            for ii = 1:subDirSize;  
                
                if ii == 1;
                    startExp(frameIdx) = true;
                else
                    startExp(frameIdx) = false;
                end
                         
                fileName = fullfile(subPathName, subDirInfo(ii).name);
                raw = imread(fileName);    
                raw = imdiffusefilt(raw);
                raw = imcomplement(raw);
                
                for kk = 1:numObjects;
                    [binarizedIm(:, :, kk), allObjectStats(frameIdx, kk), objectsLost(frameIdx, kk)] = objectBinarize(raw, objectMasks(:, :, kk), ...
                        cst(kk), threshValues(kk), prevBin(:, :, kk), ...
                        objectStats(kk).Centroid(1), objectStats(kk).Centroid(2));
                    prevBin(:, :, kk) = binarizedIm(:, :, kk);
                    binarizedImAll = or(binarizedIm(:, :, kk), binarizedImAll);
                    newLocs = allObjectStats(frameIdx, kk).Centroid;
                    storedCentroids(frameIdx, kk, :) = newLocs;
                    
                    %% Rotate Masks for Next Round
                    
                    rotateVect = flip(int8(newLocs - maskLocs(kk, :)));   
                    rotateVectAll(frameIdx, kk, :) = rotateVect;
                    if rotateVect ~= false;
                        maskRotated(frameIdx, kk) = true;
                        objectMasks(:, :, kk) = circshift(objectMasks(:, :, kk), rotateVect);
                        maskLocs(kk, :) = newLocs;
                    else
                        maskRotated(frameIdx, kk) = false;                       
                    end
%                     if kk == 1;
%                         disp(num2str(int8(newLocs - prevLocs(kk, :))));
%                         tempSubSet(:, :, ii) = binarizedIm(:, :, kk);
%                         tempNewMask(:, :, ii) = objectMasks(:, :, kk);
%                         tempNewLocs(ii, :) = newLocs;
%                     end                
                end
                binarizedIm(:, :, :) = false;
                imwrite(binarizedImAll, strcat(num2str(frameIdx), '.jpg'));                             
                binarizedImAll(:, :) = false;
                frameIdx = frameIdx + 1;
                disp(strcat({'Frame '}, num2str(ii), {' of '}, num2str(subDirSize), '.'));               
            end
        %%  Display Status of program
        
            disp(strcat({'Completed subfolder '}, num2str(jj-2), {' of '}, num2str(dirSize-2), '.'));

        end
        %% Save Processed Data
        
        save(strcat(folderName, '.mat'), 'allObjectStats', 'objectsLost', 'storedCentroids', 'rotateVectAll', 'maskRotated');    
%         save('test_variables.mat', 'tempSubSet', 'tempNewMask', 'tempNewLocs');
        
    end
    cd ..
end