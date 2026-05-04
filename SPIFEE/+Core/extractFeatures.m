% extractFeatures
% ------------------------------------------------------------
% Extracts dynamic features from processed fluorescence traces
%
% Features include:
%   Height, Width, Prominence, Frequency, Integral, etc.
%
% Input:
%   dataStruct - output from processData
%   params     - analysis parameters
%
% Output:
%   featureStruct: structured array containing:
%   .Features: feature table
%   .FeatsRaw: raw feature matrix
%   .Smoothed: smoothed traces
%   .Filtered: filtered input traces
%   .Means: (optional) feature averages
%   .AvgTrace: (optional) mean trace

function featureStruct = extractFeatures(dataStruct, params)

hours = params.Time;
lenPulse = params.Freq;

FeatureNames = ["Height","Location","Width","Prominence","Frequency", ...
    "Integral","Peak#","Trace#","AvgMax","AvgMin","Peak over Basal","NumPeaks"];

n = length(dataStruct);

featureStruct(n) = struct( ...
    'name', [], ...
    'Fullname', [], ...
    'Features', [], ...
    'FeatsRaw', [], ...
    'Smoothed', [], ...
    'Filtered', [], ...
    'Details', [], ...
    'IDs', [], ...
    'Means', [], ...
    'AvgTrace', [] ...
);

%For num Files
for i = 1:length(dataStruct)
    curr = dataStruct(i);

    [Details, Smoothed, feats] = SPIFEE_Feat(curr.data, hours, lenPulse, curr.IDs, params);

    % Build table
    %varNames = strings(1,size(feats,2));
    varNames = "Trace" + string(feats(8,:)) + "Peak" + string(feats(7,:)); 

    FeatTable = array2table(feats,'RowNames',FeatureNames,'VariableNames',varNames);

    featureStruct(i).name = curr.name;
    featureStruct(i).Fullname = curr.Fullname;
    featureStruct(i).Features = FeatTable;
    featureStruct(i).FeatsRaw = feats;
    featureStruct(i).Smoothed = Smoothed;
    featureStruct(i).Filtered = curr.data;
    featureStruct(i).Details = Details;
    featureStruct(i).IDs = curr.IDs;

    if params.Avg == 1
        featureStruct(i).Means = mean(feats,2);
        featureStruct(i).AvgTrace = mean(Smoothed,2);
    end

end

end