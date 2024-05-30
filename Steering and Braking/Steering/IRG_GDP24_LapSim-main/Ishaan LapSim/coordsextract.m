% Load the GeoJSON data into a MATLAB structure
data = jsondecode(fileread('export.geojson'));

% Extract the latitude and longitude coordinates from the nodes in the way
latitudes = [];
longitudes = [];
for i = 1:numel(data.features)
    if strcmp(data.features(i).geometry.type, 'Point')
        latitudes(end+1) = data.features(i).geometry.coordinates(2);
        longitudes(end+1) = data.features(i).geometry.coordinates(1);
    end
end


% Plot the coordinates as a line
scatter(longitudes, latitudes);
