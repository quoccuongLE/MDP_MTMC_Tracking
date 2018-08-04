function dres2 = removeFP_by_Prev(dres,img,imgPrev,binaryThreshold,threshold)
if nargin < 4
    binaryThreshold = 0.06;
end
if nargin < 5
	threshold = 0.1;
end
index = [];
for i = 1: numel(dres.fr)
    bbox = [dres.x(i); dres.y(i); dres.x(i) + dres.w(i); dres.y(i) + dres.h(i)];
    if motionCheckPrev(img,imgPrev,bbox,binaryThreshold,threshold) 
        index = [index; i]; %#ok<AGROW>
    end
end
dres2 = sub(dres, index);
end

function result = motionCheckPrev(img,imgPrev,bbox,binaryThreshold,threshold)
subtr_img = double(sum(abs(double(img)-double(imgPrev)),3)./3)./255;
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