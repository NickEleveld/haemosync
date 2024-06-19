%% Main script containing parameter settings
%% Define input data and characteristics

% originaldata = ;  % To be filled in by the user: Timetable with the input data:
                  % Size: (rows,columns=3) OR (rows, columns=4)
                  % First time column in datetime format, equally sampled with sampling frequency 'sampleFreq'
                  % When automatic variable (mode_variableNames = 'auto') selection is used:
                  %    Second column: input signal S1
                  %    Third column: input signal S2, will be corrected
                  %    Optional fourth column: input signal S2_2, will be corrected, but is not used for time-shift detection
sampleFreq = 200; % Sampling frequency of the input signals. In Hz (s^-1). For sample measurement: 200
%% Output: Select output folder for export of figures and the output details (output_struct)

plotdata        = 'on'; % 'on','off'. If you want to plot the results select 'on'. Otherwise: 'off'
%% Classification of the variables in the timetable
% There are 3 options: 
%% 
% # auto: select only the first three columns in the timetable. These should 
% correspond to 1: datetime column, 2: S1 (input signal), 3: S2 (output signal) 
% # manual: Manually select the datetime, S1, S2, and (optionally) a seconds 
% output signal in the pop-up box
% # predefined: Use predefined variable name provided by the user (must be length 
% 3 or 4, and the order must be column 1: datetime column, 2: S1, 3: S2, 4: optional 
% second signal S2

mode_selectvariables = 'auto'; %'predefined','auto','manual' 
if strcmp(mode_selectvariables, 'predefined')
    variableNames_predefined   = {'datetimevariable';'S1';'S2';'S2_2'}; % To be filled in by the user
else; variableNames_predefined = {'';'';'';''}; % Dummy variable
end
%% Settings for Step 1 and 2 (Shifting and Scaling)
% There are 3 options: 
%% 
% # none: do not apply Step 1 and 2. No changes to signals S1 or S2
% # shfiting: Apply only Step 1, shifting S2 by the difference between M1_S2 
% and M1_S1
% # shifting&scaling: Apply Step 1 and 2, by shifting and scaling S2 by the 
% difference between M2_S2 - M1_S2 and M2_S1 - M1_S1

mode_step1_2        = 'none'; %'none','shifting','shifting&scaling'
% Select markers
% There are 3 options:
%% 
% # off: Do no select any markers. Entails that Step 1 and 2 cannot be performed 
% # manual: Manually select the markers in a figure that will pop-up in the 
% following order : M1_S1 M1_S2 M2_S1 M2_S2. After each selection, press 'return'/'enter' 
% in the command window
% # predefined: Use predefined markers provided by the user. This must be a 
% vector with of size (4,1) with datetime values: [M1_S1, M1_S2, M2_S1, M2_S2]

mode_select_markers = 'off';  % 'predefined','manual','off'% For 'manual',
% Predefined markers
% When mode_select_markers = 'predefined', the variable predefined_markers contains 
% those markers.

if strcmp(mode_select_markers,'predefined')
    predefined_markers  = [datetime(2000,00,00,00,00,00,000);datetime(2000,00,00,00,00,00,000);...
                           datetime(2000,00,00,00,00,00,000);datetime(2000,00,00,00,00,00,000)]; % To be filled in by the user
else; predefined_markers  = ['';'';'';'']; % Dummy variable
end
%% Settings for Step 3 and 4 (Local and locale precise time-shift detection)

maxWindowSize       = 100; % Maximum window size in s, used in Step 3. Default: 100
minWindowSize       = 40;  % Maximum window size in s, used in Step 3. Default: 40
windowSizeprecise   = 10;  % Window size in s, used in Step 3. Default: 10
lowfreq_threshold   = 0.5; % High-pass cut-off frequency in Hz (s^-1), used in Step 3. Default: 0.5  
lowfreq_threshold2  = 0.1; % High-pass cut-off frequency in Hz (s^-1), used in Step 4. Default: 0.1 
max_tau_sec         = 5;   % Maximum absolute time-shift for cross-correlation in Step 3 & 4 in s. Default: 5
stepsize_sec        = 5;   % Step size between iterations in Step 3 & 4 in s. Default: 5
threshold_crosscorr = 0.15;% Cross-correlation treshold (mean cross-corr < threshold --> time-shift estimation excluded) in Step 3. Default: 0.15
movmedian_size      = 5;   % Movemedian smoothing of the local time-shift estimation (Step 3). Default: 5
%% Haemosync algorithm

[syncedData,output_details,markers] = ...
    haemosync(originaldata,maxWindowSize,minWindowSize,windowSizeprecise,...
        sampleFreq,lowfreq_threshold,lowfreq_threshold2,max_tau_sec,stepsize_sec,threshold_crosscorr,...
        mode_selectvariables,mode_select_markers,mode_step1_2,variableNames_predefined,...
        predefined_markers,plotdata,movmedian_size);