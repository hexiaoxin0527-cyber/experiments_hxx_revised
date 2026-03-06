
function all_events = read_eft

proj_path = get_project_path();
pt = readtable(fullfile(proj_path, 'participants.csv'));
pid = pt.id(end);

%{
proj_path = fullfile('C:', 'Users', 'isaac', 'Projects', 'eeg-eft-task');
pid = 1234;
%}
fid = fopen(fullfile(proj_path, 'data', sprintf('%d', pid), 'writing.txt'), 'r');

prefixes = {'title' 'days'};
end_str = '-end-';
all_events = [];
curr_event = [];
while true
    curr = fgetl(fid);
    if curr == -1
        break
    else
        if strcmp(end_str, curr(1:numel(end_str)))
            all_events = [all_events curr_event];
            curr_event = [];
        else
            % Check which attribute the current line contains
            for prefix = prefixes
                prefix_w_colon = [prefix{:} ': '];
                if strcmp(prefix_w_colon, curr(1:numel(prefix_w_colon)))
                    curr_event.(prefix{:}) = curr(numel(prefix_w_colon)+1:end);
                end
            end
        end
    end
end
fclose(fid);

end