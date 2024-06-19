function [variableNames] = select_variablenames(mode,variableNames_default,variableNames_predefined)
%% SELECT_VARIABLENAMES Select Variable Names
% There are three options: 
%% 
% # Auto: select only the first three columns in the timetable. These should 
% correspond to 1: datetime column, 2: S1 (input signal), 3: S2 (output signal) 
% # Manual: Manually select the datetime, S1, S2, and (optionally) a seconds 
% output signal 
% # Predefined: Use predefined variable name provided by the user (must be length 
% 3 or 4, and the order must be column 1: datetime column, 2: S1, 3: S2, 4: optional 
% second S2)
if strcmp(mode,'auto')
    if length(variableNames_default) == 4
        variableNames = variableNames_default(1:4);
    elseif length(variableNames_default) == 3
        variableNames = variableNames_default(1:3); 
    else
        error('The number of variables (columns) in the input timetable including the datetime column is NOT 3 or 4')
    end
elseif strcmp(mode,'manual')
    defaultValue                = {'','', '',''};
    titleBar                    = 'Enter Variable Names';
    userPrompt                  = {'Enter Variable Name Timestamp','Enter Name Variable 1 (S1)', 'Enter Name Variable 2 (S2)', 'In Case a third signal exist with same timeclock as Signal 2, Enter variable name'};
    variableNames               = inputdlg(userPrompt, titleBar, 1, defaultValue)';
    close all
elseif strcmp(mode,'predefined')
    variableNames = variableNames_predefined;
    if ~[length(variableNames) == 3 || length(variableNames) == 4]  
        error('The length of the predefined variableNames cell array is not 3 or 4')
    end
end