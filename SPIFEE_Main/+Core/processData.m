% processData
% ------------------------------------------------------------
% Performs preprocessing and quality control on raw fluorescence data.
% 
% File loading and structure parsing
% Orientation correction
% Missing data filtering and optional interpolation
% Jaggedness metrics computation
% Normalization (Basal or Max)
%
% Input:
%   Files, location - file references
%   params - processing parameters
%
% Output:
%   dataStruct contains:
%   .data - filtered and processed traces
%   .IDs - indices of retained traces
%   .names - condition name
%   .Fullname - prefixed condition name
%   .JaggedCol - column jaggedness metric
%   .JaggedRow - row jaggedness metric

function dataStruct = processData(Files, location, params)

numFiles = numel(Files);
hWait = waitbar(0,'Processing Data...');

%Pre alloc data struct
dataStruct(numFiles) = struct( ...
    'name', [], ...
    'Fullname', [], ...
    'data', [], ...
    'IDs', [], ...
    'JaggedCol', [], ...
    'JaggedRow', [], ...
    'DataProcessing_Info', [] ...
);

for i = 1:numFiles
    currName = Files{i};
    [~,~,ext] = fileparts(currName);
    name = extractBefore(currName,'.');
    Fullname = "Condition_" + name;

   % Load files    
    filePath = resolvePath(location, currName);
    if strcmp(ext,'.csv')
        currFile = table2array(readtable(filePath));
    else
        currFile = load(filePath);
    end

    % Parse
    if isstruct(currFile)
        fns = fieldnames(currFile);

        %Need to handle case where numel(fns) == 1, but the real data is
        %1 layer deeper.

        if numel(fns)==1
            Data = struct2array(currFile);
        elseif isfield(currFile, params.Field)
            Data = currFile.(params.Field);
        elseif isstruct(currFile.(fns{1}))
            inner = currFile.(fns{1});
            Data = inner.(params.Field);
        else
            error("Ambiguous structure in %s", currName);
        end
    else
        Data = currFile;
    end

    % Orientation
    if params.Vert == 0
        Data = Data';
    end

    %NaN Handling 
    % TO DO: handle -1's?
    n = size(Data,1);
    numNaNCol = sum(isnan(Data),1);
    cutoff = round(n * params.Thresh / 100);
    id = find((numNaNCol < cutoff) & (numNaNCol > 0));
    id2 = find(numNaNCol < 1);
    id3 = find(numNaNCol > cutoff);

    fullID = find(numNaNCol < cutoff);

    if params.Fill == 1 && any(isnan(Data(:)))
        currDataFilt = fillmissing(Data(:,fullID),'linear',2,'EndValues','nearest');
        Utils.MissingEval(name, params,Data); 
    else
        currDataFilt = Data(:,~any(isnan(Data)));
    end

    % Data Check. TODO: Warning instead of erroring out potentially?
    % Just Skipping?
    if isempty(fullID) || isempty(currDataFilt) || size(currDataFilt,2) == 0
        error("processData:EmptyData", ...
            "No valid traces remain after filtering for file: %s", currName);
    end
    
    %Data Processing QC Table
    numNaNRow = sum(isnan(Data),2);
    numNaNCol = sum(isnan(Data),1);
    
    RowNames = {
        'Traces with imputed data IDX'
        'NumNA1'
        'Traces without NA IDX'
        'NumNA2'
        'Traces filtered out (Threshold)'
        'NumNA3'
        'TotalTracesUsed'
        'TotalTracesFilteredOut'
        'numNaN_PerRow'
        'numNaN_PerCol'
    };


    %Data processing table that elaborates how nan values/ what ids were
    %used etc.
    M = table({ ...
        id; ...
        numNaNCol(id); ...
        id2; ...
        numNaNCol(id2); ...
        id3; ...
        numNaNCol(id3); ...
        length(fullID); ...
        length(id3); ...
        numNaNRow; ...
        numNaNCol ...
    }, 'RowNames', RowNames);
    
    dataStruct(i).DataProcessing_Info = M;

    % Jagged test helper
    [C_Col, C_Row] = Utils.computeJagged(params, currDataFilt);

    % Normalize
    if strcmp(params.Norm,'Basal')
        currDataFilt = currDataFilt ./ currDataFilt(1,:);
    elseif strcmp(params.Norm,'Max')
        currDataFilt = currDataFilt ./ max(currDataFilt,[],1);
    end

    % Store 
    dataStruct(i).name = name;
    dataStruct(i).Fullname = Fullname;
    dataStruct(i).data = currDataFilt;
    dataStruct(i).IDs = fullID;
    dataStruct(i).JaggedCol = C_Col;
    dataStruct(i).JaggedRow = C_Row;
    dataStruct(i).IDs = fullID;
    dataStruct(i).DataProcessing_Info = M;

    waitbar(i/numFiles,hWait); %update progress bar
end
%TO DO: Optional progress bar object. close it if SPIFEE errors? 
close(hWait);

end

%Different situations with data being a folder or not. Helper
function path = resolvePath(location, file)
if nargin < 1 || isempty(location)
    path = file;
else
    path = fullfile(location, file);
end
end