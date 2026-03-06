
% NB: PsychToolbox will only let this run if you go to settings > system >
% display and select "Extend these displays" under "Multiple displays",
% select screen 2 from the big graphic at the top of the page, and check
% the "Make this my main display" box at the bottom of the page.

% NB: In order for this to work, check that the buad rate of the USB serial
% port (COM4 at the time of writing) is set to 115200 (Device Manager >
% Ports > USB Serial Port > Port settings

function dd_prac

proj_path = fullfile('E:', 'isaac', 'dd-eft');
pt = readtable(fullfile(proj_path, 'participants.csv'));
pid = pt.id(end);

%% Experiment setup

Screen('Preference', 'SkipSyncTests', 0); % VBL synchronization--only set the parameter to 1 for testing
% mons = size(get(0, 'MonitorPositions'));
% screenNum = mons(1)-1;sca
screenNum = 1;
[wPtr, wRect] = Screen('OpenWindow', screenNum); % Get pointer to window
% NB: rect arguments to Screen() function are:
% [left top right bottom], positive directions being leftward and downward
HideCursor;
[x0, y0] = RectCenter(wRect); % Define the center of the screen
% Find the black and white color
black  = BlackIndex(wPtr);
white  = WhiteIndex(wPtr);
Screen('TextFont', wPtr, 'Courier New');
Screen('TextSize', wPtr, 28);
% Stim codes

%% Pre-generate trials

% Read event titles
fid = fopen(fullfile(proj_path, 'data', sprintf('%d', pid), 'writing.txt'), 'r');
test_str = 'title: ';
titles = {};
while true
    curr = fgetl(fid);
    if curr == -1
        break
    elseif strcmp(test_str, curr(1:numel(test_str)))
        titles{end + 1} = curr(numel(test_str)+1:end);
    end
end
fclose(fid);

% Pre-generate trials
trials = [];
% Create a cued trial
curr_trial = [];
curr_trial.del_val = round(50 + 50*rand);
curr_trial.imm_val = round(rand*curr_trial.del_val);
curr_trial.del = 30;
curr_trial.ctx = sprintf('%s', titles{1});
curr_trial.cued = true;
trials = [trials curr_trial];
% Create an uncued trial
curr_trial = [];
curr_trial.del_val = round(50 + 50*rand);
curr_trial.imm_val = round(rand*curr_trial.del_val);
curr_trial.del = 60;
curr_trial.ctx = 'xxxxxxxx';
curr_trial.cued = false;
trials = [trials curr_trial];
% Create a cued trial
curr_trial = [];
curr_trial.del_val = round(50 + 50*rand);
curr_trial.imm_val = round(rand*curr_trial.del_val);
curr_trial.del = 180;
curr_trial.ctx = sprintf('%s', titles{2});
curr_trial.cued = true;
trials = [trials curr_trial];
% Create an uncued trial
curr_trial = [];
curr_trial.del_val = round(50 + 50*rand);
curr_trial.imm_val = round(rand*curr_trial.del_val);
curr_trial.del = 360;
curr_trial.ctx = 'xxxxxxxx';
curr_trial.cued = false;
trials = [trials curr_trial];

%% Run experiment

% Countdown while the exprimenter leaves
n_cd_secs = 20;
while n_cd_secs > 0
    Screen('FillRect', wPtr, black);
    DrawFormattedText(wPtr, sprintf('Practice will begin in\n\n%d', n_cd_secs), 'center', 'center', white);
    Screen('Flip', wPtr);
    WaitSecs(1);
    n_cd_secs = n_cd_secs - 1;
end

Screen('FillRect', wPtr, black);
Screen('Flip', wPtr);
WaitSecs(1);

% Listen for keyboard input
ListenChar(1);
for trial_idx = 1:numel(trials)
    % FYI:
    fprintf('Trial %d / %d\n', trial_idx, numel(trials));
    % Fixation cross
    Screen('FillRect', wPtr, black);
    DrawFormattedText(wPtr, '.', 'center', 'center', white);
    Screen('Flip', wPtr);
    WaitSecs(1);
    % Immediate value
    Screen('FillRect', wPtr, black);
    DrawFormattedText(wPtr,...
        sprintf('$%d now', trials(trial_idx).imm_val),...
        'center', 'center', white);
    Screen('Flip', wPtr);
    WaitSecs(2);
    % ISI
    Screen('FillRect', wPtr, black);
    Screen('Flip', wPtr);
    WaitSecs(0.5);
    % Delayed value
    DrawFormattedText(wPtr,...
        sprintf('$%d', trials(trial_idx).del_val),...
        'center', 'center', white);
    Screen('Flip', wPtr);
    WaitSecs(1);
    Screen('FillRect', wPtr, black);
    Screen('Flip', wPtr);
    WaitSecs(0.5);
    % Delay
    txt = sprintf('%d days', trials(trial_idx).del);
    DrawFormattedText(wPtr, txt, 'center', 'center', white);
    Screen('Flip', wPtr);
    WaitSecs(1);
    Screen('FillRect', wPtr, black);
    Screen('Flip', wPtr);
    WaitSecs(0.5);
    % Context, if any
    txt = sprintf('%s', trials(trial_idx).ctx);
    DrawFormattedText(wPtr, txt, 'center', 'center', white);
    Screen('Flip', wPtr);
    % Hang time
    WaitSecs(3);
    Screen('FillRect', wPtr, black);
    Screen('Flip', wPtr);
    WaitSecs(0.5);
    % Query vividness?
    if trials(trial_idx).cued
        DrawFormattedText(wPtr, sprintf('Vivid?\n\n1: No image\n\n4: Image as clear and\nvivid as real life'), 'center', 'center', white);
        Screen('Flip', wPtr);
        while true
            FlushEvents('keyDown');
            [c, st] = GetChar;
            if ismember(c, '1':'4')
                c = str2double(c);
                break
            end
        end
        % Clear screen
        Screen('FillRect', wPtr, black);
        Screen('Flip', wPtr);
        WaitSecs(0.5);
    end
    % Choice
    imm_opt = sprintf('$%d now', trials(trial_idx).imm_val);
    del_opt = sprintf('$%d in %d days', trials(trial_idx).del_val, trials(trial_idx).del);
    if trials(trial_idx).cued
        del_opt = sprintf('%s (%s)', del_opt, trials(trial_idx).ctx);
    end
    opts = {imm_opt del_opt};
    if rand < 0.5
        flipped = true;
        opts = fliplr(opts);
    else
        flipped = false;
    end
    txt = sprintf('1: %s\n\n2: %s', opts{:});
    DrawFormattedText(wPtr, txt, 'center', 'center', white);
    Screen('Flip', wPtr);
    while true
        FlushEvents('keyDown');
        [c, st] = GetChar;
        if ismember(c, '12')
            c = str2double(c);
            break
        end
    end
    % Clear screen
    Screen('FillRect', wPtr, black);
    Screen('Flip', wPtr);
    % Record response
    opts = {'imm' 'del'};
    if flipped
        opts = fliplr(opts);
    end
    WaitSecs(0.2);
end
sca
ListenChar(0);

fprintf('Practice run complete!\n');

end