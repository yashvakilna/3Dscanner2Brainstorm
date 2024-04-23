clc
clear
close

% Adds path to Fieldtrip and load default set of functions:
addpath('C:\Users\mcarrascogomez\Desktop\fieldtrip-20221018');
ft_defaults

% Loads head surface from Revopoint mesh obj:
filepath = 'Y:\Shed\RevoPoint-Samples\stimCap\OBJ\model-2022-10-19-15-45-47_mesh_tex_fixed.obj';
head_surface = import_obj(filepath, 'meshed');

% Convert units to mm.
head_surface = ft_convert_units(head_surface, 'mm');

% Visualize the head surface
ft_plot_mesh(head_surface)

% Transform mesh to CTF coordinates
cfg = [];
cfg.method = 'headshape';
fiducials = ft_electrodeplacement(cfg, head_surface);

% Prompt: "Do you want to change the anatomical labels for the axes [Y, n]?"
% Prompt Response: n

% Localization Procedure of the Fiducials
%   1. Enable rotate/zoom.
%   2. Rotate/zoom the 3D mesh.
%   3. Disable rotate/zoom.
%   4. Select the anatomical landmark.
%   5. Select the fiducial label.
%       a. "1" for the first fiducial. (NPA)
%       b. "2" for the second fiducial. (LPA)
%       c. "3" for the third fiducial. (RPA)
%   6. Repeat
%   7. When complete, press 'q'.

cfg = [];
cfg.method        = 'fiducial';
cfg.coordsys      = 'ctf';
cfg.fiducial.nas  = fiducials.elecpos(1,:); %position of NAS
cfg.fiducial.lpa  = fiducials.elecpos(2,:); %position of LPA
cfg.fiducial.rpa  = fiducials.elecpos(3,:); %position of RPA
head_surface = ft_meshrealign(cfg, head_surface);

% Visualize realigned head surface
ft_plot_axes(head_surface)
ft_plot_mesh(head_surface)

% Displays channel layout of supported 32ch
[image, cmap] = imread('channel_layouts\waveguard_layout_StarStim32.png');
set(gcf, 'Visible', 'on');
imshow(image, cmap);

% Locate electrode positions
cfg = [];
cfg.method = 'headshape';
elec = ft_electrodeplacement(cfg, head_surface);
elec.label = {'Fp1', 'Fp2', 'AF3', 'AF4', 'F7', 'F3', 'Fz', 'F4', 'F8', ...
       'FC5', 'FC1', 'FC2', 'FC6', 'T7', 'C3', 'Cz', 'C4', 'T8', 'CP5', ...
       'CP1', 'CP2', 'CP6', 'P7', 'P3', 'Pz', 'P4', 'P8', 'PO3', 'PO4', ...
       'O1', 'Oz', 'O2'};

% Localization Procedure of the Electrode Channels
%   1. Enable rotate/zoom.
%   2. Rotate/zoom the 3D mesh.
%   3. Disable rotate/zoom.
%   4. Select the electrode channel landmark.
%   5. Select the electrode label.
%       a. Follow cap layout template ordering.
%   6. Repeat
%   7. When complete, press 'q'.

%   Supported cap layout templates: Cap Layout Template Files (Relavtive
%   Path: 'cap_specifications\...')
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
%       5. 256: StarStim32, 32 channels, all contained in 10/10 system

% Visualization of head surface with electrode locations

close all
ft_plot_mesh(head_surface)
ft_plot_sens(elec)
