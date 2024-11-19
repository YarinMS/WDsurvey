% Initialize an empty array to store selected rows
%selectedRows = [];

% Loop through the specified range
for It = 4276:4400
    % Plot the current row with plotNvis = 10
    exampleRow = sortedFilteredTable(It, :);
    figure();
    plotDBrow(exampleRow, 'plotNvis', 3);
    title(sprintf('Row %i ; Pwd = %.4f', It, exampleRow.P_wd));
    
    % Ask the user if they want to store this row
    choice = input('Store this row? (y/n, or "q" to quit): ', 's');
    
    if strcmpi(choice, 'y')
        % Store the row index if the user wants to keep it
        selectedRows = [selectedRows; It]; %#ok<AGROW>
        
        % Plot again with plotNvis = 20 for a more detailed view
        figure(); 
        plotDBrow(exampleRow, 'plotNvis', 10);
        title(sprintf('10 Vis, Row %i ; Pwd = %.4f', It, exampleRow.P_wd));
    elseif strcmpi(choice, 'q')
        % Break the loop if the user wants to quit
        disp('Exiting the loop.');
        break;

    elseif strcmpi(choice, 'n')
        % Break the loop if the user wants to quit
        close(gcf);
    end
    
    % Close the original plot to avoid clutter (keep the detailed plot open if it was shown)
    
end

% Display the selected rows after the loop ends
disp('Selected rows:');
disp(selectedRows);

% Save selected rows into a new table for further analysis
selectedTable = sortedFilteredTable(selectedRows, :);
