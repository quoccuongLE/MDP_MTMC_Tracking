% --------------------------------------------------------
% MDP Tracking
% Copyright (c) 2015 CVGL Stanford
% Licensed under The MIT License [see LICENSE for details]
% Written by Yu Xiang. Modified by Quoc L.
% --------------------------------------------------------
%
% draw dres structure
function show_dres_oop(input)
% frame_id, I, tit, dres, state, cmap
frame_id = input{1};
I = input{2};
tit = input{3};
dres = input{4};

if numel(input) < 5
    state = 1;
else
    state = input{5};
end
if numel(input) < 6
    cmap = colormap;
else
    cmap = input{6};
end

imshow(I);
title(tit);
hold on;

if isempty(dres) == 1
    index = [];
else
    if isfield(dres, 'state') == 1
        index = find(dres.fr == frame_id & dres.state == state);
    else
        index = find(dres.fr == frame_id);
    end
end

ids = unique(dres.id);
for i = 1:numel(index)
    ind = index(i);
    
    x = dres.x(ind);
    y = dres.y(ind);
    w = dres.w(ind);
    h = dres.h(ind);
    r = dres.r(ind);
    
    if isfield(dres, 'id') && dres.id(ind) > 0
        id = dres.id(ind);
        id_index = find(id == ids);
        str = sprintf('%d', id_index);
        index_color = min(1 + floor((id_index-1) * size(cmap,1) / numel(ids)), size(cmap,1));
        c = cmap(index_color,:);
    else
        c = 'g';
        str = sprintf('%.2f', r);
    end
    if isfield(dres, 'occluded') && dres.occluded(ind) > 0
        s = '--';
    else
        s = '-';
    end
    rectangle('Position', [x y w h], 'EdgeColor', c, 'LineWidth', 4, 'LineStyle', s);
    text(x, y-size(I,1)*0.01, str, 'BackgroundColor', [.7 .9 .7], 'FontSize', 14);    

    if isfield(dres, 'id') && dres.id(ind) > 0
        % show the previous path
        ind = find(dres.id == id & dres.fr <= frame_id);
        centers = [dres.x(ind)+dres.w(ind)/2, dres.y(ind)+dres.h(ind)];
        patchline(centers(:,1), centers(:,2), 'LineWidth', 4, 'edgecolor', c, 'edgealpha', 0.3);
    end
end
hold off;