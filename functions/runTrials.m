
function sessionPay = runTrials(exptPhase)

global MainWindow
global scr_centre DATA datafilename
global distract_col
global white black gray yellow
global bigMultiplier smallMultiplier
global stim_size stimLocs
global stimCentre aoiRadius
global fix_aoi_radius
global awareInstrPause
global starting_total_points colourName
global realVersion eyeVersion

gamma = 0.2;    % Controls smoothing of displayed gaze location. Lower values give more smoothing

if realVersion
    
    
    softTimeoutDuration = 1;     % soft timeout limit for later trials
    
    timeoutDuration = [4, 2, 2];     % [4, 2] timeout duration
    fixationTimeoutDuration = 4;    % 5 fixation timeout duration
    
    iti = 0.7;            % 0.7
    feedbackDuration = [0.7, 2.5, 1.5];       % [0.7, 2.5, 1.5]  FB duration: Practice, first block of expt phase, later in expt phase
    
    yellowFixationDuration = 0.3;     % Duration for which fixation cross turns yellow to indicate trial about to start
    blankScreenAfterFixationPause = 0.15;        % UPDATED 14/01/16 IN LINE WITH FAILING ET AL. PAPER
    
    initialPause = 2;   % 2 ***
    breakDuration = 15;  % 15 ***
    awareInstrPause = 16;  % 16
    
    requiredFixationTime = 0.1;     % Time that target must be fixated for trial to be successful
    omissionTimeLimit = 0;          % Dwell time on distractor that means this will be an omission trial
    
    fixationFixationTime = 0.7;       % Time that fixation cross must be fixated for trial to begin
    
    pracTrials = 8;
    numExptBlocksPhase = [1, 8]; %Phase 1 = practice, Phase 2 = mixed single and double distractor, Phase 3 = double distractor only
    
    blocksPerBreak = 2;
    
    singlePerBlock = [0, 12];
    %doublePerBlock = [0, 4, 11];
    
else
    
    softTimeoutDuration = 2;
    timeoutDuration = [4, 2, 2];
    fixationTimeoutDuration = 4;
    
    iti = 0.01;
    feedbackDuration = [0.001, 0.2, 0.2];
    
    yellowFixationDuration = 0.005;
    blankScreenAfterFixationPause = 0.005;
    
    initialPause = 0.005;
    breakDuration = 2;
    
    requiredFixationTime = 0.005;
    omissionTimeLimit = 0;          % Dwell time on distractor that means this will be an omission trial
    fixationFixationTime = 0.005;
    
    pracTrials = 2;
    numExptBlocksPhase = [1, 1];
    
    blocksPerBreak = 1;
    
    singlePerBlock = [0, 1];
    %doublePerBlock = [0, 1, 1];
end

savingGazeData = false;

if exptPhase == 1
    numTrials = pracTrials;
    distractorType = 3;
    exptTrialsPerBlock = pracTrials;
    trialTypeArray = ones(exptTrialsPerBlock, 1) * distractorType;
    winMultiplier = 0;
else
    
    if eyeVersion
        savingGazeData = true;
        trialEGarray = zeros(timeoutDuration(exptPhase) * 2 * 300, 27);
        fixEGarray = zeros(fixationTimeoutDuration * 2 * 300, 27);
    end
    
    numSingleDistractType = 2;
    %numDoubleDistractType = 2;
    
    numTrialTypes = numSingleDistractType;
    
    winMultiplier = zeros(2,1);     % winMultiplier is a bad name now; it's actually the amount that they win
    winMultiplier(1) = bigMultiplier;         % High-val, omission distractors
    winMultiplier(2) = smallMultiplier;     % Low val, omission distractors
%     winMultiplier(3) = smallMultiplier;         % Low value, omission
%     winMultiplier(4) = smallMultiplier;     % Low value, yoked
%     winMultiplier(5) = 0;   %double distractor high val, no reward given
%     winMultiplier(6) = 0;   %double distractor low val, no reward given
    
    numSingleDistractPerBlock = singlePerBlock(exptPhase);
    %numDoubleDistractPerBlock = doublePerBlock(exptPhase);
    
    numExptBlocks = numExptBlocksPhase(exptPhase);
    
    exptTrialsPerBlock = numSingleDistractType * numSingleDistractPerBlock;
    
    trialTypeArray = zeros(exptTrialsPerBlock, 1);
    
    loopCounter = 0;
    for ii = 1 : numSingleDistractType
        for jj = 1 : numSingleDistractPerBlock
            loopCounter = loopCounter + 1;
            trialTypeArray(loopCounter) = ii;
        end
    end
    
