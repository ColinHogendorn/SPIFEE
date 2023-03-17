% Master Script. 
%This particular master script looks at the correlations between p53 peak
%features vs p21 sigmoidal features. This is just one example of the type
%of analysis you can do with SPIFEE

%This is run in several distinct parts. Loading the data set and running
%PeakProcessing, Clustering, graphing

%%Load Data
load Full_Promoter_Dataset.mat

CDK = raw_measurements(1,:)
MDM2 = raw_measurements(2,:)

%This particular data set has 2 genes and 6 treatments
CDK_LowAmp = []
P53_LowAmp = []
CDK_HighFreq = []
P53_HighFreq = []
CDK_LongDuration = []
P53_LongDuration = []
CDK_HighAmp = []
P53_HighAmp = []
CDK_LowFreq = []
P53_LowFreq = []
CDK_Nat = []
P53_Nat =[]

%Probably a faster way of doing this, but this is how I am getting my data
%in the proper format
CDK_LowAmp = CDK{1,1}{1,1}
P53_LowAmp = CDK{1,1}{1,1}

for i =2:56
    CDK_LowAmp = vertcat(CDK_LowAmp, CDK{1,1}{i,1})
    P53_LowAmp = vertcat(P53_LowAmp, CDK{1,1}{i,2})
end

CDK_HighFreq = CDK{1,2}{1,1}
P53_HighFreq = CDK{1,2}{1,2}

for i =2:57
    CDK_HighFreq = vertcat(CDK_HighFreq, CDK{1,2}{i,1})
    P53_HighFreq = vertcat(P53_HighFreq, CDK{1,2}{i,2})
end

CDK_LongDuration = CDK{1,3}{1,1}
P53_LongDuration = CDK{1,3}{1,2}

for i =2:51
    CDK_LongDuration = vertcat(CDK_LongDuration, CDK{1,3}{i,1})
    P53_LongDuration = vertcat(P53_LongDuration, CDK{1,3}{i,2})
end

CDK_HighAmp = CDK{1,4}{1,1}
P53_HighAmp = CDK{1,4}{1,2}

for i =2:44
    CDK_HighAmp = vertcat(CDK_HighAmp, CDK{1,4}{i,1})
    P53_HighAmp = vertcat(P53_HighAmp, CDK{1,4}{i,2})
end

CDK_LowFreq = CDK{1,5}{1,1}
P53_LowFreq = CDK{1,5}{1,2}

for i =2:52
    CDK_LowFreq = vertcat(CDK_LowFreq, CDK{1,5}{i,1})
    P53_LowFreq = vertcat(P53_LowFreq, CDK{1,5}{i,2})
end

CDK_Nat = CDK{1,6}{1,1}
P53_Nat = CDK{1,6}{1,2}

for i =2:51
    CDK_Nat = vertcat(CDK_Nat, CDK{1,6}{i,1})
    P53_Nat = vertcat(P53_Nat, CDK{1,6}{i,2})
end

% CDK_LowAmp = transpose(CDK_LowAmp)
P53_LowAmp = transpose(P53_LowAmp)
% CDK_HighFreq = transpose(CDK_HighFreq)
P53_HighFreq = transpose(P53_HighFreq)
% CDK_LongDuration = transpose(CDK_LongDuration)
P53_LongDuration = transpose(P53_LongDuration)
% CDK_HighAmp = transpose(CDK_HighAmp)
P53_HighAmp = transpose(P53_HighAmp)
% CDK_LowFreq = transpose(CDK_LowFreq)
P53_LowFreq = transpose(P53_LowFreq)
% CDK_Nat = transpose(CDK_Nat)
P53_Nat = transpose(P53_Nat)


%Run the p53 PeakProcessing Script
P53_LowAmpFeat = SPIFEE(P53_LowAmp,24,'Prom')
% P53_HighFreqFeat = PeakProcessing2(P53_HighFreq,73,24,57,"p53")
