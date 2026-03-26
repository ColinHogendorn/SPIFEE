

function SPIFEE_GUI3()
%Set up Window
fig = uifigure('Position',[100 100 1000 800]);
fig.Name = "Signal Processing & Integrated FEature Extraction (SPIFEE) Pipeline";
grid = uigridlayout(fig,[13 3]); %Size of grid


%% Color Panels Layout
%Color Panel Filtering
p1 = uipanel(grid);
p1.Layout.Row = [1 5];  
p1.Layout.Column = [1 3];  
p1.BorderType = 'none';
p1.BackgroundColor = "#B8D1FF"; %Light Blue

%Color Panel Analysis
p2 = uipanel(grid);
p2.Layout.Row = [6 8];  
p2.Layout.Column = [1 3];  
p2.BackgroundColor= '#FFE6B8'; %Compliment Orange
p2.BorderType = 'none';

%Color Panel Output
p3 = uipanel(grid);
p3.Layout.Row = [9 13];  
p3.Layout.Column = [1 3];  
p3.BackgroundColor = '#D9D9D9';
p3.BorderType = 'none';

%Default Values
%Input [Required]
params.Field = 'p53FlourescentValues';
params.Freq = 5.5;
params.Time = 24;
params.Vert = 0;
params.Norm = "";
params.Fill = 0;
params.Filt = "Default";
params.PeakParams = "Default";
params.Thresh = 10;

%Anlaysis [Optional]
params.Clusters = 0;
params.Avg = 0;
params.Means = 0;
params.Name = 'Trial';
params.FirstPeak = 0;
params.Heats = 0;
params.Stats = 0;

%Clustering Window
params.Eval = 0;
params.Score = 'CalinskiHarabasz';
params.All = 0;
params.ManClust = 0;
params.ManClustAll = 0;

%Output [Optional]
params.Output = 1;
params.Cond = 0;


%Create shared apps structure
setappdata(0, 'sharedParams',params)
%guidata(fig,params);


%% Filtering Parameters Label
lbl_Input = uilabel(grid, "Text", "Input [Required]");
lbl_Input.Layout.Row = 1;
lbl_Input.Layout.Column = [1 3];
lbl_Input.HorizontalAlignment = 'center';
lbl_Input.FontSize = 20;
lbl_Input.FontAngle = 'Italic';
lbl_Input.FontWeight = 'bold';

%Edit Field
lbl_Field = uilabel(grid, "Text", "NameField");
lbl_Field.Layout.Row = 2;
lbl_Field.Layout.Column = 1;
lbl_Field.FontSize = 20;
lbl_Field.HorizontalAlignment = 'center';
ef_OutName = uieditfield(grid,"Placeholder",'Ex: p53FlourescentValues', ...
    "Tooltip", "The name of the field where traces " + ...
    "are stored in the mat file(s).","ValueChangedFcn", @(src,event) editField(src,event));
ef_OutName.Layout.Row = 3;
ef_OutName.Layout.Column = 1;
ef_OutName.FontSize = 20;


%Oscillatory Freq Label and Field
%lbl3 = uilabel(grid, "Text", "[Required] Oscillatory Frequency", 'FontWeight','bold');
lbl_Freq = uilabel(grid, "Text", "Peak Frequency (Hours)");
lbl_Freq.Layout.Row = 2;
lbl_Freq.Layout.Column = 2;
lbl_Freq.FontSize = 20;
lbl_Freq.HorizontalAlignment = 'center';

ef_Freq = uieditfield(grid,"numeric", "Limits",[0 100], ...
    "Tooltip", "The frequency that the data of interest is expressed (Default: 5.5). A rough estimate is sufficent",...
   "ValueChangedFcn", @(src,event) editFreqVal(src,event));
ef_Freq.Layout.Row = 3;
ef_Freq.Layout.Column = 2;
ef_Freq.FontSize = 20;

