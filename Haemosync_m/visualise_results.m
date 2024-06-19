%% VISUALISE_RESULTS Visualise results
function visualise_results(currentDataset,syncedData2,movmediantau,tau_step3_4,tau_Step1_2, peak_xc_final, variableNames, T)
% Three figures are created:
%% 
% # Plot original and synchronised data
% # Plot the time-shift estimation (tau), subdivided into the tau resulting 
% from Step 1+2, Step 3, Step 4 and Peak Cross-correlation
% # Plot original data, synchronised data, and total time-shift estimate (tau)
%% Plot effect synchronisation
    fig1 = figure(3); 
    hold off
    fig1.Visible = 'on';
    ax1 = subplot(2,1,1);
    for i=2:length(variableNames)
        plot(currentDataset.Properties.RowTimes, currentDataset.(variableNames{i}),'DisplayName',variableNames{i}); hold on;
    end
    legend; hold off;
    title('Original Data')
    java.lang.System.gc()    
    ax2 = subplot(2,1,2); 
    for ii=2:length(variableNames)
        plot(syncedData2.Properties.RowTimes, syncedData2.(variableNames{ii}),'DisplayName',variableNames{ii}); hold on;
    end
    legend; hold off;
    title('Synchronised Data')
    linkaxes([ax1,ax2],'x')
%% Plot Tau + Cross Correlation
    fig2=figure(4);
    fig2.Visible = 'on';
    ax1 = subplot(4,1,1);
    plot(syncedData2.Properties.RowTimes(T),movmediantau)
    hold on
    plot(tau_step3_4.Properties.RowTimes,tau_step3_4{:,1})
    title('Local Tau (Step 3) and Locale, precise Tau (Step 4)')
    legend(["Local Tau", "Local, precise Tau"])
    ylabel('Tau (shift) (samples)')
    ax2=subplot(4,1,2);
    plot(peak_xc_final.Properties.RowTimes,peak_xc_final{:,1})
    title('Peak Cross Correlation')
    ax3 = subplot(4,1,3);
    plot(tau_Step1_2.Properties.RowTimes,tau_Step1_2{:,1})
    title("Tau due to Shifting and scaling (Step 1 and Step 2) - if applied")
    ylabel('Tau (samples)')
    ax4 = subplot(4,1,4);
    plot(tau_Step1_2.Properties.RowTimes,tau_Step1_2{:,1}+tau_step3_4{:,1},'DisplayName','Final tau')
    title("Final tau - Combining Step 1/2 with Step 3/4")
    ylabel('Tau (samples)')
    linkaxes([ax1,ax2,ax3,ax4],'x')
%% Plot Tau together with the data
    fig3=figure(5);
    fig3.Visible = 'on';
    ax3 = subplot(3,1,1); 
    for i=2:length(variableNames)
        plot(currentDataset.Properties.RowTimes, currentDataset.(variableNames{i}),'DisplayName',variableNames{i}); hold on;
    end
    legend; hold off;
    ylim([-50,250]); title('Original Data')
    java.lang.System.gc()    
    ax4 = subplot(3,1,2);
    for ii=2:length(variableNames)
        plot(syncedData2.Properties.RowTimes, syncedData2.(variableNames{ii}),'DisplayName',variableNames{ii}); hold on;
    end
    legend; hold off;
    ylim([-50,250]); title('Synchronised Data')
        
    ax5 = subplot(3,1,3);
    plot(tau_step3_4.Properties.RowTimes,tau_Step1_2{:,1}+tau_step3_4{:,1})
    title('Tau (Number of samples that Signal 2 is shifted in synchronisation process')
    linkaxes([ax3,ax4,ax5],'x')
    hold off
end