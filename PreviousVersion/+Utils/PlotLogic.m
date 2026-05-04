function PlotLogic(selection, name, Fig)
    if isstring(name)
        name = convertStringsToChars(name);
    end

    if numel(selection) > 1
    % MULTIPLE CHOICES
    if ismember(1,selection)
        saveas(Fig, (fname +'.svg'));
    end
    if ismember(2,selection)
        drawnow
        savefig(Fig,fname +'.fig');
    end
    if ismember(3,selection)
        saveas(Fig,(fname +'.png'));
    end

    else
        % SINGLE CHOICE
        if selection == 1
            saveas(Fig,[name '.svg']);
        elseif selection == 2
            drawnow
            savefig(Fig,[name '.fig']);
        elseif selection == 3
            saveas(Fig,[name '.png']);
        elseif selection == 4 %IF NONE Selected
        end
    end


end


