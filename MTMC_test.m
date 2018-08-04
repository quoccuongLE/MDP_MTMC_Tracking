% --------------------------------------------------------
% MDP Tracking
% Copyright (c) 2015 CVGL Stanford
% Licensed under The MIT License [see LICENSE for details]
% Written by Yu Xiang
% Modified by Quoc C.LE
% --------------------------------------------------------


addpath('./new/')
addpath('./3rd_party/lib/')

is_show = 0;   % set is_show to 1 to show tracking results in testing
is_save = 1;   % set is_save to 1 to save tracking result
is_text = 0;   % set is_text to 1 to display detailed info
is_pause = 0;  % set is_pause to 1 to debug
is_multi_cam = 1;

opt = globals2();
opt.is_text = is_text;
opt.exit_threshold = 0.7;

if is_show
    close all;
end
if is_multi_cam
    seq = 'PETS09-S2L1'; % terrace1 PETS09-S2L1
    if strcmp(seq,'PETS09-S2L1')
        seq_name{1} = 'PETS09-S2L1_view1';
        seq_name{5} = 'PETS09-S2L1_view5';
        seq_name{6} = 'PETS09-S2L1_view6';
        seq_name{7} = 'PETS09-S2L1_view7';
        seq_name{8} = 'PETS09-S2L1_view8';
        filename   = cell(8,1);
        dres_image = cell(8,1);
        dres_det   = cell(8,1);
        dres_track = cell(8,1);
        tracker    = cell(8,1);
        trackers   = cell(8,1);
        id         = cell(8,1);
        seq_set = 'test';
        seq_num = 795;
        object = load('./data/camera/dataCalibPETS09.mat');
        cameras = object.cameras;
        object = load('./data/camera/PETS09_S2L1_bg.mat');
        imgBg  = object.imgBg;
        chosenCams = [1 5 6 7 8];
        camID = 1;
        opt.downScale = false;
    elseif strcmp(seq,'terrace1')
        % Use the sub-sequence of terrace1/ reduce video rate from ~25fps
        % to ~5fps / takes 1 frame every 5 frames of the original video
        seq_name{1} = 'terrace1-c0_sub';
        seq_name{2} = 'terrace1-c1_sub';
        seq_name{3} = 'terrace1-c2_sub';
        seq_name{4} = 'terrace1-c3_sub';
        filename   = cell(4,1);
        dres_image = cell(4,1);
        dres_det   = cell(4,1);
        dres_track = cell(4,1);
        tracker    = cell(4,1);
        trackers   = cell(4,1);
        id         = cell(4,1);
        seq_set = 'test';
        seq_num = 1002;
        object = load('./data/camera/dataCalibEpflTerrace1.mat');
        cameras = object.cameras;
        % No background available 
        imgBg  = [];
        imgPrev = cell(4,1);
        chosenCams = [1 2 3 4];
        camID = 1;
        opt.downScale = true;
    end
else
    if strcmp(seq_set, 'train') == 1
        seq_name = opt.mot2d_train_seqs{seq_idx};
        seq_num = opt.mot2d_train_nums(seq_idx);
    else
        seq_name = opt.mot2d_test_seqs{seq_idx};
        seq_num = opt.mot2d_test_nums(seq_idx);
    end
end
camList = {};

for i = 1:numel(seq_name)
    if ~isempty(seq_name{i})
        filename{i} = sprintf('%s/%s_dres_image.mat', opt.results, seq_name{i});
    end
end

for i = 1:numel(filename)
    if ~isempty(filename{i})
        dres_image{i} = dresImage(opt,seq_set,seq_name{i},seq_num);
        if strcmp(seq,'terrace1')
            imgPrev{i} = dres_image{i}.getFrame(1);
        end
    end
end
for i = chosenCams
    camList{i} = cameras{i}; %#ok<SAGROW>
    if opt.downScale
        sz = size(dres_image{i}.getFrame(1));
        scale(1) = camList{i}.mHeight/sz(1);
        scale(2) = camList{i}.mWidth/sz(2);
        camList{i}.scale = scale(:); %#ok<SAGROW>
    end
end
central = manager(camList);

% return
for i = 1:numel(seq_name)
    if ~isempty(seq_name{i})
        filename = fullfile(opt.mot, opt.mot2d, seq_set, seq_name{i}, 'det', 'det.txt');
        dres_det{i} = read_mot2dres(filename);
    end
end

object = load('.\results\TUD-Stadtmitte_tracker.mat');
tracker0 = object.tracker;
for i = 1:numel(seq_name)
    if ~isempty(seq_name{i})
        tracker{i} = MDP_initialize_test(tracker0, dres_image{i}.w(1), dres_image{i}.h(1), dres_det{i}, is_show);
    end
end
% return
% for each frame
for i = 1:numel(id)
    id{i} = 0;
