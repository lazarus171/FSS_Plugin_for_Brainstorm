function varargout = process_fss( varargin )
% PROCESS_FSS: Gets the Functional Source Separation through the Simulated
%              Annealing Algorithm
%
% USAGE:      sProcess = process_fss('GetDescription')
%               sInput = process_fss('Run', sProcess, sInput)
%                    x = process_fss('Compute',x,triglist,maxSEF,lowSEF,
%                        highSEF,TrialDuration,pretrigger,bas, smpfq,lambda,T0,
%                        sa_opt)
%
% Authors: Rosario Ribecco, 2023
% 
% This code is derived from the Brainstorm 'process_notch.m' code.

eval(macro_method);
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription()
    % === Process description
    sProcess.Comment     = 'FSS through Simulated Annealing';
    sProcess.FileTag     = 'fss';
    sProcess.Category    = 'Filter';
    sProcess.SubGroup    = 'Test';
    sProcess.Index       = 66;
    sProcess.Description = 'https://github.com/lazarus171/FSS_Plugin_for_Brainstorm';
    % === Input type definition
    sProcess.InputTypes  = {'data', 'results', 'raw', 'matrix'};
    sProcess.OutputTypes = {'data', 'results', 'raw', 'matrix'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 1;
    sProcess.processDim  = [];   % Prevents from data splitting
    % === Sensor types
    sProcess.options.sensortypes.Comment = 'Sensor types or names (empty=all): ';
    sProcess.options.sensortypes.Type    = 'text';
    sProcess.options.sensortypes.Value   = 'MEG, EEG';
    sProcess.options.sensortypes.InputTypes = {'data', 'raw'};
    % === Options definition
    % === Sample Frequency
    sProcess.options.smpfq.Comment = 'Sample frequency: ';
    sProcess.options.smpfq.Type    = 'value';
    sProcess.options.smpfq.Value   = {5000, 'Hz', 0};
    % === maxSEF
    sProcess.options.maxSEF.Comment = 'maxSEF: ';
    sProcess.options.maxSEF.Type = 'value';
    sProcess.options.maxSEF.Value = {19, 'msec', 1};
    % === lowSEF
    sProcess.options.lowSEF.Comment = 'lowSEF: ';
    sProcess.options.lowSEF.Type = 'value';
    sProcess.options.lowSEF.Value = {1, 'msec', 1};
    % === highSEF
    sProcess.options.highSEF.Comment = 'highSEF: ';
    sProcess.options.highSEF.Type = 'value';
    sProcess.options.highSEF.Value = {2, 'msec', 1};
    % === TrialDuration
    sProcess.options.TrialDuration.Comment = 'Trial Duration: ';
    sProcess.options.TrialDuration.Type = 'value';
    sProcess.options.TrialDuration.Value = {220, 'msec', 1};
    % === pretrigger
    sProcess.options.pretrigger.Comment = 'pretrigger: ';
    sProcess.options.pretrigger.Type = 'value';
    sProcess.options.pretrigger.Value = {20, 'msec', 1};
    % === bas
    sProcess.options.bas.Comment = 'Baseline: ';
    sProcess.options.bas.Type    = 'range';
    sProcess.options.bas.Value   = {[5, 10], 'msec', 1};
    
    % === Advanced Options Controller Definition
    sProcess.options.control.Comment = 'Advanced SA options';
    sProcess.options.control.Type = 'checkbox';
    sProcess.options.control.Value = 0;
    sProcess.options.control.Controller = 'advanced';
    
    % === Balancing Parameter Lambda
    sProcess.options.lambda.Comment = 'lambda: ';
    sProcess.options.lambda.Type    = 'value';
    sProcess.options.lambda.Value   = {1000, '', 0};
    sProcess.options.lambda.Class = 'advanced';
    % === Initial Temperature
    sProcess.options.T0.Comment = 'Initial temperature for SA: ';
    sProcess.options.T0.Type    = 'value';
    sProcess.options.T0.Value   = {2560, '', 0};
    sProcess.options.T0.Class = 'advanced';
    % === PCA noise threshold coefficient
    sProcess.options.pcaLimC.Comment = 'Noise threshold coefficient: ';
    sProcess.options.pcaLimC.Type    = 'value';
    sProcess.options.pcaLimC.Value   = {1, '', 2};
    sProcess.options.pcaLimC.Class = 'advanced';
    % === PCA noise threshold exponent
    sProcess.options.pcaLimE.Comment = 'Noise threshold exponent: ';
    sProcess.options.pcaLimE.Type    = 'value';
    sProcess.options.pcaLimE.Value   = {-14, '', 0};
    sProcess.options.pcaLimE.Class = 'advanced';
    % === Max Number of Iterations
    sProcess.options.maxIter.Comment = 'Max Iterations: ';
    sProcess.options.maxIter.Type = 'value';
    sProcess.options.maxIter.Value = {6000, '', 0};
    sProcess.options.maxIter.Class = 'advanced';
    % === Function Tolerance
    sProcess.options.functol.Comment = 'Function Tolerance: ';
    sProcess.options.functol.Type = 'value';
    sProcess.options.functol.Value = {0.000100, '', 6};
    sProcess.options.functol.Class = 'advanced';
    % === Max Time
    sProcess.options.maxtime.Comment = 'Max Time: ';
    sProcess.options.maxtime.Type = 'value';
    sProcess.options.maxtime.Value = {3600, 'sec', 0};
    sProcess.options.maxtime.Class = 'advanced';
    % === Max Stall Iterations
    sProcess.options.maxstalliter.Comment = 'Max Stall Iterations: ';
    sProcess.options.maxstalliter.Type = 'value';
    sProcess.options.maxstalliter.Value = {1000, '', 0};
    sProcess.options.maxstalliter.Class = 'advanced';
    % === Reannealing Interval
    sProcess.options.reanninter.Comment = 'Reannealing Interval: ';
    sProcess.options.reanninter.Type = 'value';
    sProcess.options.reanninter.Value = {30, '', 0};
    sProcess.options.reanninter.Class = 'advanced';
end

%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) 
    Comment = sProcess.Comment;
