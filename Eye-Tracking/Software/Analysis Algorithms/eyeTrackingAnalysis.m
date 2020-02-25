function eyeTrackingAnalysis(saveFileName, storedCentroids, objectsLost, FPS);
    close all
    addpath 'X:\Database\TOJ_Study_2\arduino\EyeTrackingAnalysis\Software\Analysis Algorithms'
    calibration = false;
    
    % Degrees calibrated in order.
%     degrees = [-5, 5, -10, 10, -20, 20];
    degrees = [0, 5, 10, 20, -5, -10, -20];
    
    % Index pupil and marker arrays
    pupilCentroidArray = storedCentroids(:, 1, :);                         % First column of tracked objects.
    markerCentroidArray = storedCentroids(:, 2, :);                        % Second column of tracked objects.
    eyeClosed = objectsLost(:, 1);                                         % First column of objects lost array, first object to be tracked.
    
    [synchroFileName, synchroFilePath] = uigetfile({'*.csv'; '*.xlsx'}, 'Select Synchronization Data File');
    syncData = readmatrix(fullfile(synchroFilePath, synchroFileName));
    syncDataOn = syncData(find(syncData(:, 3) == 1), :); %#ok<*FNDSB>
    recordDiff = diff(syncData(:, 3));
    recordDiff(end + 1) = 0;
    recordEdges = abs(recordDiff*10) > 1;
    recordEnd =  recordEdges(find(syncData(:, 3) == 1));
    recordEnd(end+1) = 0;
    [recordAmp, recordEndIdx] = findpeaks(recordEnd*10,'MinPeakHeight', 1);
    [buttonAmp, buttonPressed] = findpeaks(syncDataOn(:, 1), 'MinPeakHeight', 2);
   
    if calibration == false;
        [calFileName, calFilePath] = uigetfile('*.mat', 'Select Calibration MATLAB File');
        calibrationFit = fullfile(calFilePath, calFileName);
        peakHeightMin = 0.15;
        peakWidthMin = 1;
        framesAway = 5;
    else
        peakHeightMin = 5;
        peakWidthMin = 1;
        framesAway = 10;
    end
    

    centCentroids = pupilCentroidArray - markerCentroidArray;

    se1 = strel('line', 7, 0);
    pupilClosedDilated = imdilate(eyeClosed, se1);
    pupilClosedIdx = find(pupilClosedDilated == 1);

    visPupils = linspace(1, length(centCentroids(:, 1)), length(centCentroids(:, 1)));
    visPupils(pupilClosedIdx) = [];

    xCentroids = centCentroids(:, 1);
    yCentroids = centCentroids(:, 2);

    xMean = mean(xCentroids(visPupils));
    yMean = mean(yCentroids(visPupils));
%     orientationMean = mean(pupilOrientation(visPupils));

    time = linspace(0, length(xCentroids)/FPS, length(xCentroids));

    xCentroidsMean = xCentroids - xMean;
    yCentroidsMean = yCentroids - yMean;

    maxXY = ceil(max([xCentroidsMean; yCentroidsMean])/5)*5;
%     pupilOrientationMean = pupilOrientation - orientationMean;

    xCentroidsMean(pupilClosedIdx) = 0;
    yCentroidsMean(pupilClosedIdx) = 0;
%     pupilOrientationMean(pupilClosedIdx) = 0;

    if calibration == true;
        endIdx = recordEndIdx;
        for ii = 1:length(endIdx);
        meanPixDegree(ii) = mean(xCentroidsMean(endIdx(ii)-20:endIdx(ii)-5));
        end
        [fitresult, gof] = fit(meanPixDegree', degrees', 'poly1'); %#ok<*ASGLU>
    else
        fitresult = load(calibrationFit);
        fitresult = fitresult.fitresult;
    end
    
    startExp = false(1, length(xCentroidsMean));
    startExp(buttonPressed(1:2:end)) = true;
    startExp(end) = true;
    
    startLoc = find(startExp == true)/FPS;
    horzDiff = diff(xCentroidsMean);
    vertDiff = diff(yCentroidsMean);

    totalDiff = horzDiff.^2 + vertDiff.^2;
    figure;
    plot(totalDiff);
    hold on;

    % [saccadePeaksAmpX, saccadePeaksLocsX] = findpeaks(horzDiff.^2, 'MinPeakHeight', 0.1, 'MinPeakDistance', 10, 'MinPeakWidth', 2);
    % plot(saccadePeaksLocsX, -saccadePeaksAmpX, 'rx');

    [saccadeAmpXY, saccadeLocsXY] = findpeaks(totalDiff, 'MinPeakHeight', peakHeightMin, 'MinPeakDistance', framesAway, 'MinPeakWidth', peakWidthMin);
    saccadeTrialInt = find(sum(abs(saccadeLocsXY/FPS - startLoc) < framesAway/FPS, 2) == 1);
    saccadeLocsXY(saccadeTrialInt) = [];
    saccadeAmpXY(saccadeTrialInt) = [];
    plot(saccadeLocsXY, saccadeAmpXY, 'rx');
    hold off;
    
    
