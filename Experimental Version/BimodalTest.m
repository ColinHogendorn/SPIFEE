load Full_Promoter_Dataset.mat

%%
%Bring in Data

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

%% 

% rawSignalsPeaks = SPIFEE(p53_LowAmp,24,'Prom')
% rawParamPeaks = SPIFEE(p53_LowAmp,24,'Prom')
% FilteredPeaks = SPIFEE(p53_LowAmp,24,'Prom')
FilteredParamPeaks = SPIFEE(p53_LowAmp,24,'Prom')

bins = linspace(0,1000,100)
histogram(FilteredParamPeaks(1,:), bins)

