function ButtonUI()
    global CHECKBOXES;
    CHECKBOXES = [1,1,1,1,1,1,1,1,1,1,1,1];
    names = ["T1",'Three Lines','Crowded Periphery 11x11','Crowded Periphery 7x7', ...
        'Crowded Periphery 5x5', 'Crowded Periphery Cross', 'Crowded Periphery Inner', ...
        'Crowded Periphery Outer', 'Crowded Center 9x9', 'Crowded Center 3x3', 'Isolated Character', 'Anstis'];
    f = figure;
    cbh = [0,0,0,0,0,0,0,0,0,0,0,0];
    for k=1:12 
        cbh(k) = uicontrol('Style','checkbox','String',names(k), ...
                      'Value',1,'Position',[30 (280-(20*k)) 200 20],        ...
                       'Callback',{@checkBoxCallback,k});
    end
    uiwait(f);
end

function checkBoxCallback(hObject,eventData,checkBoxId)
    global CHECKBOXES
    switch checkBoxId
        case 1
            CHECKBOXES(1) = 0;
        case 2
            CHECKBOXES(2) = 0;
        case 3
            CHECKBOXES(3) = 0;
        case 4
            CHECKBOXES(4) = 0;
        case 5
            CHECKBOXES(5) = 0;
        case 6
            CHECKBOXES(6) = 0;
        case 7
            CHECKBOXES(7) = 0;
        case 8
            CHECKBOXES(8) = 0;
        case 9
            CHECKBOXES(9) = 0;
        case 10
            CHECKBOXES(10) = 0;
        case 11
            CHECKBOXES(11) = 0;
        case 12
            CHECKBOXES(12) = 0;
    end
end

