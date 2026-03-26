function [Details, FiltData,Features] = SPIFEE(Data, Hours, lenPulse, idx, params)

%Peak data processing and feature extraction
%Written by Colin Hogendorn 6/7/22
%This function uses findpeaks() from the
%Signal Processing Toolbox for peaks and feature extraction

%Designed originally for processing p53 oscillations, but handles
%biological peak finding tasks

%This function uses a gaussian filter with an adaptive 
% time windows based upon the length of experiment for smoothing the
%data, uses findpeaks() on the smoothed data, and then calculates and
%outputs features in a 2d array

%Data => a 2d array of fluorescent intensities with cell 1 being the first
%column and so on. 
%Hours => How long of a time the points were taken over
%Temporal => Option for how to calculate Temporal features.

%Take the data and smooth it with the gauss filter
[Points, NumCells] = size(Data);
PointPerHour = Points/Hours ;

if params.Filt == "Default Gaussian"
%Gaussian Filter window is one third of the pulse width in terms of points
    [FiltData, ~] = smoothdata(Data, "gaussian", (lenPulse * PointPerHour) / 3);

%Gaussian Filter window is one pulse width in terms of points
elseif params.Filt == "Gaussian (Strict)" 
    [FiltData, ~] = smoothdata(Data, "gaussian", (lenPulse * PointPerHour));

%Gaussian Filter window is one sixth of the pulse width in terms of points
elseif params.Filt == "Gaussian (Loose)" 
    [FiltData, ~] = smoothdata(Data, "gaussian", (lenPulse * PointPerHour / 6));

%Sgolay Filter window is one third of the pulse width in terms of points
elseif params.Filt == "Savitsky-Golay" 
    [FiltData, ~] = smoothdata(Data, "sgolay", (lenPulse * PointPerHour / 3));

%Sgolay Filter window is one pulse width in terms of points
elseif params.Filt == "Savitsky-Golay (Strict)" 
    [FiltData, ~] = smoothdata(Data, "sgolay", (lenPulse * PointPerHour));

%Gaussian Filter window is one sixth of the pulse width in terms of points
elseif params.Filt == "Savitsky-Golay (Loose)" 
    [FiltData, ~] = smoothdata(Data, "sgolay", (lenPulse * PointPerHour / 6));

else
    FiltData = Data;
end


AvgMax = mean(max(FiltData)); %This value will be used to determine findpeaks() parameters
AvgMin = mean(min(FiltData)); %Determines roughly the basal p53 amount per treatment

%Parameters for findpeaks()
if params.PeakParams == "Strict"
    minHeight = AvgMax / 5;
    minProm = AvgMax / 10;
    minDistance = PointPerHour * lenPulse / 5;
    minWidth = PointPerHour * lenPulse / 5;
    maxWidth = PointPerHour  * lenPulse *  5;

elseif params.PeakParams == "Loose"

    minHeight = AvgMax / 15;
    minProm = AvgMax / 20;
    minDistance = PointPerHour * lenPulse / 15;
    minWidth = PointPerHour * lenPulse / 15;
    maxWidth = PointPerHour  * lenPulse *  15;

else %Default
    minHeight = AvgMax / 10;
    minProm = AvgMax / 15;
    minDistance = PointPerHour * lenPulse / 10;
    minWidth = PointPerHour * lenPulse / 10;
    maxWidth = PointPerHour  * lenPulse *  10;
    
end

%Put in terms of hours for downstream intuition for graphs and such
minDist2  = minDistance / PointPerHour;
minWidth2 = minWidth / PointPerHour;
maxWidth2 = maxWidth / PointPerHour;

DeteNames = ["Average Max Value of Traces"; "Avg Minimum Value of Traces"; "Minimum Peak Height"; "Minimum Peak Prominance";...+
    "Minimum Distance between Peaks (Hours)"; "Minimum Width of a Peak (Hours)"; "Maximum Width of a Peak (Hours)"; "Points Per Hour"];

allParams = [AvgMax; AvgMin; minHeight; minProm; minDist2; minWidth2; maxWidth2; PointPerHour];
Details = table(DeteNames, allParams, 'VariableNames', {'Parameter', 'Value'});
j = 1;

Features = [];

for i = 1:NumCells
    %Get Trace
    CurrSignal = FiltData(:,i);

    %First 4 features
    [pks,locs,w,p] = findpeaks(CurrSignal,"MinPeakHeight", minHeight, "MinPeakProminence", minProm, "MinPeakDistance", minDistance, "MinPeakWidth",minWidth, "MaxPeakWidth", maxWidth);
    if isempty(pks) %If no peaks found, move on.
        continue
    end
    numPeaks = length(pks);

    %Calculate Freq
    if length(pks) > 1
        Freq = numPeaks / (max(locs) - min(locs));
    else
        Freq = 0;
    end
 
   %Visualize
   % findpeaks(CurrSignal,"MinPeakHeight", minHeight, "MinPeakProminence", minProm, "MinPeakDistance", minDistance, "MinPeakWidth",minWidth, "MaxPeakWidth", maxWidth, 'Annotate', 'extents');
   
   %Calculate TemporalFeatures
       tramps = [];
       drops = [];
       AUC = [];
       for z = 1:numPeaks 
           %Best way of doing rises and drops that I have found
            tramps(z) = locs(z) - w(z)/2;
            drops(z)  = locs(z) + w(z)/2;
            timePoints = 1:Points;
            myInt = cumtrapz(timePoints,CurrSignal);
            myIntv = @(a,b) max(myInt(timePoints<=b)) - min(myInt(timePoints>=a));
            AUC(z) = myIntv(tramps(z), drops(z));
       end
 
    
   %Put into the list of features
        for k=1:numPeaks
            Features(1,j) = pks(k);
            Features(2,j) = locs(k);
            Features(3,j) = w(k) / PointPerHour;
            Features(4,j) = p(k);
            Features(5,j) = Freq * PointPerHour;
            Features(6,j) = AUC(k);
     
            %Book keeping features. Tells you the peak number and cell number
            Features(7,j) = k;
            Features(8,j) = idx(i); %Tells overall cell number to help identify
            Features(9,j) = AvgMax;
            Features(10,j) = AvgMin;
            Features(11,j) = pks(k) / AvgMin; %Peak over basal
            Features(12,j) = numPeaks;
            j = j + 1;
        end
    end
end


            






