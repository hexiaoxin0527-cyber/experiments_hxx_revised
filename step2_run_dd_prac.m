
% NB: PsychToolbox will only let this run if you go to settings > system >
% display and select "Extend these displays" under "Multiple displays",
% select screen 2 from the big graphic at the top of the page, and check
% the "Make this my main display" box at the bottom of the page.

prior_path = pwd;
proj_path = get_project_path();
% proj_path = fullfile('C:', 'Users', 'isaac', 'Projects', 'eeg-eft-task');
code_path = fullfile(proj_path, 'code');
cd(code_path);
run(fullfile(code_path, 'dd_instr'));
run(fullfile(code_path, 'dd_prac'));
cd(prior_path);
