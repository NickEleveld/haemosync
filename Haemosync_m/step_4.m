%%  ... Step 4
% Use cross-correlation for local, precise time-shift estimation
function [tau_Step3_4,tau_Step1_2,peak_xc_final,T,syncedData] = ...
    step_4(rescaledTT,windowSizeprecise,lowfreq_threshold2,movmediantau,...
    maxWindowSize,sampleFreq,max_tau_sec,stepsize_sec,variableNames,tau_Step1_2_all)
%% Apply low-pass filter to S1 and S2
n = 5; % Fifth order filter
[b,a] = butter(n,lowfreq_threshold2/(sampleFreq/2),'high');
signal1filtered = filtfilt(b,a,rescaledTT.(variableNames{2})); % Filter signal 1
signal2filtered = filtfilt(b,a,rescaledTT.(variableNames{3})); % Filter signal 2
%% Cross Correlation Signal 1 and Signal 2 with one small window
W_precise        = windowSizeprecise*sampleFreq;
max_tau_samples  = max_tau_sec*sampleFreq; % Maximum lag for the correlation function: to prevent long shifts because unbiased xcorr favours large lags
stepsize_samples = stepsize_sec*sampleFreq; % 5 sec, fixed
T = [(maxWindowSize*sampleFreq)/2+max_tau_samples : stepsize_samples : length(signal2filtered)-(maxWindowSize*sampleFreq)/2-max_tau_samples];
% Initialise output timetables
signal2_input       = rescaledTT(:,variableNames(3:end)); %used as input signal2
signal2_synced      = signal2_input; signal2_synced{:,:} = 0; % 
tau_Step3_4         = timetable(rescaledTT.Properties.RowTimes,zeros(height(rescaledTT),1),'VariableNames',"tau step 3&4");
peak_xc_final        = timetable(rescaledTT.Properties.RowTimes,zeros(height(rescaledTT),1),'VariableNames',"max_xc_final");
% Run cross-correlation script over signal length with steps defined in vector T
for i = 1:length(T) 
    startWindow = T(i) - W_precise/2; %start window
    endWindow   = T(i) + W_precise/2; %end window
    [xc_none,tau_values] = xcorr(signal2filtered(startWindow:endWindow)-mean(signal2filtered(startWindow:endWindow)),...
                                 signal1filtered(startWindow:endWindow)-mean(signal1filtered(startWindow:endWindow)),'none',max_tau_samples);
    % Normalizing
    cxx0 = sum(abs(signal2filtered(startWindow:endWindow)-mean(signal2filtered(startWindow:endWindow))).^2);
    cyy0 = sum(abs(signal1filtered(startWindow:endWindow)-mean(signal1filtered(startWindow:endWindow))).^2);
    scaleCoeffCross = sqrt(cxx0*cyy0);
    xc_normalized = xc_none./scaleCoeffCross;
    
    % Unbiasing
    L = (size(xc_none,1) - 1)/2;
    m = size(signal1filtered(startWindow:endWindow)-mean(signal1filtered(startWindow:endWindow)),1);
    scaleUnbiased = (m - abs(-L:L)).';
    scaleUnbiased(scaleUnbiased <= 0) = 1;
    scaleUnbiased_v2 = scaleUnbiased/max(scaleUnbiased);
    xc_unbiased_normalized = xc_normalized./scaleUnbiased_v2;
%% Find all positive peaks in the 'cross-correlation vs tau plot' using findpeaks
    [~, locs] = findpeaks(xc_unbiased_normalized,MinPeakProminence=std(xc_unbiased_normalized),MinPeakDistance=80);
    tau_options = tau_values(locs); % These are the possible tau values from Step 4
%% Use tau_options (from precise estimation) and movmediantau (from Step 3) to determine the final tau value for location Ti
% If either movemediantau==NaN or there are no tau_options, set the final tau 
% value for location Ti to NaN. If not, set tau to tau_options@location_besttau
    if isnan(movmediantau(i)) || isempty(tau_options)
        tau = NaN;
        xc_unbiased_normalized_location_besttau = NaN;
    else
        [~,index_besttau]    = min(abs(tau_options -movmediantau(i)));
        tau                  = tau_options(index_besttau);
        xc_unbiased_normalized_location_besttau = xc_unbiased_normalized(locs(index_besttau));
    end
%% Fill timetable Signal2_synced with values time-shifted by tau
    start_correction = T(i) - ceil(stepsize_samples/2); % start window, if stepsize/2 not an integer, choose integer above
    end_correction   = T(i) + ceil(stepsize_samples/2); % end   window, if stepsize/2 not an integer, choose integer above
       
    if ~isnan(tau)
        signal2_synced(start_correction:end_correction,:)   = signal2_input((start_correction+tau):(end_correction+tau),:);
        tau_Step3_4{start_correction:end_correction,:}      = tau;
        peak_xc_final{start_correction:end_correction,:}     = xc_unbiased_normalized_location_besttau;
    else
        signal2_synced{start_correction:end_correction,:}   = zeros(size(signal2_input((start_correction):(end_correction),:)));
        tau_Step3_4{start_correction:end_correction,:}      = NaN;
        peak_xc_final{start_correction:end_correction,:}     = NaN;
    end
end
%% Keep only tau and cross-corr values for which a shift of the data has been applied
tau_Step1_2 = tau_Step1_2_all;
tau_Step1_2 ([1 : T(1) - ceil(stepsize_samples/2-1), T(end)+ceil(stepsize_samples/2+1) : height(tau_Step1_2)],:) = [];    
tau_Step3_4 ([1 : T(1) - ceil(stepsize_samples/2-1), T(end)+ceil(stepsize_samples/2+1) : height(tau_Step3_4)],:) = [];
peak_xc_final([1 : T(1) - ceil(stepsize_samples/2-1), T(end)+ceil(stepsize_samples/2+1) : height(peak_xc_final)],:) = [];
%% Create synced Datafile
syncedData = [rescaledTT(:,variableNames{2}),signal2_synced];