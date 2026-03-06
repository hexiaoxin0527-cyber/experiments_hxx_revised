sca

% NB: In order for this to work, check that the buad rate of the USB serial
% port (COM4 at the time of writing) is set to 115200 (Device Manager >
% Ports > USB Serial Port > Port settings


prior_path = pwd;
proj_path = get_project_path();
code_path = fullfile(proj_path, 'code');
cd(code_path);
run(fullfile(code_path, 'dd'));
cd(prior_path);

