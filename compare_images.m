% To compare 2 videos 
folder1 = './results_MOT/results_MOT_1/infer8_view1/'; % results_MOT_1\infer8_view1
folder2 = '../MDP_Tracking-master/results_MOT/results_MOT_1/PETS09-S2L1_view1/';
view_files1 = dir([folder1 '*.png']);
view_files2 = dir([folder2 '*.png']);
seq_name = 'MDP_ref-vs-infer_view1';

is_save = 1;
if is_save
    result_dir = sprintf('results_MOT/results_MOT_1/%s', seq_name);
    if exist(result_dir, 'dir') == 0
        mkdir(result_dir);
    end
end
for k = 1:numel(view_files1)
    img1 = imread(strcat(folder1,view_files1(k).name));
    img2 = imread(strcat(folder2,view_files2(k).name));
    if is_save
        filename = sprintf('%s/%06d.png', result_dir, k);
        imwrite([img2 img1], filename);
    end
end
