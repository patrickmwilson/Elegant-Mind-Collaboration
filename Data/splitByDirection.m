function [negx, negy, posx, posy] = splitByDirection(x, y, dir)
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

    negx = -negx;
end