%Hours
%lbl4 = uilabel(grid, "Text", "[Required] Length of Experiment (Hours)", 'FontWeight','bold');
lbl_Hours = uilabel(grid, "Text", "Length of Experiment (Hours)");
lbl_Hours.Layout.Row = 2;
lbl_Hours.Layout.Column = 3;
lbl_Hours.FontSize = 20;
lbl_Hours.HorizontalAlignment = 'center';
ef_Hours = uieditfield(grid,"numeric", "Limits",[0 5000],...
    "Tooltip", "The amount of hours of your condition (Default: 24)","ValueChangedFcn", ...
    @(src,event) editTimePointVal(src,event));
ef_Hours.Layout.Row = 3;
ef_Hours.Layout.Column = 3;
ef_Hours.FontSize = 20;

%Cell Trace Orientation
cbx_Vert = uicheckbox(grid,"Text","Each trace is a Column","Tooltip","Checking this box denotes" + ...
    "that the input data file for this pipeline is formatted" + ...
    "such that each COLUMN represents the trace of interest.",...
     "ValueChangedFcn", @(src,event)  editOrientation(src,event));
cbx_Vert.Layout.Row = 4;
cbx_Vert.Layout.Column = 1;
cbx_Vert.FontSize = 20;

%Fill in NA Vals Checkbox
cbx_NaN = uicheckbox(grid,"Text","Fill in NaN Values","Tooltip", "Checking this box includes " + ...
    "filtering out of NaN values in the traces using " + ...
    "knnimpute", "ValueChangedFcn", @(src,event) checkBoxChangedNaN(src,event));
cbx_NaN.Layout.Row = 4;
cbx_NaN.Layout.Column = 3;
%cbx.HorizontalAlignment = 'center';
cbx_NaN.FontSize = 20;

%Normalization
dd_Norm = uidropdown(grid,'Placeholder',"Normalization","Tooltip", "Basal means dividing each" + ...
    "trace by its first time point, Max means dividing each trace by its max value. Leave blank for no normalization",...
    'Items', {'','Basal','Max'},"ValueChangedFcn", @(src,event) ddNormChanged(src,event));
dd_Norm.Layout.Row = 4;
dd_Norm.Layout.Column = 2;
dd_Norm.FontSize = 20;

%Filtering Method
dd_PeakParams = uidropdown(grid,'Placeholder',"FilteringMethod","Tooltip", "Filtering methods for smoothing traces",...+
    'Items', {'','Default Gaussian','Gaussian (Strict)','Gaussian (Loose)', 'Savitsky-Golay', 'Savitsky-Golay (Strict)',...
    'Savitsky-Golay (Loose)', 'None'},"ValueChangedFcn", @(src,event) ddFiltChanged(src,event));
dd_PeakParams.Layout.Row = 5;
dd_PeakParams.Layout.Column = 1;
dd_PeakParams.FontSize = 20;

%Findpeaks Strength. Rework Tooltip
dd_PeakParams = uidropdown(grid,'Placeholder',"FindPeaks() Strength","Tooltip", "3 options for findpeaks fidelity",...+
    'Items', {'','Default','Strict','Loose'},"ValueChangedFcn", @(src,event) ddPeakParamsChanged(src,event));
dd_PeakParams.Layout.Row = 5;
dd_PeakParams.Layout.Column = 2;
dd_PeakParams.FontSize = 20;

%NaN values % Threshold
ef_Thresh = uieditfield(grid,'numeric',"Limits",[0 100],'Value',10,'Placeholder',"Missing Values Threshold","Tooltip", "The percentage of a trace that can be missing and be used. " +...
    "The value corresponds to the upper limit that will be imputed. Any trace with more than ___ percent missing data will be excluded. The threshold is 10% by default", ...
       "ValueDisplayFormat", '%.1f%%' ,"ValueChangedFcn", @(src,event) efThreshChanged(src,event));
ef_Thresh.Placeholder = "Missing Data Threshold";
ef_Thresh.Layout.Row = 5;
ef_Thresh.Layout.Column = 3;
ef_Thresh.FontSize = 20;


