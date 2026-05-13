% computeJagged
% ------------------------------------------------------------
%  Evaluates trace continuity (jaggedness) across orientations
%  Computes metrics per row and per column:
%     - Total variation (TV)
%     - Mean absolute first difference (J1)
%     - Mean absolute second difference (J2)
%     - Continuity score (C)
%  Compares average continuity between row-wise and column-wise views
%  Issues warning if data orientation (params.Vert) is likely incorrect
%
% Input:
%  params - processing parameters
%  currDataFilt - trace matrix (time x traces)
%
% Output:
%  avgC_Col - average continuity score treating traces as columns
%  avgC_Row - average continuity score treating traces as rows

function [avgC_Col, avgC_Row] = computeJagged(params, currDataFilt)
%Cell Orientation test. Trace Continuity. Throws Warning.
    %Only performs on traces that don't have NA values
    [numRows, numCols] = size(currDataFilt);

    metricsR = zeros(numRows,4);
    metricsC = zeros(numCols,4);

    for z = 1:numRows
        x = currDataFilt(z,:);
        M = JaggedHelper(x);

        %Jaggedness Measurements
        metricsR(z,1)= M.TV;
        metricsR(z,2) = M.J1;
        metricsR(z,3) = M.J2;
        metricsR(z,4)  = M.C;
    end
    
     for j = 1:numCols
        x2 = currDataFilt(:,j);
        M = JaggedHelper(x2);

        metricsC(j,1)= M.TV;
        metricsC(j,2) = M.J1;
        metricsC(j,3) = M.J2;
        metricsC(j,4)  = M.C;
    end
    
    %Eval
    avgC_Col = mean([metricsC(:,4)]);
    avgC_Row = mean([metricsR(:,4)]);

    %Turn off backtrace
    warning('off', 'backtrace')

    %Throws warning if params.Vert does not align with the continuity
    %measurement
    if avgC_Col < avgC_Row && params.Vert == 0
        warning("Trace orientation check: data appears more continuous when treated as COLUMNS. " + ...
        "Recommendation: enable the 'Each Trace is a Column' option.")
    elseif avgC_Col < avgC_Row && params.Vert == 1
         warning("Trace orientation check: data appears more continuous when treated as ROWS. " + ...
        "Recommendation: disable the 'Each Trace is a Column' option.")
    end
end


function M = JaggedHelper(x)
%JAGGEDNESS_METRICS  Compute multiple jaggedness / continuity measures
% M = jaggedness_metrics(x)
%Outputs (struct):
% M.TV   - Total variation
% M.J1   - Mean absolute first difference
% M.J2   - Mean absolute second difference
% M.C    - Continuity score (0–1, higher = smoother)
    % inputs
    x = x(:);
    n = numel(x);
    if n < 2
        M.TV = 0;
        M.J1 = 0;
        M.J2 = 0;
        M.C  = 1;
        return
    end
    % metrics
    dx  = diff(x);
    M.TV = total_variation(dx);
    M.J1 = mean_abs_first_diff(dx);
    if n < 3
        M.J2 = 0;
    else
        M.J2 = mean_abs_second_diff(x);
    end
    M.C = continuity_score(M.J2);
end

function TV = total_variation(dx)
    TV = sum(abs(dx));
end
function J1 = mean_abs_first_diff(dx)
    J1 = mean(abs(dx));
end
function J2 = mean_abs_second_diff(x)
    J2 = mean(abs(diff(x,2)));
end
function C = continuity_score(J2)
    C = 1 / (1 + J2);
end

