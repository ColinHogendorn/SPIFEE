function [stuff1,stuff2,stuff3] = ChangePointTimeFeatures(CurrSignal, numPeaks,Points)

    %Calculate Temporal Features
    dCurr = diff(CurrSignal)
    if numPeaks == 1 | numPeaks == 0
        stuff1 = NaN
        stuff2 = NaN
        stuff3 = NaN
    else
        [ipt] = findchangepts(CurrSignal, "MaxNumChanges", (numPeaks * 2 + 1), 'Statistic', 'linear')
    tramps = []
    drops = []
    sums = []

    
    

        sums(1) = sum(dCurr(1:(ipt(1) - 1)))
        if sums(1) > 0 %Is the region positive or negative.
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
    
       
       %Find tramps
       pos = find(sums)
       if isempty(pos) == 0
           if  pos(1) ~= 1 
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
    stuff1 = tramps
    stuff2 = drops
    stuff3 = AUC
       else
           stuff1 = NaN
           stuff2 = NaN
           stuff3 = NaN
    end

    end
end