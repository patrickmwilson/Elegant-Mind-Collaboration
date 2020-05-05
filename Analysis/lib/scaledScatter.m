% scaledScatter
% Created by Patrick Wilson on 1/20/2020
% Github.com/patrickmwilson
% Created for the Elegant Mind Collaboration at UCLA 
% with Professor Katsushi Arisaka
% Copyright � 2020 Elegant Mind Collaboration. All rights reserved.

% Accepts a figure, a matrix containing x-values in column 1 and y-values
% in column 2, color, initial dot size, and dot size increment as input.
% Scatters the data, then recursively scatters any duplicate data with an
% increasing dot size.
function scaledScatter(plot, data, color, dotSize, dotSizeIncrement)

    figure(plot);
    
    % Get unique x-y combinations and their indices
    [q, I, ~] = unique(data, 'rows');
    hold on;
    scatter(q(:,1), q(:,2), dotSize, color, "filled", 'HandleVisibility', 'off');
    
    % Get indices of duplicate x-y pairs and their values
    dupIndeces = setdiff(1:size(data,1),I);
    dupes = data(dupIndeces,:);
    
    % If there were duplicate x-y pairs, function is called again to
    % scatter the duplicate points with a larger dot size 
    if(size(dupes,1) > 0)
        scaledScatter(plot,dupes,color,(dotSize+dotSizeIncrement),dotSizeIncrement);
    end
    
end