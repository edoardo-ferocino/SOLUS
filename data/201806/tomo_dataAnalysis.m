%% Create a file.mat with the data used for the tomographic reconstruction
%  version @ 11-June-2018
%% Content: 
%           heterogeneous => data(n_time,n_sd,n_lambda);
%           homogeneous   => ref(n_time,n_sd,n_lambda);
%           irf           => irf(n_time,n_lambda);
%           stand. dev.   => sd(n_time,n_sd,n_lambda);
%           Source Position => SOURCE_POS;
%           Det. Position   => DETECTOR_POS;
%           Logic Mask      => dmask(n_detector, n_source);
%=========================================================================
%% Clean workspace
InitScript
addpath('./Dat');
%=========================================================================
%% TCSPC board parameters
gain     = 6;
Nchannel = 4096;
factor   = 50000/gain/Nchannel;
phot_goal = 400000;            %Total photons per curve (goal)
repetitions = 5;               %# of repetitions for each lambda
lambda   = [635, 670, 830, 915, 940, 980, 1030, 1065]; %lambda used
roi = [500 3500];
%% Background removal
background = 1;     %background = 1 => remove the backgorund
                    %background = 0 => no removal
%=========================================================================
%% Repetitions sum

sum_rep = 1;        %sum_rep = 1 => the repetitions are summed
                    %sum_rep = 0 => takes just the first repetition
%=========================================================================
%% Read .DAT files
% Measurement file

N_homo = [473:1:500];  % #homog. measurements
N_hete = [501:1:528];  % #heterog. measurements
meas_homo = [];
meas_hete = [];
B = [];
C = [];

% Homog. measurements
for i = 1:length(N_homo)
    B    = DatRead2(strcat('SOLm0',num2str(N_homo(i))),4096,5,8);
    if sum_rep == 0
        meas_homo(:,i,:) = B(:,1,:);  %takes just the first repetion.
    else
        meas_homo(:,i,:) = squeeze(sum(B,2)); %sums the 5 repetitions
    end
end 

% Heterog. measurements
for i = 1:length(N_hete)
    C    = DatRead2(strcat('SOLm0',num2str(N_hete(i))),4096,5,8);
    if sum_rep == 0
        meas_hete(:,i,:) = C(:,1,:);  %takes just the first repetion.
    else
        meas_hete(:,i,:) = squeeze(sum(C,2)); %sums the 5 repetitions
    end
end

meas_homo = permute(meas_homo,[3 2 1]);  %rearrange of the dimensions
meas_hete = permute(meas_hete,[3 2 1]);

%Irf file
irf = DatRead2('SOLs0100',4096,5,8);  
    if sum_rep == 0 
        irf = squeeze(permute(irf(:,1,:),[3 2 1])); %rearrange of the dimensions
    else
        irf = squeeze(permute(sum(irf,2),[3 2 1]));
    end
% for i = 1: size(irf,2)
%     semilogy(irf(:,i));
%     hold on, grid on
% end
%=========================================================================
%% Subtraction of the background

if background == 0
    
else
    back_start = 450;  %first channel for the background
    back_stop  = 500;  %last channel for the background
    
    back_ref  = mean(meas_homo(back_start:back_stop,:,:));
    back_data = mean(meas_hete(back_start:back_stop,:,:));
    back_irf  = mean(irf(back_start:back_stop,:,:));
    
    meas_homo  = meas_homo  - back_ref;
    meas_homo(meas_homo < 0) = 0;
    meas_hete = meas_hete - back_data;
    meas_hete(meas_hete < 0) = 0;
    irf  = irf  - back_irf;
    irf(irf < 0) = 0;
end

% for i = 1: size(data,2)
%     semilogy(ref(:,i,1));
%     hold on, grid on
% end
%=========================================================================

%% Calculation of the standard deviation
sd = sqrt(meas_hete);
%=========================================================================

%% Create the S-D pos.
% SOURCE_POS = [xs1 ys1 zs1; xs2 ys2 zs2; ... ; xs8 ys8 zs8];
% SOURCE_POS = [xd1 yd1 zd1; xd2 yd2 zd2; ... ; xd8 yd8 zd8];

SOURCE_POS = [1.95 1 0; 0.65 1 0; -0.65 1 0; -1.95 1 0;...
              1.95 -1 0; 0.65 -1 0; -0.65 -1 0; -1.95 -1 0].*10;
DET_POS    = SOURCE_POS;
xs = [19.5 6.5 -6.5 -19.5];
ys = [10 -10];
zs = 0;
%=========================================================================

%% Create the logic mask
% dmask = [s1-d1 s2-d1 ... sn-dn; s1-d2 s2-d2 ... sn-d2 ...]
dmask = ones(size(SOURCE_POS,1),size(DET_POS,1));
dmask = dmask - triu(dmask); % we didn't perform rho = 0 and 1->2 , 2->1

%imagesc(dmask)
%=========================================================================
T.dmask = dmask;
T.sourcepos = SOURCE_POS;
T.detpos = DET_POS;
T.xs = xs;
T.ys = ys;
T.zs = zs;
T.gain = gain;
T.Nchannel = Nchannel;
T.factor = factor;
T.lambda = lambda;
T.roi = roi;
T.bkg.ch_start = back_start;
T.bkg.ch_stop = back_stop;
TomoFolder = 'Tomo structs';
mkdir(TomoFolder);
cd(TomoFolder);
T.path.data_folder = pwd;
for iw=1:numel(T.lambda)
    T.irf.data = irf(:,iw);
    T.irf.t0 = 0;
    T.meas_hete = zeros(T.Nchannel,numel(T.dmask));
    T.meas_homo = zeros(T.Nchannel,numel(T.dmask));
    idm = 1;
    for im = 1:numel(T.dmask(:))
       if T.dmask(im)==1
            T.meas_hete(:,im)=meas_hete(:,idm,iw);
            T.meas_homo(:,im)=meas_homo(:,idm,iw);
            idm = idm +1;
       end
    end
    T.meas_hete = reshape(T.meas_hete,T.Nchannel,8,8);
    T.meas_homo = reshape(T.meas_homo,T.Nchannel,8,8);
    T.path.file_name = ['Tomo_wave_' num2str(T.lambda(iw))];
    save(['Tomo_wave_' num2str(T.lambda(iw))],'T');
end
cd('../')