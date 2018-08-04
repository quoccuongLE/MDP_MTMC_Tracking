% Written by Quoc L.
% cost = MDP_pairwise_apprearance_cost(frame_id, frame_view_A, frame_view_B, tracker_A, tracker_B)
function cost = MDP_pairwise_apprearance_cost(input)
% dres_one_A = [];
% dres_one_A.fr = frame_id;
% dres_one_A.id = tracker_A.target_id;
% dres_one_A.x = tracker_A.bb(1);
% dres_one_A.y = tracker_A.bb(2);
% dres_one_A.w = tracker_A.bb(3) - tracker_A.bb(1);
% dres_one_A.h = tracker_A.bb(4) - tracker_A.bb(2);
% dres_one_A.r = 1;
% dres_one_A.state = 2;

% dres_one_B = [];
% dres_one_B.fr = frame_id;
% dres_one_B.id = tracker_B.target_id;
% dres_one_B.x = tracker_B.bb(1);
% dres_one_B.y = tracker_B.bb(2);
% dres_one_B.w = tracker_B.bb(3) - tracker_B.bb(1);
% dres_one_B.h = tracker_B.bb(4) - tracker_B.bb(2);
% dres_one_B.r = 1;
% dres_one_B.state = 2;

frame_id     = input{1};
frame_view_A = input{2};
frame_view_B = input{3};
tracker_A    = input{4};
tracker_B    = input{5};

dres_one_A = sub(tracker_A.dres, numel(tracker_A.dres.fr));
dres_one_A.fr = frame_id;
dres_one_A.id = tracker_A.target_id;

dres_one_B = sub(tracker_B.dres, numel(tracker_B.dres.fr));
dres_one_B.fr = frame_id;
dres_one_B.id = tracker_B.target_id;

dres_one_A = MDP_crop_image_box(dres_one_A, frame_view_A, tracker_A);
dres_one_B = MDP_crop_image_box(dres_one_B, frame_view_B, tracker_B);

% I_crop = dres_one_A.I_crop{1};
I_crop = tracker_A.Is{tracker_A.anchor};
BB1_crop = dres_one_A.BB_crop{1};
J_crop = dres_one_B.I_crop{1};
BB2_crop = dres_one_B.BB_crop{1};

[BB3, xFJ, flag, medFB, medNCC, medFB_left, medFB_right, medFB_up, medFB_down] = LK(I_crop, ...
    J_crop, BB1_crop, BB2_crop, tracker_A.margin_box, tracker_A.level);
if isnan(medFB) || isnan(medFB_left) || isnan(medFB_right) || isnan(medFB_up) || isnan(medFB_down) ...
        || isnan(medNCC)
    cost = inf;
else
    cost = medFB;
end
end