% PlotLogic
% ------------------------------------------------------------
%  Handles saving figure outputs based on user-selected formats
%  Supports single or multiple output types
%  Formats:
%     1 - .svg
%     2 - .fig
%     3 - .png
%     4 - none (skip saving)
%  Uses params to determine output selection and folder
%
% Input:
%  params - processing parameters
%  name - name of condition
%  Fig - figure handle to save
%
% Output:
%  none

function PlotLogic(params, name, Fig)
    selection = params.Output;
    Folder = params.Folder;
    if isstring(name)
        name = convertStringsToChars(name);
    end

    if numel(selection) > 1
    % MULTIPLE CHOICES
    if ismember(1,selection)
        saveas(Fig, fullfile(Folder, [name +'.svg']));
    end
    if ismember(2,selection)
        drawnow
        saveas(Fig, fullfile(Folder, [name +'.fig']));
    end
    if ismember(3,selection)
        saveas(Fig, fullfile(Folder, [name +'.png']));
    end

    else
        % SINGLE CHOICE
        if selection == 1
            saveas(Fig, fullfile(Folder, [name +'.svg']));
        elseif selection == 2
            drawnow
            saveas(Fig, fullfile(Folder, [name +'.fig']));
        elseif selection == 3
            saveas(Fig, fullfile(Folder, [name +'.png']));
        elseif selection == 4 %IF NONE Selected
        end
    end


end


