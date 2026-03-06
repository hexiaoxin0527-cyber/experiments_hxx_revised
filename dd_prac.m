% NB: PsychToolbox will only let this run if you go to settings > system >
% display and select "Extend these displays" under "Multiple displays",
% select screen 2 from the big graphic at the top of the page, and check
% the "Make this my main display" box at the bottom of the page.

% NB: In order for this to work, check that the buad rate of the USB serial
function dd_prac

proj_path = get_project_path();
pt = readtable(fullfile(proj_path, 'participants.csv'));
pid = pt.id(end);
%{\r\nproj_path = fullfile('C:', 'Users', 'isaac', 'Projects', 'eeg-eft-task');\r\npid = 1234;\r\n%}
%% Experiment setup

Screen('Preference', 'SkipSyncTests', 0); % VBL synchronization--only set the parameter to 1 for testing
screenNum = 0;
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
ListenChar(2);

%% Pre-generate trials

% Read events
efts = read_eft;
titles = {efts.title};
cued_delays = cellfun(@str2double, {efts.days});
% Read uncued delays
uncued_delays = read_uncued_delays;

% Pre-generate trials
trials = [];
% Create a cued trial
curr_trial = [];
curr_trial.del_val = round(50+rand*50);
curr_trial.del = cued_delays(1);
curr_trial.ctx = sprintf('%s', titles{1});
curr_trial.cued = true;
curr_trial.rev_opts = false;
trials = [trials curr_trial];
% Create an uncued trial
curr_trial = [];
curr_trial.del_val = round(50+rand*50);
curr_trial.del = uncued_delays(1);
curr_trial.ctx = '########';
curr_trial.cued = false;
curr_trial.rev_opts = false;
trials = [trials curr_trial];
% Create a cued trial
curr_trial = [];
curr_trial.del_val = round(50+rand*50);
curr_trial.del = cued_delays(3);
curr_trial.ctx = sprintf('%s', titles{2});
curr_trial.cued = true;
curr_trial.rev_opts = true;
trials = [trials curr_trial];
% Create an uncued trial
curr_trial = [];
curr_trial.del_val = round(50+rand*50);
curr_trial.del = uncued_delays(end-1);
curr_trial.ctx = '########';
curr_trial.cued = false;
curr_trial.rev_opts = true;
trials = [trials curr_trial];

%% Run experiment

% Countdown briefly
n_cd_secs = 3;
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

for trial_idx = 1:numel(trials)
    % FYI:
    fprintf('Trial %d / %d\n', trial_idx, numel(trials));
    % Fixation cross
    Screen('FillRect', wPtr, black);
    DrawFormattedText(wPtr, '+', 'center', 'center', white);
    Screen('Flip', wPtr);
    WaitSecs(1);
    % Context, if any
    txt = sprintf('%s', trials(trial_idx).ctx);
    DrawFormattedText(wPtr, txt, 'center', 'center', white);
    Screen('Flip', wPtr);
    WaitSecs(2);
    % ISI
    Screen('FillRect', wPtr, black);
    Screen('Flip', wPtr);
    WaitSecs(1 + 0.5*rand);
    % Delay
    txt = sprintf('%d days', trials(trial_idx).del);
    DrawFormattedText(wPtr, txt, 'center', 'center', white);
    Screen('Flip', wPtr);
    WaitSecs(2);
    % ISI
    Screen('FillRect', wPtr, black);
    Screen('Flip', wPtr);
    WaitSecs(1 + 0.5*rand);
    % Delayed value
    DrawFormattedText(wPtr, sprintf('$%d', trials(trial_idx).del_val), 'center', 'center', white);
    Screen('Flip', wPtr);
    WaitSecs(2);
    % ISI
    Screen('FillRect', wPtr, black);
    Screen('Flip', wPtr);
    WaitSecs(1 + 0.5*rand);
    % Choice
    if trials(trial_idx).rev_opts
        DrawFormattedText(wPtr, sprintf('Choice?\n\n1: Later option\n\n2: Immediate option\n\n3: Skip'), 'center', 'center', white);
    else
        DrawFormattedText(wPtr, sprintf('Choice?\n\n1: Immediate option\n\n2: Later option\n\n3: Skip'), 'center', 'center', white);
    end
    Screen('Flip', wPtr);
    while true
        [key_down, key_time, key_code] = KbCheck;
        WaitSecs(0.001);
        if key_down
            key_pressed = find(key_code) - 48;
            if nnz(key_code) == 1
                if any(key_pressed == 1:3)
                    break
                end
            end
        end
    end
    % Query vividness?
    if trials(trial_idx).cued
        DrawFormattedText(wPtr, sprintf('Vivid?\n\n1: No image\n\n4: Image as clear and\nvivid as real life'), 'center', 'center', white);
        Screen('Flip', wPtr);
        while true
            [key_down, key_time, key_code] = KbCheck;
            WaitSecs(0.001);
            if key_down
                key_pressed = find(key_code) - 48;
                if nnz(key_code) == 1
                    if any(key_pressed == 1:4)
                        break
                    end
                end
            end
        end
        % Clear screen
        Screen('FillRect', wPtr, black);
        Screen('Flip', wPtr);
        WaitSecs(0.5);
    else
        trials(trial_idx).viv = nan;
        trials(trial_idx).viv_time = nan;
    end
    % ISI
    Screen('FillRect', wPtr, black);
    Screen('Flip', wPtr);
    WaitSecs(1 + 0.5*rand);
end

sca
ListenChar(0);

fprintf('Practice run complete!\n');

end
