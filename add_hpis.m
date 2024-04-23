function channelMat = add_hpis(hpi, channelMat)

% ADD_HPIS: Adds HPIs to the Brainstorm channelMat structure.
%
% INPUT:
%  - hpi:   HPI matrix. The row index coorsponding to that specific HPI
%           coil.
%   - channelMat:   Brainstorm EEG position structure.

channelMat.HeadPoints.Loc = cat(2, channelMat.HeadPoints.Loc, hpi.elecpos.'./1000);
for idx = 1:5
    name = 'HPI';
    num = convertStringsToChars(int2str(idx));
    name = [name, '-', num];
    channelMat.HeadPoints.Label = [channelMat.HeadPoints.Label, {name}];
    channelMat.HeadPoints.Type = [channelMat.HeadPoints.Type, {'HPI'}];
end
