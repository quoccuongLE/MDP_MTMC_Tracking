function obj = multiviewAssociation(obj,input)
trackers   = input{1};
camList    = input{2};
dres_image = input{3};
fr         = input{4};
j0 = obj.chosenCams(1);% obj.camList(1); main camera
obj.associationId       = zeros(size(obj.targetStateRecord{j0},1),numel(obj.targetStateRecord));
obj.associationId_state = zeros(size(obj.targetStateRecord{j0},1),numel(obj.targetStateRecord));
usedItemList = cell(numel(obj.camList),1);

index_track = sort_trackers(trackers{j0});
if isempty(obj.associationId), return; end
for i0 = 1:numel(index_track) % 1:size(obj.targetStateRecord{j0},1) % % indx0 = obj.targetStateRecord{j0}(i0,1);
    indx0 = index_track(i0);
    id_tmp = find(obj.targetStateRecord{j0}(:,1)==indx0);
    if ~isempty(id_tmp)
        obj.associationId(id_tmp,j0) = trackers{j0}{indx0}.target_id;
        obj.associationId_state(id_tmp,j0) = trackers{j0}{indx0}.state;
        for j = obj.chosenCams(2:end)
    %         if j==7 % & i0 == 2,
    %             t = err
    %             % pause
    %         end
            cost = [];
            for i = 1:size(obj.targetStateRecord{j},1)
                indx = obj.targetStateRecord{j}(i,1);
                if isempty(find(trackers{j}{indx}.target_id == usedItemList{j}, 1)) % & trackers{j}{indx}.state == 2
                    % (frame_id, cam_A, cam_B, tracker_A, tracker_B,zplane)
                    input_data = {fr, camList{j0}, camList{j}, trackers{j0}{indx0}, trackers{j}{indx}, 0};
                    cost1 = MDP_pairwise_long_distance_cost(input_data);
                    input_data = {fr, dres_image{j0}.getFrameGray(fr), dres_image{j}.getFrameGray(fr), trackers{j0}{indx0}, trackers{j}{indx}};
                    cost2 = MDP_pairwise_apprearance_cost(input_data);
                    cost3 = cost1 + 0.125*cost2;
                    cost = [cost; trackers{j}{indx}.target_id cost1 cost2 cost3]; %#ok<AGROW>
                end
            end
            if isempty(cost), continue; end
            [valMin, index] = min(cost(:,4));
            if valMin < 6 & cost(index,2) < 1.5 
                obj.associationId(id_tmp,j) = cost(index,1); % target ID associated
                obj.associationId_state(id_tmp,j) = trackers{j}{cost(index,1)}.state; % state of target associated
                usedItemList{j} = [usedItemList{j}; cost(index,1)];
                % a = usedItemList{j}
            end
        end
    end
end
end
function index = sort_trackers(trackers)

sep = 10;
num = numel(trackers);
len = zeros(num, 1);
state = zeros(num, 1);
for i = 1:num
    len(i) = trackers{i}.streak_tracked;
    state(i) = trackers{i}.state;
end

index1 = find(len > sep);
[~, ind] = sort(state(index1));
index1 = index1(ind);

index2 = find(len <= sep);
[~, ind] = sort(state(index2));
index2 = index2(ind);
index = [index1; index2];
end