
prior_path = pwd;
proj_path = get_project_path();
% proj_path = fullfile('C:', 'Users', 'isaac', 'Projects', 'eeg-eft-task');
code_path = fullfile(proj_path, 'code');
cd(code_path);
run(fullfile(code_path, 'demographic'))
run(fullfile(code_path, 'eft_instr'))
run(fullfile(code_path, 'getwriting'))
run(fullfile(code_path, 'get_delays'))
cd(prior_path);
