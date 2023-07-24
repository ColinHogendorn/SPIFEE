
function results = SPIFEE_Master(folder, hours, lenPulse)

Files = dir(fullfile(folder, '*.mat'))
numFiles = length(Files)
names = strings(numFiles,1)
results = struct



% for i = 1:numFiles
%     names(i) = extractBefore(Files(i).name, '.')
% end

% 

for i = 1:numFiles
    currName =  Files(i).name
    name = extractBefore(currName, '.')
    Fullname = append('Treatment_', name)
    currDataFile = load(currName)
    currData = currDataFile.p53FlourescentValues
    currData = transpose(currData)
    currDataFilt = currData(:,~any(isnan(currData)))
    currFeats = SPIFEE(currDataFilt, hours, lenPulse)
    results.Features.(Fullname) = currFeats
    currAnalysis = SPIFEE_Single(name,currDataFilt,currFeats, hours, lenPulse)
    results.Analysis.(Fullname) = currAnalysis
end
close all
results.Means = SPIFEE_Group(results.Features)



end

