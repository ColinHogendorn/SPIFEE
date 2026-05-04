function txt = structToPlainEnglish(S, Details, Data)
    %Plain English Output
    dayTime = string(datetime('now'));

    plainDate = "Analysis Date and Time:" + newline + dayTime + newline;
    plainVer = "Software Environment " +newline+ string(version) + newline;
    [Points, NumCells] = size(Data);

    f = S(1);
    %Filter Name
     if contains(f.Filt, "Gaussian") || contains(f.Filt, "Default")
        FiltName = "Gaussian";
     else
        FiltName = "Savitsky-Golay";
     end

    %WIndow Name
    if contains(f.Filt, "Strict")
        window = table2array(Details(8,2)) * f.Freq;
        window_name = "the length of the user's input frequency";
    elseif contains(f.Filt, "Loose")
        window = table2array(Details(8,2)) * f.Freq / 6;
        window_name = "1/6th the length of the user's input frequency";
    else
        window = table2array(Details(8,2)) * f.Freq / 3;
        window_name = "1/3rd the length of the user's input frequency";
    end

    %Normalization String
    if contains(f.Norm, "Basal")
        norm = "Basal Normalized";
    elseif contains(f.Norm, "Max")
        norm = "Max Normalized";
    else
        norm = "Not Normalized";
    end

       %Orientatation String
    if f.Vert == 1
        orientation = "Vertically";
    else
        orientation = "Horizontally";
    end

    if f.Fill == 1
        FillInfo = "data imputation with fillmissing() with linear interpolation from nearest EndValues." + newline + ...
            "Only traces with less than 10 percent of points missing were imputed.";
       %fillmissing(currDataFilt, 'linear',2, 'Endvalues', 'nearest');
    else
        FillInfo = "no data imputation";
    end


    %Get findpeaks details
    detes = table2array(Details);
 

    lines = strings(numel(f)+12,1);
    lines(1) = "SPIFEE Analysis Summary";
    lines(2) = "------------------------";
    lines(3) = plainDate;
    lines(4) = plainVer;

    lines(5) = "Preprocessing and Data Handling:";
    lines(6) = "--------------------------------";
    lines(7) = ...
        "Input traces were analyzed as being over a user-defined duration of " + ...
        string(f.Time) + " hours." + newline + ...
        "The Data had " + string(NumCells) + " Traces with " + string(Points) + " points" + newline + ...
        "Data were smoothed using a " + FiltName + ...
        " filter derived from a user-specified oscillation frequency of " + ...
        string(f.Freq) + " hours." + newline + ...
        "The resulting smoothing window size was " + ...
        string(window) + " points, corresponding to " + ...
        window_name + "." + newline;

        %Data Orientation, imputation and normalization
    lines(8) = "Data was " + norm + newline ...
    + "Data was inputted as being structured " + orientation + newline...
    + "For NaN values, there was " + FillInfo + newline...
    + "Traces exceeding the missing-data threshold of 10% of points were excluded from downstream analysis." + newline;

    lines(9) = "Peak Detection Parameters:";
    lines(10) = "--------------------------";
    lines(11) = ...
        "Peaks were identified using the following criteria:" + newline + ...
        "Minimum peak height: " + detes(3,2) + newline + ...
        "Minimum peak prominence: " + detes(4,2) + newline + ...
        "Minimum peak-to-peak distance: " + detes(5,2) + " hours" + newline + ...
        "Minimum peak width: " + detes(6,2) + " hours" + newline;
        %"Maximum peak width: " + detes(7,2) + " hours";
    %tx

   outputFile = "SPIFEE_Record_.txt";
   

    txt = strjoin(lines, newline);
    writelines(txt, outputFile);
end
