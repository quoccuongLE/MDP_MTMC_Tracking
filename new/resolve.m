% resolve conflict between trackers
function trackers = resolve(trackers, dres_det, opt)
% global err
% err = {};
% collect dres from trackers
dres_track = [];
tracker = [];
for i = 1:numel(trackers)
    % i
    tracker = trackers{i};
    % numel(tracker.dres.fr)
    dres = sub(tracker.dres, numel(tracker.dres.fr));
    
    if tracker.state == 2
        if isempty(dres_track)
            dres_track = dres;
        else
            dres_track = concatenate_dres(dres_track, dres);
        end
    end
end   
% err{1} = dres_track;
% err{2} = dres;
% err{3} = tracker;
% compute overlaps
num_det = numel(dres_det.fr);
if isempty(dres_track)
    num_track = 0;
else
    num_track = numel(dres_track.fr);
end

flag = zeros(num_track, 1);
for i = 1:num_track
    [~, o] = calc_overlap(dres_track, i, dres_track, 1:num_track);
    o(i) = 0;
    o(flag == 1) = 0;
    [mo, ind] = max(o);
    if mo > opt.overlap_sup       
        % i
        % a = dres_track.id
        num1 = trackers{dres_track.id(i)}.streak_tracked;
        num2 = trackers{dres_track.id(ind)}.streak_tracked;
        o1 = max(calc_overlap(dres_track, i, dres_det, 1:num_det));
        o2 = max(calc_overlap(dres_track, ind, dres_det, 1:num_det));
        
        if num1 > num2
            sup = ind;
        elseif num1 < num2
            sup = i;
        else
            if o1 > o2
                sup = ind;
            else
                sup = i;
            end
        end
        
        trackers{dres_track.id(sup)}.state = 3;
        trackers{dres_track.id(sup)}.dres.state(end) = 3;
        if opt.is_text
            fprintf('target %d suppressed\n', dres_track.id(sup));
        end
        flag(sup) = 1;
    end
end