function Features = SPIFEE(Data, Hours, Temporal)

%Peak data processing and feature extraction
%Written by Colin Hogendorn 6/7/22
%This function uses findpeaks() from the
%Signal Processing Toolbox for peaks and feature extraction as well as
%findchangepts()
%Designed for processing p53 oscillations

%This function uses a gaussian filter with 9 time points for smoothing the
%data, uses findpeaks() on the smoothed data, and then calculates and
%outputs features in a 2d array

%Data => a 2d array of fluorescent intensities with cell 1 being the first
%column and so on. 
%Hours => How long of a time the points were taken over
%Temporal => Option for how to calculate Temporal features.



%Take the data and smooth it with the gauss filter
[Points, NumCells] = size(Data)
PointPerHour = Points/Hours 
FreqPulse = 5.5

%Gaussian Filter window is half of the pulse width in terms of points
FiltData = smoothdata(Data, "gaussian", PointPerHour * FreqPulse * 1/3); 
AvgMax = mean(max(FiltData)) %This value will be used to determine findpeaks() parameters
AvgMin = mean(min(FiltData)) %Determines roughly the basal p53 amount per treatment

%Parameters for findpeaks()
minHeight = AvgMax / 10
minProm = AvgMax / 15
minDistance = PointPerHour * .3
minWidth = PointPerHour * .5
maxWidth = PointPerHour  * 5 


j = 1
i = 1

Features = []


for i = 1:NumCells
     CurrSignal = FiltData(:,i)
     %CurrSignal = Data(:,i)
    %First 4 features
    [pks,locs,w,p] = findpeaks(CurrSignal,"MinPeakHeight", minHeight, "MinPeakProminence", minProm, "MinPeakDistance", minDistance, "MinPeakWidth",minWidth, "MaxPeakWidth", maxWidth);
    %[pks,locs,w,p] = findpeaks(CurrSignal)
    numPeaks = length(pks)

    %Calculate Freq
    if length(pks) > 1
        Freq = numPeaks / (max(locs) - min(locs))
    else
        Freq = 0
    end


         %Visualize Features
%        findchangepts(CurrSignal, "MaxNumChanges", (numPeaks * 2 + 1), 'Statistic', 'linear')
%         findpeaks(CurrSignal,"MinPeakHeight", minHeight, "MinPeakProminence", minProm, "MinPeakDistance", minDistance, "MinPeakWidth",minWidth, "MaxPeakWidth", maxWidth, 'Annotate', 'extents');
%         figure()

   %Calculate TemporalFeatures
   if strcmp(Temporal, 'Changepts')
       [tramps,drops,AUC] = ChangePointTimeFeatures(CurrSignal,numPeaks,Points)
   elseif strcmp(Temporal, 'Prom')
       tramps = []
       drops = []
       AUC = []

       for z = 1:numPeaks
            %PeakLowerBound = locs(i) - w(i) / 2
            %PeakUpperBound = locs(i) + w(i) / 2
            
            %Placeholder while I figure something better out
            tramps(z) = locs(z) - (locs(z) - w(z)/2)
            drops(z) = locs(z) - (locs(z) - w(z)/2)
            
            timePoints = 1:Points
            myInt = cumtrapz(timePoints,CurrSignal)
            myIntv = @(a,b) max(myInt(timePoints<=b)) - min(myInt(timePoints>=a));
            AUC(z) = myIntv((locs(z) - tramps(z)), (locs(z) + drops(z)))
%             AUC(z) = myIntv(1,143)

       end
   else
       continue
   end

   %Feature List: Height,Location,Width,Prominence,Frequency, Duration,
   %Area under Curve, Peak Number, Cell Number, AvgMax, AvgMin, Basal rate
   %Put into the list of features
    for k=1:numPeaks
        Features(1,j) = pks(k)
        Features(2,j) = locs(k)
        Features(3,j) = w(k) / PointPerHour
        Features(4,j) = p(k)
        Features(5,j) = Freq * PointPerHour
        Features(6,j) = tramps(k) + drops(k) / PointPerHour
        Features(7,j) = AUC(k)
 
        %Book keeping features. Tells you the peak number and cell number
        Features(8,j) = k
        Features(9,j) = i
        Features(10,j) = AvgMax
        Features(11,j) = AvgMin
        Features(12,j) = pks(k) / AvgMin

    
            j = j + 1
        end
    
    end


end


            






