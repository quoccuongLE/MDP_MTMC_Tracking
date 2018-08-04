function index = getMiniTracklet(trackers)
sep = 5;
num = numel(trackers);
len = zeros(num, 1);
state = zeros(num, 1);
for i = 1:num
    len(i) = trackers{i}.streak_tracked;
    state(i) = trackers{i}.state;
end
index = find(len<sep & len>1);

end