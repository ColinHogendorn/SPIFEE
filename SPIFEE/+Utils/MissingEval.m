% MissingEval
% ------------------------------------------------------------
%  Evaluates missing data across traces
%  Computes cumulative missingness over time
%  Determines optimal cutoff balancing trace count and time points used
%
%  Plots:
%     - Usable traces vs time (with suggested cutoff)
%     - Histogram of % missing per trace (pass/fail by threshold)
%
% Input:
%  name - name of condition
%  params - processing parameters
%  data - trace matrix (time x traces)
%
% Output:
%  none

function MissingEval(name, params,data)
   % Missing / Threshold Visualization
   % data = transpose(data);   % time x traces
    numTime = size(data,1);
    
    threshold = params.Thresh;
    
    %Missing per trace
    missing = isnan(data); 
    cum_missing = cumsum(missing, 1);
    n = (1:numTime)'; 
    percent_missing_prefix = cum_missing ./ n * 100;
    
    good_traces = percent_missing_prefix < threshold;   % logical
    num_good = sum(good_traces, 2); % per timepoint
    
    %Cutpoint
    score = num_good .* n;   % tradeoff: more traces × longer duration
    [~, optimal_point] = max(score);
    fprintf(('Suggested cutoff for ' + string(name) + ': %d timepoints\n'), optimal_point);
    
    %plot
    CumMissingFig = figure;
    plot(n, num_good, 'k', 'LineWidth', 2);
    ylabel('# Good Traces')
    
    xlabel('Timepoint')
    title('Cumulative Missingness and Usable Traces')
    grid on
    
    xline(optimal_point, '--r', 'Suggested Cutoff');
   
    %Percent missing per trace
    percent_missing_per_trace = sum(isnan(data), 1) / numTime * 100;
    threshold = params.Thresh;
    
    %Split for colors
    passing = percent_missing_per_trace < threshold;
    failing = percent_missing_per_trace >= threshold;

     % Define consistent bin edges (every 5%)
    edges = 0:5:100;
    
    PassingHist = figure;
    hold on;
    
    histogram(percent_missing_per_trace(passing), edges, ...
        'FaceAlpha', 0.7);
    
    histogram(percent_missing_per_trace(failing), edges, ...
        'FaceAlpha', 0.7);
    xline(threshold, '--r', 'Threshold', 'LineWidth', 2);
    xlim([0 100])
    xlabel('% Missing per Trace');
    ylabel('Number of Traces');
    title('Trace Missingness Distribution');

    num_pass = sum(passing);
    num_fail = sum(failing);
    
    legend({ ...
        ['Passing (n = ' num2str(num_pass) ')'], ...
        ['Failing (n = ' num2str(num_fail) ')'], ...
        'Threshold' ...
    });
    grid on;
    hold off;

    %Save Average Cluster Fig
    Utils.PlotLogic(params, (name + "_PointwiseMissingness"), CumMissingFig)
    
    %Save ClusterComposition Fig
    Utils.PlotLogic(params, (name + "_PassingHist"), PassingHist)
    end