%     for ii = numSingleDistractType + 1 : numSingleDistractType + numDoubleDistractType
%         for jj = 1 : numDoubleDistractPerBlock
%             loopCounter = loopCounter + 1;
%             trialTypeArray(loopCounter) = ii;
%         end
%     end
    
    numTrials = numExptBlocks * exptTrialsPerBlock;
    
end

shTrialTypeArray = shuffleTrialorder(trialTypeArray, exptPhase);

exptTrialsBeforeBreak = exptTrialsPerBlock * blocksPerBreak;

if ~eyeVersion
    ShowCursor('Arrow');
end



fixationPollingInterval = 0.03;    % Duration between successive polls of the eyetracker for gaze contingent stuff; during fixation display
trialPollingInterval = 0.01;      % Duration between successive polls of the eyetracker for gaze contingent stuff; during stimulus display

junkFixationPeriod = 0.1;   % Period to throw away at start of fixation before gaze location is calculated
junkGazeCycles = junkFixationPeriod / trialPollingInterval;




stimLocs = 6;       % Number of stimulus locations
stim_size = dva2pix(2.3);%    % 92 Size of stimuli
perfectDiam = stim_size + 10;   % Used in FillOval to increase drawing speed

circ_diam = dva2pix(5.05); %200;    % Diameter of imaginary circle on which stimuli are positioned

fix_size = dva2pix(0.5); %20;      % This is the side length of the fixation cross
fix_aoi_radius = dva2pix(1.5); %fix_size * 3;

gazePointRadius = fix_size/2; %10;






% Create a rect for the fixation cross
fixRect = [scr_centre(1) - fix_size/2    scr_centre(2) - fix_size/2   scr_centre(1) + fix_size/2   scr_centre(2) + fix_size/2];


% Create a rect for the circular fixation AOI
fixAOIrect = [scr_centre(1) - fix_aoi_radius    scr_centre(2) - fix_aoi_radius   scr_centre(1) + fix_aoi_radius   scr_centre(2) + fix_aoi_radius];


[diamondTex, fixationTex, colouredFixationTex, fixationAOIsprite, colouredFixationAOIsprite, gazePointSprite, stimWindow] = setupStimuli(fix_size, gazePointRadius);


% Create a matrix containing the six stimulus locations, equally spaced
% around an imaginary circle of diameter circ_diam
stimRect = zeros(stimLocs,4);

for i = 0 : stimLocs - 1    % Define rects for stimuli and line segments
    stimRect(i+1,:) = [scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs) - stim_size / 2   scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs) - stim_size / 2   scr_centre(1) - circ_diam * sin(i*2*pi/stimLocs) + stim_size / 2   scr_centre(2) - circ_diam * cos(i*2*pi/stimLocs) + stim_size / 2];
end

stimCentre = zeros(stimLocs, 2);
for i = 1 : stimLocs
    stimCentre(i,:) = [stimRect(i,1) + stim_size / 2,  stimRect(i,2) + stim_size / 2];
end
distractorAOIradius = 2 * (circ_diam / 2) * sin(pi / stimLocs);       % This gives circular AOIs that are tangent to each other
targetAOIradius = round(stim_size * 0.75);        % This gives a smaller AOI that will be used to determine target fixations on each trial

aoiRadius = zeros(stimLocs);


sessionPay = 0;

trialCounter = 0;
block = 1;
trials_since_break = 0;
DATA.fixationTimeouts = [0, 0];
DATA.trialTimeouts = [0, 0];

% if exptPhase > 1
%     omissionTracker = zeros(9,numSingleDistractPerBlock);
%     omissionCounter = zeros(9,1);
% end

if eyeVersion
    tetio_startTracking;
end

WaitSecs(initialPause);