%% Analysis box
lbl_Analysis = uilabel(grid, "Text", "Analysis [Optional]");
lbl_Analysis.Layout.Row = 6;
lbl_Analysis.Layout.Column = [1 3];
lbl_Analysis.HorizontalAlignment = 'center';
lbl_Analysis.FontSize = 20;
lbl_Analysis.FontAngle = 'Italic';
lbl_Analysis.FontWeight = 'bold';
%set(lbl5, "BackgroundColor", '#f5f4d0' )

%Clustering Checkbox
cbx_Clust = uicheckbox(grid,"Text","Clustering [Opens New Window]","Tooltip", "Checking this box includes clustering of traces by condition and " + ...
    "subsequent graphs and averaged features per cluster", "ValueChangedFcn", ...
    @(src,event) checkBoxChangedClust(src,event,src));
cbx_Clust.Layout.Row = 7;
cbx_Clust.Layout.Column = 1;
cbx_Clust.FontSize = 20;
%cbx2.HorizontalAlignment = 'center';

%Average Trace Checkbox
cbx_Avg = uicheckbox(grid,"Text","Average Traces","Tooltip", "Checking this box includes " + ...
    "graphs of the overall average trace per condition", "ValueChangedFcn", ...
    @(src,event) checkBoxChangedAvg(src,event));
cbx_Avg.Layout.Row = 7;
cbx_Avg.Layout.Column = 2;
cbx_Avg.FontSize = 20;

%Mean Traces Checkbox
cbx_Means = uicheckbox(grid,"Text","Means","Tooltip", "Checking this box includes a table of the mean " + ...
    "value of each feature per condition", "ValueChangedFcn", ...
    @(src,event) checkBoxChangedMean(src,event));
cbx_Means.Layout.Row = 7;
cbx_Means.Layout.Column = 3;
cbx_Means.FontSize = 20;

%1st Peak Results Checkbox
cbx_1st = uicheckbox(grid,"Text","1st Peaks","Tooltip", "Checking this box includes a table of the mean" + ...
    " values of just the 1st Peak for each trace per each Condition", "ValueChangedFcn", ...
    @(src,event) checkBoxChanged1st(src,event));
cbx_1st.Layout.Row = 8;
cbx_1st.Layout.Column = 1;
cbx_1st.FontSize = 20;

%Heatmaps Checkbox
cbx_Heat = uicheckbox(grid,"Text","Heatmaps","Tooltip", "Checking this box includes heatmpas of each Condition", "ValueChangedFcn", ...
    @(src,event) checkBoxChangedHeat(src,event));
cbx_Heat.Layout.Row = 8;
cbx_Heat.Layout.Column = 2;
cbx_Heat.FontSize = 20;

%Stats Checkbox
cbx_Stats = uicheckbox(grid,"Text","Statistics Suite","Tooltip", "Checking this box includes assumption tests and ANOVA of each feature", "ValueChangedFcn", ...
    @(src,event) checkBoxChangedStats(src,event));
cbx_Stats.Layout.Row = 8;
cbx_Stats.Layout.Column = 3;
cbx_Stats.FontSize = 20;



%% Output Section
lbl_Field = uilabel(grid, "Text", "Output [Optional]");
lbl_Field.Layout.Row = 9;
lbl_Field.Layout.Column = [1 3];
lbl_Field.HorizontalAlignment = 'center';
lbl_Field.FontSize = 20;
lbl_Field.FontAngle = 'Italic';
lbl_Field.FontWeight = 'bold';


%OutPut Name
lbl_Name = uilabel(grid, "Text", "Save Figures as");
lbl_Name.Layout.Row = [10 11];
lbl_Name.Layout.Column = 1;
lbl_Name.HorizontalAlignment = 'center';
lbl_Name.VerticalAlignment = 'center';
lbl_Name.FontSize = 20;

