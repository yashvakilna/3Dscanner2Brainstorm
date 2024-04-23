function elec = projection_electrodeplacement(hs, numberOfPoints)

% PROJECTION_ELECTRODEPLACEMENT allows manual localization of electrodes on
% a projected surface of a 3D surface mesh. Assign an electrode location by
% clicking on the surface.
%
% INPUT:
%   - hs:   Is a structure that encapsulated the projection surface patch
%           figure, the original 3D surface mesh vertex coordinates and their
%           corresponding 2D positions on the projection surface.
%   - numberOfPoints:   Is the number of points the user is interested in 
%                       localizing from the projection surface.

%% Initialize output elec structure
elec = struct( ...
    'unit', 'mm', ...
    'coordsys', 'ctf', ...
    'label', [], ...
    'elecpos', [], ...
    'chanpos', [], ...
    'tra', [], ...
    'cfg', struct([]));

%% Give the user instructions

disp('Zoom in towards the desired electrode.');
disp('Exit zoom by pressing any key.');
disp('Use the mouse to click on the desired position for the electrode');

%% Localize the electrodes on the flattened head_surface projection.

coordinates = [];
numberOfLocalizedElectrodes = 1;
% Collect the specified number of points from the projected surface.
while (size(coordinates,1) < numberOfPoints)
    % Enable zoom functionality till a key is pressed.
    zoom on;
    pause();
    zoom off;
    % Request coordinate input from user via ginput selection.
    [x,y] = ginput(1);
    coordinates = cat(1, coordinates, [x,y]);
    zoom out;
    % Tell to user the number of electrodes now assigned by the user.
    fprintf("You labeled %d electrodes.\n", numberOfLocalizedElectrodes);
    numberOfLocalizedElectrodes = numberOfLocalizedElectrodes + 1;
end
close gcf;

%% Convert the 2D Coordinates to their cooresponding 3D Coordinates

originalCart3D = hs.originalCart3D;
originalCart2D = hs.originalCart2D;
% Find the 3D vertex positions of the original mesh surface that are
% closest to the corresponding points derived from the 2D surface
% positions.
k = dsearchn(originalCart2D, coordinates);
elec.elecpos = originalCart3D(k, :);
elec.chanpos = elec.elecpos;

return