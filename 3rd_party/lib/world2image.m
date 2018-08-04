function im_p = world2image(w, cam)
    im_p = zeros(2,size(w,2));
    uvw_cam = cam.mR*w + repmat([cam.mTx;cam.mTy;cam.mTz],1,size(w,2));
    Xu = cam.mFocal*uvw_cam(1,:)./uvw_cam(3,:);
    Yu = cam.mFocal*uvw_cam(2,:)./uvw_cam(3,:);
    Xd = zeros(1,size(w,2));
    Yd = zeros(1,size(w,2));
    for i = 1:size(w,2)
        [Xd(i), Yd(i)] = undistortedToDistortedSensorCoord(Xu(i),Yu(i),cam.mKappa1);
    end
    im_p(1,:) = Xd*cam.mSx/cam.mDpx + cam.mCx;
    im_p(2,:) = Yd/cam.mDpy + cam.mCy;
    if isfield(cam,'scale')
        im_p = bsxfun(@rdivide, im_p, cam.scale);
    end
end