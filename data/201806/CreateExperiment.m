%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a structure EXP containing all data of the experiment
% This structure is loaded in the reconstruction script
% Andrea Farina (CNR-Polimi)
% October 2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

InitScript
addpath('../../src/experimental/');
addpath('./Tomo structs/');
lambda   = [635, 670, 830, 915, 940, 980, 1030, 1065]; %lambda used
for iw = 1:numel(lambda)
EXP_file = strcat('Tomo_wave_',num2str(lambda(iw)));
load(EXP_file)
% =========================================================================
%%                                Path
% =========================================================================
%EXP.path.data_folder = '/media/psf/Home/Documents/Politecnico/Work/Data/Compressive Imaging/';
%EXP.path.data_folder = '/Users/andreafarina/Documents/Politecnico/Work/Data/Compressive Imaging/';
output_folder = './';
output_suffix = '';%'_sum100';
% =========================================================================
%%                      Measurement info
% =========================================================================
% Measurement folder and name
EXP.path.day = '201807';
EXP.path.data_folder = T.path.data_folder;%['../../results/201710/dynamic phantom'];

EXP.path.file_name = T.path.file_name;
% Time resolved windows
EXP.spc.gain = T.gain;
EXP.spc.n_chan = T.Nchannel;
EXP.spc.factor = 50e3/T.Nchannel/T.gain;
%EXP.time.roi = [500,1500];
EXP.time.roi = T.roi;  % just for info
EXP.bkg.ch_start = T.bkg.ch_start;
EXP.bkg.ch_end = T.bkg.ch_stop;
% % time windows
%  a = 1:2001;
%  b = a + 0;
%  twin1 = [a', b'];
%  twin = twin1;
% EXP.time.twin = twin;
% irf file
EXP.path.irf_file = 'IRF.mat';
% irf shift
EXP.irf.t0 = T.irf.t0; %40;%-15;%-30;   % ps
% sum repetitions

% =========================================================================
%%                         Pre-process SPC and CCD
% =========================================================================
[homo,hete,t,EXP.irf] = PreProcessing_SPC(EXP);

% =========================================================================
%%                         Determine size of data
% =========================================================================
spc_size = size(hete);
ref_size = size(homo);


% =========================================================================
%%                            Save forward data
% =========================================================================
EXP.data.spc = int32(reshape(hete,size(hete,1),[]));
EXP.data.ref = int32(reshape(homo,size(homo,1),[]));
EXP.time.axis = t;
EXP.grid.dmask = T.dmask;
EXP.grid.xs = T.xs;
EXP.grid.ys = T.ys;
EXP.grid.zs = T.zs;
EXP.grid.SourcePos = T.sourcepos;
EXP.grid.DetPos = T.detpos;
mkdir(fullfile(pwd,'EXP structs'))
str_file = [fullfile(pwd,'EXP structs'),filesep,...
    'EXP_',EXP_file,output_suffix];
save(str_file,'EXP');
end
