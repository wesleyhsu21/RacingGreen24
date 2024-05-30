function data = readCSVConfig(filename)
            % Read the CSV file into a table
            data = readtable(filename, 'ReadVariableNames', false);

            % Iterate through each row of the table and update the properties
            for i = 1:height(data)
                % Extract the row name and value
                rowName = strrep(data.Var1{i}, ' ', '_');  % Replace spaces with underscores

                % Convert the row name to a valid property name
                data.Var1{i} = matlab.lang.makeValidName(rowName);
            end
            return 
        
end