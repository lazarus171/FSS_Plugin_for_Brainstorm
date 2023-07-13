function varargout = process_fss( varargin )
% PROCESS_FSS: Estrae la sorgente funzionale con il simulated annealing
%
% USAGE:      sProcess = process_fss('GetDescription')
%               sInput = process_fss('Run',     sProcess, sInput)
%                    x = process_fss('Compute', ............)

% @=============================================================================
% This function is part of the Brainstorm software:
% https://neuroimage.usc.edu/brainstorm
% 
% Copyright (c) University of Southern California & McGill University
% This software is distributed under the terms of the GNU General Public License
% as published by the Free Software Foundation. Further details on the GPLv3
% license can be found at http://www.gnu.org/copyleft/gpl.html.
% 
% FOR RESEARCH PURPOSES ONLY. THE SOFTWARE IS PROVIDED "AS IS," AND THE
% UNIVERSITY OF SOUTHERN CALIFORNIA AND ITS COLLABORATORS DO NOT MAKE ANY
% WARRANTY, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, NOR DO THEY ASSUME ANY
% LIABILITY OR RESPONSIBILITY FOR THE USE OF THIS SOFTWARE.
%
% For more information type "brainstorm license" at command prompt.
% =============================================================================@
%
% Authors: Rosario Ribecco, 2023
% 
% Codice derivato dallo script 'process_notch.m' di Brainstorm

eval(macro_method);
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
    % Process description
    sProcess.Comment     = 'FSS through Simulated Annealing';
    sProcess.FileTag     = 'fss';
    sProcess.Category    = 'Filter';
    sProcess.SubGroup    = 'Test';
    sProcess.Index       = 66;
    sProcess.Description = 'https://github.com/lazarus171/FSS_Plugin_for_Brainstorm';
    % Definition of the input accepted by this process
    sProcess.InputTypes  = {'data', 'results', 'raw', 'matrix'};
    sProcess.OutputTypes = {'data', 'results', 'raw', 'matrix'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 1;
    sProcess.processDim  = [];   % Impedisce di splittare i dati
    % === Sensor types
    sProcess.options.sensortypes.Comment = 'Sensor types or names (empty=all): ';
    sProcess.options.sensortypes.Type    = 'text';
    sProcess.options.sensortypes.Value   = 'MEG, EEG';
    sProcess.options.sensortypes.InputTypes = {'data', 'raw'};
    % Definition of the options
    % === smpfq
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
    % === durata
    sProcess.options.durata.Comment = 'durata: ';
    sProcess.options.durata.Type = 'value';
    sProcess.options.durata.Value = {220, 'msec', 1};
    % === pretrigger
    sProcess.options.pretrigger.Comment = 'pretrigger: ';
    sProcess.options.pretrigger.Type = 'value';
    sProcess.options.pretrigger.Value = {20, 'msec', 1};
    % === bas
    sProcess.options.bas.Comment = 'Baseline: ';
    sProcess.options.bas.Type    = 'range';
    sProcess.options.bas.Value   = {[5, 10], 'msec', 1};
   
    
    % === Controller
    sProcess.options.control.Comment = 'Advanced SA options';
    sProcess.options.control.Type = 'checkbox';
    sProcess.options.control.Value = 0;
    sProcess.options.control.Controller = 'advanced';
    
    % === Lambda
    sProcess.options.lambda.Comment = 'lambda: ';
    sProcess.options.lambda.Type    = 'value';
    sProcess.options.lambda.Value   = {1000, '', 0};
    sProcess.options.lambda.Class = 'advanced';
    % === T0
    sProcess.options.T0.Comment = 'Initial temperature for SA: ';
    sProcess.options.T0.Type    = 'value';
    sProcess.options.T0.Value   = {2560, '', 0};
    sProcess.options.T0.Class = 'advanced';
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
function Comment = FormatComment(sProcess) %#ok<DEFNU>
    Comment = sProcess.Comment;
end


%% ===== RUN =====
function sInput = Run(sProcess, sInput) %#ok<DEFNU>
    
    % === Get options
    maxSEF = sProcess.options.maxSEF.Value{1};
    lowSEF = sProcess.options.lowSEF.Value{1};
    highSEF = sProcess.options.highSEF.Value{1};
    durata = sProcess.options.durata.Value{1};
    pretrigger = sProcess.options.pretrigger.Value{1};
    bas = sProcess.options.bas.Value{1};
    smpfq = sProcess.options.smpfq.Value{1};
    
    % === Advanced options
    lambda = sProcess.options.lambda.Value{1};
    T0 = sProcess.options.T0.Value{1};
    sa_opt = struct;
    sa_opt.functol = sProcess.options.functol.Value{1};
    sa_opt.maxtime = sProcess.options.maxtime.Value{1};
    sa_opt.maxstalliter = sProcess.options.maxstalliter.Value{1};
    sa_opt.reanninter = sProcess.options.reanninter.Value{1};
    
    % triglist
    triglist = load(sInput.FileName);
    triglist = triglist.F.events.times;
    triglist = int64(triglist * smpfq);
    
    % Execute FSS_SEF code
    [sInput.A] = Compute(sInput.A, triglist,maxSEF,lowSEF,highSEF,durata,pretrigger,bas,smpfq,lambda,T0, sa_opt);
   

end


%% ===== EXTERNAL CALL =====
% USAGE: x = process_fss('Compute', x, triglist,maxSEF,lowSEF,highSEF,durata,pretrigger,bas,smpfq,lambda,T0)
function [x] = Compute(x, triglist,maxSEF,lowSEF,highSEF,durata,pretrigger,bas,smpfq,lambda,T0, sa_opt)
    %% Centramento dell'EEG
medie_eeg = mean(x,2);
eeg_c = x - medie_eeg;


%% Calcolo delle Matrici di Sbiancamento e Desbiancamento a partire dall'EEG centrato
[whiteMatrix,dewhiteMatrix] = pcaWhitening(eeg_c);


%% Sbiancamento dell'EEG centrato
whiteEEGc = whiteMatrix*eeg_c;


%% Inizializzazione del punto iniziale per il Simulated Annealing
w0 = whiteMatrix*(rand(size(eeg_c,1), 1)-0.5);


%% Definizione della funzione obiettivo
fun_obj=@(w) -f_obj(w, whiteEEGc, triglist, maxSEF, lowSEF, highSEF, durata, pretrigger, bas, lambda, smpfq);


%% Settaggio del Simulated Annealing

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
    'MaxIterations',6000,...
    'MaxTime', sa_opt.maxtime,...
    'MaxStallIterations',sa_opt.maxstalliter,...
    'ReannealInterval',sa_opt.reanninter);
    
