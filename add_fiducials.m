function channelMat = add_fiducials(fid, channelMat);

% ADD_FIDUCIALS: Adds fiducials to the Brainstorm channelMat structure.
%
% INPUT:
%  - fid:   Fiducials 3x3 matrix:
%               - 1st Row:  3D position of NAS.
%               - 2nd Row:  3D position of LPA.
%               - 3rd Row:  3D position of RPA.
%   - channelMat:   Brainstorm EEG position structure.

channelMat.HeadPoints.Loc = cat(2, channelMat.HeadPoints.Loc, fid.elecpos.'./1000);
channelMat.HeadPoints.Label = [channelMat.HeadPoints.Label, {'Nasion'}, {'LPA'}, {'RPA'}];
channelMat.HeadPoints.Type = [channelMat.HeadPoints.Type, {'CARDINAL'}, {'CARDINAL'}, {'CARDINAL'}];

return