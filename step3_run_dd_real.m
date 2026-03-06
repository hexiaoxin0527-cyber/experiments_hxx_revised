sca

% 注意：为使此脚本正常运行，请确认USB串口（编写时为COM4）的波特率
% 已设置为115200（设备管理器 > 端口 > USB串行端口 > 端口设置）


prior_path = pwd;
proj_path = get_project_path();
code_path = fullfile(proj_path, 'code');
cd(code_path);
run(fullfile(code_path, 'dd'));
cd(prior_path);

