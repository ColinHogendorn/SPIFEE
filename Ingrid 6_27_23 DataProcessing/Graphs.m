load Full_Promoter_Dataset.mat

%Bring in Data

CDKData = raw_measurements(1,:)
GemininData = raw_measurements(2,:)
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
LAmpData1 = CDKData{:,1}
p53_LowAmp = transpose(vertcat(LAmpData1{:,2}))
CDK_LowAmp = transpose(vertcat(LAmpData1{:,1}))
LAmpData2 = GemininData{:,1}
LAmpGemmy = transpose(vertcat(LAmpData2{:,1}))
LAmpP53 = transpose(vertcat(LAmpData2{:,2}))

p53_HighFreq = CDKData{:,2}
p53_HighFreq1 = transpose(vertcat(p53_HighFreq{:,2}))
CDK_HighFreq = transpose(vertcat(p53_HighFreq{:,1}))




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
HighFeat = SPIFEE(p53_HighAmp,24,'Prom')
%FilteredPeaks = SPIFEE(p53_LowAmp,24,'Prom')
% FilteredParamPeaks = SPIFEE(p53_LowAmp,24,'Prom')

%%
% bins = linspace(0,300,100)
% 
% histogram(rawParamPeaks(4,:), bins)
% set(gca, 'fontsize',16)
% xlabel("Prominence", fontsize = 20)
% ylabel("Number of peaks", fontsize = 20)
% title({"Distribution of Prominence Feature from Raw Signals"; "" },fontsize = 20)


%%
%Making Flowchart
% Data = p53_HighAmp(:,12)
% 
% Smoothed = smoothdata(Data,'gaussian', 5.5764)
% [pks,locs,w,p] = findpeaks(Smoothed, 'Annotate', 'extents')
% 
% 
% plot(Smoothed, 'color', 'b')
% plot(Smoothed, 'LineWidth', 4)
% hold on
% plot(locs,pks,  'o', 'LineWidth', 7)
% figure()


%%
%Averages for Geminindata
% avgTrace = mean(LAmpGemmy,2)
% smoothed = smoothdata(LAmpGemmy, 'gaussian', 5)
% plot(smoothed)
% hold on
% plot(avgTrace, 'LineWidth', 4, 'color', 'b')
% xlabel("Time (24Hours)")
% ylabel("Geminin - mCherry (AU)")
% title("Geminin Expression p53 Low Amplitude Treatment")
% axis = gca
% ax.FontSize = 18

%%
%Derivative Graphs 2 axis
% figure()
% filtGem = smoothdata(LAmpGemmy, 'gaussian', 10 )
% Derivs = diff(filtGem)
% Derivs2 = diff(Derivs)
% num = 12
% 
% yyaxis left
% plot(filtGem(:,num), 'LineWidth', 2)
% ylabel("Geminin - mCherry (AU)")
% xticks([4,8,12,16,20,24] * 3.041666667)
% xticklabels({'4','8','12','16','20','24'})
% 
% 
% hold on
% yyaxis right
% plot(Derivs(:,num), 'LineWidth', 2)
% 
% legend('SmoothedSignal','FirstDerivative')
% xlabel("Time (Hours)")
% ylabel("Geminin - mCherry (AU)")
% title("Smoothed Geminin Expression vs First Derivative")
% axis = gca
% ax.FontSize = 30

%%
% % CDK Graphs
% filtCDK = smoothdata(CDK_LowAmp, 'gaussian', 10)
% plot(filtCDK)
% hold on
% avgTrace = mean(filtCDK,2)
% plot(avgTrace, 'LineWidth', 4, 'color', 'b')

%%
% Fourier Transforms
L = 73
Y = fft(LAmpP53(:,1))
Fs = 10

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;

plot(f,P1)

Y2 = smoothdata(LAmpP53(:,1), "gaussian", 5)
P2 = abs(Y2/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;

hold on
plot(f,P1)
