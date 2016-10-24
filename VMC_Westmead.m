
clear all

Screen('Preference', 'VisualDebuglevel', 3);    % Hides the hammertime PTB startup screen

Screen('CloseAll');

clc;

functionFoldername = fullfile(pwd, 'functions');    % Generate file path for "functions" folder in current working directory
addpath(genpath(functionFoldername));       % Then add path to this folder and all subfolders

global MainWindow screenNum
global scr_centre DATA datafilename p_number
global centOrCents
global screenRes
global distract_col colourName
global white black gray yellow
global bigMultiplier smallMultiplier
global calibrationNum
global awareInstrPause
global starting_total starting_total_points
global orange green blue pink sessionPoints

global realVersion
global eyeVersion
global laptopVersion viewDistance monitorDims

eyeVersion = false; % set to true to test eyetracking
realVersion = false; % set to true for correct numbers of trials etc.
laptopVersion = false; % set to true to scale stimuli for laptop screen dimensions

commandwindow;

if realVersion
    screenNum = 0;
    Screen('Preference', 'SkipSyncTests', 0); % Enables PTB calibration
    awareInstrPause = 18;
else
    screens = Screen('Screens');
    screenNum = 1; %max(screens);
    Screen('Preference', 'SkipSyncTests', 2); %Skips PTB calibrations
    fprintf('\n\nEXPERIMENT IS BEING RUN IN DEBUGGING MODE!!! IF YOU ARE RUNNING A ''REAL'' EXPT, QUIT AND CHANGE realVersion TO true\n\n');
    awareInstrPause = 1;
end

if laptopVersion
    DPI = 96; % will probably need to change
    viewDistance = 60; %viewing distance in cm
else
    DPI = 96;
    viewDistance = 60; %viewing distance in cm
end

set(0, 'ScreenPixelsPerInch', DPI);
set(0, 'units', 'centimeters');
monitorDims = get(0, 'screensize');
monitorDims = monitorDims(3:4);

bigMultiplier = 500;    % Points multiplier for trials with high-value distractor
smallMultiplier = 10;   % Points multiplier for trials with low-value distractor

if smallMultiplier == 1
    centOrCents = 'point';
else
    centOrCents = 'points';
end

starting_total = 0;

calibrationNum = 0;

% *************************************************************************
%
% Initialization and connection to the Tobii Eye-tracker
%
% *************************************************************************
if eyeVersion
    disp('Initializing tetio...');
    tetio_init();
    
    disp('Browsing for trackers...');
    trackerinfo = tetio_getTrackers();
    trackerId = trackerinfo(1).ProductId;
    
    fprintf('Connecting to tracker "%s"...\n', trackerId);
    tetio_connectTracker(trackerId)
    
    currentFrameRate = tetio_getFrameRate;
    fprintf('Connected!  Sample rate: %d Hz.\n', currentFrameRate);
end

if exist('BehavData', 'dir') == 0
    mkdir('BehavData');
end
if exist('CalibrationData', 'dir') == 0
    mkdir('CalibrationData');
end
if exist('EyeData', 'dir') == 0
    mkdir('EyeData');
end

