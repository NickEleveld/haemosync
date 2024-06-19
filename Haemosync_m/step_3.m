%%  ... Step 3
% Use cross-correlation for local time-shift estimation
function [tau_selected_all,xc_mean_maxvalue_all] = ...
step_3(rescaledTT,lowfreq_threshold,variableNames,maxWindowSize,...
minWindowSize,sampleFreq,max_tau_sec,stepsize_sec,threshold_correlation)
%% Obtain original S1 and S2
signal1 = rescaledTT.(variableNames{2});
signal2 = rescaledTT.(variableNames{3});
%% Apply high-pass filter
n= 5;
[b,a] = butter(n,lowfreq_threshold/(sampleFreq/2),'high');
signal1filtered = filtfilt(b,a,signal1);
signal2filtered = filtfilt(b,a,signal2);
%% Cross Correlation S1 and S2
nr_windows = 30; % 28 + 2 windows (lowest and highest window size, default: 40 and 100 s)
W_temp = primes(maxWindowSize*sampleFreq);
W_temp = W_temp (W_temp > minWindowSize*sampleFreq);
W_temp = 2*floor(W_temp/2); % Make windowsizes even, so windowsize/2 is always an integer
W_temp = W_temp(1:ceil(length(W_temp)/(nr_windows-2)):length(W_temp));
W = [minWindowSize*sampleFreq,W_temp,maxWindowSize*sampleFreq]; % Final Array with window sizes
max_tau     = max_tau_sec*sampleFreq; % Maximum lag for the correlation function
stepsize    = stepsize_sec*sampleFreq; 
T       = max(W)/2+max_tau : stepsize : length(signal2filtered)-max(W)/2-max_tau;
tau_selected_all     = zeros(1,length(T));
xc_mean_maxvalue_all = zeros(1,length(T));
% Iterate over all timepoint in steps of 5 (default) seconds
for i = 1:length(T)
    xc_all          = zeros(max_tau*2+1,length(W));
% Iterate over all window sizes
    for j = 1:length(W)
        
        startWindow  = T(i) - W(j)/2; % Start index window
        endWindow    = T(i) + W(j)/2; % End   index window
        if j==1
        [xc_none,tau_values] = xcorr(signal2filtered(startWindow:endWindow)-mean(signal2filtered(startWindow:endWindow)),...
                                     signal1filtered(startWindow:endWindow)-mean(signal1filtered(startWindow:endWindow)),'none',max_tau); % Define tau_values
        else
        [xc_none,~]          = xcorr(signal2filtered(startWindow:endWindow)-mean(signal2filtered(startWindow:endWindow)),...
                                     signal1filtered(startWindow:endWindow)-mean(signal1filtered(startWindow:endWindow)),'none',max_tau);
        end
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
% Put cross-correlations for each window (j) in a matrix xc_all
        xc_all(:,j) = xc_unbiased_normalized;
    end
%% Calculate mean cross-correlation for over all windows
    xc_mean = mean(xc_all,2);
%% Determine the maximum cross-correlation in xc_mean and find the corresponding index
    [xc_mean_maxvalue, xc_mean_maxvalue_index] = max(xc_mean);
%% Save only the tau values when the max cross-correlation exceeds the threshold
    if xc_mean_maxvalue >= threshold_correlation
        tau_selected     = tau_values(xc_mean_maxvalue_index);
    else
        tau_selected     = NaN; 
    end
%% Put all tau values and max cross correlation values in a array
    tau_selected_all(i)     = tau_selected;         
    xc_mean_maxvalue_all(i) = xc_mean_maxvalue;
end