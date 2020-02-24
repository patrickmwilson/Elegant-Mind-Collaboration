function ButtonUI()
    global CHECKBOXES;
    CHECKBOXES = [0,0,0,0,0,0,0];
    names = ["T1", 'Crowded Periphery', 'Crowded Periphery Outer', ...
        'Crowded Center 9x9', 'Crowded Center 3x3', 'Isolated Character', 'Anstis'];
    f = figure;
    for k=1:7 
        cbh(k) = uicontrol('Style','checkbox','String',names(k), ...
                      'Value',0,'Position',[30 (280-(20*k)) 200 20],        ...
                       'Callback',{@checkBoxCallback,k});
    end
    uiwait(f);
end

function checkBoxCallback(hObject,eventData,checkBoxId)
    global CHECKBOXES
    switch checkBoxId
        case 1
            CHECKBOXES(1) = (CHECKBOXES(1)==0);
        case 2
            CHECKBOXES(2) = (CHECKBOXES(2)==0);
        case 3
            CHECKBOXES(3) = (CHECKBOXES(3)==0);
        case 4
            CHECKBOXES(4) = (CHECKBOXES(4)==0);
        case 5
            CHECKBOXES(5) = (CHECKBOXES(5)==0);
        case 6
            CHECKBOXES(6) = (CHECKBOXES(6)==0);
        case 7
            CHECKBOXES(7) = (CHECKBOXES(7)==0);
    end
end

