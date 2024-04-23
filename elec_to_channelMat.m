function channelMat = elec_to_channelMat(elec, capSize)

% ELEC_TO_CHANNELMAT: Converts electrode data contained within an elec 
% structure (FieldTrip) into a Brainstorm ChannelMat structure.
% 
% INPUT:
%   - elec : FieldTrip structure containing electrode positional data and 
%            labels.

% NOTES:
%   Order of localization should be the following...
%       1.  EEG electrodes (32, 64, 128, 256)
%       2.  Fiducials (NPA, LPA, RPA)
%       3.  HPIs (Must be exactly five HPIs).
%       4.  EXTRAs
%   
%   Possible schemes...
%       1. EEG electrodes
%       2. EEG electrodes + Fiducials
%       3. EEG electrodes + Fiducials + HIPs
%       4. EEG electrodes + Fiducials + HIPs + EXTRAs
%
%   Supported cap layout templates:
%       1. 32:  EEG Cap 32 channels based on CA-065 identical CW-0434,
%               10/20
%               (Code: CW-3484)
%       2. 64:  EEG cap, 64 ch, identical to CW-0435, 10/10
%               (Code: CW-3485)
%       3. 128: waveguard original cap, 128 channels with 5 HPI coil
%               openings, 10/5, unshielded, Redel connector 
%               (Code: CA-069.s1)
%       4. 256: EEG dry cap, 256 channels, shielded, equidistant, Tyco68
%               (Code: CY-281.s1)
%
%   Failure to localize the exact number of fiducials and HPIs will lead to
%   incorrect labeling in the resulting channelMat structure.

% DEVELOPER NOTE:
%   Added some variables (numberOfFiducials, numberOfHIPs) and conditional
%   statements incase further development is needed for varying fiducial 
%   and HIP recordings. 

numberOfFiducials = 3;
numberOfHIPs = 5;

%% Initialize ChannelMat

channelMat = struct(...
            'Comment',    'Channels', ...
            'MegRefCoef', [], ...   % CTF compensators matrix, [nMeg x nMegRef]
            'Projector',  [], ...   % SSP matrix, [nChannels x nChannels]
            'TransfMeg',  [], ...   % MEG sensors: Successive transforms from device coord. system to brainstorm SCS
            'TransfMegLabels', [], ... % Labels for each MEG transformation
            'TransfEeg',  [], ...   % EEG sensors: Successive transforms from device coord. system to brainstorm SCS
            'TransfEegLabels', [], ... % Labels for each EEG transformation
            'HeadPoints', struct(...% Digitized head points 
                'Loc',    [], ...
                'Label',  [], ...
                'Type',   []), ...
            'Channel',    [], ...  % [nChannels] Structure array, one structure per sensor
            'IntraElectrodes', [], ...
            'History',     [], ...
            'SCS' , struct(...
                'NAS',    [], ...
                'LPA',    [], ...
                'RPA',    [], ...
                'R',      [], ...
                'T',      [] ));
          
%% Read elec structure cap specification (naming convention)

% Determine the cap size configuration of the data.
switch capSize
    case 32
        channelMat.Comment = 'ANT Waveguard 32 10/20';
        antCap = load("cap_specifications\ant_32_cap.mat");
        antCap = antCap.ant_32_cap;
    case 64
        channelMat.Comment = 'ANT Waveguard 64 10/10';
        antCap = load("cap_specifications\ant_64_cap.mat");
        antCap = antCap.ant_64_cap;

        %channelMat.Comment = 'Isotrak Positions';
        %antCap = load("cap_specifications\fif_64_mapping.mat");
        %antCap = antCap.temp_fif_mapping;
    case 128
        channelMat.Comment = 'ANT Waveguard 128 Non-Equi. 10/5';
        antCap = load("cap_specifications\ant_128_cap.mat");
        antCap = antCap.ant_128_cap;
    case 256
        channelMat.Comment = 'ANT Waveguard 256 Equi.';
        antCap = load("cap_specifications\ant_256_cap.mat");
        antCap = antCap.ant_256_cap;
    otherwise
        error("No available template for the cap size of %d.\n", capSize);
