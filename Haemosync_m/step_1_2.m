function [rescaledTT,tau_Step1_2] = step_1_2(mode_step1_2,currentDataset,variableNames,markers,sampleFreq)
%% STEP_1_2 Step 1 and 2:
% There are 3 options: 
%% 
% # none: do not apply Step 1 and 2. No changes to signals S1 or S2
% # shfiting: Apply only Step 1, shifting S2 by the difference between M1_S2 
% and M1_S1
% # shifting&scaling: Apply Step 1 and 2, by shifting and scaling S2 by the 
% difference between M2_S2 - M1_S2 and M2_S1 - M1_S1
%% 
% tau_Step1_2 contains the applied shifting (and scaling) to each sample of 
% S2
%% No Step 1 and/or 2
if strcmp(mode_step1_2,'none')
    rescaledTT          = currentDataset;
    tau_Step1_2         = timetable(currentDataset.Properties.RowTimes,zeros(height(currentDataset),1),'VariableNames',"tau step 1&2"); % Contains only zeros
%% Step 1: Shifting
% Determine difference between first markers M1_S1 and M1_S2
elseif strcmp(mode_step1_2,'shifting')
    shifted_datetimesS2 = currentDataset.(variableNames{1})-(markers(2)-markers(1));
    S2_new              = currentDataset(:,{variableNames{3:end}});
    S2_new.Properties.RowTimes = shifted_datetimesS2;
    S2_new_retimed      = retime(S2_new,currentDataset.(variableNames{1}),'linear','EndValues',0);
    rescaledTT          = [currentDataset(:,variableNames{2}),S2_new_retimed];
% Tau resulting from Step 1
    tau_temp            = seconds(markers(2)-markers(1))*sampleFreq;
    tau_Step1_2         = timetable(currentDataset.Properties.RowTimes,ones(height(currentDataset),1)*tau_temp,'VariableNames',"tau step 1&2");
%% Step 1 + 2: Shifting + Scaling
% Signal 1 - Determine number of samples between the Markers M1 and M2
elseif strcmp(mode_step1_2,'shifting&scaling')
    [diffStartS1,rowMarker1_S1]  = min(abs((currentDataset.(variableNames{1})-markers(1))));
    [diffEndS1  ,rowMarker2_S1]  = min(abs((currentDataset.(variableNames{1})-markers(3))));
    rowsSignal1                  = rowMarker2_S1 - rowMarker1_S1;    
    if any([[milliseconds(diffStartS1),milliseconds(diffEndS1)]>10])
        error('Error: Difference between annotated Marker 1 or 2 datetime timestamp and closest datetime timestamp in Signal 1 is > 10 ms.\n%s',...
            'Choose a marker closer to a timestamp in Signal 1')
    end
% Signal 2 - Determine number of samples between the Markers M1 and M2
    [diffStartS2,rowMarker1_S2]   = min(abs((currentDataset.(variableNames{1})-markers(2))));
    [diffEndS2  ,rowMarker2_S2]   = min(abs((currentDataset.(variableNames{1})-markers(4))));
    rowsSignal2                              = rowMarker2_S2 - rowMarker1_S2;
    if any([[milliseconds(diffStartS2),milliseconds(diffEndS2)]>10])
        error('Error: Difference between annotated Marker 1 or 2 datetime timestamp and closest datetime timestamp in Signal 2 is > 10 ms.\n%s',...
            'Choose a marker closer to a timestamp in Signal 2')
    end
% Calculate correction factor: By how much should the timestep for S2 be multiplied?
    correctionFactor          = rowsSignal1/rowsSignal2;
    timestepSignal2Original   = mean(diff(currentDataset.(variableNames{1}))); 
    timestepSignal2New        = timestepSignal2Original*correctionFactor;
% Create a new datetime vector with the corrected timestamps for S2
    nr_following_rows_Signal2           = height(currentDataset) - rowMarker1_S2;
    datetimes_following                 = [markers(1) + [ 1:nr_following_rows_Signal2 ] * timestepSignal2New]';
    datetimes_preceding                 = [markers(1) -        [ rowMarker1_S2-1:-1:0 ] * timestepSignal2New]';
    shifted_scaleddatetimesS2           = [datetimes_preceding;datetimes_following];
    shifted_scaleddatetimesS2.Format    = 'yyyy-MM-dd hh:mm:ss.SSSSSSSSSS';
% Combine datetime vector with original S2 data. Linearly interpolate to original sampling frequency
    S2_new                     = currentDataset(:,{variableNames{3:end}});
    S2_new.Properties.RowTimes = shifted_scaleddatetimesS2;
    S2_new_retimed             = retime(S2_new,currentDataset.(variableNames{1}),'linear','EndValues',0);
    rescaledTT                 = [currentDataset(:,variableNames{2}),S2_new_retimed];
% Tau resulting from Step 1 and 2
    diff_scaled = currentDataset.Properties.RowTimes - shifted_scaleddatetimesS2; % Negative value because tau represents the (previously present) time-shift
    tau_Step1_2 = timetable(currentDataset.Properties.RowTimes,seconds(diff_scaled)*sampleFreq,'VariableNames',"tau step 1&2");    
end