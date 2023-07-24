
close all

load control_Updated.mat

Data = p53FlourescentValues
Data = transpose(Data)
CntrlFilt = Data(:,~any(isnan(Data)))
CntrlFeat = SPIFEE(CntrlFilt, 48, 5.5)

load 10uP53.mat
Data1 = p53FlourescentValues 
Data1 = transpose(Data1)
Data1(:,43) = []
Data1(:,36) = []
Treat1Filt = Data1(:,~any(isnan(Data1)))
Treat1Feat = SPIFEE(Treat1Filt,48,5.5)




load 100umP53.mat
Data2 = p53FlourescentValues 
Data2 = transpose(Data2)
Data2(:,41) = []
Data2(:,53) = []
Data2(:,54) = []
Data2(:,58) = []
Data2(:,71) = []
Treat2Filt = Data2(:,~any(isnan(Data2)))
Treat2Feat = SPIFEE(Treat2Filt,48,5.5)

load 250umP53.mat
Data3 = p53FlourescentValues 
Data3 = transpose(Data3)

Data3(:,31) = []
Data3(:,55) = []
Data3(:,65) = []

Treat3Filt = Data3(:,~any(isnan(Data3)))
Treat3Feat = SPIFEE(Treat3Filt,48,5.5)


load 500umP53.mat
Data4 = p53FlourescentValues 
Data4 = transpose(Data4)
Treat4Filt = Data4(:,~any(isnan(Data4)))
Treat4Feat = SPIFEE(Treat4Filt,48,5.5)

load 750ump53flourescence.mat
Data5 = p53FlourescentValues 
Data5 = transpose(Data5)
Treat5Filt = Data5(:,~any(isnan(Data5)))
Treat5Feat = SPIFEE(Treat5Filt,48,5.5)


%%
close all
[meany] = temp('Control', CntrlFilt, CntrlFeat, 48, 5.5 )
[mean] = temp('10um',Treat1Filt,Treat1Feat,48,5.5)
[mean2] = temp('100um',Treat2Filt, Treat2Feat, 48, 5.5)
[mean3] = temp('250um',Treat3Filt, Treat3Feat, 48, 5.5)
[mean4] = temp('500um',Treat4Filt, Treat4Feat, 48, 5.5)
[mean5] = temp('750um',Treat5Filt, Treat5Feat, 48, 5.5)
%%
Features = ["Height", "Location", "Width", "Prominence", "Frequency", "Duration", "Integral", "Peak", "Cell", "AvgMax",...
    "AvgMin", "Peak over Basal", "Peaks Per Cell", "Number of Cells with Peaks", "Percent with Peaks"];
Features = transpose(Features)


% t0 = length(CntrlFeat) / length(unique(CntrlFeat(9,:)))
% t1 = length(Treat1Feat) / length(unique(Treat1Feat(9,:)))
% t2 = length(Treat2Feat) / length(unique(Treat2Feat(9,:)))
% t3 = length(Treat3Feat) / length(unique(Treat3Feat(9,:)))
% t4 = length(Treat4Feat) / length(unique(Treat4Feat(9,:)))
% t5 = length(Treat5Feat) / length(unique(Treat5Feat(9,:)))
% 
% meany = vertcat(meany,t0)
% mean = vertcat(meany,t1)
% mean2 = vertcat(meany,t2)
% mean3 = vertcat(meany,t3)
% mean4 = vertcat(meany,t4)
% mean5 = vertcat(meany,t5)


titles = {'Control', '10um', '100um', '250um', '500um', '750um'};
MeanResults = array2table([meany,mean,mean2,mean3,mean4,mean5],'Rownames',Features, 'VariableNames', titles)

writetable(MeanResults, 'TreatmentMeanFeatures.csv')