%Listbox of types of Outputs
lb_Out = uilistbox(grid, 'Items',[".svg",".fig",".png", "Do not save"], ...
    "ItemsData", [1,2,3,4],"Tooltip", "Save figures as one of or all of these options (Shift click for multiselect)", ...
    'Multiselect', 'on', "ValueChangedFcn", ...
    @(src,event) editListBox(src,event));
lb_Out.Layout.Row = [10 11];
lb_Out.Layout.Column = [2 3];
lb_Out.FontSize = 20;

%Output NameLabel
lbl_OutLabel = uilabel(grid, "Text", "Save Output As");
lbl_OutLabel.Layout.Row = 12;
lbl_OutLabel.Layout.Column = 1;
lbl_OutLabel.HorizontalAlignment = 'center';
lbl_OutLabel.VerticalAlignment = 'center';
lbl_OutLabel.FontSize = 20;

%Name of Output Experiment Box
ef_OutName = uitextarea(grid,"Placeholder","Ex: Trial1Run1", ...
    "FontSize", 20, ...
    "ValueChangedFcn", @(src,event) editName(src,event));
ef_OutName.Layout.Row = 12;
ef_OutName.Layout.Column = [2 3];

%Run Button
b = uibutton(grid,'Text','Run',"ButtonPushedFcn", ...
    @(src,event) ButtonPushed(src,event));
b.FontSize = 20;
b.FontWeight = 'bold';
b.Layout.Column = [1 3];
b.Layout.Row = 13;

exportapp(fig, 'SPIFEE.png')

%exportapp(app.UIFigure, 'SPIFEE.png', 'Resolution', 600)

end




%% Clustering. Creates a new window when selected with specific options
function checkBoxChangedClust(~, event, parentCheckbox)
if event.Value == 0
    return
end
params = getappdata(0, 'sharedParams');
params.("Clusters") = event.Value;
setappdata(0, 'sharedParams', params);

%Create new fig
fig2 = uifigure('Position',[100 100 1000 800]);
fig2.Name = "Clustering";
%Parental Control
fig2.UserData.parentCheckbox = parentCheckbox;

grid2 = uigridlayout(fig2,[4 3]);
set(grid2, 'BackgroundColor', '#FFE6B8')

%Title
lbl_CTitle = uilabel(grid2,'Text','Clustering Analysis');
lbl_CTitle.Layout.Row = 1;
lbl_CTitle.FontSize = 20;
lbl_CTitle.Layout.Column = [1 3];
lbl_CTitle.HorizontalAlignment = 'center';
lbl_CTitle.FontWeight = 'Bold';

%Criteria Dropdown
d1_Crit = uidropdown(grid2,'Placeholder',"ClusterScore","Tooltip", "Various clustering criteria, default is Calinksi-Harabasz",...
    'Items', {'','CalinskiHarabasz','DaviesBouldin','Gap','Silhouette'},"ValueChangedFcn", ...
    @(src,event) dChanged(src,event));
d1_Crit.Layout.Row = 2;
d1_Crit.Layout.Column = 1;
d1_Crit.FontSize = 15;

%Criteria Evalutation Graph
cb_CritEval = uicheckbox(grid2,"Text","Clustering Scores Evaluation Graph","Tooltip", "Checking this box includes a "+ ...
    "graph of each clustering score finding the optimal K value", "ValueChangedFcn", ...
    @(src,event) cBoxChanged1(src,event));
cb_CritEval.Layout.Row = 2;
cb_CritEval.Layout.Column = 2;
cb_CritEval.FontSize = 15;

%Manual Cluster
ef4_Man = uieditfield(grid2,"Placeholder",'Manual Cluster Value (ex: 1-6)', ...
    "Tooltip", "Manual imputation of the number of clusters to use. LEAVE BLANK to have number of clusters " + ...
    "automatically evaluated","ValueChangedFcn", @(src,event) editField2(src,event));
ef4_Man.Layout.Row = 2;
ef4_Man.Layout.Column = 3;

