
%Sigmoidal data processing and feature extraction
%Written by Colin Hogendorn 9/21/22
%This is a script that processes sigmoidal fluorescnece data with a
%gaussian filter and the extracts useful features. findchangepts() function
%From the SignalProcessingToolbox to help find slope times.
%Signal Processing Toolbox for peaks and feature extraction
%Originally designed for processing p21 data

%Output is a 2d array. Cells are columns and features are rows

%Data => a 2d array of fluorescent intensities with cell 1 being the first
%column and so on. 

function Features = SigmoidalProcessing(Data)

FiltData = smoothdata(Data, "gaussian", 9); %Filters the data with a gaussian filter


for i = 1:size(Data,2)  %For each column
    curr = FiltData(:,i) %Current Signal

    %If the signal is "Activated" label as 1, else its 0
    if max(curr) <= 1.5 * curr(1)
        Features(1,i) = 0
    else
        Features(1,i) = 1
    end
    
    %This function creates a linear approximation with a maximum of 3 lines for the
    %current signal. 
    [ipt,residual] = findchangepts(curr, "MaxNumChanges", 3, 'Statistic', 'linear')
    
    %Slope start is defined as the first changepoint
    slopeStart = ipt(1)
    
    %Not all signals will have 3 lines. This part says that if there are 3
    %changepts, then the slope end is the greater of the two
    %Handled roughly 20% of fringe cases
    if length(ipt) == 3
        midPoint = curr(ipt(2))
        endPoint = curr(ipt(3))
        if midPoint >= endPoint
            slopeEnd = ipt(2)
        else
            slopeEnd = ipt(3)
        end
    else
        slopeEnd = ipt(2)
        
    end

    
    %Features
    %Feature 2 is time of slope
    %Feature 3 is the slope rate of change
    %Feature 4 is activated over basal expression
    %Feature 5 is for bookeeping to see which cell this belongs to.
    Features(2,i) = slopeEnd - slopeStart
    Features(3,i) = curr(slopeEnd) - curr(slopeStart) / Features(2,i)
    Features(4,i) = max(curr) / min(curr)
    Features(5,i) = i

    %This commented out section graphs each cell trace with the slope that
    %it calcualated shown on the line
%     title("HighAmpFeats Graph " + string(i))
%     xlabel("Time")
%     plot(1:size(Data,1),curr)
%     hold on
%     plot(slopeStart, curr(slopeStart),'*r')
%     plot(slopeEnd, curr(slopeEnd), '*m')
%     ylabel("CDK Amount")
%     figure()
    end
end



