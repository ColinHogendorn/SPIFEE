function results = SPIFEE_Master(params)

% Load first 2 features
hours = params.Time;
lenPulse = params.Freq;

%% LOAD FILES  
% Prompt user for Files
[Files,location] = uigetfile({'*.mat;*.csv','MAT-files and CSV-files (*.mat, *.csv)'}, ...
    'Select One or More Files','MultiSelect', 'on');

% Create a timestamped FolderPath
timestamp = string(datetime('now', 'Format', 'yyyy-MM-dd_HH-mm-ss'));
folderName = append(cellstr(params.Name), ("_"+timestamp));
if ~exist(folderName, 'dir')
    mkdir(folderName);
end
disp(['Folder created: ' folderName]);
params.Folder = folderName;

% Check numFiles
if isempty(Files)
    error("No Files Selected")
elseif iscell(Files)
    numFiles = numel(Files);
else
    numFiles = 1;
    Files = {Files}; % wrap single file as cell for consistency
end

% Check Type of file
valid_ext = {'.xlsx', '.mat', '.csv'};
[~,~,ext] = cellfun(@fileparts, Files, 'UniformOutput', false);
ext = lower(ext);
if any(~ismember(ext, valid_ext))
    error('Files must be in .xlsx, .mat, or .csv format.');
end

% Initialize results
results = struct;

% Cell-array for later sticking everything together
allFeats = cell(1, numFiles);
allFiltTraces = cell(1, numFiles);
allSmoothTraces = cell(1, numFiles);
allNamesCell = cell(1, numFiles);
allGroupLabels = cell(1, numFiles);
allIDs = cell(1, numFiles);
fullMeansCell = cell(1, numFiles);
avgTracesCell = cell(1, numFiles);

% String array for condition names
names = strings(1, numFiles);

%% Process Files loop
hWait = waitbar(0,'Starting SPIFEE analysis...');

