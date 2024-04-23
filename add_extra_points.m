function channelMat = add_extra_points(bs_head_surface, channelMat);

% ADD_EXTRA_POINTS: Adds additional HeadPoints to the Brainstorm channelMat
% structure from the decimated Brainstorm head surface. Adds them as
% 'EXTRA' points.
%
% INPUT:
%   - bs_head_surface:  Brainstorm head surface structure exported to
%                       MATLAB that only includes vertices after 'less 
%                       vertices' decimation of the head surface. All the
%                       vertices will be 'EXTRA' points in channelMat.
%   - channelMat:       Brainstorm EEG position structure.

extraPoints = bs_head_surface.Vertices;
remove = extraPoints(:,3) < 0;
extraPoints(remove, :) = [];

channelMat.HeadPoints.Loc = cat(2, channelMat.HeadPoints.Loc, extraPoints.');
for idx = 1:length(extraPoints)
    channelMat.HeadPoints.Label = [channelMat.HeadPoints.Label, {'EXTRA'}];
    channelMat.HeadPoints.Type = [channelMat.HeadPoints.Type, {'EXTRA'}];
end

return