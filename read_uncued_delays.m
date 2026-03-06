
function uncued_delays = read_uncued_delays

proj_path = get_project_path();
pt = readtable(fullfile(proj_path, 'participants.csv'));
pid = pt.id(end);

%{
proj_path = fullfile('C:', 'Users', 'isaac', 'Projects', 'eeg-eft-task');
pid = 1234;
%}

fid = fopen(fullfile(proj_path, 'data', sprintf('%d', pid), 'uncued-delays.txt'), 'r');

uncued_delays = [];
while true
    currl = fgetl(fid);
    if currl == -1
        break
    else
        uncued_delays = [uncued_delays str2double(currl)];
    end
end

end