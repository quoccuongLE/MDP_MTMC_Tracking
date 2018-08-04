function tracker = associate_oop(fr, dres_image, dres_associate, tracker, central, opt)

% occluded
if tracker.state == 3
    tracker.streak_occluded = tracker.streak_occluded + 1;
    % find a set of detections for association
    [dres_associate, index_det] = generate_association_index(tracker, fr, dres_associate);
    tracker = MDP_value_oop(tracker, fr, dres_image, dres_associate, index_det);
    if tracker.state == 2
        tracker.streak_occluded = 0;
    end
%     cam_id = tracker.cam_id;
%     target_id = tracker.target_id;
%     % ind = [];
%     ind = find(central.associationId(:,cam_id)==target_id);
%     if tracker.state == 3 & tracker.state == 2 & sum(central.associationId_state(ind,:)==2) > 2 %#ok<AND2>
%         allProposal = [];
%         for j = 1:size(central.associationId_state,2)
%             if central.associationId_state(ind,j)==2
%                 dres_one = sub(tracker.dres, numel(tracker.dres.fr));
%             end
%         end
%     end
    if tracker.streak_occluded > opt.max_occlusion % (tracker.streak_occluded > opt.max_occlusion & condition) || tracker.streak_occluded > 30
        tracker.state = 0;
        if opt.is_text
            fprintf('target %d exits due to long time occlusion\n', tracker.target_id);
        end
    end
    % check if target outside image
    [~, ov] = calc_overlap(tracker.dres, numel(tracker.dres.fr), dres_image, fr);
    if ov < opt.exit_threshold
        if opt.is_text
            fprintf('target outside image by checking boarders\n');
        end
        tracker.state = 0;
    end    
end