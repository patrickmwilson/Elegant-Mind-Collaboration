% ButtonUI
% Created by Patrick Wilson on 1/20/2020
% Github.com/patrickmwilson
% Created for the Elegant Mind Collaboration at UCLA under Professor Katsushi Arisaka
% Copyright © 2020 Elegant Mind Collaboration. All rights reserved.

% Creates a UI figure with checkboxes that upon callback, edit the values stored
% in the global checkboxes array. Usage of this script is not reccommended as 
% global variables can be tricky to work with. These were used here to avoid 
% issues with transferring variables from the figure's workspace to the base 
% workspace.

function ButtonUI(names)
    global CHECKBOXES;
    CHECKBOXES = ones(length(names));
    
    % Create the figure with named checkboxes
    f = figure;
    for k=1:length(names) 
        cbh(k) = uicontrol('Style','checkbox','String',names(k), ...
                      'Value',1,'Position',[30 (280-(20*k)) 200 20],        ...
                       'Callback',{@checkBoxCallback,k});
    end
%     cbh(k+1) = uicontrol('Style','checkbox','String',"Plot Histograms Separately", ...
%                       'Value',1,'Position',[30 (280-(20*(k+1))) 200 20],        ...
%                        'Callback',{@checkBoxCallback,(k+1)});
    uiwait(f);
end

% Upon checkbox callback, reverse the value held by the checkbox.
function checkBoxCallback(~,~,checkBoxId)

    global CHECKBOXES
    CHECKBOXES(checkBoxId) = (CHECKBOXES(checkBoxId)==0);
    
end