if realVersion
    
    inputError = 1;
    
    while inputError == 1
        inputError = 0;
        
        p_number = input('Participant number  ---> ');
        
        group = 'a';
        while group ~= 'Y' && group ~= 'y' && group ~= 'N' && group ~= 'n'
            group = input('Control subject? (Y/N) --- > ', 's');
            if isempty(group);
                group = 'a';
            elseif group == 'y' || group == 'Y'
                 groupFileEnd = '_C';
                 p_group = 2; % 2 = control
            elseif group == 'n' || group == 'N'
                groupFileEnd = '_P';
                p_group = 1; % 1 = patient
            end
        end
        
        
        datafilename = ['BehavData\VMC_Westmead_dataP', num2str(p_number), groupFileEnd];
        
        
        if exist([datafilename, '.mat'], 'file') == 2
            disp(['Data for participant ', num2str(p_number),' already exist'])
            inputError = 1;
        end
        
        
    end
    
    colBalance = 0;
    while colBalance < 1 || colBalance > 2
        colBalance = input('Counterbalance (1-2)---> ');
        if isempty(colBalance); colBalance = 0; end
    end
    
    p_age = input('Participant age ---> ');
    p_sex = 'a';
    while p_sex ~= 'm' && p_sex ~= 'f' && p_sex ~= 'M' && p_sex ~= 'F' && p_sex ~= 'o' && p_sex ~= 'O'
        p_sex = input('Participant gender (M/F/O) ---> ', 's');
        if isempty(p_sex);
            p_sex = 'a';
        elseif p_sex == 'o' || p_sex == 'O'
            p_genderInfo = input('(Optional) Please specify --> ', 's');
        elseif p_sex == 'm' || p_sex == 'M'
            p_genderInfo = 'Male';
        elseif p_sex == 'f' || p_sex == 'F'
            p_genderInfo = 'Female';
        end
    end
    
    p_hand = 'a';
    while p_hand ~= 'r' && p_hand ~= 'l' && p_hand ~= 'R' && p_hand ~= 'L'
        p_hand = input('Participant hand (R/L) ---> ','s');
        if isempty(p_hand); p_hand = 'a'; end
    end
    
else
    
    p_number = 1;
    colBalance = 1;
    p_group = 3;
    p_sex = 'm';
    p_genderInfo = 'male';
    p_age = 123;
    p_hand = 'r';
    
end

datafilename = [datafilename, '.mat'];

starting_total_points = 0;

DATA.subject = p_number;
DATA.counterbal = colBalance;
%DATA.instrCondition = instrCondition;
DATA.age = p_age;
DATA.sex = p_sex;
DATA.genderInfo = p_genderInfo;
DATA.hand = p_hand;
DATA.group = p_group;
DATA.start_time = datestr(now,0);
if eyeVersion
    DATA.trackerID = trackerId;
end
DATA.totalBonus = 0;
DATA.session_Bonus = 0;
DATA.session_Points = 0;
DATA.actualBonusSession = 0;

