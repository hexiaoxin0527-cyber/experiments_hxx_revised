
function demographic

proj_path = get_project_path();
% Randomly generate participant ID
curr_date = datetime;
pid = sprintf('%d', round(posixtime(curr_date)));


%{
curr_date = datetime;
proj_path = fullfile('C:', 'Users', 'isaac', 'Projects', 'eeg-eft-task');
pid = 1234;
%}


% Create participant-specific data folder
mkdir(fullfile(proj_path, 'data', pid));
% Get age, gender, handedness
unit = 0.1;
fs = 15;
queries = {
    'age' '您的年龄是？'
    'gender' '您的性别是？'
    'handedness' '您的惯用手是？（右利手/左利手/双利手）'
};
n_queries = size(queries, 1);
f = figure(...
    'MenuBar', 'none',...
    'Toolbar', 'none',...
    'CloseRequestFcn', @(h, e) []);
idx = 1;
for query_i = 1:n_queries
    uicontrol(f,...
        'Style', 'text',...
        'String', queries{query_i, 2},...
        'FontSize', fs,...
        'Units', 'normalized',...
        'Position', [0 1-idx*unit 1 unit]);
    idx = idx + 1;
    uicontrol(f,...
        'Style', 'edit',...
        'Tag', queries{query_i, 1},...
        'FontSize', fs,...
        'Units', 'normalized',...
        'Position', [0.2 1-idx*unit 0.6 unit]);
    idx = idx + 1;
end
uicontrol(f,...
    'Style', 'pushbutton',...
    'String', '完成',...
    'FontSize', fs,...
    'Units', 'normalized',...
    'Position', [0.25 0 0.5 unit],...
    'Callback', @(h, e) uiresume(f));
uiwait(f);
% Write info
csv_file = fullfile(proj_path, 'participants.csv');

% 检查文件是否存在（用于判断是否需要写表头）
file_exists = exist(csv_file, 'file');

% 打开文件
fid = fopen(csv_file, 'a');

% 错误检查：如果文件被 Excel 占用，fid 会是 -1
if fid == -1
    error('无法打开文件 %s。请检查该文件是否已在 Excel 中打开，若是请关闭它，并在命令行运行 fclose(''all'') 后重试。', csv_file);
end

% 如果是新文件，先写入表头
if ~file_exists
    % 注意：这里的列名必须与您后续代码中引用的变量名一致（如 id）
    fprintf(fid, 'id,date,age,gender,handedness\n');
end

% 写入数据
fprintf(fid, '%s,', pid);
fprintf(fid, '%s,', char(curr_date));
for query_i = 1:n_queries
    obj = findobj(f, 'Tag', queries{query_i, 1});
    str = obj.String;
    fprintf(fid, '\"%s\"', str);
    if query_i < n_queries
        fprintf(fid, ',');
    end
end
fprintf(fid, '\n');
fclose(fid);
delete(f);

end