%Cluster traces
cb_Cond = uicheckbox(grid2,"Text","Cluster each Condition","Tooltip", "Checking this box includes a "+ ...
    "graph of each cluster for each Condition", "ValueChangedFcn", ...
    @(src,event) cBoxChanged2(src,event));
cb_Cond.Layout.Row = 3;
cb_Cond.Layout.Column = 1;
cb_Cond.FontSize = 15;

%ClusterALL
cb_All = uicheckbox(grid2,"Text","Cluster All Conditions Together","Tooltip", "Checking this box includes a "+ ...
    "Cluster evaluations of every condition pooled together into one big set", "ValueChangedFcn", ...
    @(src,event) cBoxChangedAll(src,event));
cb_All.Layout.Row = 3;
cb_All.Layout.Column = 2;
cb_All.FontSize = 15;

%Manual Cluster All
ef4_Man = uieditfield(grid2,"Placeholder",'All Data Manual Cluster Value (ex: 1-6)', ...
    "Tooltip", "Manual imputation of the number of clusters to use for the Cluster All conditions together option. LEAVE BLANK to have number of clusters " + ...
    "automatically evaluated","ValueChangedFcn", @(src,event) editField3(src,event));
ef4_Man.Layout.Row = 3;
ef4_Man.Layout.Column = 3;

%Button Update
btn_Update = uibutton(grid2, ...
    'Text','UPDATE', ...
    'FontSize',16, ...
    'ButtonPushedFcn', @(btn,event) clusteringUpdate(fig2));

btn_Update.Layout.Row = 4;
btn_Update.Layout.Column = [1 3];

%TO DO: Reimplement for transient / given time course.
%Numeric Value for Cluster End Points
% lb2 = uilabel(grid2, "Text", "Cluster with End Points");
% lb2.Layout.Row = 3;
% lb2.Layout.Column = 3;
% lb2.FontSize = 15;
% lb2.HorizontalAlignment = 'center';
% ef3 = uieditfield(grid2,"numeric", "Limits",[0, 1000],...
%     "Tooltip", "Cluster with only the last ___ number of points instead of full traces","ValueChangedFcn", ...
%     @(src,event) clustField1(src,event));
% ef3.Layout.Row = 3;
% ef3.Layout.Column = 2;

end

%% Clustering Boxes
%Score
function dChanged(~, event)
params = getappdata(0, 'sharedParams');
params.("Score") = event.Value;
setappdata(0, 'sharedParams', params);
end

%Eval Graph
function cBoxChanged1(~, event)
params = getappdata(0, 'sharedParams');
params.("Eval") = event.Value;
setappdata(0, 'sharedParams', params);
end

%Cluster Conditions
function cBoxChanged2(~, event)
params = getappdata(0, 'sharedParams');
params.("Cond") = event.Value;
setappdata(0, 'sharedParams', params);
end

%Manual Cluster Value
function editField2(~, event)
params = getappdata(0, 'sharedParams');
params.("ManClust") = event.Value;
setappdata(0, 'sharedParams', params);
end


%Manual Cluster All Value
function editField3(~, event)
params = getappdata(0, 'sharedParams');
params.("ManClustAll") = event.Value;
setappdata(0, 'sharedParams', params);
end


% %Cluster All traces
function cBoxChangedAll(~, event)
params = getappdata(0, 'sharedParams');
params.("All") = event.Value;
setappdata(0, 'sharedParams', params);
end

function clusteringUpdate(fig2)

    % Get parent checkbox
    parentCheckbox = fig2.UserData.parentCheckbox;

    % Optional: ensure clustering is "confirmed"
    params = getappdata(0, 'sharedParams');
    params.Clusters = 1;
    setappdata(0, 'sharedParams', params);

    % 🔥 Uncheck the checkbox in main GUI
    parentCheckbox.Value = false;

    % Close clustering window
    delete(fig2);
end

% %Prev Point Clusts
% function clustField1(src, event)
% params = getappdata(0, 'sharedParams');
% params.("Prev") = event.Value;
% setappdata(0, 'sharedParams', params);
% end


