load mChe-Geminin_dataset_high_frequency_expt.mat


% 
cells = raw_measurements_geminin{1,1}

GemData = cells(:,1)
p53Data = cells(:,2)

% 
% %This particular data set has 6 treatments (Harton et al)

p53_HighFreq = []

%Probably a faster way of doing this, but this is how I am getting my data
%in the proper format

Gem_HighFreq = transpose(vertcat(GemData{:,1}))
p53_HighFreq = transpose(vertcat(p53Data{:,1}))




%%
%Derivative Graphs 2 axis MDM2
% figure()
% filtGem = smoothdata(Gem_HighFreq, 'gaussian', 10 )
% Derivs = diff(filtGem)
% Derivs2 = diff(Derivs)
% num = 3
% 
% yyaxis left
% plot(filtGem(:,num), 'LineWidth', 2)
% ylabel("Geminin - mCherry (AU)")
% xticks([8,16,24,32,40] * 3.041666667)
% xticklabels({'8','16','24','32','40'})
% 
% 
% hold on
% yyaxis right
% plot(Derivs(:,num), 'LineWidth', 2)
% 
% legend('SmoothedSignal','FirstDerivative')
% xlabel("Time (Hours)")
% ylabel("Geminin - mCherry (AU) dt")
% title("Smoothed Geminin Expression vs First Derivative")
% axis = gca
% ax.FontSize = 30

%%
% Geminin Landscape

% filtGem = smoothdata(Gem_HighFreq, 'gaussian', 10 )
% plot(filtGem(:,2), 'LineWidth', 4)
% hold on
% plot(filtGem(:,5), 'LineWidth', 4)
% plot(filtGem(:,7), 'LineWidth',4)
% plot(filtGem(:,11), 'LineWidth',4)
% plot(filtGem(:,16), 'LineWidth',4)
% plot(filtGem(:,22), 'LineWidth',4)
% title("Sample Geminin Traces", 'FontSize', 12)
% xlabel("Time (Hours)")
% ylabel("Geminin - mCherry (AU)")
% xticks([8,16,24,32,40] * 3.041666667)
% xticklabels({'8','16','24','32','40'})

% avgTrace = mean(filtGem,2)
% plot(avgTrace, 'LineWidth', 4, 'Color', 'r')

%%
%Single
% plot(filtGem)
% avgTrace = mean(filtGem,2)
% hold on
% 
% plot(avgTrace, 'LineWidth', 4, 'Color', 'r')
% axis off

