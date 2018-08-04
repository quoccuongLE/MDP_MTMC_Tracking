% --------------------------------------------------------
% MDP Tracking
% Copyright (c) 2015 CVGL Stanford
% Licensed under The MIT License [see LICENSE for details]
% Written by Yu Xiang
% --------------------------------------------------------
%
% compile cpp files
% change the include and lib path if necessary
function compile

% include = ' -I/usr/local/include/opencv/ -I/usr/local/include/ -I/usr/include/opencv/';
% lib = ' -lopencv_core -lopencv_highgui -lopencv_imgproc -lopencv_video';
% eval(['mex lk.cpp -O' include lib]);

% include = ' -I"C:\opencv2411\build\include\"';
% lib = ' -L"C:\opencv2411\build\x64\vc12\lib\" -lopencv_core2411 -lopencv_highgui2411 -lopencv_imgproc2411 -lopencv_video2411';
% eval(['mex lk.cpp -O' include lib]);
%%
OPENCV_DIR = 'C:\opencv';
include = ' -I"C:\openc\build\include\opencv"  -I"C:\opencv\build\include"';
LPath = fullfile(OPENCV_DIR, 'build\x64\vc12\lib\');

files = dir([LPath '*.lib']);

lib = [];
for i = 1:length(files),
    lib = [lib ' ' LPath files(i).name];
end
    
eval(['mex lk.cpp -O' include lib]);
%%
mex distance.cpp 
mex imResampleMex.cpp 
mex warp.cpp

disp('Compilation finished.');