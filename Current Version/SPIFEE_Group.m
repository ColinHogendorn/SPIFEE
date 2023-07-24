function results = SPIFEE_GroupAnalysis(data)
 
fields = fieldnames(data)

means = []
for i=1:length(fields)
    curr = mean(data.(char(fields(i))),2)
    means = [means, curr]

end

% Means Table

Features = ["Height", "Location", "Width", "Prominence", "Frequency", "Duration", "Integral", "Peak", "Cell", "AvgMax",...
    "AvgMin", "Peak over Basal"]
Features = transpose(Features)

titles = convertCharsToStrings(fields)
MeanResults = array2table(means,'Rownames',Features, 'VariableNames', titles)
% writetable(MeanResults, '11_MeanFeatures.csv')

results = MeanResults