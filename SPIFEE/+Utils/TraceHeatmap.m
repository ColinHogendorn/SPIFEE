function TraceHeatmap(currDataFilt, name, params)
    figure;
    % Clean name
    name2 = strrep(name, "_", '');
    %Handle invalid values
    currDataFilt(currDataFilt == -1) = NaN;
    currDataFilt = transpose(currDataFilt); %Want it in rows to match other plots
    %create heatmap
    h = heatmap(currDataFilt);

    title(name2 + " Heatmap")
    xlabel('TimePoints');
    ylabel('Samples');

    %Color scaling
    validData = currDataFilt(~isnan(currDataFilt));

    if ~isempty(validData)
        climLow = prctile(validData, 1);
        climHigh = prctile(validData, 99);
        h.ColorLimits = [climLow climHigh];
    end

    % Tick logic
    numX = size(currDataFilt, 2); % samples
    numY = size(currDataFilt, 1); % timepoints

    xticks = 1:max(1, round(numX/20)):numX;
    yticks = 1:max(1, round(numY/20)):numY;

    h.XDisplayLabels = repmat(" ", 1, numX);
    h.YDisplayLabels = repmat(" ", numY, 1);

    %Heatmap object is super weird in terms of the axis ticks, and it requires this awfulness to plot
    %correctly. If you are reading this and figure something better out,
    %please email me and tell me how you did it because I would be
    %FASCINATED to know!
    h.XDisplayLabels(xticks) = cellstr(num2str((xticks)'));
    h.YDisplayLabels(yticks) = cellstr(num2str((yticks)'));

    % Colormap
    colormap(jet);
    colorbar;

    % save/export
    Utils.PlotLogic(params, (name + "_Heatmap"), gcf)
end