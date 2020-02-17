function graphLine(pointSlope, fixedOrigin, logPlot, x, y, dir, name, color1, color2)
    %x = normalize(x);
    pos = 1;
    neg = 1;
    for i = 1:length(x)
        if dir(i) == 1
            posx(pos) = x(i);
            posy(pos) = y(i);
            pos = pos + 1;
        else
            negx(neg) = x(i);
            negy(neg) = y(i);
            neg = neg + 1;
        end
    end
        i = 1;
    while i <= length(posx)
        if posx(i) == 0 || posy(i) == 0 || posx(i) > 20
            posx(i) = [];
            posy(i) = [];
        else
            i = i+1;
        end
    end
    i = 1;
    while i <= length(negx)
        if negx(i) == 0 || negy(i) == 0 || negx(i) > 20
            negx(i) = [];
            negy(i) = [];
        else
            i = i+1;
        end
    end
    negx = -negx;
    figure(pointSlope);
    txt = "%s %s : y = %4.3fx + %4.3f";
    posfit = polyfit(posx(1,:), posy(1,:), 1);
    yfit = polyval(posfit,posx);
    hold on;
    plot(posx,posy,'.','Color', color1, 'HandleVisibility', 'off', 'MarkerSize', 10);
    plot(posx, yfit, 'Color', color1, 'LineWidth', 1, 'DisplayName', sprintf(txt, name, '(Right)', posfit(1,1), posfit(1,2)));
    negfit = polyfit(negx(1,:), negy(1,:), 1);
    yfit = polyval(negfit,negx);
    hold on;
    plot(negx,negy,'.','Color', color2, 'HandleVisibility', 'off', 'MarkerSize', 10);
    plot(negx, yfit, 'Color', color2, 'LineWidth', 1, 'DisplayName', sprintf(txt, name, '(Left)', negfit(1,1), posfit(1,2)));
    grid on;
    
    figure(fixedOrigin);
    txt = "%s %s : y = %4.3fx";
    hold on
    posfit = polyfix(posx, posy, 1, 0, 0);
    yfit = polyval(posfit,posx);
    hold on;
    plot(posx,posy,'.','Color', color1, 'HandleVisibility', 'off', 'MarkerSize', 10);
    plot(posx,yfit, 'Color', color1, 'LineWidth', 1, 'DisplayName', sprintf(txt, name, '(Right)', posfit(1,1)));
    grid on;
    negfit = polyfix(negx, negy, 1, 0, 0);
    yfit = polyval(negfit,negx);
    hold on;
    plot(negx,negy,'.','Color', color2, 'HandleVisibility', 'off', 'MarkerSize', 10);
    plot(negx,yfit, 'Color', color2, 'LineWidth', 1, 'DisplayName', sprintf(txt, name, '(Left)', negfit(1,1)));
    grid on;
    
    figure(logPlot);

    
    poslogx = log10(posx);
    poslogy = log10(posy);
    neglogx = log10(-negx);
    neglogy = log10(negy);
    
    txt = "%s %s : y = %4.2fx + %4.2f";
    hold on
    poslogfit = polyfit(poslogx(1,:), poslogy(1,:), 1);
    yfit = polyval(poslogfit,poslogx);
    hold on
    plot(poslogx,poslogy,'.','Color', color1, 'HandleVisibility', 'off', 'MarkerSize', 10);
    plot(poslogx,yfit, 'Color', color1, 'LineWidth', 1, 'DisplayName', sprintf(txt, name, '(Right)', poslogfit(1,1), poslogfit(1,2)));
    hold on
    neglogfit = polyfit(neglogx(1,:), neglogy(1,:), 1);
    yfit = polyval(neglogfit,neglogx);
    hold on
    if name ~= "Anstis"
        plot(neglogx,neglogy,'.','Color', color2, 'HandleVisibility', 'off', 'MarkerSize', 10);
        plot(neglogx,yfit, 'Color', color2, 'LineWidth', 1, 'DisplayName', sprintf(txt, name, '(Left)', neglogfit(1,1), neglogfit(1,2)));
    end
    grid on;
end