lower_bound=-ones(size(w0));
lower_bound(1)=0; % Rimozione dell'ambiguità del segno sui pesi w.
upper_bound=ones(size(w0));

%% Massimizzazione della Funzione Obiettivo tramite Simulated Annealing
tic
rng default;
[w, fval ]= simulannealbnd(fun_obj,w0,lower_bound,upper_bound,options);
w=w/norm(w);

%% Calcolo AFS e WFS
AFS = dewhiteMatrix*w;
WFS = w'*whiteMatrix;


%% Calcolo della sorgente funzionale FS e della sua retro-proiezione sui canali Retroprojected_FS
FS = w'*(whiteEEGc+whiteMatrix*medie_eeg);
Retroprojected_FS=AFS*FS;
x = Retroprojected_FS;
toc
end

%% ===== WHITENING MATRIX =====
function [whiteMatrix,dewhiteMatrix]=pcaWhitening(eeg_c)
% Funzione che calcola le matrici di sbiancamento whiteMatrix e di de-sbiancamento dewhiteMatrix,
% a partire dai dati in X, usando la PCA.

%% Calcolo della matrice delle covarianze
covarianceMatrix = cov(eeg_c', 1);

%% Calcolo degli autovalori e relativi autovettori della matrice delle covarianze
[E, D] = eig (covarianceMatrix,'vector');
[D,I]=sort(D,'descend');
k=nnz(D>1e-14);
D=D(1:k);
E=E(:,I(1:k));

%% Calcolo delle matrici di sbiancamento e de-sbiancamento
whiteMatrix = (sqrt(D.^-1)).*E';
dewhiteMatrix = E.*sqrt(D');

end

%% ===== OBJECT FUNCTION =====
function [Res] = f_obj(w, whiteEEGc, triggerList, maxSEF, lowSEF, highSEF, durata_ms, pretrigger_ms, bas_ms,lambda, smpfq)
% Funzione Obiettivo per FSS con vincolo funzionale S1:
% f_obj(w)=J(w'*whiteEEGc)+lambda*RF_S1(w'*whiteEEGc)
w=w/norm(w);
evokedActivity = w'*whiteEEGc;

%% Calcolo della Kurtosi
m2 = mean(evokedActivity.^2);
m4 = mean(evokedActivity.^4);
Kurtosis = m4/(m2^2)-3;

%% Calcolo del vincolo funzionale
durata = round((durata_ms/1000)*smpfq);
pretrigger = round((pretrigger_ms/1000)*smpfq);
if isempty(bas_ms) == 0
    bas(1) = round(((pretrigger_ms+bas_ms(1))/1000)*smpfq);
    bas(2) = round(((pretrigger_ms+bas_ms(2))/1000)*smpfq);
else
    bas = [];
end
sef = zeros(1,durata);
maxSEF = round((maxSEF/1000)*smpfq);
lowSEF = round((lowSEF/1000)*smpfq);
highSEF = round((highSEF/1000)*smpfq);
for k = 2:length(triggerList)-1
    if isempty(bas_ms) == 1
        sef = sef+evokedActivity((triggerList(k)-pretrigger+1):(triggerList(k)-pretrigger+durata));
    else
        sef = sef+evokedActivity((triggerList(k)-pretrigger+1):(triggerList(k)-pretrigger+durata))-mean(evokedActivity((triggerList(k)+bas(1)):(triggerList(k)+bas(2))));
    end
end
nave = length(triggerList)-2;
sef = sef/nave;
if isempty(bas_ms) == 0
    sef = sef - mean(sef(bas(1):bas(2)));
end
absSef = abs(sef);
windows = ((maxSEF-lowSEF+pretrigger):(maxSEF+highSEF+pretrigger));
if isempty(bas_ms) == 0
    indiceSEF = sum(absSef(windows),2)-sum(absSef(bas(1):bas(2)),2);
else
    indiceSEF = sum(absSef(windows),2);
end


%% Somma tra Kurtosi e vincolo funzionale
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