for trial = 1 : numTrials
    
    trialCounter = trialCounter + 1;    % This is used to set distractor type below; it can cycle independently of trial
    trials_since_break = trials_since_break + 1;
    
    
    if exptPhase == 0
        FB_duration = feedbackDuration(1);
    else
        if block == 1
            FB_duration = feedbackDuration(2);
        else
            FB_duration = feedbackDuration(3);
        end
        
    end
    
    targetLoc = randi(stimLocs);
    
    distractLoc = targetLoc;
    while distractLoc == targetLoc  %distractor cannot be at the target location
        distractLoc = randi(stimLocs);
    end
    
    distractType = shTrialTypeArray(trialCounter);
    
    
%     secondDistractLoc = targetLoc - (distractLoc - targetLoc);      %second distractor location is a mirror image of the first
%     if secondDistractLoc < 1
%         secondDistractLoc = secondDistractLoc + stimLocs;
%     elseif secondDistractLoc > stimLocs
%         secondDistractLoc = secondDistractLoc - stimLocs;
%     end
    
    postFixationPause = blankScreenAfterFixationPause; %UPDATED IN LINE WITH FAILING ET AL. 14/01/16
    
    Screen('FillRect', stimWindow, black);  % Clear the screen from the previous trial by drawing a black rectangle over the whole thing
    %Screen('DrawTexture', stimWindow, fixationTex, [], fixRect); UPDATED
    %14/01/16 IN LINE WITH FAILING ET AL.
    
    for i = 1 : stimLocs
        Screen('FillOval', stimWindow, gray, stimRect(i,:), perfectDiam);       % Draw stimulus circles
        aoiRadius(i) = distractorAOIradius;     % Set large AOIs around all locations (we'll change the AOI around the target location in a minute)
    end
    Screen('FillOval', stimWindow, distract_col(distractType,:), stimRect(distractLoc,:), perfectDiam);      % Draw first coloured circle in distractor 1 location
    %Screen('FillOval', stimWindow, distract_col(distractType,4:6), stimRect(secondDistractLoc,:), perfectDiam);  %Draw second coloured circle in distractor 2 location
    Screen('DrawTexture', stimWindow, diamondTex, [], stimRect(targetLoc,:));       % Draw diamond in target location
    
    aoiRadius(targetLoc) = targetAOIradius;     % Set a special (small) AOI around the target
    
    if ~eyeVersion
        for i = 1 : stimLocs          % Draw AOI circles
            Screen('FrameOval', stimWindow, white, [stimCentre(i,1) - aoiRadius(i), stimCentre(i,2) - aoiRadius(i), stimCentre(i,1) + aoiRadius(i), stimCentre(i,2) + aoiRadius(i)], 1, 1);
        end
    end
    
    Screen('FillRect',MainWindow, black);
    
    Screen('DrawTexture', MainWindow, fixationAOIsprite, [], fixAOIrect);
    Screen('DrawTexture', MainWindow, fixationTex, [], fixRect);
    
    timeOnFixation = zeros(2);    % a slot for each stimulus location, and one for "everywhere else"
    stimSelected = 2;   % 1 = fixation cross, 2 = everywhere else
    fixated_on_fixation_cross = 0;
    fixationBadSamples = 0;
    fixationTimeout = 0;
    gazeCycle = 0;
    arrayRowCounter = 2;    % Used to write EG data to the correct rows of an array. Starts at 2 because we write the first row in separately below (line marked ***)
    
    startFixationTime = Screen(MainWindow, 'Flip', [], 1);     % Present fixation cross
    
    if savingGazeData
        fixEGarray(:,:) = 0;
    end
    
    if eyeVersion
        
        [lefteye, righteye, ts, ~] = tetio_readGazeData; % Empty eye tracker buffer
        startEyePeriod = double(ts(end));  % Take the timestamp of the last element in the buffer as the start of the trial. Need to convert to double so can divide by 10^6 later to change to seconds
        startFixationTimeoutPeriod = startEyePeriod;
        
        currentGazePoint = zeros(1,2);
        
        if savingGazeData
            fixEGarray(1,:) = [double(ts(length(ts))), lefteye(length(ts),:), righteye(length(ts),:)];       % *** First row of saved EG array gives start time
        end
        
        
        while fixated_on_fixation_cross == 0
            Screen('DrawTexture', MainWindow, fixationAOIsprite, [], fixAOIrect);   % Redraw fixation cross and AOI, and draw gaze point on top of that
            Screen('DrawTexture', MainWindow, fixationTex, [], fixRect);
            
            WaitSecs(fixationPollingInterval);      % Pause between updates of eye position
            [lefteye, righteye, ts, ~] = tetio_readGazeData;    % Get eye-tracker data since previous call
            
            
            
            if isempty(ts) == 0
                
                
                [eyeX, eyeY, validPoints] = findMeanGazeLocation(lefteye, righteye, length(ts));    % Find mean gaze location during the previous polling interval
                
                gazeCycle = gazeCycle + 1;
                
                endPoint = fixArrayRowCounter + length(ts) - 1;
                if savingGazeData
                    fixEGarray(fixArrayRowCounter:endPoint,:) = [double(ts), lefteye, righteye];
                end
                
                fixArrayRowCounter = endPoint + 1;
                
                if validPoints > 0
                    if gazeCycle <= junkGazeCycles
                        currentGazePoint = [eyeX, eyeY];        % If in junk period at start of trial, keep track of gaze location; this will determine starting point of gaze when the junk period ends
                    else
                        currentGazePoint = (1 - gamma) * currentGazePoint + gamma * [eyeX, eyeY];       % Calculate smoothed gaze location using weighted moving average of current and previous locations
                        
                        Screen('DrawTexture', MainWindow, gazePointSprite, [], [currentGazePoint(1) - gazePointRadius, currentGazePoint(2) - gazePointRadius, currentGazePoint(1) + gazePointRadius, currentGazePoint(2) + gazePointRadius]);
                        Screen('DrawingFinished', MainWindow);
                        
                        stimSelected = checkEyesOnFixation(eyeX, eyeY);     % If some gaze has been detected, check whether this is on the fixation cross, or "everywhere else"
                        
                    end
                    
                else
                    stimSelected = 2;   % If no gaze detected, record gaze as "everywhere else"
                    fixationBadSamples = fixationBadSamples + 1;
                end
                
                endEyePeriod = double(ts(end));     % Last entry in timestamp data gives end time of polling period
                timeOnFixation(stimSelected) = timeOnFixation(stimSelected) + (endEyePeriod - startEyePeriod) / 10^6;   % Divided by 10^6 because eyetracker gives time in microseconds
                startEyePeriod = endEyePeriod;      % Start of next polling period is end of the last one
                
            end
            
            if timeOnFixation(1) >= fixationFixationTime         % If fixated on target
                fixated_on_fixation_cross = 1;
            elseif (endEyePeriod - startFixationTimeoutPeriod)/ 10^6 >= fixationTimeoutDuration        % If time since start of fixation period > fixation timeout limit
                fixated_on_fixation_cross = 2;
                fixationTimeout = 1;
            end
            
            Screen(MainWindow, 'Flip');     % Update display with gaze point
            
        end
        
    else
        
        while fixated_on_fixation_cross == 0
            WaitSecs(fixationPollingInterval);
            [mouseX, mouseY] = GetMouse;
            
            stimSelected = checkEyesOnFixation(mouseX, mouseY);
            
            timeOnFixation(stimSelected) = 1;
            
            if timeOnFixation(1) == 1
                fixated_on_fixation_cross = 1;
            elseif GetSecs - startFixationTime >= fixationTimeoutDuration
                fixated_on_fixation_cross = 2;
                fixationTimeout = 1;
            end
        end
    end
    
    fixationTime = GetSecs - startFixationTime;      % Length of fixation period in ms
    fixationPropGoodSamples = 1 - double(fixationBadSamples) / double(gazeCycle);
    
    Screen('DrawTexture', MainWindow, colouredFixationAOIsprite, [], fixAOIrect);
    Screen('DrawTexture', MainWindow, colouredFixationTex, [], fixRect);
    Screen(MainWindow, 'Flip');     % Present coloured fixation cross
    
    WaitSecs(yellowFixationDuration);
    
    FixOff = Screen(MainWindow, 'Flip');     % Show fixation cross without circle (and record off time)
    
    trialEnd = 0;
    timeOnLoc = zeros(1, stimLocs + 1);    % a slot for each stimulus location, and one for "everywhere else"
    stimSelected = stimLocs + 1;
    trialBadSamples = 0;
    gazeCycle = 0;
    arrayRowCounter = 2;    % Used to write EG data to the correct rows of an array. Starts at 2 because we write the first row in separately below (line marked ***)
    
    if savingGazeData
        trialEGarray(:,:) = 0;
    end
    
    Screen('DrawTexture', MainWindow, stimWindow);      % Copy stimuli to main window
    
    WaitSecs(postFixationPause-(GetSecs-FixOff)); % UPDATED 14/01/16 to ensure that post-fixation pause is as close to 150ms as possible
    
    startTrialTime = Screen(MainWindow, 'Flip', [], 1);      % Present stimuli, and record start time (st) when they are presented.
    
    if eyeVersion
        [lefteye, righteye, ts, ~] = tetio_readGazeData; % Empty eye tracker buffer
        
        startEyePeriod = double(ts(end));  % Take the timestamp of the last element in the buffer as the start of the first eye tracking period
        startEyeTrial = startEyePeriod;     % This will be used to judge timeouts below
        
        if savingGazeData
            trialEGarray(1,:) = [double(ts(length(ts))), lefteye(length(ts),:), righteye(length(ts),:)];       % *** First row of saved EG array gives start time
        end
        
        while trialEnd == 0
            WaitSecs(trialPollingInterval);      % Pause between updates of eye position
            [lefteye, righteye, ts, ~] = tetio_readGazeData;    % Get eye-tracker data since previous call
            
            if isempty(ts) == 0
                
                
                [eyeX, eyeY, validPoints] = findMeanGazeLocation(lefteye, righteye, length(ts));    % Find mean gaze location during the previous polling interval
                
                endPoint = arrayRowCounter + length(ts) - 1;
                if savingGazeData
                    trialEGarray(arrayRowCounter:endPoint,:) = [double(ts), lefteye, righteye];
                end
                
                arrayRowCounter = endPoint + 1;
                
                gazeCycle = gazeCycle + 1;
                
                if validPoints > 0
                    stimSelected = checkEyesOnStim(eyeX, eyeY);     % If some gaze has been detected, check whether this is on the fixation cross, or "everywhere else"
                else
                    trialBadSamples = trialBadSamples + 1;
                    stimSelected = stimLocs + 1;
                end
                
                endEyePeriod = double(ts(end));     % Last entry in timestamp data gives end time of polling period
                timeOnLoc(stimSelected) = timeOnLoc(stimSelected) + (endEyePeriod - startEyePeriod) / 10^6;   % Divided by 10^6 because eyetracker gives time in microseconds
                startEyePeriod = endEyePeriod;      % Start of next polling period is end of the last one
                
            end
            
            if timeOnLoc(targetLoc) >= requiredFixationTime         % If fixated on target
                trialEnd = 1;
            elseif (endEyePeriod - startEyeTrial)/ 10^6 >= timeoutDuration(exptPhase)        % If time since start of trial > timeout limit for this phase
                trialEnd = 2;
            end
            
        end
        
    else
        
        while trialEnd == 0
            WaitSecs(trialPollingInterval);
            [mouseX, mouseY] = GetMouse;
            
            stimSelected = checkEyesOnStim(mouseX, mouseY);
            
            timeOnLoc(stimSelected) = 1;
            
            if timeOnLoc(targetLoc) == 1
                trialEnd = 1;
            elseif GetSecs - startTrialTime >= timeoutDuration(exptPhase)
                trialEnd = 2;
            end
        end
    end
    
    
    rt = GetSecs - startTrialTime;      % Response time
    
    Screen('Flip', MainWindow);
    
    trialPropGoodSamples = 1 - double(trialBadSamples) / double(gazeCycle);
    
    timeout = 0;
    softTimeoutTrial = 0;
    omissionTrial = 0;
    trialPay = 0;
    lookedAtMainDistractor = 0;
    %lookedAtSecondDistractor = 0;
    
    if trialEnd == 2
        timeout = 1;
        fbStr = 'TOO SLOW\n\nPlease try to look at the diamond more quickly';
        
    else
        
        fbStr = 'correct';
        
        
        if exptPhase ~= 1       % If this is NOT practice
            
            %omissionCounter(distractType,1) = omissionCounter(distractType,1) + 1;
            
            if timeOnLoc(distractLoc) > omissionTimeLimit          % If people have looked at the distractor location (includes trials with no distractor actually presented)
                 omissionTrial = 1;
            end

            
            if rt > softTimeoutDuration      % If RT is greater than the "soft" timeout limit, don't get reward (but also don't get explicit timeout feedback)
                softTimeoutTrial = 1;
            end
            
            if omissionTrial ~= 1 && softTimeoutTrial ~= 1      % If this trial is NOT an omission trial or a soft timeout then reward, otherwise pay zero
                trialPay = winMultiplier(distractType);       % winMultiplier is a bad name now; it's actually the amount that they win
            else
                trialPay = 0;
            end
            
            if trialPay == 1
                centCents = 'point';
            else
                centCents = 'points';
            end
            
            sessionPay = sessionPay + trialPay;

            fbStr = ['+', num2str(trialPay), ' ', centCents];
            Screen('TextSize', MainWindow, 36);
            DrawFormattedText(MainWindow, [separatethousands(sessionPay+starting_total_points, ','), ' points total'], 'center', 760, white);

            
            if softTimeoutTrial == 1
                fbStr = ['+', num2str(trialPay), ' ', centCents,'\n\nToo slow'];
            end
            
            
            
        end
    end
    
    
    Screen('TextSize', MainWindow, 48);
    DrawFormattedText(MainWindow, fbStr, 'center', 'center', yellow, [], [], [], 1.3);
    %DrawFormattedText(instrWin, insStr, 0, 0 , white, 60, [], [], 1.5);
    
    
    Screen('Flip', MainWindow);
    
    WaitSecs(FB_duration);
    
    
    %     Screen('Flip', MainWindow);
    %     WaitSecs(iti);
    
    trialData = [block, trial, trialCounter, trials_since_break, targetLoc, distractLoc, fixationTime, fixationPropGoodSamples, fixationTimeout, trialPropGoodSamples, timeout, softTimeoutTrial, omissionTrial, rt, trialPay, sessionPay, distractType, timeOnLoc(1,:)];
    
    if trial == 1
        DATA.trialInfo(exptPhase).trialData = zeros(numTrials, size(trialData, 2));
    end
    DATA.trialInfo(exptPhase).trialData(trial,:) = trialData(:);
    
    DATA.fixationTimeouts(exptPhase) = DATA.fixationTimeouts(exptPhase) + fixationTimeout;
    DATA.trialTimeouts(exptPhase) = DATA.trialTimeouts(exptPhase) + timeout;
    DATA.sessionPayment = sessionPay;
    
    save(datafilename, 'DATA');
    
    if savingGazeData
        EGdatafilename = [EGdataFilenameBase, 'Ph', num2str(exptPhase), 'T', num2str(trial), '.mat'];
        FIXdatafilename = [EGdataFilenameBase, 'Ph', num2str(exptPhase), 'T', num2str(trial), '_FIX.mat'];
        FIXDATA = fixEGarray(1:fixArrayRowCounter-1,:);
        GAZEDATA = trialEGarray(1:arrayRowCounter-1,:);
        save(EGdatafilename, 'GAZEDATA');
        save(FIXdatafilename, 'FIXDATA');
    end
    
    RestrictKeysForKbCheck(KbName('c'));
    startITItime = Screen('Flip', MainWindow);
    
    [~, keyCode, ~] = KbWait([], 2, startITItime + iti);    % Wait for ITI duration while monitoring keyboard
    
    RestrictKeysForKbCheck([]);
    
    % If pressed C during ITI period, run an extraordinary calibration, otherwise
    % carry on with the experiment
    if sum(keyCode) > 0
        if eyeVersion
            try
                tetio_stopTracking;
            catch ME
                a = 1;
            end
            runPTBcalibration;
            tetio_startTracking;
            WaitSecs(initialPause);
        end
    end
    
    if mod(trial, exptTrialsPerBlock) == 0
        shTrialTypeArray = shuffleTrialorder(trialTypeArray, exptPhase);     % Re-shuffle order of distractors
        trialCounter = 0;
        %omissionCounter = zeros(8,1);
        DATA.blocksCompleted = block;
        block = block + 1;
        %if exptPhase > 1
         %   omissionTracker(2,:) = omissionTracker(1,randperm(length(omissionTracker(1,:)))); %randomise order of high val trials for irrelevant cue
          %  omissionTracker(4,:) = omissionTracker(3,randperm(length(omissionTracker(3,:)))); %randomise order of low val trials for irrelevant cue
           % omissionTracker([1,3,5:8],:) = zeros(6,numSingleDistractPerBlock);
        %end
        %Beeper;
    end
    
    if (mod(trial, exptTrialsBeforeBreak) == 0 && trial ~= numTrials);
        %             save(datafilename, 'DATA');
        
        take_a_break(breakDuration, initialPause, 0, sessionPay); %removed the additional calibrations that would occur throughout expt 14/01/16
        trials_since_break = 0;
    end
    
