function txt = structToPlainEnglish(S,Files, Details, Data)
    %Plain English Output
    dayTime = string(datetime('now'));
    Details = Details{1};

    plainDate = "Analysis Date and Time:" + newline + dayTime + newline;
    plainVer = "Software Environment:" +newline+ string(version) + newline;
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
    
    %Imputation String
    if f.Fill == 1
        FillInfo = "data imputation with fillmissing() with linear interpolation from nearest EndValues." + newline + ...
            "Only traces with less than " + string(f.Thresh) + " percent of points missing were imputed.";
       %fillmissing(currDataFilt, 'linear',2, 'Endvalues', 'nearest');
    else
        FillInfo = "no data imputation";
    end

    %Handle FilesNames
    FileNames = string(Files);
    fileList = "Data files used:" + newline + " - " + strjoin(FileNames, newline + " - ");


    %Get findpeaks details
    detes = table2array(Details);
 
    n = 1;

    lines = strings(numel(f)+14,1);
    lines(n) = "SPIFEE Analysis Summary"; n = n+1; 
    lines(n) = "------------------------"; n = n+1; 
    lines(n) = plainDate; n = n+1; 
    lines(n) = plainVer; n = n+1; 
    
    % Data Files used.
    lines(n) = fileList + newline; n = n+1;


    lines(n) = "Preprocessing and Data Handling:"; n = n+1; 
    lines(n) = "--------------------------------"; n = n+1; 
    lines(n) = ...
        "Input traces were analyzed as being over a user-defined duration of " + ...
        string(f.Time) + " hours." + newline + ...
        "The Data had " + string(NumCells) + " Traces with " + string(Points) + " points" + newline + ...
        "Data were smoothed using a " + FiltName + ...
        " filter derived from a user-specified oscillation frequency of " + ...
        string(f.Freq) + " hours." + newline + ...
        "The resulting smoothing window size was " + ...
        string(window) + " points, corresponding to " + ...
        window_name + "." + newline; n = n+1; 

        %Data Orientation, imputation and normalization
    lines(n) = "Data was " + norm + newline ...
    + "Data was inputted as being structured " + orientation + newline...
    + "For NaN values, there was " + FillInfo + newline...
    + "Traces exceeding the missing-data threshold of " + string(f.Thresh) + "% of points were excluded from downstream analysis." + newline; n = n+1; 

    lines(n) = "Peak Detection Parameters:"; n = n+1; 
    lines(n) = "--------------------------"; n = n+1; 
    lines(n) = ...
        "Peaks were identified using the following criteria:" + newline + ...
        "Minimum peak height: " + detes(3,2) + newline + ...
        "Minimum peak prominence: " + detes(4,2) + newline + ...
        "Minimum peak-to-peak distance: " + detes(5,2) + " hours" + newline + ...
        "Minimum peak width: " + detes(6,2) + " hours" + newline;
        %"Maximum peak width: " + detes(7,2) + " hours";
    %tx

   outputFile = S.Name +"_SPIFEE_Record_.txt";
   

    txt = strjoin(lines, newline);
    writelines(txt, fullfile(S.Folder,outputFile));
end
