% StatsSuitev2
% ------------------------------------------------------------
%  Performs statistical analysis across grouped feature data
%  Tests:
%     - Normality (Lilliefors per group)
%     - Variance homogeneity (Levene)
%     - Omnibus (ANOVA or KrUSKAL-WALLIS)
%  Posthoc:
%     - Tukey-Kramer (parametric) or Dunn-Sidak (nonparametric)
%  Computes:
%     - Pairwise comparisons with effect sizes (Cohen’s d / Cliff’s delta)
%     - FDR correction (Benjamini-Hochberg)
%     - Significant results and effect ranking
%     - Condition distinctiveness summary
%  Plots:
%     - Effect size heatmap (feature × condition)
%
% Input:
%  params - processing parameters
%  feats - feature table (features x peaks/traces)
%  groupLabels - grouping labels for each feature
%
% Output:
%  results - struct containing:
%     .Omnibus - omnibus test results
%     .Pairwise - all pairwise comparisons
%     .Significant - significant comparisons (FDR corrected)
%     .EffectRanking - ranked significant effects
%     .DistinctConditions - condition distinctiveness summary

function results = StatsSuitev2(fullFeats,groupLabels,params)

featNames = ["Height","Width","Prominence","Frequency","Integral"];
groupLabels = string(groupLabels);

% remove unused rows
fullFeats([2,7,8,9,10,11,12], :) = [];
nFeatures = size(fullFeats,1);
groups = unique(groupLabels);

maxRows = 1000; % choose a number safely larger than expected
omnibusRows = cell(maxRows, 5); % 5 columns
pairRows = cell(maxRows, 8);    % 8 columns

omnibusCount = 0;
pairCount = 0;

for i = 1:nFeatures

    data = fullFeats(i,:)';
    featName = featNames(i);

    %Normality test per group
    normalP = nan(numel(groups),1);
    for g = 1:numel(groups)
        d = data(groupLabels==groups(g));
        if numel(d) >= 4
            [~,normalP(g)] = lillietest(d);
        else
            normalP(g) = 1; % small sample fallback
        end
    end

    isNormal = all(normalP > 0.05);

    % Variance homogeneity
    levene_p = vartestn(data,groupLabels,'TestType','LeveneAbsolute','Display','off');

    % Choose omnibus test
    if isNormal && levene_p > 0.05

        [pVal,~,stats] = anova1(data,groupLabels,'off');
        testUsed = "ANOVA";
        posthocType = "tukey-kramer";
        isParametric = true;

    else

        [pVal,~,stats] = kruskalwallis(data,groupLabels,'off');
        testUsed = "Kruskal-Wallis";
        posthocType = "dunn-sidak";
        isParametric = false;

    end
    omnibusCount = omnibusCount + 1;
    omnibusRows(omnibusCount,:) = {featName,min(normalP),levene_p,pVal,testUsed};

    % Posthoc tests
    if pVal < 0.05

        c = multcompare(stats,'display','off','ctype',posthocType);

        for r = 1:size(c,1)

            g1 = groups(c(r,1));
            g2 = groups(c(r,2));
            p12 = c(r,6);

            d1 = data(groupLabels==g1);
            d2 = data(groupLabels==g2);

            if isParametric
                eff = cohensD(d1,d2);
                effType = "Cohen_d";
            else
                eff = cliffsDelta(d1,d2);
                effType = "Cliffs_delta";
            end

           pairCount = pairCount + 1;
           pairRows(pairCount,:) = {featName,g1,g2,p12,eff,effType,length(d1),length(d2)};
        end

    end

end
%Trim Rows
omnibusRows = omnibusRows(1:omnibusCount,:);
pairRows = pairRows(1:pairCount,:);

% Tables
omnibusTable = cell2table(omnibusRows,...
    'VariableNames',["Feature","Normality_p","Levene_p","Omnibus_p","TestUsed"]);

pairwiseTable = cell2table(pairRows,...
    'VariableNames',["Feature","Group1","Group2","p","Effect","EffectType","N1","N2"]);

% Global FDR correction
if ~isempty(pairwiseTable)
    pairwiseTable.FDR_p = mafdr(pairwiseTable.p,'BHFDR',true);
    pairwiseTable.Significant = pairwiseTable.FDR_p < 0.05;
else
    pairwiseTable.FDR_p = zeros(0);
    pairwiseTable.Significant = zeros(0);
end

% Significant results table
if ~isempty(pairwiseTable)
    significantTable = pairwiseTable(pairwiseTable.Significant,:);
else
    significantTable = table;
end

