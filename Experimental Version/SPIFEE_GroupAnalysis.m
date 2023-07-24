function SPIFEE_GroupAnalysis(data, varargin)


%TO DO: Mean Table, 
NumConditions = length(varagin)


for i = 1:NumConditions
    treat


end
ControlMeans = mean(ControlDataFeat, 2)
Treat1Means = mean(FiltTreat1Feat, 2)

% Means Table
means = [ControlMeans,Treat1Means]
Features = ["Height", "Location", "Width", "Prominence", "Frequency", "Duration", "Integral", "Peak", "Cell", "AvgMax",...
    "AvgMin", "Peak over Basal"]
Features = transpose(Features)

titles = {'Control'; 'Treatment'};
MeanResults = array2table(means,'Rownames',Features, 'VariableNames', titles)
writetable(MeanResults, '11_MeanFeatures.csv')
roup Clusters with eval, 