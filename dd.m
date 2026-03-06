% NB: PsychToolbox will only let this run if you go to settings > system >
% display and, select "Extend these displays" under "Multiple displays",
% select screen 2 from the big graphic at the top of the page, and check
% the "Make this my main display" box at the bottom of the page

function dd

% --- DEBUG 开关 ---
is_debug = false; % true = 调试模式(窗口透明/可退出/短倒计时); false = 正式实验
% ------------------

proj_path = get_project_path();
pt = readtable(fullfile(proj_path, 'participants.csv'));
pid = pt.id(end);

try % <--- 开始 Try 保护，防止报错卡死

    %% Pre-generate trials
    
    % Read events
    efts = read_eft;
    % 补全之前缺失的变量定义
    cued_delays = cellfun(@str2double, {efts.days});
    uncued_delays = read_uncued_delays;
    
    % Experiment parameters
    delays = [30 90 180 360];
    n_del_vals = 16;
    del_vals = round(linspace(50, 100, n_del_vals));
    % Pre-generate trials
    trials = [];
    for eft_idx = 1:numel(efts)
        % Each delayed value will be offered twice: once with a scenario, once
        % without.
        for del_val_idx = 1:numel(del_vals)
            % Cued trial
            curr_trial = [];
            curr_trial.del_val = del_vals(del_val_idx);
            curr_trial.del = cued_delays(eft_idx);
            curr_trial.ctx = efts(eft_idx).title;
            curr_trial.cued = true;
            curr_trial.rev_opts = rand < 0.5;
            trials = [trials curr_trial];
            % Uncued trial
            curr_trial = [];
            curr_trial.del_val = del_vals(del_val_idx);
            curr_trial.del = uncued_delays(eft_idx);
            curr_trial.ctx = repmat('#', 1, 10);
            curr_trial.cued = false;
            curr_trial.rev_opts = rand < 0.5;
            trials = [trials curr_trial];
        end
    end
    % Randomize
    trials = trials(randperm(numel(trials)));
    
    %% Experiment setup
    
    KbName('UnifyKeyNames'); % 确保按键名称跨平台统一
    
    if is_debug
        Screen('Preference', 'SkipSyncTests', 1); % 调试模式跳过同步测试
        PsychDebugWindowConfiguration; % 调试模式：半透明窗口，允许鼠标操作 MATLAB
    else
        Screen('Preference', 'SkipSyncTests', 0); % VBL synchronization--only set the parameter to 1 for testing
    end
    
    screenNum = 0;
    [wPtr, wRect] = Screen('OpenWindow', screenNum); % Get pointer to window
    % NB: rect arguments to Screen() function are:
    % [left top right bottom], positive directions being leftward and downward
    
    if ~is_debug
        HideCursor; % 只有正式实验才隐藏鼠标
    end
    
    [x0, y0] = RectCenter(wRect); % Define the center of the screen
    % Find the black and white color
    black  = BlackIndex(wPtr);
    white  = WhiteIndex(wPtr);
    Screen('TextFont', wPtr, 'Courier New');
    Screen('TextSize', wPtr, 28);
    % Stim codes
    ev_types = {
        'imm_val'
        'del_val'
        'del_del'
        'del_ctx'
        'choice'
        'viv'
    }';
    codes = [];
    nm = 20;
    n = nm;
    for curr_ev = ev_types
        codes.(curr_ev{:}) = uint8(n);
        n = n + nm;
    end
    
    % Listen for keyboard input
    if ~is_debug
        ListenChar(2); % 只有正式实验才屏蔽 MATLAB 键盘输入
    end
    
    %% Run experiment
    
    % Countdown while the exprimenter leaves
    if is_debug
        n_cd_secs = 1; % 调试模式倒计时 1 秒
    else
        n_cd_secs = 20;
    end
    
    while n_cd_secs > 0
        Screen('FillRect', wPtr, black);
        DrawFormattedText(wPtr, sprintf('Experiment will begin in\n\n%d', n_cd_secs), 'center', 'center', white);
        Screen('Flip', wPtr);
        WaitSecs(1);
        n_cd_secs = n_cd_secs - 1;
    end
    
    Screen('FillRect', wPtr, black);
    Screen('Flip', wPtr);
    WaitSecs(1);
    
    % Pre-determine breaks
    n_between_breaks = 20;
    for trial_idx = 1:numel(trials)
        % Break time?
        if mod(trial_idx, n_between_breaks) == 0
            Screen('FillRect', wPtr, black);
            DrawFormattedText(wPtr, sprintf('You can take a pause now if you need to.\n\nTrial %d/%d will begin when you press "1".\n\nThank you very much for\nparticipating in this study.', trial_idx, numel(trials)), 'center', 'center', white);
            Screen('Flip', wPtr);
            while true
                [key_down, key_time, key_code] = KbCheck;
                WaitSecs(0.001);
                
                if key_down
                    % --- ESC 检测 ---
                    if key_code(KbName('ESCAPE'))
                        error('User pressed ESC to exit.');
                    end
                    % ---------------
                    
                    if nnz(key_code) == 1
                        if find(key_code) == 49
                            break
                        end
                    end
                end
            end
            Screen('FillRect', wPtr, black);
            Screen('Flip', wPtr);
            WaitSecs(1);
        end
        % FYI:
        fprintf('Trial %d / %d\n', trial_idx, numel(trials));
        % Fixation cross
        Screen('FillRect', wPtr, black);
        DrawFormattedText(wPtr, '', 'center', 'center', white);
        Screen('Flip', wPtr);
        WaitSecs(1);
        % Time and context
        txt = sprintf('%d days\n(%s)', trials(trial_idx).del, trials(trial_idx).ctx);
        DrawFormattedText(wPtr, txt, 'center', 'center', white);
        [~, trials(trial_idx).del_ctx_displaytime] = Screen('Flip', wPtr);
        trials(trial_idx).del_ctx_triggercode = codes.del_ctx;
        WaitSecs(2);
        % ISI
        Screen('FillRect', wPtr, black);
        Screen('Flip', wPtr);
        WaitSecs(1 + 0.5*rand);
        % Delayed value
        DrawFormattedText(wPtr, sprintf('$%d', trials(trial_idx).del_val), 'center', 'center', white);
        [~, trials(trial_idx).del_val_displaytime] = Screen('Flip', wPtr);
        trials(trial_idx).del_val_triggercode = codes.del_val;
        WaitSecs(2);
        % ISI
        Screen('FillRect', wPtr, black);
        Screen('Flip', wPtr);
        WaitSecs(1 + 0.5*rand);
        
        % --- STEP 1: Choice (DISPLAY & RESPONSE) ---
        if trials(trial_idx).rev_opts
            % 1 = later, 2 = immediate
            DrawFormattedText(wPtr, sprintf('Choice?\n\n1: Later option\n\n2: Immediate option\n\n3: Skip'), 'center', 'center', white);
            curr_opts = {'del' 'imm' 'na'};
        else
            % 1 = immediate, 2 = later
            DrawFormattedText(wPtr, sprintf('Choice?\n\n1: Immediate option\n\n2: Later option\n\n3: Skip'), 'center', 'center', white);
            curr_opts = {'imm' 'del' 'na'};
        end
        [~, trials(trial_idx).choice_displaytime] = Screen('Flip', wPtr);
        trials(trial_idx).choice_triggercode = codes.choice;
        
        % [MOVED] Record choice response HERE (before vividness)
        while true
            [key_down, key_time, key_code] = KbCheck;
            WaitSecs(0.001);
            if key_down
                % --- ESC 检测 ---
                if key_code(KbName('ESCAPE'))
                    error('User pressed ESC to exit.');
                end
                % ---------------
    
                key_pressed = find(key_code) - 48;
                if nnz(key_code) == 1
                    if any(key_pressed == 1:3)
                        break
                    end
                end
            end
        end
        trials(trial_idx).choice = curr_opts{key_pressed};
        trials(trial_idx).choice_time = key_time;
        
        % Wait for key release to prevent accidental skip of next screen
        while KbCheck; WaitSecs(0.01); end
        
        % --- STEP 2: Query vividness? (If Cued) ---
        if trials(trial_idx).cued
            DrawFormattedText(wPtr, sprintf('Vivid?\n\n1: No image\n\n4: Image as clear and\nvivid as real life'), 'center', 'center', white);
            [~, trials(trial_idx).viv_displaytime] = Screen('Flip', wPtr);
            trials(trial_idx).viv_triggercode = codes.viv;
            
            while true
                [key_down, key_time, key_code] = KbCheck;
                WaitSecs(0.001);
                if key_down
                    % --- ESC 检测 ---
                    if key_code(KbName('ESCAPE'))
                        error('User pressed ESC to exit.');
                    end
                    % ---------------
    
                    key_pressed = find(key_code) - 48;
                    if nnz(key_code) == 1
                        if any(key_pressed == 1:4)
                            break
                        end
                    end
                end
            end
            trials(trial_idx).viv = key_pressed;
            trials(trial_idx).viv_time = key_time;
            
            % Wait for key release
            while KbCheck; WaitSecs(0.01); end
            
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
    
    sca % Close screen
    ListenChar(0); % Release keyboard
    ShowCursor;
    
    % Save trial data to CSV
    beh_table = struct2table(trials);
    save_path = fullfile(proj_path, 'data', sprintf('%d', pid), 'beh.csv');
    writetable(beh_table, save_path);
    
    fprintf('\n\nExperiment complete!\n');
    fprintf('Remember, also, to add the participant to the payment log\n\n');

catch ME
    % --- 错误处理 ---
    sca;            % 关闭 Psychtoolbox 窗口
    ListenChar(0);  % 恢复键盘输入
    ShowCursor;     % 恢复鼠标
    
    % 重新抛出错误，以便在 Command Window 看到具体的报错信息
    rethrow(ME);
end

end