% Effect Ranking
if ~isempty(significantTable)
    [~,idx] = sort(abs(significantTable.Effect),'descend');
    rankedTable = significantTable(idx,:);
    direction = strings(height(rankedTable),1);
    for j = 1:height(rankedTable)
        if rankedTable.Effect(j) > 0
            direction(j) = rankedTable.Group1(j) + " > " + rankedTable.Group2(j);
        else
            direction(j) = rankedTable.Group1(j) + " < " + rankedTable.Group2(j);
        end
    end
    rankedTable.Direction = direction;
else
    rankedTable = table;
end


%% Condition Distinctiveness Summary
nFeatures = length(unique(pairwiseTable.Feature));
nGroups   = length(unique([pairwiseTable.Group1; pairwiseTable.Group2]));
maxRows   = nFeatures * nGroups;

flagRows = cell(maxRows, 5);  % 5 columns
flagCount = 0;

if ~isempty(pairwiseTable)
    features = unique(pairwiseTable.Feature);
    groups = unique([pairwiseTable.Group1; pairwiseTable.Group2]);
    for f = 1:length(features)
        feat = features(f);
        featRows = pairwiseTable.Feature == feat;
        sub = pairwiseTable(featRows,:);
        for g = 1:length(groups)
            grp = groups(g);
            % comparisons involving this group
            idx = (sub.Group1==grp | sub.Group2==grp) & sub.Significant;
            nDiff = sum(idx);
            if nDiff > 0
                eff = sub.Effect(idx);
                % flip sign when group appears as Group2
                flipIdx = sub.Group2(idx)==grp;
                eff(flipIdx) = -eff(flipIdx);
                meanEff = mean(eff);
            else
                meanEff = 0;
            end
            % Flag if different from most groups
            if nDiff >= ceil((length(groups)-1)/2)
                flag = "Distinct";
            else
                flag = "";
            end
            flagCount = flagCount + 1;
            flagRows(flagCount,:) = {feat, grp, nDiff, meanEff, flag};
        end
    end
    flagRows = flagRows(1:flagCount, :);
    distinctTable = cell2table(flagRows, ...
    'VariableNames', ["Feature","Condition","NumDifferences","MeanEffect","Flag"]);
    % sort strongest first
    distinctTable = sortrows(distinctTable,"NumDifferences","descend");
else
    distinctTable = table;
end

% Save results
results.Omnibus = omnibusTable;
results.Pairwise = pairwiseTable;
results.Significant = significantTable;
results.EffectRanking = rankedTable;
results.DistinctConditions = distinctTable;

plotEffectHeatmap(results,params)
end


% Helper Functions
function d = cohensD(x,y)
s = sqrt((var(x)+var(y))/2);
d = (mean(x)-mean(y))/s;
end

function delta = cliffsDelta(x,y)
    nx = length(x);
    ny = length(y);
    count = 0;
    for i = 1:nx
        for j = 1:ny
            if x(i) > y(j)
                count = count + 1;
            elseif x(i) < y(j)
                count = count - 1;
            end
        end
    end
    delta = count/(nx*ny);
end

function plotEffectHeatmap(results,params)
    sig = results.Significant;
    
    if isempty(sig)
        disp("No significant effects")
        return
    end
    
    features = unique(sig.Feature);
    groups = unique([sig.Group1; sig.Group2]);
    mat = zeros(length(features),length(groups));
    
    for i = 1:height(sig)
        f = find(ismember(features, sig.Feature(i)), 1); % take first match
        g = find(ismember(groups, sig.Group2(i)), 1);
        if ~isempty(f) && ~isempty(g)
            mat(f,g) = sig.Effect(i);
        end
    end
    heatFig = figure();
    imagesc(mat)
    xticks(1:length(groups))
    xticklabels(groups)
    set(gca, 'TickLabelInterpreter', "None")
    yticks(1:length(features))
    yticklabels(features)
    colormap(bluewhitered)
    clim([-max(abs(mat(:))) max(abs(mat(:)))]);  % center at 0
    colorbar
    title("Feature × Condition Effect Size")
    Utils.PlotLogic(params, "StatsSuiteHeatmap", heatFig)

end

function cmap = bluewhitered(n)

if nargin < 1
    n = 256;
end

half = floor(n/2);

% Blue → White
r1 = linspace(0,1,half)';
g1 = linspace(0,1,half)';
b1 = ones(half,1);

% White → Red
r2 = ones(half,1);
g2 = linspace(1,0,half)';
b2 = linspace(1,0,half)';

cmap = [r1 g1 b1; r2 g2 b2];

end