function graphDistLine(x, y, fitx, fity, name, color, N)
    txt = "%s: y = %4.3f Mean: %4.3f, Sigma: %5.4f, N = %4.2f";
    %txttwo = "%s ?:
    hold on
    sd = std(y);
    disp(sd);
    m = mean(y);
    %[p, delta] = polyfix(x, y, 1, 0, 0);
    %legend = sprintf(txt, name, p(1,1));
    [p,S,mu] = polyfit(fitx,fity,0);
    [poly,delta] = polyval(p,fitx,S,mu);
    hold on;
    distribution = scatter(x(1,:), y(1,:), 15, color, "filled", 'HandleVisibility', 'off');
    %plot(x,y,'.','Color', color, 'HandleVisibility', 'off');

    plot(fitx,poly, 'Color', color, 'LineWidth', 1, 'DisplayName', sprintf(txt, name, p(1,1), m, sd, N));
    %plot(x,polyval(p,x,mu), 'Color', color, 'LineWidth', 1, 'DisplayName', sprintf(txt, name, p(1,1)));
    edges = [];
    edge = 0;
    for i = 1:18
        edges(i) = (edge + ((i-1)*0.05));
    end
%     histo = histogram(t1heights, 'BinEdges', edges);
end