function [tramps,drops,AUC] = ProminenceTimeFeatures(CurrSignal,Points,pks,locs,w,p,numPeaks)
    for i = 1:numPeaks
        tramps = []
        drops = []
        AUC = []
        %Set up to calculate other features
        PeakLowerBound = locs(i) - w(i) / 2
        PeakUpperBound = locs(i) + w(i) / 2


        
        %This chunk finds the closest y value in the signal due to the
        %signal not being perfectly continuous
        [val1, index1] = min(abs(Points - PeakLowerBound))
        [val2, index2] = min(abs(Points - PeakUpperBound))
        
        %Value at the bottom two points of the peak
        LowerValue = temp(index1)
        UpperValue = temp(index2)

        %Times for these points
        LowerTime = time(index1)
        UpperTime = time(index2)

        %Finds the smaller of the two
        minSignal = min([UpperValue, LowerValue])
        
        %Signal for our region of interest
        roisignal = temp(index1:index2)
        roit = time(index1:index2)


        %Rise Time
        tramp = 9

        %Drop Time

       
        s = 0
        AUC = 0
        timePoints = 1:Points
        %Area under the curve (AUC)
        myInt = cumtrapz(time,CurrSignal(:,i))
        myIntv = @(a,b) max(myInt(time<=b)) - min(myInt(time>=a));
        AUC(i) = myIntv(LowerTime,UpperTime);
        
        
        
        
        end
end