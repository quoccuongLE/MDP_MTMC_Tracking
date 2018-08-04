function dres2 = removeFP_by_BG(dres,img,imgBg,binaryThreshold,threshold)
% vérifier s'il exsite un objet movant dans le bounding box
if nargin < 4
    binaryThreshold = 0.05;
end
if nargin < 5
	threshold = 0.3;
end
index = [];
for i = 1: numel(dres.fr)
    bbox = [dres.x(i); dres.y(i); dres.x(i) + dres.w(i); dres.y(i) + dres.h(i)];
    if motionCheck(img,imgBg,bbox,binaryThreshold,threshold) 
        index = [index; i]; %#ok<AGROW>
    end
end

dres2 = sub(dres, index);
end

function result = motionCheck(img,imgBg,bbox,binaryThreshold,threshold)
subtr_img = double(sum(abs(double(img)-double(imgBg)),3)./3)./255;
id_y = floor(bbox(2)):floor(bbox(4));
id_x = floor(bbox(1)):floor(bbox(3));
[H_img,W_img] = size(subtr_img);

id_y(id_y > H_img) = H_img;
id_x(id_x > W_img) = W_img;
id_y(id_y < 1) = 1;
id_x(id_x < 1) = 1;

impatch = subtr_img(id_y,id_x);
impatch(impatch<binaryThreshold)  = 0;
impatch(impatch>=binaryThreshold) = 1;
result = sum(impatch(:))/numel(impatch)>threshold;
end
