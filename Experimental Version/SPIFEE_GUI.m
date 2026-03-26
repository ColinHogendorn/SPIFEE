function SPIFEE_GUI()
%SPIFEE GUI 

fig = uifigure;
fig.Name = "SPIFEE";

% 
% gl = uigridlayout(fig,[2 2]);
% gl.RowHeight = {30,'1x'};
% gl.ColumnWidth = {'fit','1x'};
% 
% 
% lbl = uilabel(gl);
% dd = uidropdown(gl);
% ax = uiaxes(gl);
tg = uitabgroup(fig,'Position',[0 0 400 400]);
f = uitab(tg,'Title','Filtering');
A = uitab(tg,'Title','Analysis');
cbx = uicheckbox(f,"Text","Fill in Na Values");
b = uibutton(f,'Position',[11 40 140 22],'Text','Run');

cbx.ValueChangedFcn = @(src,event) checkBoxChanged(src,event);

end


function checkBoxChanged(src,event,lgd)
val = event.Value;
vals = SPIFEE

end
