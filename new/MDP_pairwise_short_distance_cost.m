% Written by Quoc L.
function cost = MDP_pairwise_short_distance_cost(input)
tracker_A = input{1};
tracker_B = input{2};
cam_A = input{3};
cam_B = input{4};
zplane = input{5};

dres_one_A = sub(tracker_A.dres,numel(tracker_A.dres.fr));
dres_one_B = sub(tracker_B.dres,numel(tracker_B.dres.fr));

pt_A = [dres_one_A.x' + 0.5*dres_one_A.w'; dres_one_A.y' + dres_one_A.h' ];
pt_B = [dres_one_B.x' + 0.5*dres_one_B.w'; dres_one_B.y' + dres_one_B.h' ];
w_A = image2world(pt_A, zplane, cam_A);
w_B = image2world(pt_B, zplane, cam_B);

cost = sqrt(sum((w_A - w_B).^2,1))./1e3;
end