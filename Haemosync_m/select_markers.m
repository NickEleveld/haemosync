function markers = select_markers(mode_select_markers,variableNames,currentDataset,predefined_markers)
%% SELECT_MARKERS Select Marker
% Markers used for the shifting (Step 1) or shifting+scaling (Step 1 and 2) 
% 
% There are 3 options: 
%% 
% # Off: Do no select any markers. Entails that Step 1 and 2 cannot be performed 
% # Manual: Manually select the markers in the following order: M1_S1 M1_S2 
% M2_S1 M2_S2. After each selection, press 'return'/'enter' in the command window
% # Predefined: Use predefined markers provided by the user. This must be a 
% vector with of size (4,1) with datetime values: [M1_S1, M1_S2, M2_S1, M2_S2]
if strcmp(mode_select_markers,'off')
    markers_all = currentDataset.(variableNames{1});
    markers = [markers_all(1);markers_all(1);markers_all(end);markers_all(end)];
elseif strcmp(mode_select_markers,'manual')
    % Plot figure
    fig1 = figure;
    set(fig1,'Visible','on')
    ax1 = subplot(2,1,1);
    plot(currentDataset.(variableNames{1}),currentDataset.(variableNames{2}))
    title(variableNames{2})
    ax2 = subplot(2,1,2);
    plot(currentDataset.(variableNames{1}), currentDataset.(variableNames{3}))
    title(variableNames{3})
    linkaxes([ax1,ax2],'x')
    java.lang.System.gc()
    % Select timepoints using datacursormode
    datacursormode on
    actionToBeTaken = ["Click Marker 1 Signal 1 (top figure) using the Data Tips tool - Then press 'Enter' in command window",...
                       "Click Marker 1 Signal 2 (bottom figure) using the Data Tips tool - Then press 'Enter' in command window",...
                       "Click Marker 2 Signal 1 (top figure) using the Data Tips tool - Then press 'Enter' in command window"...
                       "Click Marker 2 Signal 2 (bottom figure) using the Data Tips tool - Then press 'Enter' in command window --> Done selecting!"];
    for i = 1:4
        dcm_obj = datacursormode(fig1);
        % Wait while the user to click
        disp(actionToBeTaken(i))
        disp('When  selected, press "Return/Enter"')
        sgtitle(actionToBeTaken(i))
        pause 
        % Export cursor to workspace
        info_struct = getCursorInfo(dcm_obj); %info_struct contains the row numbers of the event
        selectedmarkers(i) = info_struct.DataIndex;
    end
        markers    = currentDataset.(variableNames{1})(selectedmarkers(1:4));
        close(fig1)  
elseif strcmp(mode_select_markers,'predefined')
    if ~isa(predefined_markers,'datetime')
        error('The predefined Markers are not of the type datetime')
    elseif any(~[size(predefined_markers) == [4 1]])
        error('The predefined Markers are not of size (4,1)')
    elseif predefined_markers(1)>= predefined_markers(3)
        error('For Signal 1: predefined Marker 1 (element 1) is not smaller than predefined Marker 2 (element 3)')
    elseif predefined_markers(2) >= predefined_markers(4)
        error('For Signal 2: predefined Marker 1 (element 2) is not smaller than predefined Marker 2 (element 4)')
    else
        markers = predefined_markers;
    end
end