end

if eyeVersion
    try
        tetio_stopTracking;
    catch ME
        a = 1;
    end
end




Screen('Close', diamondTex);
Screen('Close', fixationTex);
Screen('Close', colouredFixationTex);
Screen('Close', fixationAOIsprite);
Screen('Close', colouredFixationAOIsprite);
Screen('Close', gazePointSprite);
Screen('Close', stimWindow);


end

function [eyeXpos, eyeYpos, sum_validities] = findMeanGazeLocation(lefteyeData, righteyeData, samples)
global screenRes

lefteyeValidity = zeros(samples,1);
righteyeValidity = zeros(samples,1);

for ii = 1 : samples
    if lefteyeData(ii,13) == 4 && righteyeData(ii,13) == 4
        lefteyeValidity(ii) = 0; righteyeValidity(ii) = 0;
    elseif lefteyeData(ii,13) == righteyeData(ii,13)
        lefteyeValidity(ii) = 0.5; righteyeValidity(ii) = 0.5;
    elseif lefteyeData(ii,13) < righteyeData(ii,13)
        lefteyeValidity(ii) = 1; righteyeValidity(ii) = 0;
    elseif lefteyeData(ii,13) > righteyeData(ii,13)
        lefteyeValidity(ii) = 0; righteyeValidity(ii) = 1;
    end
