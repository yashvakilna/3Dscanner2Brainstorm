function hs = mesh_project_2d(head_surface)

% MESH_PROJECT_2D visualizes a 3D surface mesh - described by triangles and
% consist of a structure with the fields "pos", "tri", and "color" - as a
% 2D surface.
%
% INPUT:
%   - head_surface: Structure of the head surface.

pos = head_surface.pos;
tri = head_surface.tri;
color = head_surface.color;

%% Remove nonessential vertices from the 3D surface mesh.

% Identify vertices to remove from the surface mesh.
[TH,PHI,R] = cart2sph(pos(:,1), pos(:,2), pos(:,3));
R2 = 1 - PHI ./ pi*2;
t = (R2 > 1.1);

% Remove the identified vertices from the surface mesh.
remove = (1:length(t));
remove = remove(t);
if ~isempty(remove)
    [pos, tri] = remove_vertices(pos, tri, remove);
    color(remove, :) = [];
end
% Update hs structure with the remaining vertices.
hs.originalCart3D = pos;

%% Project the surface mesh as a 2D surface.

% Derive the 2D projection coordinates of the surface mesh.
[TH,PHI,R] = cart2sph(pos(:,1), pos(:,2), pos(:,3));
R2 = 1 - PHI ./ pi*2;
[X,Y] = pol2cart(TH,R2);
v = cat(2, X, Y);
f = tri;
% Update hs structure with these derived projection coordinates.
hs.originalCart2D = [X, Y];

% Generate a figure that displays the 2D projection of the surface mesh.
figure;
hs.figure = patch('Vertices', v, 'Faces', f);
set(hs.figure, 'FaceVertexCData', color, 'FaceColor', 'interp');
set(hs.figure, 'EdgeColor', 'none');
axis equal

return