% %% Open Statistics Window
% %Create new fig
% function ActivateStats(src, event)
% params = getappdata(0, 'sharedParams');
% params.("Stats") = event.Value;
% setappdata(0, 'sharedParams', params);
% 
% fig3 = uifigure;
% fig3.Name = "Statistics";
% grid3 = uigridlayout(fig3,[4 3]);
% set(grid3, 'BackgroundColor', '#f5f4d0')
% %guidata(fig2,params);
% %handles = guidata(src)
% 
% %Title
% Stitle = uilabel(grid3,'Text','Statistical Analysis Suite');
% Stitle.Layout.Row = 1;
% Stitle.FontSize = 20;
% Stitle.Layout.Column = [1 3];
% Stitle.HorizontalAlignment = 'center';
% Stitle.FontWeight = 'Bold';
% 
% 
% end


%%
%Function calls (where changed inputs are recorded and added to params)
%Structure data name
function editField(~, event)
params = getappdata(0, 'sharedParams');
params.("Field") = event.Value;
setappdata(0, 'sharedParams', params);
end

%Frequency
function editFreqVal(~, event)
params = getappdata(0, 'sharedParams');
params.("Freq") = event.Value;
setappdata(0, 'sharedParams', params);
end

%Hours
function editTimePointVal(~, event)
params = getappdata(0, 'sharedParams');
params.("Time") = event.Value;
setappdata(0, 'sharedParams', params);
end

%Cell Orientation
function editOrientation(~, event)
params = getappdata(0, 'sharedParams');
params.("Vert") = event.Value;
setappdata(0, 'sharedParams', params);
end

%Fill in NA Values
function checkBoxChangedNaN(~, event)
params = getappdata(0, 'sharedParams');
params.("Fill") = event.Value;
setappdata(0, 'sharedParams', params);
end

%Normalization
function ddNormChanged(~, event)
params = getappdata(0, 'sharedParams');
params.("Norm") = event.Value;
setappdata(0, 'sharedParams', params);
end

%FiltStrength
function ddFiltChanged(~, event)
params = getappdata(0, 'sharedParams');
params.("Filt") = event.Value;
setappdata(0, 'sharedParams', params);
end

%FiltStrength
function ddPeakParamsChanged(~, event)
params = getappdata(0, 'sharedParams');
params.("PeakParams") = event.Value;
setappdata(0, 'sharedParams', params);
end

%Thresh
function efThreshChanged(~, event)
params = getappdata(0, 'sharedParams');
params.("Thresh") = event.Value;
setappdata(0, 'sharedParams', params);
end


%Averages
function checkBoxChangedAvg(~, event)
params = getappdata(0, 'sharedParams');
params.("Avg") = event.Value;
setappdata(0, 'sharedParams', params);
end

%Means
function checkBoxChangedMean(~, event)
params = getappdata(0, 'sharedParams');
params.("Means") = event.Value;
setappdata(0, 'sharedParams', params);
end

%First Peaks
function checkBoxChanged1st(~, event)
params = getappdata(0, 'sharedParams');
params.("FirstPeak") = event.Value;
setappdata(0, 'sharedParams', params);
end

%Heatmaps
function checkBoxChangedHeat(~, event)
params = getappdata(0, 'sharedParams');
params.("Heats") = event.Value;
setappdata(0, 'sharedParams', params);
end

%Statistics
function checkBoxChangedStats(~, event)
params = getappdata(0, 'sharedParams');
params.("Stats") = event.Value;
setappdata(0, 'sharedParams', params);
end

%EditListBox
function editListBox(~, event)
params = getappdata(0, 'sharedParams');
params.("Output") = event.Value;
setappdata(0, 'sharedParams', params);
end

%Name of Output
function editName(~, event)
params = getappdata(0, 'sharedParams');
params.("Name") = event.Value;
setappdata(0, 'sharedParams', params);
end

function ButtonPushed(~, ~)

params = getappdata(0, "sharedParams");
SPIFEE_Master2(params)
end

