load markData.mat

%Converting from cells to arrays
Anno = measurements.cellAnnotation
temp = Anno(:,2)
An = cell2mat(temp)

%Find indexes of particular treatments based if 1-10 or 10-20 etc.
%This is done because measurements.cellAnnotation is out of order
treat1 = find(An <= 5)
treat2 = find(An >= 6 & An <= 10)
treat3 = find(An >= 11 & An <= 15)
treat4 = find(An >= 16 & An <= 20)
treat5 = find(An <= 21 & An <= 25)
treat6 = find(An <= 26 & An <= 30)

newtreat1 = find(An >= 31 & An <= 35)
newtreat2 = find(An >= 36 & An <= 40)
newtreat3 = find(An >= 41 & An <= 45)
newtreat4 = find(An >= 46 & An <= 50)
newtreat5 = find(An <= 51 & An <= 55)
newtreat6 = find(An <= 56 & An <= 60)

%Traces of each treatment. Transpose
treat1Data = transpose(measurements.singleCellTraces(treat1,:))
treat2Data = transpose(measurements.singleCellTraces(treat2,:))
treat3Data = transpose(measurements.singleCellTraces(treat3,:))
treat4Data = transpose(measurements.singleCellTraces(treat4,:))
treat5Data = transpose(measurements.singleCellTraces(treat5,:))
treat6Data = transpose(measurements.singleCellTraces(treat6,:))

newtreat1Data = transpose(measurements.singleCellTraces(newtreat1,:))
newtreat2Data = transpose(measurements.singleCellTraces(newtreat2,:))
newtreat3Data = transpose(measurements.singleCellTraces(newtreat3,:))
newtreat4Data = transpose(measurements.singleCellTraces(newtreat4,:))
newtreat5Data = transpose(measurements.singleCellTraces(newtreat5,:))
newtreat6Data = transpose(measurements.singleCellTraces(newtreat6,:))


%Replace -1s with NaNs
treat1Data(treat1Data == -1) = NaN
treat2Data(treat2Data == -1) = NaN
treat3Data(treat3Data == -1) = NaN
treat4Data(treat4Data == -1) = NaN
treat5Data(treat5Data == -1) = NaN
treat6Data(treat6Data == -1) = NaN

newtreat1Data(newtreat1Data == -1) = NaN
newtreat2Data(newtreat2Data == -1) = NaN
newtreat3Data(newtreat3Data == -1) = NaN
newtreat4Data(newtreat4Data == -1) = NaN
newtreat5Data(newtreat5Data == -1) = NaN
newtreat6Data(newtreat6Data == -1) = NaN

%Get only the data this has data for every timepoint
fullTreat1 = treat1Data(:,~any(isnan(treat1Data)))
fullTreat2 = treat2Data(:,~any(isnan(treat2Data)))
fullTreat3 = treat3Data(:,~any(isnan(treat3Data)))
fullTreat4 = treat4Data(:,~any(isnan(treat4Data)))
fullTreat5 = treat5Data(:,~any(isnan(treat5Data)))
fullTreat6 = treat6Data(:,~any(isnan(treat6Data)))

newfullTreat1 = newtreat1Data(:,~any(isnan(newtreat1Data)))
newfullTreat2 = newtreat2Data(:,~any(isnan(newtreat2Data)))
newfullTreat3 = newtreat3Data(:,~any(isnan(newtreat3Data)))
newfullTreat4 = newtreat4Data(:,~any(isnan(newtreat4Data)))
newfullTreat5 = newtreat5Data(:,~any(isnan(newtreat5Data)))
newfullTreat6 = newtreat6Data(:,~any(isnan(newtreat6Data)))
%%
% for i = 1:215
%    timePoints = 1:143
%    myInt = cumtrapz(timePoints,newfullTreat6(:,i))
%    myIntv = @(a,b) max(myInt(timePoints<=b)) - min(myInt(timePoints>=a));
% %             AUC(z) = myIntv((locs(z) - tramps(z)), (locs(z) + drops(z)))
%    AUC(i) = myIntv(1,143)
%    Val = mean(AUC)

end
%%

% %Features of the Peaks
% treat1Feat = SPIFEE(fullTreat1,48,'p53','Changepts')
% treat2Feat = SPIFEE(fullTreat2,48,'p53','Changepts')
% treat3Feat = SPIFEE(fullTreat3,48,'p53','Changepts')
% treat4Feat = SPIFEE(fullTreat4,48,'p53','Changepts')
% treat5Feat = SPIFEE(fullTreat5,48,'p53','Changepts')
% treat6Feat = SPIFEE(fullTreat6,48,'p53','Changepts')
% 

newTreat = [newfullTreat1,newfullTreat2,newfullTreat3,newfullTreat4,newfullTreat5,newfullTreat6]
newtreatFeat = SPIFEE(newTreat,48,'Prom')


Treat1Feat = newtreatFeat(:,find(newtreatFeat(9,:) >= 1 & newtreatFeat(9,:) <= 18))
Treat2Feat = newtreatFeat(:,find(newtreatFeat(9,:) > 18 & newtreatFeat(9,:) <= 33))
Treat3Feat = newtreatFeat(:,find(newtreatFeat(9,:) > 33 & newtreatFeat(9,:) <= 53))
Treat4Feat = newtreatFeat(:,find(newtreatFeat(9,:) > 53 & newtreatFeat(9,:) <= 71))  
Treat5Feat = newtreatFeat(:,find(newtreatFeat(9,:) > 71 & newtreatFeat(9,:) <= 262))
Treat6Feat = newtreatFeat(:,find(newtreatFeat(9,:) > 262 & newtreatFeat(9,:) <= 477))

%Means
mean1 = mean(Treat1Feat,2)
mean2 = mean(Treat2Feat,2)
mean3 = mean(Treat3Feat,2)
mean4 = mean(Treat4Feat,2)
mean5 = mean(Treat5Feat,2)
mean6 = mean(Treat6Feat,2)

means = [mean1,mean2,mean3,mean4,mean5,mean6]

% newmeans = mean(newtreatFeat,2)
% newmeans([3,6,7,8,9,10,11],:) = []

%%
%Sanity Checks

% T1m = mean(newfullTreat1,2)
% T2m = mean(newfullTreat2,2)
% T3m = mean(newfullTreat3,2)
% T4m = mean(newfullTreat4,2)
% T5m = mean(newfullTreat5,2)
% T6m = mean(newfullTreat6,2)
% 
% p = plot(newfullTreat1)
% hold on
% plot(T1m, 'LineWidth', 7, 'Color', 'black')
% ylim([0, 5000])