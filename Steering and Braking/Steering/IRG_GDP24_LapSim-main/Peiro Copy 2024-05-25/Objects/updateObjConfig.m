function obj = updateObjConfig(obj, filename)
            % Read the CSV file into a table
            data = readCSVConfig(filename);

            % Iterate through each row of the table and update the properties
            for i = 1:height(data)
                % Extract the row name and value
                value = data.Var2(i);

                % Convert the row name to a valid property name
                rowName = data.Var1{i};

                % Dynamically add or update the property in the object
                if rowName=="CLA"||rowName=="CDA"
                    s = size(obj.(rowName),3);
                    t = size(obj.(rowName),2);
                    obj.(rowName)(end+1,:,:)  =value.*ones(1,t,s);
                else
                    obj.(rowName) = value;
                end
                    
            end
            
            % Update the track property if trackF and trackR are present
                obj.track = (obj.trackF + obj.trackR) / 2;
        end