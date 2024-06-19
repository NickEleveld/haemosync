function output_details = create_output(markers,lowfreq_threshold,lowfreq_threshold2,maxWindowSize,sampleFreq,movmediantau,tau_Step1_2,tau_Step3_4,peak_xc_final)
%% CREATE_OUTPUT_PUBLISHEDVERSION Create output
% Create a struct with:
%% 
% # Time-shift detection and correction details
% # The detected time-shift per sample
% # Some input data properties
output_details  = struct([]);
output_details(1).firstmarkerS1               = markers(1);
output_details(1).firstmarkerS2               = markers(2);
output_details(1).lastmarkerS1                = markers(3);
output_details(1).lastmarkerS2                = markers(4);
output_details(1).freqThreshold_Step3         = lowfreq_threshold;
output_details(1).freqThreshold_Step4         = lowfreq_threshold2;
output_details(1).maxWindowSize               = maxWindowSize;
output_details(1).sampleFreq                  = sampleFreq;
output_details(1).medianTau                   = movmediantau;
tau_final = timetable(tau_Step1_2.Properties.RowTimes,tau_Step1_2{:,1}+tau_Step3_4{:,1},'VariableNames',"tau final");
output_details(1).tau_final                   = tau_final;
output_details(1).tau_Step1_2                 = tau_Step1_2;
output_details(1).tau_Step3_4                 = tau_Step3_4;
output_details(1).peak_xc_final               = peak_xc_final;