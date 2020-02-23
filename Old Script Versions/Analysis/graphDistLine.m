function graphDistLine(x, y, fitx, fity, name, color, N, divided, distribution)
    txt = "%s: y = %4.3f Mean: %4.3f, Sigma: %5.4f, N = %4.2f";
    sd = std(y);
    disp(sd);
    m = mean(y);
    
    hold on
    figure(divided);
    p = polyfit(fitx,fity,0);
    [poly,~] = polyval(p,fitx,S,mu);
    hold on;
    scatter(x(1,:), y(1,:), 15, color, "filled", 'HandleVisibility', 'off');
    plot(fitx,poly, 'Color', color, 'LineWidth', 1, 'DisplayName', sprintf(txt, name, p(1,1), m, sd, N));
    edges = [];
    for i = 1:18
        edges(i) = (i-1)*0.05;
    end
    figure(distribution);
    histogram(t1heights, 'BinEdges', edges);
end