%%Intital Pass
% load Control_Traces.mat
% Data = p53FlourescentValues
% Data = transpose(Data)
% FiltData = Data(:,~any(isnan(Data)))
% DataFeat = SPIFEE(FiltData, 48, 5.5)
% 
% load matlab.mat
% Data = p53FlourescentValues
% Data = transpose(Data)
% Treat1Filt = Data(:,~any(isnan(Data)))
% Treat1Feat = SPIFEE(Treat1Filt,48,5.5)
% 
% close all
% [mean,idx,ClusterMeans, fig,fig2,fig3,fig4] = SPIFEE_Single('Control',FiltData,DataFeat,48,5.5)
% [mean2, id2, ClusterMeans2, fig6, fig7, fig8, fig9] = SPIFEE_Single('Treat1',Treat1Filt, Treat1Feat, 48, 5.5)
% 
% Features = ["Height", "Location", "Width", "Prominence", "Frequency", "Duration", "Integral", "Peak", "Cell", "AvgMax",...
%     "AvgMin", "Peak over Basal"];
% Features = transpose(Features)
% 
% titles = {'Control', 'Treat1'};
% MeanResults = array2table([mean,mean2],'Rownames',Features, 'VariableNames', titles)
% writetable(MeanResults, 'ControlMeanFeatures.csv')
% 
% 
% save("Means", "MeanResults")

%% Trial 2
% close all
% load Control2Traces.mat
% Data = p53FlourescentValues
% Data = transpose(Data)
% FiltData = Data(:,~any(isnan(Data)))
% DataFeat = SPIFEE(FiltData, 48, 5.5)
% 
% load 500umTraces.mat
% Data2 = p53FlourescentValues 
% Data2 = transpose(Data2)
% Treat1Filt = Data2(:,~any(isnan(Data2)))
% Treat1Feat = SPIFEE(Treat1Filt,48,5.5)
% 
% close all
% [mean,idx,ClusterMeans, fig,fig2,fig3,fig4] = SPIFEE_Single('Control2OUT',FiltData,DataFeat,48,5.5)
% [mean2, id2, ClusterMeans2, fig6, fig7, fig8, fig9] = SPIFEE_Single('500umOUT',Treat1Filt, Treat1Feat, 48, 5.5)
% 
% Features = ["Height", "Location", "Width", "Prominence", "Frequency", "Duration", "Integral", "Peak", "Cell", "AvgMax",...
%     "AvgMin", "Peak over Basal"];
% Features = transpose(Features)
% 
% titles = {'Control', 'Treat1'};
% MeanResults = array2table([mean,mean2],'Rownames',Features, 'VariableNames', titles)
% writetable(MeanResults, 'ControlMeanFeatures.csv')
% 
% 
% save("Means", "MeanResults")

%%Updated Control

close all
load control_Updated.mat
Data = p53FlourescentValues
Data = transpose(Data)
FiltData = Data(:,~any(isnan(Data)))
DataFeat = SPIFEE(FiltData, 48, 5.5)

% load 500umTraces.mat
% Data2 = p53FlourescentValues 
% Data2 = transpose(Data2)
% Treat1Filt = Data2(:,~any(isnan(Data2)))
% Treat1Feat = SPIFEE(Treat1Filt,48,5.5)


[mean,idx,ClusterMeans, fig,fig2,fig3,fig4] = SPIFEE_Single('Control2OUT',FiltData,DataFeat,48,5.5)


Features = ["Height", "Location", "Width", "Prominence", "Frequency", "Duration", "Integral", "Peak", "Cell", "AvgMax",...
    "AvgMin", "Peak over Basal"];
Features = transpose(Features)

titles = {'ControlUpdated'};
MeanResults = array2table([mean],'Rownames',Features, 'VariableNames', titles)
writetable(MeanResults, 'ControlUpdatedMeanFeatures.csv')

% 