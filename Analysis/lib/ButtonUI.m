% ButtonUI
%
% Creates a UI figure with checkboxes that upon callback, edit the values stored
% in the global checkboxes array. Usage of this script is not recommended as 
% global variables can be tricky to work with. These were used here to avoid 
% issues with transferring variables from the figure's workspace to the base 
% workspace.
function ButtonUI(info)
    global CHECKBOXES;
    CHECKBOXES = ones(length(info));
    
    % Create the figure with named checkboxes
    f = figure;
    for k=1:length(info) 
        cbh(k) = uicontrol('Style','checkbox','String',info(k).name, ...
                      'Value',1,'Position',[30 (280-(20*k)) 200 20], ...
                       'Callback',{@checkBoxCallback,k});
    end
    uiwait(f);
end

% Upon checkbox callback, reverse the value held by the checkbox.
function checkBoxCallback(~,~,checkBoxId)

    global CHECKBOXES
    CHECKBOXES(checkBoxId) = (CHECKBOXES(checkBoxId)==0);
    
end

