function Features = SPIFEE(Data, Hours, Channel)

%Peak data processing and feature extraction
%Written by Colin Hogendorn 6/7/22
%Rewritten with findchangepts for temporal features 11/16/22
%This function uses findpeaks() from the
%Signal Processing Toolbox for peaks and feature extraction as well as
%findchangepts()
%Designed for processing p53 oscillations and  geminin peaks

%This function uses a gaussian filter with 9 time points for smoothing the
%data, uses findpeaks() on the smoothed data, and then calculates and
%outputs features in a 2d array

%Data => a 2d array of fluorescent intensities with cell 1 being the first
%column and so on. 
%Period => How long of a time the points were taken over
%Channel => Geminin or P53 Channel will vary the parameters for findpeaks()
%


%Take the data and smooth it with the gauss filter
[Points, NumCells] = size(Data)
PointPer = Points/Hours %Length of Pulse in terms of number of points
LengthPulse = 3
FiltData = smoothdata(Data, "gaussian", PointPer * LengthPulse);
AvgMax = mean(max(FiltData)) %This value will be used to determine findpeaks() parameters

%Parameters for findpeaks based upon channel
if Channel == "Geminin"
minHeight = 100
minProm = 20
minDistance = .5
minWidth = .5
maxWidth = 20
elseif Channel == "p53"
minHeight = AvgMax / 10
minProm = AvgMax / 50
minDistance = PointPer * 1
minWidth = PointPer * 1
maxWidth = PointPer * 50 % this is just here so it runs.

%Old values 100, 20, 1, .75, 50

end



j = 1
i = 1


Features = []


for i = 1:NumCells
    CurrSignal = FiltData(:,i)
    %First 4 features
    [pks,locs,w,p] = findpeaks(CurrSignal,"MinPeakHeight", minHeight, "MinPeakProminence", minProm, "MinPeakDistance", minDistance, "MinPeakWidth",minWidth, "MaxPeakWidth", maxWidth);
    numPeaks = length(pks)

    %Calculate Freq
    if length(pks) > 1
        Freq = numPeaks / (max(locs) - min(locs))
    else
        Freq = 0
    end

    %Calculate Temporal Features
    dCurr = diff(CurrSignal)
    [ipt] = findchangepts(CurrSignal, "MaxNumChanges", (numPeaks * 2 + 1), 'Statistic', 'linear')
    tramps = []
    drops = []
    sums = []
    
    if length(ipt) <= 1 %Handles cases in which there are 0 peaks.
        continue
    else
    

        sums(1) = sum(dCurr(1:(ipt(1) - 1)))
        if sums(1) > 0
            sums(1) = 1
        else
            sums(1) = 0
        end 
       sums(length(ipt) + 1) = sum(dCurr((Points-1):ipt(1)))
        if sums(1) > 0
            sums(1) = 1
        else
            sums(1) = 0
        end 
    
        %Find all the sums and then turn them into 1s and 0s if they were
        %positive or negative
        for q=1:length(ipt) - 1
            value = sum(dCurr(ipt(q):ipt(q+1)))
                if value > 0
                    sums(q+1) = 1
                else
                    sums(q+1) = 0
                end
        end
       ipt = transpose(ipt)
        
       sums = logical(sums)
    
       %Visualize Features
%        figure()
%        findchangepts(CurrSignal, "MaxNumChanges", (numPeaks * 2 + 1), 'Statistic', 'linear')
%        figure()
%        hold on
        findpeaks(CurrSignal,"MinPeakHeight", minHeight, "MinPeakProminence", minProm, "MinPeakDistance", minDistance, "MinPeakWidth",minWidth, "MaxPeakWidth", maxWidth, 'Annotate', 'extents');
        figure()
    
    
       
       %Find tramps
       pos = find(sums)
       if pos(1) ~= 1
           begs = ipt(pos-1)
           ends = ipt(pos)
       else
           ipt = [0,ipt]
           begs = ipt(pos)
           ends = ipt(pos+1)
       end
    
       trampArray = [begs;ends]
       flagged = []
        
       for s = 2:length(ends)
           if trampArray(1,s) == trampArray(2,s-1)
               flagged = [flagged, s]
           end
       end
    
       s = 0 
       orgArraySize = length(trampArray)
       for s = 1:length(flagged)
           trampArray(2,(flagged(s)-1)) = trampArray(2,flagged(s))
           trampArray(:,(flagged(s))) = []
           flagged = flagged -1 
       end
       tramps = diff(trampArray)
    
       %Find Drops
       zeroes = find(sums == 0)
       zeroes(zeroes == 1) = []
    
       begs = []
       ends = []
    
    
       begs = ipt(zeroes - 1)
       ipt = [ipt,Points]
       ends = ipt(zeroes)
    
       DropArray = [begs;ends]
       flagged = []
        
       for s = 2:length(ends)
           if DropArray(1,s) == DropArray(2,s-1)
               flagged = [flagged, s]
           end
       end
    
       s = 0 
       orgArraySize = length(DropArray)
       for s = 1:length(flagged)
           DropArray(2,(flagged(s)-1)) = DropArray(2,flagged(s))
           DropArray(:,(flagged(s))) = []
           flagged = flagged -1 
       end
       drops = diff(DropArray)
    
    
    
       %Area under the curve (AUC)
       s= 0
       AUC = 0
       timePoints = 1:Points
       for s = 1:length(tramps)
            myInt = cumtrapz(timePoints,CurrSignal)
            myIntv = @(a,b) max(myInt(timePoints<=b)) - min(myInt(timePoints>=a));
            AUC(s) = myIntv(trampArray(1,s),DropArray(2,s))
       end
    
       %Put into the list of features
        for k=1:numPeaks
            Features(1,j) = pks(k)
            Features(2,j) = locs(k)
            Features(3,j) = w(k)
            Features(4,j) = p(k)
            Features(5,j) = Freq
       %There are a few cases in which findchangepts() doesn't work well.
       %This if-else handles those cases and puts NA for those features
            if length(tramps) == numPeaks
                Features(6,j) = tramps(k)
                Features(7,j) = drops(k)
                Features(8,j) = tramps(k) + drops(k)
                Features(9,j) = AUC(k)
            else
                continue %delete this continue if you want ALL the data points. Leave if you just want data points that findchangepts() works for
                Features(6,j) = "NA"
                Features(7,j) = "NA"
                Features(8,j) = "NA"
                Features(9,j) = "NA"
            end
    
            %Book keeping features. Tells you the peak number and cell number
            Features(10,j) = k
            Features(11,j) = i
    
    
            j = j + 1
        end
    
    end


end
            
end





