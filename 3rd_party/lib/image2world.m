function w = image2world(px_cam, zp, cam)
if isfield(cam,'scale'), px_cam = bsxfun(@times,px_cam,cam.scale); end
ones_array = ones(1,size(px_cam,2));
Xd = cam.mDpx*(px_cam(1,:) - cam.mCx)/cam.mSx;
Yd = cam.mDpy*(px_cam(2,:) - cam.mCy);
[Xu,Yu] = distortedToUndistortedSensorCoord(Xd, Yd,cam.mKappa1);
X = [Xu;Yu;cam.mFocal*ones_array];
tmp1 = cam.mR\X;
tmp2 = cam.mR\[cam.mTx;cam.mTy;cam.mTz];
m = (zp+tmp2(3))./tmp1(3,:);
w = tmp1.*repmat(m,3,1)-repmat(tmp2,1,size(px_cam,2));
end