end

%% Populate channelMat's Channel field with electrode data

elecCoordinates = elec.elecpos;
% Populate channelMat's Channel field for electrodes
for channelIdx = 1:capSize
    currentStruct = struct( ...
        'Name', '', ...
        'Type', 'EEG', ...
        'Loc', zeros(3,1), ...
        'Orient', [], ...
        'Comment', '', ...
        'Weight', 1);
    currentStruct.Name = char(antCap(channelIdx));
    % Write into the Loc field of the current
    currentStruct.Loc(:,1) = reshape(elecCoordinates(channelIdx,:), 3, 1) ./1000;

    %currentStruct.Loc(:,1) = reshape(elecCoordinates(channelIdx,:), 3, 1) ./100;

    channelMat.Channel = [channelMat.Channel, currentStruct];
end

% Update globalIdx when done with electrodes
globalIdx = capSize;

%% Populate channelMat's HeadPoint field with fiducial data: NAS, LPA, RPA

% Determine if the user recorded the placement of the fiducials
if (length(elec.elecpos) >= (globalIdx + numberOfFiducials)) && (numberOfFiducials == 3)
    % Store the data for the NAS fiducial
    channelMat.HeadPoints.Loc(:,1) = reshape(elecCoordinates(globalIdx + 1,:), 3, 1) ./1000;
    channelMat.HeadPoints.Label{1,1} = 'Nasion';
    channelMat.HeadPoints.Type{1,1} = 'CARDINAL';
    % Store the data for the LPA fiducial
    channelMat.HeadPoints.Loc(:,2) = reshape(elecCoordinates(globalIdx + 2,:), 3, 1) ./1000;
    channelMat.HeadPoints.Label{1,2} = 'LPA';
    channelMat.HeadPoints.Type{1,2} = 'CARDINAL';
    % Store the data for the RPA fiducial
    channelMat.HeadPoints.Loc(:,3) = reshape(elecCoordinates(globalIdx + 3,:), 3, 1) ./1000;
    channelMat.HeadPoints.Label{1,3} = 'RPA';
    channelMat.HeadPoints.Type{1,3} = 'CARDINAL';
end

% Update globalIdx when done with fiducials
globalIdx = globalIdx + numberOfFiducials;

%% Populate channelMat's HeadPoint field with HPI data (There should be five.)

% Determine if the user recorded the placement of the HPIs
if length(elec.elecpos) >= (globalIdx + numberOfHIPs)
    for num = 1:numberOfHIPs
        headPointsIdx = numberOfFiducials + num;
        channelMat.HeadPoints.Loc(:,headPointsIdx) = reshape(elecCoordinates(globalIdx + num,:), 3, 1) ./1000;
        channelMat.HeadPoints.Label{1,headPointsIdx} = 'HPI';
        channelMat.HeadPoints.Type{1,headPointsIdx} = 'HPI';
    end
end

% Update globalIdx when done with HPIs
globalIdx = globalIdx + numberOfHIPs;

%% Populate channelMat's HeadPoint field with EXTRA data

% Determine if the user recorded the placement of EXTRAs
if length(elec.elecpos) > globalIdx
    for num = 1:(length(elec.elecpos)-globalIdx)
        headPointsIdx = numberOfFiducials + numberOfHIPs + num;
        channelMat.HeadPoints.Loc(:,headPointsIdx) = reshape(elecCoordinates(globalIdx + num,:), 3, 1) ./1000;
        channelMat.HeadPoints.Label{1,headPointsIdx} = 'EXTRA';
        channelMat.HeadPoints.Type{1,headPointsIdx} = 'EXTRA';
    end
end

return


