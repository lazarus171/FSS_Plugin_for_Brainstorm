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
    sProcess.Category    = 'File';
    sProcess.SubGroup    = 'Test';
    sProcess.Index       = 70;
    sProcess.Description = 'https://github.com/lazarus171/FSS_Plugin_for_Brainstorm';
    % === Input type definition
    sProcess.InputTypes  = {'recordings', 'data'};
    sProcess.OutputTypes = {'recordings', 'data'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 1;
    sProcess.processDim  = [];   % Prevents from data splitting
    % === Options definition
    % === Sensor types
    sProcess.options.sensortypes.Comment = 'Sensors type or name (empty=all): ';
    sProcess.options.sensortypes.Type    = 'text';
    sProcess.options.sensortypes.Value   = 'EEG';
    sProcess.options.sensortypes.InputTypes = {'recordings', 'data', 'raw'};
    % === Area selector
    sProcess.options.selector.Comment = {'S1', 'M1', 'Area'};
    sProcess.options.selector.Type = 'radio_line';
    sProcess.options.selector.Value = 1;
    % === Sampling Frequency
    sProcess.options.smpfq.Comment = 'Sampling frequency: ';
    sProcess.options.smpfq.Type    = 'value';
    sProcess.options.smpfq.Value   = {5000, 'Hz', 0};
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
    
    % === Annealing Function
    sProcess.options.annfcn.Comment = {'boltz', 'fast', 'custom', 'Annealing Function: '};
    sProcess.options.annfcn.Type    = 'radio_line';
    sProcess.options.annfcn.Value   = 1;
    sProcess.options.annfcn.Class = 'advanced';
    % === Acceptance Function
    sProcess.options.accfcn.Comment = {'standard', 'custom', 'Acceptance Function: '};
    sProcess.options.accfcn.Type    = 'radio_line';
    sProcess.options.accfcn.Value   = 2;
    sProcess.options.accfcn.Class = 'advanced';
    % === Temperature Function
    sProcess.options.tmpfcn.Comment = {'boltz', 'fast', 'exp' , 'custom', 'Temperature Function: '};
    sProcess.options.tmpfcn.Type    = 'radio_line';
    sProcess.options.tmpfcn.Value   = 3;
    sProcess.options.tmpfcn.Class = 'advanced';
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
    sProcess.options.functol.Value = {0.001000, '', 6};
    sProcess.options.functol.Class = 'advanced';
    % === Max Time
    sProcess.options.maxtime.Comment = 'Max Time: ';
    sProcess.options.maxtime.Type = 'value';
    sProcess.options.maxtime.Value = {1200, 'sec', 0};
    sProcess.options.maxtime.Class = 'advanced';
    % === Max Stall Iterations
    sProcess.options.maxstalliter.Comment = 'Max Stall Iterations: ';
    sProcess.options.maxstalliter.Type = 'value';
    sProcess.options.maxstalliter.Value = {100, '', 0};
    sProcess.options.maxstalliter.Class = 'advanced';
    % === Reannealing Interval
    sProcess.options.reanninter.Comment = 'Reannealing Interval: ';
    sProcess.options.reanninter.Type = 'value';
    sProcess.options.reanninter.Value = {100, '', 0};
    sProcess.options.reanninter.Class = 'advanced';
end

%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) 
    Comment = sProcess.Comment;
end

%% ===== RUN =====
function [TopoOut] = Run(sProcess, sInput)
    
    % Load input files
    DataMat = in_bst_data(sInput.FileName);
    ChMat = in_bst_data(sInput.ChannelFile);
    
    % === Get options
    if sProcess.options.selector.Value == 1
        area = 'S1';
        lowSEF = 1;
        maxSEF = 19;
        highSEF = 2;
    else
        area = 'M1';
        lowSEF = 1.8;
        maxSEF = 22;
        highSEF = 2;
    end
    
    % Show the SEF values checking window
    % Get the prompt list ready
    prompt = {'lowSEF', 'maxSEF', 'highSEF'};
    % Get the window title ready
    dlgtitle = strcat(area, ' area SEF values check');
    % Set the text boxes dimensions
    dims = [1 45];
    % Get the default list ready
    definput = {num2str(lowSEF), num2str(maxSEF), num2str(highSEF)};
    % Get the option structure ready
    opts.Resize = 'on';
    % Show dialog window
    answer = inputdlg(prompt,dlgtitle,dims,definput, opts);
    
    % Set the SEF values according to window inputs
    lowSEF = str2double(answer{1});
    maxSEF = str2double(answer{2});
    highSEF = str2double(answer{3});

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
    sa_opt.annfcn = sProcess.options.annfcn.Value;
    sa_opt.tmpfcn = sProcess.options.tmpfcn.Value;
    sa_opt.accfcn = sProcess.options.accfcn.Value;  
    
    % Get the trigger list
    triglist = DataMat.Events.times;
    triglist = int64(triglist * smpfq);
    
    % Identify channel types
    id = 1;
    while id <= size(DataMat.F, 1)
        DataMat.ChannelFlag(id) = strcmp(ChMat.Channel(id).Type, sProcess.options.sensortypes.Value);
        id = id+1;
    end
	
    % List of useless channels
    k = find(~DataMat.ChannelFlag);
    % Wipe out useless channels
    DataMat.F(k, :) = [];
    % Modify comment
    DataMat.Comment = strcat(area, '_', sProcess.FileTag);
    
    % Execute FSS_SEF code
    DataMat.F = Compute(DataMat.F, triglist,maxSEF,lowSEF,highSEF,TrialDuration,pretrigger,bas,smpfq,lambda,T0, sa_opt);
    
    % Refill unuseful channels
    DataMat.F(k, :) = 0;
    DataMat.Time = 0;
    OutputMat = DataMat;
    
    % Generate a new file name in the same folder
    sStudy = bst_get('Study', sInput.iStudy);
    TopoOut=bst_process('GetNewFilename',bst_fileparts(sStudy.FileName),sInput.FileType);
    
    % Save the new file
    save(TopoOut, '-struct', 'OutputMat');
    
    % Reference OutputFile in the database:
    db_add_data(sInput.iStudy, TopoOut, OutputMat);