%% Calibrated Data
    xCentroidsCal = fitresult(xCentroidsMean);
    yCentroidsCal = fitresult(yCentroidsMean);
        
    dataLine = linspace(1, length(xCentroidsCal), length(xCentroidsCal));
    trendFitX = fit(dataLine', xCentroidsCal, 'poly1');
    trendFitY = fit(dataLine', yCentroidsCal, 'poly1');
    
    xCentroidsCal = xCentroidsCal - trendFitX(dataLine);
    yCentroidsCal = yCentroidsCal - trendFitY(dataLine);

    maxXYcal = ceil(max(abs([xCentroidsCal; yCentroidsCal]))/5)*5;

    figure;
    plot(xCentroidsCal, yCentroidsCal);
    hold on;
    plot(xCentroidsCal, yCentroidsCal, 'r.');
    xlabel('Degree Deviation');
    ylabel('Degree Deviation');
    title('2D Pupil Centroid Degree Location');
    xlim([-maxXYcal, maxXYcal]);
    ylim([-maxXYcal, maxXYcal]);
    axis square
    hold off;


    figure;
    subplot(2,1,1);
    plot(time, yCentroidsCal);
    hold on;
    ylabel('Degree Deviation');
    xlabel('Time (s)');
    title('Vertical Degree Deviation');
    xline(0, '--k', strcat('Trial_', num2str(0)), 'LineWidth', 1);
    for ii = 1:length(startLoc);
        xline(startLoc(ii), '--k', strcat('Trial ', num2str(ii)), 'LineWidth', 1);
    end
    for jj = 1:length(saccadeLocsXY);
        xline(saccadeLocsXY(jj)/FPS, 'r');
    end
    % yline(0, 'k', 'LineWidth', 1);
    ylim([-maxXYcal, maxXYcal]);
    hold off;

    subplot(2,1,2);
    plot(time, xCentroidsCal);
    hold on;
    ylabel('Degree Deviation');
    xlabel('Time (s)');
    title('Horizontal Degree Deviation');
    xline(0, '--k', strcat('Trial_', num2str(0)), 'LineWidth', 1);
    for ii = 1:length(startLoc);
        xline(startLoc(ii), '--k', strcat('Trial ', num2str(ii)), 'LineWidth', 1);
    end
    for jj = 1:length(saccadeLocsXY);
        xline(saccadeLocsXY(jj)/FPS, 'r');
    end
    % yline(0, 'k', 'LineWidth', 1);
    ylim([-maxXYcal, maxXYcal]);
    hold off;

    deltaDegree = zeros(length(saccadeLocsXY), 2);

    for ii = 1:length(saccadeLocsXY);
        avgDegreeAX = mean(xCentroidsCal(saccadeLocsXY(ii)+2:saccadeLocsXY(ii)+5));
        avgDegreeBX = mean(xCentroidsCal(saccadeLocsXY(ii)-6:saccadeLocsXY(ii)-3));
        deltaDegree(ii, 1) = abs(avgDegreeAX - avgDegreeBX);
        avgDegreeAY = mean(yCentroidsCal(saccadeLocsXY(ii)+2:saccadeLocsXY(ii)+5));
        avgDegreeBY = mean(yCentroidsCal(saccadeLocsXY(ii)-6:saccadeLocsXY(ii)-3));
        deltaDegree(ii, 2) = abs(avgDegreeAY - avgDegreeBY);
    end

    figure;
    h0 = histogram(deltaDegree(:, 1), 'BinWidth', 0.1);
    xlabel('Opening Angle');
    ylabel('Saccade Bin Count');
    title('Distribution of Opening Angle from Previous Location');

    figure;
    h1 = histogram(xCentroidsCal(visPupils));
    h1.BinWidth = 0.25;
    hold on;
    h2 = histogram(yCentroidsCal(visPupils));
    h2.BinWidth = 0.25;
    xlabel('Degree Deviation');
    ylabel('Bin Count');
    title('Distribution of Degree Deviation from Mean/Center');
    xlim([-25, 25]);
    hold off;

    deviationAngle = atan2(yCentroidsCal(visPupils), xCentroidsCal(visPupils));
    figure;
    polarhistogram(deviationAngle, 36);
    title('Saccade Angular Preference');        

    save(strcat(saveFileName, '.mat'), 'fitresult', 'xCentroidsCal', 'yCentroidsCal', ...
        'time', 'maxXYcal', 'deltaDegree', 'deviationAngle', 'visPupils', 'saccadeLocsXY');
end