end

sum_validities = sum(lefteyeValidity) + sum(righteyeValidity);
if sum_validities > 0
    eyeXpos = screenRes(1) * (lefteyeData(:,7)' * lefteyeValidity + righteyeData(:,7)' * righteyeValidity) / sum_validities;
    eyeYpos = screenRes(2) * (lefteyeData(:,8)' * lefteyeValidity + righteyeData(:,8)' * righteyeValidity) / sum_validities;
    
    if eyeXpos > screenRes(1)       % This guards against the possible bug that Tom identified where gaze can be registered off-screen
        eyeXpos = screenRes(1);
    end
    if eyeYpos > screenRes(2)
        eyeYpos = screenRes(2);
    end
    
else
    eyeXpos = 0;
    eyeYpos = 0;
end

end




function detected = checkEyesOnStim(x, y)
global stimCentre aoiRadius stimLocs

detected = stimLocs + 1;
for s = 1 : stimLocs
    if (x - stimCentre(s,1))^2 + (y - stimCentre(s,2))^2 <= aoiRadius(s)^2
        detected = s;
        return
    end
end

end


function detected = checkEyesOnFixation(x, y)
global scr_centre fix_aoi_radius

detected = 2;
if (x - scr_centre(1))^2 + (y - scr_centre(2))^2 <= fix_aoi_radius^2
    detected = 1;
    return