for i = 1:numFiles
    fprintf("Processing file %d of %d\r", i, numFiles);
    waitbar((i-1)/numFiles, hWait, sprintf('Filtering data for %s...', Files{i})); %Progress Bar

    currName = Files{i};
    currBase = regexprep(currName, '\.(?=[^.]*\.)', '_'); 
    name = extractBefore(currBase, '.');
    names(i) = name;
    Fullname = append('Condition_', name);

    % Load file
    if strcmp(ext{i}, ".csv")
        currFile = readtable(currName);
        currFile = table2array(currFile);
    else
        currFile = load(fullfile(location, currName));
    end

    % Parse data
    if isstruct(currFile)
        fns = fieldnames(currFile);
        if length(fns) == 1
            Data = struct2array(currFile);
        elseif isfield(currFile, params.Field)
            Data = currFile.(params.Field);
        elseif numel(fns) == 1 && isstruct(currFile.(fns{1}))
            innerStruct = currFile.(fns{1});
            if isfield(innerStruct, params.Field)
                Data = innerStruct.(params.Field);
            else
                error("File '%s' struct '%s' has no field '%s'", currName, fns{1}, params.Field);
            end
        else
            error("File '%s' ambiguous top-level fields: %s", currName, strjoin(fns, ', '));
        end
    else
        Data = currFile;
    end

    % Handle orientation
    if params.Vert == 0
        Data = Data';
    end

    % Handle NaNs
    n = size(Data,1);
    numNaNRow = sum(isnan(Data),2);
    numNaNCol = sum(isnan(Data),1);
    cutoff = round(n * params.Thresh / 100);
    id = find((numNaNCol < cutoff) & (numNaNCol > 0));
    id2 = find(numNaNCol < 1);
    id3 = find(numNaNCol > cutoff);
    fullID = find(numNaNCol < cutoff);

    if params.Fill == 1 && sum(sum(isnan(Data))) > 0
        currDataFilt = Data(:,fullID);
        currDataFilt = fillmissing(currDataFilt, 'linear', 2, 'EndValues','nearest');
    else
        currDataFilt = Data(:,~any(isnan(Data)));
    end

    % Check if data survived filtering
    if isempty(currDataFilt) %Check if any data made it through
        error("Data appears to be missing / wrongly formatted OR" +...
            "No data was below the missing threshold")
    elseif any(numNaNCol > 1) %If there are NaN values in the data just in general. add the QC figs.
        Utils.MissingEval(name, params,Data);    
    else
    end


    % Jagged metrics
    [C_Col, C_Row] = Utils.computeJagged(params, currDataFilt);

    % Build processing table
    RowNames = {'Traces with imputed data IDX','NumNA1','Traces without NA IDX',...
        'NumNA2', 'Traces filtered out (Threshold = 10% NaN)', 'NumNA3',...
        'TotalTracesUsed', 'TotalTracesFilteredOut', 'numNaN_PerRow', 'numNaN_PerCol',...
        'JaggedMetricColumns', 'JaggedMetricRows'};
    M = table({id; numNaNCol(id); id2; numNaNCol(id2); id3; numNaNCol(id3); length(fullID); ...
        length(id3); numNaNRow; numNaNCol; {C_Col}; {C_Row}}, 'RowNames', RowNames);
    results.(Fullname).("DataProcessing_Info") = M;

    % Normalization
    if strcmp(params.Norm,'Basal')
        currDataFilt = currDataFilt ./ currDataFilt(1,:);
    elseif strcmp(params.Norm,'Max')
        currDataFilt = currDataFilt ./ max(currDataFilt,[],1);
    end

    % Feature extraction
    waitbar((i-0.6)/numFiles, hWait, sprintf('Extracting features for %s...', Files{i}));

    [Details,SmoothedTraces,currFeats] = SPIFEE(currDataFilt, hours, lenPulse, fullID, params);
    FeatureNames = ["Height","Location","Width","Prominence","Frequency","Integral","Peak#","Trace#","AvgMax","AvgMin","Peak over Basal","NumPeaks"];
    numPeaks = width(currFeats);
    varNames = strings(numPeaks,1);
    for j=1:numPeaks
        varNames(j) = "Trace"+string(currFeats(8,j))+"Peak"+string(currFeats(7,j));
    end
    FeatTable = array2table(currFeats,'RowNames',FeatureNames,'VariableNames',varNames);
    results.(Fullname).("Features") = FeatTable;
    results.(Fullname).("FullFiltTraces") = currDataFilt;
    results.(Fullname).("SmoothedTraces") = SmoothedTraces;
    results.(Fullname).("TracesUsedID") = fullID;

    % Avg trace and means
    if params.Avg == 1
        fullMeansCell{i} = mean(currFeats,2);
        avgTracesCell{i} = mean(SmoothedTraces,2);

        SingleMeanTable = array2table(fullMeansCell{i},'RowNames',FeatureNames,'VariableNames',"Averages");
        SingleMeanTable([2,7:12],:) = [];
        results.(Fullname).("Means") = SingleMeanTable;
        results.(Fullname).("AvgTrace") = avgTracesCell{i};
    end

    % Collect for merging at end
    allFeats{i} = currFeats;
    allFiltTraces{i} = currDataFilt;
    allSmoothTraces{i} = SmoothedTraces;
    allNamesCell{i} = Fullname;
    allGroupLabels{i} = repmat(name,1,size(currFeats,2));
    allIDs{i} = repmat(i,(size(currDataFilt,2)),1);
    waitbar(i/numFiles, hWait, sprintf('Completed %s', Files{i}));
end

%% Merge Data / Analysis
fullFeats = horzcat(allFeats{:});
%FullFiltTraces = horzcat(allFiltTraces{:});
FullSmoothTraces = horzcat(allSmoothTraces{:});
fullNames = [allNamesCell{:}];
groupLabels = [allGroupLabels{:}];
FullSetID = vertcat(allIDs{:});

if params.Avg == 1
    fullMeans = horzcat(fullMeansCell{:});
    avgTraces = horzcat(avgTracesCell{:});
    results.("AvgTraces") = avgTraces;
end
results.("AnalysisOrder") = cellstr(names);