if eyeVersion
    EGfolderName = 'Data\EyeData';
    if p_group == 1
        EGgroupfolderNameString = 'Pat';
    else
        EGgroupfolderNameString = 'Con';
    end
    EGsubfolderNameString = ['\P', num2str(p_number)];
    if exist([EGfolderName,'\', EGgroupfolderNameString], 'dir') ~= 7
        mkdir(EGfolderName, EGgroupfolderNameString);
    end        
    mkdir(EGgroupfolderNameString, EGsubfolderNameString);
    EGdataFilenameBase = [EGfolderName, '\', EGgroupfolderNameString, EGsubfolderNameString, '\GazeData', EGsubfolderNameString];
end

% *******************************************************

KbName('UnifyKeyNames');    % Important for some reason to standardise keyboard input across platforms / OSs.

Screen('Preference', 'DefaultFontName', 'Courier New');

% generate a random seed using the clock, then use it to seed the random
% number generator
rng('shuffle');
randSeed = randi(30000);
DATA.rSeed = randSeed;
rng(randSeed);

% Get screen resolution, and find location of centre of screen
[scrWidth, scrHeight] = Screen('WindowSize',screenNum);
screenRes = [scrWidth scrHeight];
scr_centre = screenRes / 2;

setupMainWindowScreen;
HideCursor;
DATA.frameRate = round(Screen(MainWindow, 'FrameRate'));

% now set colors - UPDATED TO FOUR COLOURS 3/5/16 yet to check luminance
white = WhiteIndex(MainWindow);
black = BlackIndex(MainWindow);
gray = [70 70 70];   %[100 100 100]
orange = [193 95 30];
green = [54 145 65];
blue = [37 141 165]; %[87 87 255];
pink = [193 87 135];
yellow = [255 255 0];
Screen('FillRect',MainWindow, black);

distract_col = zeros(3,3);

distract_col(3,:) = yellow;       % Practice colour
switch colBalance
    case 1
        distract_col(1,:) = orange;      % High-value distractor colour, second colour is the irrelevant distractor
        distract_col(2,:) = blue;      % Low-value distractor colour, second colour is the irrelevant distract
        colourName = char('ORANGE','BLUE');
    case 2
        distract_col(1,:) = blue;      % High-value distractor colour, second colour is the irrelevant distractor
        distract_col(2,:) = orange;      % Low-value distractor colour, second colour is the irrelevant distractor
        colourName = char('BLUE','ORANGE');
end

phaseLength = zeros(3,1);

sessionPoints = 0;
 
initialInstructions;

if eyeVersion
    runCalibration;
end

pressSpaceToBegin;

phaseLength(1) = runTrials(1);     % Practice phase

save(datafilename, 'DATA');

DrawFormattedText(MainWindow, 'Please let the experimenter know\n\nyou are ready to continue', 'center', 'center' , white);
Screen(MainWindow, 'Flip');

RestrictKeysForKbCheck(KbName('t'));   % Only accept T key to continue
KbWait([], 2);

exptInstructions;

if realVersion
    save(datafilename, 'DATA');
end

RestrictKeysForKbCheck([KbName('c'), KbName('t')]);   % Only accept keypresses from keys C and t
KbWait([], 2);
[~, ~, keyCode] = KbCheck;      % This stores which key is pressed (keyCode)
keyCodePressed = find(keyCode, 1, 'first');     % If participant presses more than one key, KbCheck will create a keyCode array. Take the first element of this array as the response
keyPressed = KbName(keyCodePressed);    % Get name of key that was pressed
RestrictKeysForKbCheck([]); % Re-enable all keys

if keyPressed == 'c' && eyeVersion == true;
    runCalibration;
end

pressSpaceToBegin;

phaseLength(2) = runTrials(2);
%phaseLength(3) = runTrials(3);

awareInstructions;
awareTest;

%sessionBonus = sessionPoints / 160;   % convert points into cents at rate of 13 000 points = $1. Updated 13/5.

%sessionBonus = 10 * ceil(sessionBonus/10);        % ... round this value UP to nearest 10 cents
%sessionBonus = sessionBonus / 100;    % ... then convert back to dollars

%DATA.session_Bonus = sessionBonus;
DATA.session_Points = sessionPoints;

%totalBonus = starting_total + sessionBonus;

% if totalBonus < 7.10        %check to see if participant earned less than $10.10; if so, adjust payment upwards
%     actual_bonus_payment = 7.10;
% else
%     actual_bonus_payment = totalBonus;
% end
% 
% DATA.totalBonus = totalBonus;
% DATA.actualTotalBonus = actual_bonus_payment;
DATA.end_time = datestr(now,0);

save(datafilename, 'DATA');

[~, ny, ~] = DrawFormattedText(MainWindow, ['SESSION COMPLETE\n\nPoints in this session = ', separatethousands(sessionPoints, ',')], 'center', 'center' , white, [], [], [], 1.4);

fid1 = fopen('BehavData\_TotalBonus_summary.csv', 'a');
fprintf(fid1,'%d,%f\n', p_number, sessionPoints);
fclose(fid1);

DrawFormattedText(MainWindow, '\n\nPlease fetch the experimenter', 'center', ny , white, [], [], [], 1.5);

Screen(MainWindow, 'Flip');

if eyeVersion
    overallEGdataFilename = [EGfolderName, '\', EGgroupfolderNameString, '\GazeData', EGsubfolderNameString, '.mat'];
    
    minPhase = 2;
    maxPhase = 2;
    
    for exptPhase = minPhase:maxPhase
        
        for trial = 1:phaseLength(exptPhase)
            inputFilename = [EGdataFilenameBase, 'Ph', num2str(exptPhase), 'T', num2str(trial), '.mat'];
            load(inputFilename);
            ALLGAZEDATA.EGdataPhase(exptPhase).EGdataTrial(trial).data = GAZEDATA;
            clear GAZEDATA;
        end
    end
    
    save(overallEGdataFilename, 'ALLGAZEDATA');
    rmdir([EGfolderName,'\', EGgroupfolderNameString, EGsubfolderNameString], 's');
end

RestrictKeysForKbCheck(KbName('q'));   % Only accept Q key to quit
KbWait([], 2);

rmpath(genpath(functionFoldername));       % Then add path to this folder and all subfolders
Snd('Close');

Screen('Preference', 'SkipSyncTests',0);

Screen('CloseAll');

clear all
