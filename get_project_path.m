function proj_path = get_project_path
% GET_PROJECT_PATH 动态获取项目根目录路径
% 假设目录结构如下：
% /project_root/
%   /code/ (此文件所在位置)
%   /data/ (数据存储位置)

    % 获取当前文件的完整路径
    current_file_path = mfilename('fullpath');
    % 获取包含当前文件的文件夹路径 (即 code 文件夹)
    code_path = fileparts(current_file_path);
    % 获取 code 文件夹的上一级目录 (即 project_root)
    proj_path = fileparts(code_path);
end
