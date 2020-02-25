function [binarizedIm, objectStats, objectLost] = objectBinarize(raw, objectMask, cst, bestThresh, prevBin, x, y);
    
    maskedIm = immultiply(raw, objectMask);
    BW = im2bw(maskedIm, bestThresh); 
    specRemoved = bwareaopen(BW, 100);
    bwErode = imerode(specRemoved, ones(1,1));  
    bwMedFilt = medfilt2(bwErode);
    bwDilate = imdilate(bwMedFilt, ones(2, 2));
    bwErode2 = imerode(bwDilate, ones(1, 1));
    bwSpecRemoved = bwareaopen(bwErode2, 500);
    binarizedIm = bwSpecRemoved;
%     bwSelected = bwselect(bwSpecRemoved, x, y);
%     binarizedIm = bwSelected;
    [objectLabel, num] = bwlabel(binarizedIm);

    if num > 1;
        for n = 1:num;
            object = find(objectLabel == n);
            objectSize = length(object);
            if objectSize > objectSize + cst;
                objectLabel(object) = 0;
            elseif objectSize < objectSize - cst;
                objectLabel(object) = 0;
            else
                objectLabel(object) = 1;
            end
        end

        [objectLabel2, num] = bwlabel(objectLabel);
        if num > 1;
            imshow(objectLabel2);
            caxis auto
            disp('Please click on the object being tracked.');
            [X, Y] = ginput(1);
            X = uint16(X);
            Y = uint16(Y);
            value = objectLabel2(Y, X);
            pupilIndex = objectLabel2 == value;
            objectLabel2(pupilIndex) = 1;
            objectLabel2(~pupilIndex) = 0;
            objectLost = false;
        end
        objectLabel = objectLabel2;
        binarizedIm = objectLabel;
    elseif num == 0;
        objectLost = true;
        binarizedIm = prevBin;
    else
        objectLost = false;
    end
    
    objectStats = regionprops(binarizedIm, 'Centroid', 'BoundingBox', 'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'Area');
end