
proj_path = get_project_path();
pt = readtable(fullfile(proj_path, 'participants.csv'));
pid = pt.id(end);
%{
proj_path = fullfile('C:', 'Users', 'isaac', 'Projects', 'eeg-eft-task');
pid = 1234;
%}
efts = read_eft;
cued_delays = cellfun(@str2double, {efts.days});

% Interpolate and extrapolate uncued delays assuming a geometric
% progression (but round to the nearest 10 days)

uncued_delays = nan(1, numel(cued_delays));

for delay_idx = 1:(numel(cued_delays)-1)
    uncued_delays(delay_idx) = ceil(sqrt(cued_delays(delay_idx)*cued_delays(delay_idx+1))/10)*10;
end

x1 = uncued_delays(end-1);
x2 = cued_delays(end);
x3 = (x2^2)/x1;

uncued_delays(end) = ceil(x3/10)*10;

% Save info
fid = fopen(fullfile(proj_path, 'data', sprintf('%d', pid), 'uncued-delays.txt'), 'w');
for delay_idx = 1:numel(uncued_delays)
    fprintf(fid, '%d\n', uncued_delays(delay_idx));
end
fclose(fid);