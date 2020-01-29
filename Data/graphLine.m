function graphLine(x, y, name, color)
    txt = "%s : y = %4.2fx";
    hold on
    [p, delta] = polyfix(x, y, 1, 0, 0);
    %legend = sprintf(txt, name, p(1,1));
    hold on;
    plot(x,y,'.','Color', color, 'HandleVisibility', 'off');
    plot(x,polyval(p,x,delta), 'Color', color, 'LineWidth', 1, 'DisplayName', sprintf(txt, name, p(1,1)));
end