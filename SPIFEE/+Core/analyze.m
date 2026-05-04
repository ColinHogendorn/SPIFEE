% analyze
% ------------------------------------------------------------
% Performs higher-level analysis across conditions.
%
% Includes:
%   - Feature aggregation across datasets
%   - Group labeling
%   - Statistical analysis (StatsSuite)
%   - Cross-condition clustering
%
% Input:
%   featureStruct - extracted feature data
%   params        - analysis parameters
%
% Output:
% analysisStruct contains:
% .fullFeats
% .fullTraces
% .names
% .groupLabels
% .stats (optional)
%  .clusterAll (optional)

function analysisStruct = analyze(featureStruct, params)
FeatureNames = ["Height","Location","Width","Prominence","Frequency","Integral","Peak#","Trace#","AvgMax","AvgMin","Peak over Basal","NumPeaks"];

%Find numFile and Feat Sizes
numFiles = length(featureStruct);
featCounts = zeros(1,numFiles);
traceCounts = zeros(1,numFiles);

for i = 1:numFiles
    featCounts(i)  = size(featureStruct(i).FeatsRaw,2);
    traceCounts(i) = size(featureStruct(i).Smoothed,2);
end
%Totals
totalFeats = sum(featCounts);
totalTraces = sum(traceCounts);

%Preallocate
numFeatRows  = size(featureStruct(1).FeatsRaw,1);
numTraceRows = size(featureStruct(1).Smoothed,1);
allFeats   = zeros(numFeatRows, totalFeats);
allTraces  = zeros(numTraceRows, totalTraces);
groupLabels = strings(1, totalFeats);
fullSetID   = zeros(1, totalFeats);
traceID   = zeros(1, totalTraces);
names       = strings(1, numFiles);

featIdx  = 1;
traceIdx = 1;

for i = 1:numFiles
    f = featureStruct(i);
    nF = size(f.FeatsRaw,2);
    nT = size(f.Smoothed,2);
   
    % Store names
    names(i) = f.name;
    
    % Fill features
    allFeats(:, featIdx:featIdx+nF-1) = f.FeatsRaw;
    groupLabels(featIdx:featIdx+nF-1) = f.name; %FeatLabels
    fullSetID(featIdx:featIdx+nF-1)   = i; %Feat Ids
    traceID(traceIdx:traceIdx+nT-1) = i; %Trace Ids

    
    % Fill traces
    allTraces(:, traceIdx:traceIdx+nT-1) = f.Smoothed;
    featIdx  = featIdx  + nF;
    traceIdx = traceIdx + nT;
end

analysisStruct.featureStruct = featureStruct;
analysisStruct.fullFeats = allFeats;
analysisStruct.fullTraces = allTraces;
analysisStruct.names = names;
analysisStruct.groupLabels = groupLabels; %peak number labels
analysisStruct.traceID = traceID;
analysisStruct.meta.files = {featureStruct.name};
analysisStruct.meta.details = featureStruct;

% Stats
if params.Stats && numFiles > 1
    analysisStruct.stats = Utils.StatsSuitev2(allFeats, groupLabels, params);
end

% Clustering All 
if params.All && numFiles > 1
    %[perc, idx, means] = Utils.ClusterAllTraces( ...
        %params, {featureStruct.Fullname}, allTraces, allFeats, FeatureNames, fullSetID);
    [perc, idx, means] = Utils.ClusterAllTraces( ...
    params, {featureStruct.Fullname}, allTraces, allFeats, FeatureNames, traceID);

    analysisStruct.clusterAll.perc = perc;
    analysisStruct.clusterAll.idx = idx;
    analysisStruct.clusterAll.means = means;
end

end