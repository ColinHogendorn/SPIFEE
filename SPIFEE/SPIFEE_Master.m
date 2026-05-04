
%  SPIFEE_Master
% ------------------------------------------------------------
% Main orchestration function for the SPIFEE analysis pipeline.
%
% This function coordinates the full workflow:
%   1. Data loading (filePrompt or programmatic)
%   2. Preprocessing and filtering
%   3. Feature extraction
%   4. Downstream statistical and clustering analysis
%   5. Visualization and result export

function results = SPIFEE_Master(params)

% Pipeline
[Files,location, params] = Core.loadData(params) ;
dataStruct      = Core.processData(Files, location, params);
featureStruct   = Core.extractFeatures(dataStruct, params);
analysisStruct  = Core.analyze(featureStruct, params);
results         = Core.plot_SaveRez(analysisStruct, params);

end