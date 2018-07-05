%==========================================================================
%%                      RECONSTRUCTION DOMAIN: CW or TD
%==========================================================================
REC.domain = 'td';          % CW or TD: data type to be inverted
REC.type_fwd = 'linear';    % 'linear' or 'fem'.
% -------------------------------------------------------------------------
REC.time.roi = [264  922];% ROI in time-step unit. If omitted, the ROI will be 
                        % selected dinamically by the user.
NUM_TW = 10;            % Number of Time Windows within ROI
% =========================================================================
%%                        Initial parameter estimates 
% =========================================================================
% In this section all the parameter for the inverse solver are setted.
% --------------------------- Optical properties --------------------------
REC.solver.variables = {'mua'}; % variables mua,mus.
%edo
REC.opt.mua0 = [0.038517856    0.018542158    0.013310352    0.10426413    0.076341175    0.037790618    0.077246618    0.051126001]./10;
REC.opt.musp0 = [14.02351381    12.96894155    9.890654679    9.01713981    8.651220881    8.25907144    7.746354119    7.443392762]./10;
%luca
REC.opt.mua0 = [0.0253288800000000    0.00847272700000000    0.0119888600000000    0.0986880300000000    0.0751418100000000    0.0377212900000000    0.0777311100000000    0.0516792900000000]./10;
REC.opt.musp0 = [13.0121000000000    14.1417300000000    11.7669300000000    10.9200700000000    10.3264400000000    9.97632800000000    10.1331000000000    10.0489100000000]./10;
REC.opt.musp0 = REC.opt.musp0(lambda_id);
REC.opt.mua0 = REC.opt.musp0(lambda_id);
REC.opt.nB = 1.44;
% ---------------------- Solver and regularization ------------------------
REC.solver.tau = 1e-1;            % regularisation parameter
REC.solver.type = 'born';         % 'born','GN': gauss-newton, 
                                  % 'USprior': Simon's strutural prior
                                  % 'LM': Levenberg-Marquardt,
                                  % 'l1': L1-based minimization
                                  % 'fit': fitting homogeneous data
% =========================================================================
%%                            US prior 
% =========================================================================
REC.solver.prior.path = [];
% =========================================================================
%%                     load a precomputed jacobian 
% =========================================================================
% Pay attention! The jacobian depends on source-detectors configuration,
% optical properties of the background and number of time-windows.
REC.solver.prejacobian.load = false;
REC.solver.prejacobian.path = '../results/precomputed_jacobians/J';
