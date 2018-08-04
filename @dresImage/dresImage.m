classdef dresImage
    properties
        x
        y
        h
        w
        seq_name
        imgFolder
    end
    methods
        function obj = dresImage(opt,seq_set0,seq_name0,seq_num)
            if nargin > 0
                filename = fullfile(opt.mot, opt.mot2d, seq_set0, seq_name0, 'img1', sprintf('%06d.jpg', 1));
                disp(filename);
                I = imread(filename);
                
                obj.seq_name = seq_name0;
                obj.x = ones(seq_num,1);
                obj.y = ones(seq_num,1);
                obj.w = size(I, 2)*ones(seq_num,1);
                obj.h = size(I, 1)*ones(seq_num,1);
                obj.imgFolder = fileparts(filename);
            end
        end
        function img = getFrame(obj,fr)
            filename = fullfile(obj.imgFolder, sprintf('%06d.jpg', fr));
            img = imread(filename);
        end
        function img = getFrameGray(obj,fr)
            filename = fullfile(obj.imgFolder, sprintf('%06d.jpg', fr));
            I = imread(filename);
            img = rgb2gray(I);
        end
    end
end