end

end



function shuffArray = shuffleTrialorder(inArray, exptPhase)


acceptShuffle = 0;

while acceptShuffle == 0
    shuffArray = inArray(randperm(length(inArray)));     % Shuffle order of distractors
    acceptShuffle = 1;   % Shuffle always OK in practice phase
    if exptPhase == 2
        if shuffArray(1) > 4 || shuffArray(2) > 4
            acceptShuffle = 0;   % Reshuffle if either of the first two trials (which may well be discarded) are rare types
        end
    end
end

end




function take_a_break(breakDur, pauseDur, runCalib, totalPointsSoFar)

global MainWindow white

if runCalib == 0
    
    [~, ny, ~] = DrawFormattedText(MainWindow, ['Time for a break\n\nSit back, relax for a moment! You will be able to carry on in ', num2str(breakDur),' seconds\n\nRemember that you should be trying to move your eyes to the diamond as quickly and as accurately as possible!'], 'center', 'center', white, 50, [], [], 1.5);
    
    DrawFormattedText(MainWindow, ['Total so far = ', separatethousands(totalPointsSoFar, ','), ' points'], 'center', ny + 150, white, 50, [],[], 1.5);
    
    Screen(MainWindow, 'Flip');
    WaitSecs(breakDur);
    
else
    
    DrawFormattedText(MainWindow, 'Please fetch the experimenter', 'center', 'center', white);
    Screen(MainWindow, 'Flip');
    RestrictKeysForKbCheck(KbName('c'));   % Only accept C key to begin calibration
    KbWait([], 2);
    RestrictKeysForKbCheck([]);   % Re-enable all keys
    runCalibration;
    