end


%% ===== RUN =====
function sInput = Run(sProcess, sInput)
    
    % === Get options
    maxSEF = sProcess.options.maxSEF.Value{1};
    lowSEF = sProcess.options.lowSEF.Value{1};
    highSEF = sProcess.options.highSEF.Value{1};
    TrialDuration = sProcess.options.TrialDuration.Value{1};
    pretrigger = sProcess.options.pretrigger.Value{1};
    bas = sProcess.options.bas.Value{1};
    smpfq = sProcess.options.smpfq.Value{1};
    
    % === Get advanced options
    lambda = sProcess.options.lambda.Value{1};
    T0 = sProcess.options.T0.Value{1};
    coeff = sProcess.options.pcaLimC.Value{1};
    expon = sProcess.options.pcaLimE.Value{1};
    sa_opt = struct;
    sa_opt.nsThr = coeff*10^expon;
    sa_opt.maxIter = sProcess.options.maxIter.Value{1};
    sa_opt.functol = sProcess.options.functol.Value{1};
    sa_opt.maxtime = sProcess.options.maxtime.Value{1};
    sa_opt.maxstalliter = sProcess.options.maxstalliter.Value{1};
    sa_opt.reanninter = sProcess.options.reanninter.Value{1};
    
    % Get the trigger list
    triglist = load(sInput.FileName);
    triglist = triglist.F.events.times;
    triglist = int64(triglist * smpfq);
    
    % Execute FSS_SEF code
    [sInput.A] = Compute(sInput.A, triglist,maxSEF,lowSEF,highSEF,TrialDuration,pretrigger,bas,smpfq,lambda,T0, sa_opt);
   

end


%% ===== EXTERNAL CALL =====
% USAGE: x = process_fss('Compute', x, triglist,maxSEF,lowSEF,highSEF,TrialDuration,pretrigger,bas,smpfq,lambda,T0, sa_opt)
function [x] = Compute(x, triglist,maxSEF,lowSEF,highSEF,TrialDuration,pretrigger,bas,smpfq,lambda,T0, sa_opt)
% EEG centering
medie_eeg = mean(x,2);
eeg_c = x - medie_eeg;
% Whitening and de_whitening martices calculation from centered EEG
[whiteMatrix,dewhiteMatrix] = pcaWhitening(eeg_c, sa_opt.nsThr);
% Centered EEG whitening
whiteEEGc = whiteMatrix*eeg_c;
% Simulated Annealing starting point initialization
w0 = whiteMatrix*(rand(size(eeg_c,1), 1)-0.5);
% Objective function definition
fun_obj=@(w) -f_obj(w, whiteEEGc, triglist, maxSEF, lowSEF, highSEF, TrialDuration, pretrigger, bas, lambda, smpfq);
% Simulated Annealing settings
options = optimoptions(@simulannealbnd,...
    'AcceptanceFcn',@(optimValues,newx,newfval) boltzacceptancefun(optimValues,newx,newfval),...
    'AnnealingFcn','annealingboltz',...
    'DataType','double',...
    'FunctionTolerance',sa_opt.functol,...
    'InitialTemperature',T0,...
    'ObjectiveLimit',-Inf,...
    'TemperatureFcn',@(optimValues,options) options.InitialTemperature.*0.8.^(optimValues.k),...
    'HybridFcn',[],...
    'PlotFcn',{'saplotf','saplotx'},...
    'Display','iter',...
    'MaxIterations',sa_opt.maxIter,...
    'MaxTime', sa_opt.maxtime,...
    'MaxStallIterations',sa_opt.maxstalliter,...
    'ReannealInterval',sa_opt.reanninter);
    
