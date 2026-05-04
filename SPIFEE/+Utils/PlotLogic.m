%Handles the various figure output file type for each of the figures plotted.

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


