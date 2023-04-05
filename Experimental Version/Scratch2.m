% Master Script. 
%This particular master script looks at the correlations between p53 peak
%features vs p21 sigmoidal features. This is just one example of the type
%of analysis you can do with SPIFEE

%This is run in several distinct parts. Loading the data set and running
%PeakProcessing, Clustering, graphing

%%Load Data
load Full_Promoter_Dataset.mat

CDKData = raw_measurements(1,:)
MDM2Data = raw_measurements(2,:)
%temp2 = vertcat(temp{:,2})

%This particular data set has 6 treatments (Harton et al)

p53_LowAmp = []
p53_HighFreq = []
p53_LongDuration = []
p53_HighAmp = []
p53_LowFreq = []
p53_Nat =[]

%Probably a faster way of doing this, but this is how I am getting my data
%in the proper format
p53_LowAmp = CDKData{:,1}
p53_LowAmp = transpose(vertcat(p53_LowAmp{:,2}))

p53_HighFreq = CDKData{:,2}
p53_HighFreq = transpose(vertcat(p53_HighFreq{:,2}))

p53_LongDuration = CDKData{:,3}
p53_LongDuration = transpose(vertcat(p53_LongDuration{:,2}))

p53_HighAmp = CDKData{:,4}
p53_HighAmp = transpose(vertcat(p53_HighAmp{:,2}))

p53_LowFreq = CDKData{:,5}
p53_LowFreq = transpose(vertcat(p53_LowFreq{:,2}))

p53_Nat = CDKData{:,6}
p53_Nat = transpose(vertcat(p53_Nat{:,2}))


% Previous Way
% for i =2:56
%     p53_LowAmp = vertcat(p53_LowAmp, p53Data{1,1}{i,2})
% end



%Run the p53 PeakProcessing Script
p53_LowAmpFeat = SPIFEE(p53_LowAmp,24,'Prom')
p53_HighFreqFeat = SPIFEE(p53_HighFreq,24,'Prom')
p53_LongDurationFeat = SPIFEE(p53_LongDuration,24,'Prom')
p53_HighAmpFeat = SPIFEE(p53_HighAmp,24,'Prom')
p53_LowFreqFeat = SPIFEE(p53_LowFreq,24,'Prom')
p53_NatFeat = SPIFEE(p53_Nat,24,'Prom')

%Analysis
Treatments = ["", "LowAmp", "HighFreq", "LongDuration", "HighAmp", "LowFreq", "Nat"]
Features = ["Height", "Location", "Width", "Prominence", "Frequency", "Tramps", "Drops", "Duration", "Integral", "Peak", "Cell", "AvgMax", "AvgMin", "Peak over Basal"]

temp1 = mean(p53_LowAmpFeat,2)
temp2 = mean(p53_HighFreqFeat,2)
temp3 = mean(p53_LongDurationFeat,2)
temp4 = mean(p53_HighAmpFeat,2)
temp5 = mean(p53_LowFreqFeat,2)
temp6 = mean(p53_NatFeat,2)

means = horzcat(transpose(Features),temp1,temp2,temp3,temp4,temp5,temp6)
means = vertcat(Treatments, means)
%%
%Just First Peaks
LowAmp1 = PeakAverages(p53_LowAmpFeat, 'FirstPeaks')
HighFreq1 = PeakAverages(p53_HighFreqFeat, 'FirstPeaks')
LongDuration1 = PeakAverages(p53_LongDurationFeat, 'FirstPeaks')
HighAmp1 = PeakAverages(p53_HighAmpFeat, 'FirstPeaks')
LowFreq1 = PeakAverages(p53_LowFreqFeat, 'FirstPeaks')
Nat1 = PeakAverages(p53_NatFeat, 'FirstPeaks')


FirstPeakMeans = horzcat(transpose(Features), LowAmp1, HighFreq1, LongDuration1, HighAmp1, LowFreq1, Nat1)
FirstPeakMeans = vertcat(Treatments, FirstPeakMeans)

%Biggest peak

% bigLowAmp = p53_LowAmpFeat(:,find(max(p53LowAmpFeat(1,:))
LowAmpBig = PeakAverages(p53_LowAmpFeat, 'Big')
HighFreqBig = PeakAverages(p53_HighFreqFeat, 'Big')
LongDurationBig = PeakAverages(p53_LongDurationFeat, 'Big')
HighAmpBig = PeakAverages(p53_HighAmpFeat, 'Big')
LowFreqBig = PeakAverages(p53_LowFreqFeat, 'Big')
NatBig = PeakAverages(p53_NatFeat, 'Big')

BigPeakMeans = horzcat(transpose(Features), LowAmpBig, HighFreqBig, LongDurationBig, HighAmpBig, LowFreqBig,NatBig)
BigPeakMeans = vertcat(Treatments, BigPeakMeans)

%%
% Clustering and PCA