end

%% ===== EXTERNAL CALL =====
function [AFS] = Compute(x, triglist,maxSEF,lowSEF,highSEF,TrialDuration,pretrigger,bas,smpfq,lambda,T0, sa_opt)

    % EEG centering
    medie_eeg = mean(x,2);
    eeg_c = x - medie_eeg;
    % Whitening and de_whitening matrices calculation from centered EEG
    [whiteMatrix,dewhiteMatrix] = pcaWhitening(eeg_c, sa_opt.nsThr);
    % Centered EEG whitening
    whiteEEGc = whiteMatrix*eeg_c;
    
	% Simulated Annealing starting point initialization
    w0 = whiteMatrix*(rand(size(eeg_c,1), 1)-0.5);
    
	% Objective function definition
    fun_obj =@(w) -f_obj(w, whiteEEGc, triglist, maxSEF, lowSEF, highSEF, TrialDuration, pretrigger, bas, lambda, smpfq);

    % Simulated Annealing settings
    options = optimoptions(@simulannealbnd,...
        'DataType','double',...
        'Display','iter',...
        'FunctionTolerance',sa_opt.functol,...
        'HybridFcn', [],...
        'InitialTemperature', T0,...
        'MaxFunctionEvaluations', Inf,...
        'MaxIterations', sa_opt.maxIter,...
        'MaxTime', sa_opt.maxtime,...
        'ObjectiveLimit',-Inf,...
        'OutputFcn', [],...
        'PlotFcn',{'saplotf','saplotx'},...
        'MaxStallIterations', sa_opt.maxstalliter,...
        'ReannealInterval', sa_opt.reanninter,...
        'HybridFcn',[]);

    switch sa_opt.annfcn
        case 1
            options.AnnealingFcn = @annealingboltz;
        otherwise
            options.AnnealingFcn = @annealingfast;
    end
	
    switch sa_opt.accfcn
        case 1
            options.AcceptanceFcn = @acceptancesa;
        otherwise
            options.AcceptanceFcn = @(optimValues,newx,newfval) boltzacceptancefun(optimValues,newx,newfval);
    end

    switch sa_opt.tmpfcn
        case 1
            options.TemperatureFcn = @temperatureboltz;
        case 2
            options.TemperatureFcn =@temperaturefast;
        case 3
            options.TemperatureFcn = @temperatureexp;
        otherwise
            options.TemperatureFcn = @(optimValues,options) options.InitialTemperature.*0.8.^(optimValues.k);
    end

    lower_bound=-ones(size(w0));
    lower_bound(1)=0; % Sign ambiguity removal on w.
    upper_bound=ones(size(w0));

    % Objective Function minimization through Simulated Annealing
    rng('default');% for reproducibility
    [w, ~, ~, sa_out]= simulannealbnd(fun_obj,w0,lower_bound,upper_bound,options);
    w = w/norm(w);

    % AFS calculation
    AFS = dewhiteMatrix*w;
	
	% Other entity calculation (not used here)
    % WFS = w'*whiteMatrix;
    % FS = w'*(whiteEEGc+whiteMatrix*medie_eeg);
    % FS_ave = trialAverage(FS, triglist, TrialDuration, pretrigger, smpfq);
    % ave_time = zeros(size(FS_ave));
    % ave_time = find(~ave_time)*(1000/smpfq)-pretrigger;

    % Display results
    t=['Elapsed time is ', num2str(sa_out.totaltime), ' seconds.'];
    disp(t);
end

%% ===== WHITENING MATRIX =====
function [whiteMatrix,dewhiteMatrix] = pcaWhitening(eeg_c, noiseLevel)
    % Whitening and de-whitening matrices calculation using PCA.

    % Covariance matrix calculation
    covarianceMatrix = cov(eeg_c', 1);

    % Eigenvalues and related eigenvectors calculation
    [E, D] = eig (covarianceMatrix,'vector');
    [D,I]=sort(D,'descend');
    
    % PCA application
    k = nnz(D>noiseLevel);
    D=D(1:k);
    E=E(:,I(1:k));

    % Whitening and de-whitening matrices calculation
    whiteMatrix = (sqrt(D.^-1)).*E';
    dewhiteMatrix = E.*sqrt(D');
end

%% ===== OBJECTIVE FUNCTION =====
function [Res] = f_obj(w, whiteEEGc, triggerList, maxSEF, lowSEF, highSEF, TrialDuration_ms, pretrigger_ms, bas_ms,lambda, smpfq)
    % Objective function for FSS definition:
    % f_obj(w)=J(w'*whiteEEGc)+lambda*RF_S1(w'*whiteEEGc)
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
function acceptpoint = boltzacceptancefun(optimValues,newx,newfval)
    if newfval <= optimValues.fval
        acceptpoint = true;
    elseif rand(1)<=exp((optimValues.fval-newfval)/(max(optimValues.temperature)))
        acceptpoint = true;
    else
        acceptpoint = false;
    end
end