end
for fr = 1:seq_num
    if is_text
        fprintf('frame %d\n', fr);
    else
        fprintf('.');
        if mod(fr, 100) == 0
            fprintf('%d\n',size(central.associationId_state,1));
            fprintf('\n');
        end
    end
    for j = chosenCams % [1 5 6 7 8] % chosenCams
        % extract detection
        index = find(dres_det{j}.fr == fr);
        dres = sub(dres_det{j}, index);
        if ~isempty(imgBg)
            dres = removeFP_by_BG(dres, dres_image{j}.getFrame(fr), imgBg{j}, 0.05, 0.3);
        elseif fr > 1
            % numel(dres)
            dres = removeFP_by_Prev(dres, dres_image{j}.getFrame(fr), imgPrev{j}, 0.06, 0.1);
            imgPrev{j} = dres_image{j}.getFrame(fr);
            % numel(dres)
        end
        dres = MDP_crop_image_box(dres, dres_image{j}.getFrameGray(fr), tracker{j});
        % sort trackers
        index_track = sort_trackers(trackers{j});

        % process trackers
        for i = 1:numel(index_track)
            ind = index_track(i);

            if trackers{j}{ind}.state == 2
                % track target
                trackers{j}{ind} = track_oop(fr, dres_image{j}, dres, trackers{j}{ind}, opt);
                % connect target
                if trackers{j}{ind}.state == 3
                    [dres_tmp, index] = generate_initial_index(trackers{j}(index_track(1:i-1)), dres);
                    dres_associate = sub(dres_tmp, index);
                    trackers{j}{ind} = associate_oop(fr, dres_image{j}, dres_associate, trackers{j}{ind}, central, opt);
                    %---------------collaborative tracking----------------%
                    % recatch the tracking status in partial occlusion
                    % cases
                    if ~isempty(central.associationId)
                        cam_id = trackers{j}{ind}.cam_id;
                        target_id = trackers{j}{ind}.target_id;
                        idx = find(central.associationId(:,cam_id)==target_id);
                        if ~isempty(idx)
                            if trackers{j}{ind}.state == 3 & trackers{j}{ind}.prev_state == 2 & sum(central.associationId_state(idx,:)==2) >= 2 %#ok<AND2>
                                allProposal = [];
                                for jj = 1:size(central.associationId_state,2)
                                    if central.associationId_state(idx,jj)==2 & jj~=j
                                        index = central.associationId(idx,jj);
                                        dres_one = sub(trackers{jj}{index}.dres, numel(trackers{jj}{index}.dres.fr));
                                        feet = [dres_one.x + dres_one.w*0.5; dres_one.y + dres_one.h];
                                        feet3D = image2world(feet,0, camList{jj});
                                        allProposal = [allProposal, feet3D(:)];
                                    end
                                end
                                if ~isempty(allProposal)
                                    med_feet = mean(allProposal,2);
                                    [dres_associate, index_det] = generate_association_index(trackers{j}{ind}, fr, dres_associate);
                                    the_one = [];
                                    tmp = inf;
                                    for ii = 1:numel(index_det)
                                        dres_one = sub(dres_associate, index_det(ii));
                                        feet = [dres_one.x + dres_one.w*0.5; dres_one.y + dres_one.h];
                                        feet3D = image2world(feet,0, camList{j});
                                        dis_tmp = norm(feet3D - med_feet);
                                        if tmp > dis_tmp & dis_tmp < 1.2e3
                                            tmp = dis_tmp;
                                            the_one = dres_one;
                                        end
                                    end
                                    if ~isempty(the_one)
                                        the_one.id = trackers{j}{ind}.target_id;
                                        the_one.r = 1;
                                        the_one.state = 2;
                                        if trackers{j}{ind}.dres.fr(end) == fr
                                            dres_abc = trackers{j}{ind}.dres;
                                            index = 1:numel(dres_abc.fr)-1;
                                            trackers{j}{ind}.dres = sub(dres_abc, index);
                                        end
                                        trackers{j}{ind}.dres = interpolate_dres(trackers{j}{ind}.dres, the_one);
                                        trackers{j}{ind}.state = 2;
                                        trackers{j}{ind} = LK_update(fr, trackers{j}{ind}, dres_image{j}.getFrameGray(fr), the_one, 0);
                                        % fprintf('colab: cam %d target%d\n', j, ind);
                                    end
                                end
                            end
                        end
                    end
                    %-----------------------------------------------------%
                end
            elseif trackers{j}{ind}.state == 3
                % associate target
                [dres_tmp, index] = generate_initial_index(trackers{j}(index_track(1:i-1)), dres);
                dres_associate = sub(dres_tmp, index);
                trackers{j}{ind} = associate_oop(fr, dres_image{j}, dres_associate, trackers{j}{ind}, central, opt);
                if trackers{j}{ind}.state == 3
                    trackers{j}{ind}.prev_state = 3;
                end
                    
            end
        end

        % find detections for initialization
        [dres, index] = generate_initial_index(trackers{j}, dres);
        for i = 1:numel(index)
            % extract features
            dres_one = sub(dres, index(i));
            f = MDP_feature_active(tracker{j}, dres_one);
            % prediction
            label = svmpredict(1, f, tracker{j}.w_active, '-q');
            % make a decision
            if label < 0
                continue;
            end

            % reset tracker
            tracker{j}.prev_state = 1;
            tracker{j}.state = 1;
            id{j} = id{j} + 1;

            trackers{j}{end+1} = initialize_oop(fr, dres_image{j}, id{j}, dres, index(i), tracker{j}, j);
        end
        %--------------------recovery after hard occlusion----------------%
        % connect the newborn tracklets to occluded trackers
        index_tracklet = getMiniTracklet(trackers{j});
        for ii = 1:size(central.associationId,1)
            target_id = central.associationId(ii,j);
            if central.associationId_state(ii,j)==3 & sum(central.associationId_state(ii,:)==2) >= 2 %#ok<AND2>
                for i = 1:numel(index_tracklet)
                    ind = index_tracklet(i);
                    if trackers{j}{ind}.state == 2
                        cost = [];
                        for jj = 1:size(central.associationId,2)
                            if central.associationId_state(ii,jj) == 2
                                input = {trackers{j}{ind}, trackers{jj}{central.associationId(ii,jj)}, camList{j}, camList{jj}, 0};
                                cost = [cost, MDP_pairwise_short_distance_cost(input)];
                            end
                        end
                        startFrame = trackers{j}{ind}.dres.fr(1);
                        index_state2 = find(trackers{j}{target_id}.dres.state == 2);
                        ind2 = index_state2(end);
                        endFrame = trackers{j}{target_id}.dres.fr(ind2);
                        if mean(cost)<1.2 & startFrame > endFrame %#ok<AND2>
                            trackers{j}{target_id}.state = 2;
                            trackers{j}{ind}.state = 0;
                            dres_one = sub(trackers{j}{ind}.dres,numel(trackers{j}{ind}.dres.fr));
                            dres_one.id = trackers{j}{target_id}.target_id;
                            dres_one.r = 1;
                            trackers{j}{target_id}.dres = interpolate_dres(trackers{j}{target_id}.dres, dres_one);
                        end
                    end
                end
            end
        end
        %-----------------------------------------------------------------%
        % resolve tracker conflict
        trackers{j} = resolve(trackers{j}, dres, opt);
        dres_track{j} = generate_results(trackers{j});
    end
    input = {trackers,opt.tracked};
    central = central.updateState(input);
    input_data = {trackers, camList, dres_image, fr};
    central = central.multiviewAssociation(input_data);
    if is_show
        figure(1);
        if strcmp(seq,'PETS09-S2L1')
            % show tracking results
            subplot(2, 3, 1);
            dres_track_tmp = dres_track{5};
            show_dres(fr, dres_image{5}.getFrame(fr), 'Tracking cam5', dres_track_tmp, 2);
            subplot(2, 3, 2);
            dres_track_tmp = dres_track{6};
            show_dres(fr, dres_image{6}.getFrame(fr), 'Tracking cam6', dres_track_tmp, 2);
            subplot(2, 3, 3);
            dres_track_tmp = dres_track{7};
            show_dres(fr, dres_image{7}.getFrame(fr), 'Tracking cam7', dres_track_tmp, 2);
            subplot(2, 3, 4);
            dres_track_tmp = dres_track{8};
            show_dres(fr, dres_image{8}.getFrame(fr), 'Tracking cam8', dres_track_tmp, 2);

            dres_track_tmp = dres_track{camID};
            subplot(2, 3, 5);
            show_dres(fr, dres_image{camID}.getFrame(fr), 'Tracking', dres_track_tmp, 2);
            % show lost targets
            subplot(2, 3, 6);
            show_dres(fr, dres_image{camID}.getFrame(fr), 'Lost/Occluded', dres_track_tmp, 3);
        elseif strcmp(seq,'terrace1')
            % show tracking results
            subplot(2, 3, 1);
            dres_track_tmp = dres_track{2};
            show_dres(fr, dres_image{2}.getFrame(fr), 'Tracking cam1', dres_track_tmp, 2);
            subplot(2, 3, 2);
            dres_track_tmp = dres_track{3};
            show_dres(fr, dres_image{3}.getFrame(fr), 'Tracking cam2', dres_track_tmp, 2);
            subplot(2, 3, 3);
            dres_track_tmp = dres_track{4};
            show_dres(fr, dres_image{4}.getFrame(fr), 'Tracking cam3', dres_track_tmp, 2);

            dres_track_tmp = dres_track{camID};
            subplot(2, 3, 5);
            show_dres(fr, dres_image{camID}.getFrame(fr), 'Tracking', dres_track_tmp, 2);
            % show lost targets
            subplot(2, 3, 6);
            show_dres(fr, dres_image{camID}.getFrame(fr), 'Lost/Occluded', dres_track_tmp, 3);
        end
        if is_pause || fr ==1
            disp(['Frame' num2str(fr)])
            pause();
        else
            pause(0.01);
        end
    end
end

% write tracking results
for i = 1:numel(seq_name)
    if ~isempty(seq_name{i})
        filename = sprintf('%s/%s.txt', opt.results, seq_name{i});
        fprintf('write results: %s\n', filename);
        write_tracking_results(filename, dres_track{i}, opt.tracked);
    end
end
for i = 1:numel(seq_name)
    filename = sprintf('%s/%s_results.mat', opt.results, seq_name{i});
    save(filename, 'dres_track');
end