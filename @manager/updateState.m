function obj = updateState(obj,input)
% updateState(obj,allTrackers,threshold)
allTrackers = input{1};
threshold   = input{2};
for j = obj.chosenCams
    trackers = allTrackers{j};
    obj.targetStateRecord{j} = [];
    for i = 1:numel(trackers)
        if trackers{i}.state ~= 1 & trackers{i}.state ~= 0 & trackers{i}.streak_tracked > threshold
            id = trackers{i}.target_id;
            tmp = [id, trackers{i}.state];
            obj.targetStateRecord{j} = [obj.targetStateRecord{j}; tmp];
        end
    end
end
end