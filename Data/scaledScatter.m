function scaledScatter(plot, x, y, color, dotSize)
    figure(plot);
    z = x';
    z(:,2) = y';

    [q, I, ~] = unique(z, 'rows');
    hold on;
    scatter(q(:,1), q(:,2), dotSize, color, "filled", 'HandleVisibility', 'off');
    
    dupIndeces = setdiff(1:size(z,1),I);
    dupRows = z(dupIndeces,:);
    
    if(size(dupRows,1) > 0)
        dupX = (dupRows(:,1))';
        dupY = (dupRows(:,2))';
        scaledScatter(plot,dupX,dupY,color,dotSize+2);
    end
    
end