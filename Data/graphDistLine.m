function graphDistLine(x, y, name, color, N)
    txt = "%s: y = %4.3f Mean: %4.3f, Sigma: %5.4f, N = %4.2f";
    %txttwo = "%s ?:
    hold on
    sd = std(y);
    disp(sd);
    m = mean(y);
    %[p, delta] = polyfix(x, y, 1, 0, 0);
    %legend = sprintf(txt, name, p(1,1));
    [p,S,mu] = polyfit(x,y,0);
    [poly,delta] = polyval(p,x,S,mu);
    hold on;
    scatter(x(1,:), y(1,:), 15, color, "filled", 'HandleVisibility', 'off');
    %plot(x,y,'.','Color', color, 'HandleVisibility', 'off');

    plot(x,poly, 'Color', color, 'LineWidth', 1, 'DisplayName', sprintf(txt, name, p(1,1), m, sd, N));
    %plot(x,polyval(p,x,mu), 'Color', color, 'LineWidth', 1, 'DisplayName', sprintf(txt, name, p(1,1)));
end