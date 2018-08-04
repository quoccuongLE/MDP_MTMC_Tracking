% Written by Quoc L.
% cost = MDP_pairwise_distance_cost(frame_id, cam_A, cam_B, tracker_A, tracker_B,zplane)
function cost = MDP_pairwise_long_distance_cost(input)
frame_id  = input{1};
cam_A     = input{2};
cam_B     = input{3};
tracker_A = input{4};
tracker_B = input{5};
zplane    = input{6};
% len = 5;
l_a = numel(tracker_A.dres.fr);
l_b = numel(tracker_B.dres.fr);
len_min = min(l_a,l_b);
len = min(len_min,30);

dres_one_A = sub(tracker_A.dres, l_a-len+1:l_a);
dres_one_A.fr = frame_id;
dres_one_A.id = tracker_A.target_id;
    
dres_one_B = sub(tracker_B.dres, l_b-len+1:l_b);
dres_one_B.fr = frame_id;
dres_one_B.id = tracker_B.target_id;

pt_A = [dres_one_A.x' + 0.5*dres_one_A.w'; dres_one_A.y' + dres_one_A.h' ];
pt_B = [dres_one_B.x' + 0.5*dres_one_B.w'; dres_one_B.y' + dres_one_B.h' ];

w_A = image2world(pt_A, zplane, cam_A);
w_B = image2world(pt_B, zplane, cam_B);

cost = mean(sqrt(sum((w_A - w_B).^2,1))./1e3);
end