lower_bound=-ones(size(w0));
lower_bound(1)=0; % Sign ambiguity removal on w.
upper_bound=ones(size(w0));
% Objective Function minimization through Simulated Annealing
tic
rng default;
[w, fval ]= simulannealbnd(fun_obj,w0,lower_bound,upper_bound,options);
w=w/norm(w);
% AFS and WFS calculation
AFS = dewhiteMatrix*w;
WFS = w'*whiteMatrix;
% Functional Source and its retroprojection calculation
FS = w'*(whiteEEGc+whiteMatrix*medie_eeg);
Retroprojected_FS=AFS*FS;
x = Retroprojected_FS;
toc
end

%% ===== WHITENING MATRIX =====
function [whiteMatrix,dewhiteMatrix]=pcaWhitening(eeg_c, pcaLim)
% Whitening and de-whitening matrices calculation using PCA.

% Covariance matrix calculation
covarianceMatrix = cov(eeg_c', 1);

% Eigenvalues and related eigenvectors calculation
[E, D] = eig (covarianceMatrix,'vector');
[D,I]=sort(D,'descend');
% PCA application
k=nnz(D>pcaLim);
D=D(1:k);
E=E(:,I(1:k));

% Whitening and de-whitening matrices calculation
whiteMatrix = (sqrt(D.^-1)).*E';
dewhiteMatrix = E.*sqrt(D');

end

%% ===== OBJECTIVE FUNCTION =====
function [Res] = f_obj(w, whiteEEGc, triggerList, maxSEF, lowSEF, highSEF, TrialDuration_ms, pretrigger_ms, bas_ms,lambda, smpfq)
% Objective function for FSS definition: f_obj(w)=J(w'*whiteEEGc)+lambda*RF_S1(w'*whiteEEGc)
w=w/norm(w);
evokedActivity = w'*whiteEEGc;

% Kurtosis calculation
m2 = mean(evokedActivity.^2);
m4 = mean(evokedActivity.^4);
Kurtosis = m4/(m2^2)-3;

% Functional constraint calculation
TrialDuration = round((TrialDuration_ms/1000)*smpfq);
pretrigger = round((pretrigger_ms/1000)*smpfq);

% Baseline settings
if bas_ms(1)~= bas_ms(2)
    bas(1) = round(((pretrigger_ms+bas_ms(1))/1000)*smpfq);
    bas(2) = round(((pretrigger_ms+bas_ms(2))/1000)*smpfq);
else
    bas = [];
end
sef = zeros(1,TrialDuration);
maxSEF = round((maxSEF/1000)*smpfq);
lowSEF = round((lowSEF/1000)*smpfq);
highSEF = round((highSEF/1000)*smpfq);
for k = 2:length(triggerList)-1
    if isempty(bas) == 1
        sef = sef+evokedActivity((triggerList(k)-pretrigger+1):(triggerList(k)-pretrigger+TrialDuration));
    else
        sef = sef+evokedActivity((triggerList(k)-pretrigger+1):(triggerList(k)-pretrigger+TrialDuration))-mean(evokedActivity((triggerList(k)+bas(1)):(triggerList(k)+bas(2))));
    end
end
nave = length(triggerList)-2;
sef = sef/nave;
if isempty(bas) == 0
    sef = sef - mean(sef(bas(1):bas(2)));
end
absSef = abs(sef);
windows = ((maxSEF-lowSEF+pretrigger):(maxSEF+highSEF+pretrigger));
if isempty(bas) == 0
    indiceSEF = sum(absSef(windows),2)-sum(absSef(bas(1):bas(2)),2);
else
    indiceSEF = sum(absSef(windows),2);
end


% Objective function return
Res = Kurtosis+lambda*indiceSEF;

end

%% ===== ACCEPTANCE FUNCTION =====
function acceptpoint = boltzacceptancefun(optimValues,~,newfval)

if newfval <= optimValues.fval
    acceptpoint = true;
elseif rand(1)<=exp((optimValues.fval-newfval)/(max(optimValues.temperature)))
    acceptpoint = true;
else
    acceptpoint = false;
end
end
