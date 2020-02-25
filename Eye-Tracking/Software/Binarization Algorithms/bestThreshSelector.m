function [threshValue, bestThreshIm] = bestThreshSelector(raw, numThresh, imSizeX, imSizeY);
    startStack = zeros(imSizeX, imSizeY, numThresh);

    %% Initial Threshold Paramaters for Objects
    disp('Use the data cursor to determine a threshold value for the object.');
    
    fig1 = figure;
    imshow(raw);
    caxis auto
    thresh = input('What is that threshold value? ');
    close(fig1);
    
    threshRange = linspace(thresh-9, thresh+10, numThresh)/255;

    for r = 1:numThresh;  
        BW = im2bw(raw, threshRange(r));
        specRemoved = bwareaopen(BW, 100);
        bwErode = imerode(specRemoved, ones(1,1));  
        bwMedFilt = medfilt2(bwErode);
        bwDilate = imdilate(bwMedFilt, ones(2, 2));
        bwErode2 = imerode(bwDilate, ones(1, 1));
        bwSpecRemoved = bwareaopen(bwErode2, 100);
        startStack(:, :, r) = bwSpecRemoved;
    end   
    
    playStack = implay(startStack);
    bestThresh = input('Which frame has the best thresholding? ');
    threshValue = threshRange(bestThresh);
    bestThreshIm = startStack(:, :, bestThresh);
    close(playStack);
    
end