end

RestrictKeysForKbCheck(KbName('Space'));   % Only accept spacebar

DrawFormattedText(MainWindow, 'Please put your chin back in the chinrest,\nand press the spacebar when you are ready to continue', 'center', 'center' , white, [], [], [], 1.5);
Screen(MainWindow, 'Flip');

KbWait([], 2);
Screen(MainWindow, 'Flip');

WaitSecs(pauseDur);

end


function [diamondTex, fixationTex, colouredFixationTex, fixationAOIsprite, colouredFixationAOIsprite, gazePointSprite, stimWindow] = setupStimuli(fs, gpr)

global MainWindow
global fix_aoi_radius
global white black gray yellow
global stim_size

perfectDiam = stim_size + 10;   % Used in FillOval to increase drawing speed

% This plots the points of a large diamond, that will be filled with colour
d_pts = [stim_size/2, 0;
    stim_size, stim_size/2;
    stim_size/2, stim_size;
    0, stim_size/2];


% Create an offscreen window, and draw the two diamonds onto it to create a diamond-shaped frame.
diamondTex = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 stim_size stim_size]);
Screen('FillPoly', diamondTex, gray, d_pts);

% Create an offscreen window, and draw the fixation cross in it.
fixationTex = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 fs fs]);
Screen('DrawLine', fixationTex, white, 0, fs/2, fs, fs/2, 2);
Screen('DrawLine', fixationTex, white, fs/2, 0, fs/2, fs, 2);


