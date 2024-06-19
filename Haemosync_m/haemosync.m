%% HAEMOSYNC Haemosync Algorithm
function [syncedData,output_details,markers] = haemosync(originaldata,...
maxWindowSize,minWindowSize,windowSizeprecise,sampleFreq,lowfreq_threshold,lowfreq_threshold2,...
max_tau_sec,stepsize_sec,threshold_crosscorr,mode_variableNames,mode_select_markers,mode_step1_2,variableNames_predefined,predefined_markers,plotdata,movmedian_size)
%% Select Variable names to detect the:
%% 
% # Datetime vector
% # S1
% # S2 (to be time-shift corrected)
% # (Optionally) an additional signal S2
[variableNames] = select_variablenames(mode_variableNames,[originaldata.Properties.DimensionNames(1),originaldata.Properties.VariableNames],variableNames_predefined);
%% Markers
% Select or upload markers (datetime format)
markers = select_markers(mode_select_markers,variableNames,originaldata,predefined_markers);
%% Step 1 & 2: Shift and rescale the data
[rescaledTT,tau_Step1_2_all] = step_1_2(mode_step1_2,originaldata(:,variableNames(2:end)),variableNames,markers,sampleFreq);
%% Step 3: Local tau estimation
[tau,~] = step_3(rescaledTT,lowfreq_threshold,variableNames,maxWindowSize,...
    minWindowSize,sampleFreq,max_tau_sec,stepsize_sec,threshold_crosscorr);
% Smooth local tau estimation
movmediantau = movmedian(tau,movmedian_size,'omitnan');
%% Step 4: Local, precise tau estimation
[tau_Step3_4,tau_Step1_2,peak_xc_final,T,syncedData] =...
    step_4(rescaledTT,windowSizeprecise,lowfreq_threshold2,movmediantau,...
        maxWindowSize,sampleFreq,max_tau_sec,stepsize_sec,variableNames,tau_Step1_2_all);
%% Visualisatise corrected data and tau
if strcmp(plotdata,'on')
    visualise_results(originaldata,syncedData,movmediantau,tau_Step3_4,...
        tau_Step1_2,peak_xc_final, variableNames,T);
end
%% Create Output struct
output_details = create_output(markers, lowfreq_threshold,lowfreq_threshold2,...
    maxWindowSize,sampleFreq,movmediantau,tau_Step1_2,tau_Step3_4,peak_xc_final);