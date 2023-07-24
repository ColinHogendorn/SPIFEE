%Read Control Data
load cumulativeMCF10AControlCellTraces_26JUN2023_1331.mat

%Assign the data to "ControlData" for conviencence sake
ControlData = p53FlourescentValuesCopy
%Transpose because SPIFEE needs cells in columns and timepoints as rows
ControlData = transpose(ControlData)

%Beacuase this data contains Nan values that SPIFEE can't currently
%handle,.. get only traces that dont have nan values
FiltControlData = ControlData(:,~any(isnan(ControlData)))

ControlDataFeat = SPIFEE(FiltControlData, 240, 30);

% Read Experimental Data
load cumulativeMCF10ATreatedCellTraces_26JUN2023_1331.mat

Treat1Data = p53FlourescentValues
Treat1Data = transpose(Treat1Data)
FiltTreat1Data = Treat1Data(:,~any(isnan(Treat1Data)))

FiltTreat1Feat = SPIFEE(FiltTreat1Data, 240, 30);

[mean1,idx,clustMeans, fig1,fig2, fig3, fig4, fig5] = SPIFEE_Single(FiltControlData, ControlDataFeat, 240,30);
[mean2,idx2,clustMeans2, fig6,fig7, fig8, fig9, fig10] = SPIFEE_Single(FiltTreat1Data, FiltTreat1Feat, 240,30);

% Means Table
means = [mean1,mean2]
Features = ["Height", "Location", "Width", "Prominence", "Frequency", "Duration", "Integral", "Peak", "Cell", "AvgMax",...
    "AvgMin", "Peak over Basal"]
Features = transpose(Features)

titles = {'Control'; 'Treatment'};
MeanResults = array2table(means,'Rownames',Features, 'VariableNames', titles)
writetable(MeanResults, '36_MeanFeatures.csv')