colouredFixationTex = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 fs fs]);
Screen('DrawLine', colouredFixationTex, yellow, 0, fs/2, fs, fs/2, 4);
Screen('DrawLine', colouredFixationTex, yellow, fs/2, 0, fs/2, fs, 4);

% Create a sprite for the circular AOI around the fixation cross
fixationAOIsprite = Screen('OpenOffscreenWindow', MainWindow, black, [0 0  fix_aoi_radius*2  fix_aoi_radius*2]);
Screen('FrameOval', fixationAOIsprite, white, [], 1, 1);   % Draw fixation aoi circle

colouredFixationAOIsprite = Screen('OpenOffscreenWindow', MainWindow, black, [0 0  fix_aoi_radius*2  fix_aoi_radius*2]);
Screen('FrameOval', colouredFixationAOIsprite, yellow, [], 2, 2);   % Draw fixation aoi circle


% Create a marker for eye gaze
gazePointSprite = Screen('OpenOffscreenWindow', MainWindow, black, [0 0 gpr*2 gpr*2]);
Screen('FillOval', gazePointSprite, yellow, [0 0 gpr*2 gpr*2], perfectDiam);       % Draw stimulus circles

% Create a full-size offscreen window that will be used for drawing all
% stimuli and targets (and fixation cross) into
stimWindow = Screen('OpenOffscreenWindow', MainWindow, black);
end
