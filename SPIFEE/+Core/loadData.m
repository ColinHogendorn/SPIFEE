% loadData
% ------------------------------------------------------------
% Handles file selection and validation for SPIFEE.
% 
% GUI-based file selection (uigetfile or script mode)
% Multi-file input handling
% File type validation (.mat, .csv)
% Output directory creation with timestamp.
%
% Input:
%   params - processing parameters
%
% Output:
%   params - updated params struct with output folder
%   Files - cell array of filenames
%   location - directory path of selected files

function [Files,location, params] = loadData(params, Files, location)

% Type of File input loading (uigetfile, or files lisst, or folder)
%TODO Handle case of csvs with no gui.
%TODO Select folder?

if nargin < 2 || isempty(Files)

    % gui. Allow multiselect alt click
    [Files, location] = uigetfile( ...
        {'*.mat;*.csv','MAT-files and CSV-files (*.mat, *.csv)'}, ...
        'Select One or More Files','MultiSelect','on');
    if isempty(Files) %if user didnt select any files
        error("No Files Selected")
    end
    if ~iscell(Files)
        Files = {Files};
    end
else

    % script mode in the form of a list of files, or the folder.
    if nargin < 3 || isempty(location)
        location = pwd;
    end
    if ~iscell(Files)
        Files = cellstr(Files);
    end
end

% Validate File tyoes
valid_ext = {'.xlsx','.mat','.csv'};
[~,~,ext] = cellfun(@fileparts, Files, 'UniformOutput', false);
if any(~ismember(lower(ext), valid_ext))
    error("Invalid file type detected")
end

% makefolder
timestamp = string(datetime('now','Format','yyyy-MM-dd_HH-mm-ss'));
folderName = params.Name + "_" + timestamp;

if ~exist(folderName,'dir')
    mkdir(folderName);
end

params.Folder = folderName;
disp("SPIFEE output folder: " + folderName);

end