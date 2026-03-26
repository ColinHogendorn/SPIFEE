function results = SPIFEE_Master2(params)

%Load first 2 features
hours = params.Time;
lenPulse = params.Freq;

%Prompt user for Files
[Files,location] = uigetfile({'*.mat;*.csv','MAT-files and CSV-files (*.mat, *.csv)'},'Select One or More Files','MultiSelect', 'on');

%Check numFiles
if class(Files) == 'cell'
    numFiles = length(Files);
elseif Files == 0
    error("No Files Selected")
else
    numFiles = 1;
end

%Check Type of file. %TO DO Enable CSVs?
valid_ext = {'.xlsx', '.mat', '.csv'};

[~,~,ext] = fileparts(Files);

if ~ismember(lower(ext), valid_ext)
    error('Files must be in .xlsx, .mat, or .csv format.');
end


results = struct;
fullMeans = [];
names = [];
fullNames = [];
avgTraces = [];
fullFeats = [];
groupLabels = [];
FullTraces = [];
FullSetID = [];

%Analyze each file
for i = 1:numFiles
    
    %Checks if there's only 1 file
    if numFiles == 1
        currName = Files;
    else
        currName =  string(Files(i));
    end
    
    %Replace periods with underscores except for last one
    name = regexprep(currName, '\.(?=[^.]*\.)', '_'); 

    %Read File, Extract Condition names, Filter out traces with NaN values
    name = extractBefore(name, '.');
    names = [names, name]; %store list of names for later.
    names = cellstr(names);
    Fullname = append('Condition_', name);
    
    if ext == ".csv" %CSV Handling.
        currFile = readtable(currName);
        currFile = table2array(currFile);
    else
        currFile = load(char(strcat(location, currName)));

    end
    %Parse Data type, handle structures and arrays
    %Handles various forms of user input data. 
    %IF the current file is simply an array, the else part of isstruct will simply read it in
    %If it's a structure, and the field containing the traces are
    %immedietely available, it reads it in. Else if its nested within
    %another layer, it reads through that layer and then finds the field

   if isstruct(currFile)
    
        fns = fieldnames(currFile);


        %TO DO. if fieldnames has a match for Name?. Mult handle
        if length(fns) == 1 && fns{1} == name 
            Data = struct2array(currFile);
    
        % Case 1: params.Field exists at top level
        elseif isfield(currFile, params.Field)
            Data = currFile.(params.Field);

        elseif strcmp(string(fieldnames(currFile)), name) %IF not a structure. but the file is the same name
            Data = getfield(currFile, name);
    
        % Case 2: single-field struct, recurse one level
        elseif numel(fns) == 1 && isstruct(currFile.(fns{1}))
            innerStruct = currFile.(fns{1});
    
            if isfield(innerStruct, params.Field)
                Data = innerStruct.(params.Field);
            else
                error( ...
                    "File '%s' contains struct '%s' but it does not have field '%s'.", ...
                    currName, fns{1}, params.Field ...
                );
            end
    
        % Case 3: multiple fields — ambiguous
        else
             error( ...
            [ ...
            'File ''%s'' does not contain field ''%s'' at the top level, ' ...
            'and automatic resolution is ambiguous.\n\n' ...
            'Top-level fields found:\n  %s\n\n' ...
            'Ensure all files share the same structure or update params.Field.' ...
            ], ...
            currName, ...
            params.Field, ...
            strjoin(fns, ', ') ...
            );
        end
        %Data = currFile;
    end
    
    %Cell Orientation
    if params.Vert == 0
        Data = transpose(Data);
    else
    end

    fullID =  [];
    FillDataInfo = [];

    if params.Fill == 0 || params.Fill == 1 && sum(sum(isnan(Data))) == 0
        fullID = find(~any(isnan(Data)));
        currDataFilt = Data(:,~any(isnan(Data)));

        % Goes through and makes the table
        [n,~] = size(Data);
        numNA = sum(isnan(Data));
        %Tracking what traces are filled / ingnored
        Thresh = params.Thresh;
        cutoff = round(n / Thresh); %Maybe include this as part of the settings? if <10% values missing, ignore
        id = find((numNA < cutoff ) & (numNA > 0)); %Traces with imputed data
        id2 = find(numNA < 1); %Traces without NA
        id3 = find(numNA > cutoff); %Traces that aren't used
        fullID = find(numNA < cutoff); %Traces Used

        numNaNRow = sum(isnan(Data));
        numNaNCol = sum(isnan(Data), 2);
   
        RowNames = {'Traces with imputed data IDX','NumNA1','Traces without NA IDX',...
            'NumNA2', 'Traces filtered out (Threshold = 10% NaN)', 'NumNA3',...
            'TotalTracesUsed', 'TotalTracesFilteredOut', 'numNaN_PerRow', 'numNaN_PerCol'};
        
        M = table({id; numNA(id); id2; numNA(id2); id3; numNA(id3); length(fullID);...
            length(id3); numNaNRow; numNaNCol}, 'RowNames', RowNames); 
        results.(Fullname).("DataProcessing_Info") = M;

    else
        [n,~] = size(Data);
        numNA = sum(isnan(Data));

        %Tracking what traces are filled / ingnored
        Thresh = params.Thresh;
        cutoff = round(n / Thresh); %if <10% values missing, ignore
        id = find((numNA < cutoff ) & (numNA > 0)); %Traces with imputed data
        id2 = find(numNA < 1); %Traces without NA
        id3 = find(numNA > cutoff); %Traces that aren't used
        fullID = find(numNA < cutoff); %Traces Used

        numNaNRow = sum(isnan(Data));
        numNaNCol = sum(isnan(Data), 2);
            
        currDataFilt = Data(:,fullID);
        currDataFilt = fillmissing(currDataFilt, 'linear',2, 'Endvalues', 'nearest');
   
        RowNames = {'Traces with imputed data IDX','NumNA1','Traces without NA IDX',...
            'NumNA2', 'Traces filtered out (Threshold = 10% NaN)', 'NumNA3',...
            'TotalTracesUsed', 'TotalTracesFilteredOut', 'numNaN_PerRow', 'numNaN_PerCol'};
        
        M = table({id; numNA(id); id2; numNA(id2); id3; numNA(id3); length(fullID);...
            length(id3); numNaNRow; numNaNCol}, 'RowNames', RowNames);   

        results.(Fullname).("DataProcessing_Info") = M;
    end

    %Jagged Test

    %TO DO THrow warning
    [C_Col, C_Row] = Utils.computeJagged(params,currDataFilt);

    %Normalization
    if strcmp(params.Norm, 'Basal')
        [Points,NumCells] = size(currDataFilt);
        for j = 1:NumCells
          currDataFilt(:,j) = currDataFilt(:,j) / currDataFilt(1,j);
        end
    elseif strcmp(params.Norm, 'Max')
        [Points,NumCells] = size(currDataFilt);
        for j = 1:NumCells
            currDataFilt(:,j) = currDataFilt(:,j) / max(currDataFilt(:,j));
        end
    end
    
    %Main Feat
    results.(Fullname).("TracesUsedID") = fullID;
    [Details, Traces, currFeats] = SPIFEE(currDataFilt, hours, lenPulse,fullID,params);
    
    %Row/Col names for tables
    FeatureNames = ["Height", "Location", "Width", "Prominence", "Frequency", "Integral", "Peak#", "Trace#", "AvgMax","AvgMin", "Peak over Basal", "NumPeaks"];
    varNames = [];
    for j = 1:width(currFeats)
        %Creates Trace/Peak Header
        curr = "Trace" + string(currFeats(8,j)) + "Peak" + string(currFeats(7,j));curr = "Trace" + string(currFeats(8,j)) + "Peak" + string(currFeats(7,j));
        varNames = [varNames,curr];
    end
    
    %Main Raw features table
    FeatTable = array2table(currFeats,'Rownames',FeatureNames, 'VariableNames', varNames);
    
    %Create a version without the book keeping features
    FeatTable2 = FeatTable;
    FeatTable2([2,7,8,9,10,11,12], :) = [];

    %Save Features/Traces
    results.(Fullname).("Features") = FeatTable;
    results.(Fullname).("FullFiltTraces") = Traces;

    %NumResp
    numEmpty = width(Data) - length(unique(currFeats(8,:))); %(Double check length)
    results.(Fullname).("NumTracesUsedButNoPeaks") = numEmpty;

    %Get means (need for Means option anyway)
    means = mean(currFeats, 2);
    fullMeans = [fullMeans, means];

    %Main average Trace and mean table
    if params.Avg == 1
       % [means, meanFig] = SPIFEE_Single(currDataFilt,currFeats, hours, lenPulse).AvgTrace();
        means = mean(currFeats, 2);
        avgTrace = mean(currDataFilt,2);

        SingleMeanTable = array2table(means,'Rownames',FeatureNames, 'VariableNames', "Averages");
        SingleMeanTable([2,7,8,9,10,11,12], :) = [];
        results.(Fullname).("Means") = SingleMeanTable;
        fullMeans = [fullMeans, means];
        avgTraces = [avgTraces, avgTrace];
        results.(Fullname).("AvgTrace") = avgTrace;
    end

    %Main Clusters
    if params.Clusters == 1
        %Plot Optimal K Eval Graph
        if params.Eval == 1
            Utils.ClustEvalFig(params, currDataFilt,name); %double check for bugs
        end
        %Plot Clusters
        if params.Cond == 1
            [idx, ClusterMeans] = Utils.ConditionClusteringFig(params, name, currDataFilt, currFeats, FeatureNames);
            ClusterMeans([2,7,8,9,10,11,12], :) = [];
            results.(Fullname).("ClusterMeans") = ClusterMeans;
            results.(Fullname).("ClusterIndexes") = idx;
        end
    end
     
    %Heatmaps
    if params.Heats == 1
        figure;
        name2 = strrep(name, "_", '');
        
        h = heatmap(currDataFilt);
        title(name2 + " Heatmap")
        xlabel('Time Points');
        ylabel('Samples');
        %Fixed Tick way
        numX = size(currDataFilt, 2);  % number of timepoints (columns)
        numY = size(currDataFilt, 1);  % number of samples (rows)

        % Choose tick spacing
        xticks = 1:10:numX;  % show every 10th column
        yticks = 1:5:numY;   % show every 5th row
        
        % Initialize labels as blanks
        h.XDisplayLabels = repmat(" ", 1, numX);
        h.YDisplayLabels = repmat(" ", numY, 1);
        
        % Set only some visible
        h.XDisplayLabels(xticks) = cellstr(num2str((xticks)'));  % convert numbers to cell of chars
        h.YDisplayLabels(yticks) = cellstr(num2str((yticks)'));
        colormap(jet);
        colorbar;

        Utils.PlotLogic(params.Output, (name+"_Heatmap"), gcf)
    end

    %Grab Full Feature List and Name List (For Stats Suite)
    fullFeats = [fullFeats, currFeats];
    fullNames = [fullNames Fullname];
    temp = repmat(name, 1, length(currFeats)); %FIX. double check length
    groupLabels = [groupLabels,temp];

    %Add Traces to FullSet. Keep track of IDX
    FullTraces = [FullTraces, currDataFilt];
    [~,numVals] = size(currDataFilt);
    fullInts = repmat(i,1,numVals);
    FullSetID = [FullSetID fullInts];

    %To do, add 


%OVERALL FEATURES / GRAPHS

%TO DO only run at end.
if params.Avg == 1 && i == numFiles
    results.("AvgTraces") = avgTraces;
    results.("AnalysisOrder") = names;
    if i > 1 %IF more than one file, plot all of the conditions together.
    FullAverageTracesPlot(params,avgTraces, names)
    end
end

% %Stats Suite
% if params.Stats == 1 && numFiles > 1
%    %results = Utils.StatsSuite(fullFeats,names,groupLabels,results,params);
% 
%    %V2
%    tempys = Utils.StatsSuite2(fullFeats, groupLabels,params);
% elseif params.Stats == 1 && numFiles == 1
%    warning("Stats Analysis was not run. You need more than one condition" + ...
%             " for this analysis.")
% end



end % End of Parse Files LOOP

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
% titles = {'Control'; 'Treatment'};
if params.Means == 1
    MeanResults = array2table(fullMeans,'Rownames',FeatureNames, 'VariableNames', names);
    MeanResults([7,8,9,10,11,12], :) = [];
    results.("Means") = MeanResults;
    %writetable(MeanResults, 'MeanFeatures.csv');
end


if params.FirstPeak == 1
    %numExp = numel(fieldnames(results))
           
    FirstPeakMeans = [];
    numExp = length(Files); %OK for length()
    if iscell(Files)
         for i = 1:numExp
         temp = results.(char(fullNames(i))).('Features');
         cols = temp{7, :} == 1; %Extract all that were the 1st peak
         ones = temp(:, cols);
         meanz = mean(ones, 2);
         meanz = table2array(meanz);
         FirstPeakMeans = [FirstPeakMeans, meanz];
         end

    else
         temp = results.(char(fullNames)).('Features');
         cols = temp{7, :} == 1; %Extract all that were the 1st peak
         ones = temp(:, cols);
         meanz = mean(ones, 2);
         meanz = table2array(meanz);
         FirstPeakMeans = [FirstPeakMeans, meanz];
       
    end
    FirstPeakMeans = array2table(FirstPeakMeans,'Rownames',FeatureNames, 'VariableNames', names);
    FirstPeakMeans([7,8,9,10,11,12],:) = [];
    results.("FirstPeakMeans") = FirstPeakMeans;


end

%Cluster all / Boxplot for percentages of each cluster in larger group.
if params.All == 1 && numFiles > 1
    [idx, ClusterMeans,TPercents] = Utils.ClusterAllTraces(params, fullNames, FullTraces, fullFeats, FeatureNames,FullSetID);
    ClusterMeans([2,7,8,9,10,11,12], :) = [];
    results.("ClusterAllConditionsMeans") = ClusterMeans;
    results.("ClusterAllIndexes") = idx;
    

elseif params.All == 1 && numFiles == 1
    warning("Cluster all conditions together was not run. You need more than one condition" + ...
        " for this analysis.")
end
    
%Plain English Output
txt = Utils.structToPlainEnglish(params, Details,Data);
results.("ReprodTxt") = txt;



%Final Step. Save Everything
save((strcat(params.Name, "_Results.mat")), "results")

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Below are various analysis functions


%Plot all Average Traces Together
function FullAverageTracesPlot(params,avgTraces, names)
fullAvgTraceFig = figure;
ax = axes(fullAvgTraceFig);
plot(ax, avgTraces, 'LineWidth', 4);
title("Average Traces of each Condition", "Interpreter", 'none')
legend(names, 'Location', 'best', "Interpreter", 'none')
set(gca, 'FontSize', 14)
Utils.PlotLogic(params.Output, "FullCondtitionAverages",fullAvgTraceFig)
end