%Main Clusters
if params.Clusters == 1
    %Plot Optimal K Eval Graph
    if params.Eval == 1
        Utils.ClustEvalFig(params, currDataFilt,name); %double check for bugs
    end
    %Plot Clusters per Cond
    if params.Cond == 1
        [percentages, idx, ClusterMeans] = Utils.ConditionClusteringFig(params, name, currDataFilt, currFeats, FeatureNames);
        ClusterMeans([2,7,8,9,10,11,12], :) = [];
        results.(Fullname).("ClusterMeans") = ClusterMeans;
        results.(Fullname).("ClusterIndexes") = idx;
        results.(Fullname).("ClusterPercents") = percentages;
    end
end
     
%Heatmaps
if params.Heats == 1
   Utils.TraceHeatmap(currDataFilt,name,params)
end



%OVERALL FEATURES / GRAPHS
names = cellstr(names);
%TO DO only run at end.
if params.Avg == 1 && i == numFiles
    results.("AvgTraces") = avgTraces;
    results.("AnalysisOrder") = names;
    if i > 1 %IF more than one file, plot all of the conditions together.
    FullAverageTracesPlot(params,avgTraces, names)
    end
end


%Stats Suite
if params.Stats == 1 && numFiles > 1
   %results = Utils.StatsSuite(fullFeats,names,groupLabels,results,params);

   %V2
   StatRez = Utils.StatsSuitev2(fullFeats, groupLabels, params);
   results.Stats = StatRez;
elseif params.Stats == 1 && numFiles == 1
   warning("Stats Analysis was not run. You need more than one condition" + ...
            " for this analysis.")
end

%Means Table
if params.Means == 1
    MeanResults = array2table(fullMeans,'Rownames',FeatureNames, 'VariableNames', names);
    MeanResults([7,8,9,10,11,12], :) = [];
    results.("Means") = MeanResults;
    %writetable(MeanResults, 'MeanFeatures.csv');
end


%FirstPeaks
if params.FirstPeak == 1
    %numExp = numel(fieldnames(results))
    numExp = length(Files); %OK for length()
    FirstPeakMeans = zeros(12, numExp);
     for i = 1:numExp
         if numExp == 1
            temp = results.(fullNames).('Features');
         else
            temp = results.(char(allNamesCell(i))).('Features'); 
         end
         cols = temp{7, :} == 1; %Extract all that were the 1st peak
         ones = temp(:, cols);
         meanz = mean(ones, 2);
         meanz = table2array(meanz);
         FirstPeakMeans(:,i) = meanz;
     end
    FirstPeakMeans = array2table(FirstPeakMeans,'Rownames',FeatureNames, 'VariableNames', names);
    FirstPeakMeans([7,8,9,10,11,12],:) = [];
    results.("FirstPeakMeans") = FirstPeakMeans;
end

%Cluster all / Boxplot for percentages of each cluster in larger group.
if params.All == 1 && numFiles > 1
    [TPercents, idx, ClusterMeans] = Utils.ClusterAllTraces(params, allNamesCell, FullSmoothTraces, fullFeats, FeatureNames,FullSetID);
    ClusterMeans([2,7,8,9,10,11,12], :) = [];
    results.("ClusterAllConditionsMeans") = ClusterMeans;
    results.("ClusterAllIndexes") = idx;
    results.("ClusterPercentages") = TPercents;
    
elseif params.All == 1 && numFiles == 1
    warning("Cluster all conditions together was not run. You need more than one condition for this analysis.")
end
 
%% End of Pipeline
%Plain English Output
txt = Utils.structToPlainEnglish(params,Files, Details,Data);
results.("ReprodTxt") = txt;

%Final Step. Save Everything
save(fullfile(params.Folder,(strcat(params.Name, "_Results.mat"))), "results");

close(hWait);
disp("SPIFEE Analysis has completed");
end

%Plot all Average Traces Together
function FullAverageTracesPlot(params,avgTraces, names)
fullAvgTraceFig = figure;
ax = axes(fullAvgTraceFig);
plot(ax, avgTraces, 'LineWidth', 4);
title("Average Traces of each Condition", "Interpreter", 'none')
legend(names, 'Location', 'best', "Interpreter", 'none')
set(gca, 'FontSize', 14)
Utils.PlotLogic(params, "FullCondtitionAverages",fullAvgTraceFig)

end
