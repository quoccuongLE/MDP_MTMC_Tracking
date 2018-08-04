function [Xu,Yu] = distortedToUndistortedSensorCoord(Xd,Yd,kappa1)
	distortion_factor = 1 + kappa1 * (Xd.*Xd + Yd.*Yd);
	Xu = Xd.* distortion_factor;
	Yu = Yd.* distortion_factor;
end