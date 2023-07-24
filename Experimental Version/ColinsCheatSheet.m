%%Colin's MATLAB coding cheat sheet
%Functions, indexing, and plotting bits of code I use often and find
%useful. This is not an all encompassing guide to coding in MATLAB.

%A more comprehensive guide: https://sites.nd.edu/gfu/files/2019/07/cheatsheet.pdf

%Sample data

x = linspace(1,5,5) %Creates 5 points from 1 - 5
y = [2,8,4,3,6] %1x5 Row vector of values 

% y = [2; 8; 4; 3; 6;] 1x5 Column Vector of values

%% Plotting

fig1 = plot(x,y) %Basic Line Plot
set(fig1, 'LineWidth', 2) %Change Width of lines

set(fig1, 'Marker', '.' ) %Change what the the points are plotted as
%Sample markers +, *, x, o, square

set(fig1,'color','red') %Change color
%Sample colors: Red 'r', Blue 'b', Green 'g', Yellow 'y', Black 'k'

figure(j) %graphics object j
figure %New Figure window
get(j) %returns information about j

%subplot(a,b,c) %Multiple figures in same plot

xlabel('Name', 'FontSize', 10) %Names x axis and denotes fontsize. samething for y but 'ylabel'
title('Name', 'FontSize', 12) %Title
grid('on') %Turns grid on. say off for off
hold on %Keep current data on figure so you can add new stuff

%%Random

num2str(x) %Converts number x to string

length(x) 
find(x)
any(x)

