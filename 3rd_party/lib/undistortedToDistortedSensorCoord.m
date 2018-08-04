function [Xd, Yd] = undistortedToDistortedSensorCoord(Xu,Yu, mKappa1)
    if ((Xu==0)&&(Yu==0)) || (mKappa1==0)
        Xd = Xu;
        Yd = Yu;
    else 
        Ru = sqrt(Xu.*Xu + Yu.*Yu);
        c = 1.0/mKappa1;
        d = -c * Ru;
        Q = c/3;
        R = -d/2;
        D = Q^3 + R^2;
        if D>=0
            D = sqrt(D);
            S = sign(R+D)*abs(R+D)^(1/3);
            T = sign(R-D)*abs(R-D)^(1/3);
            Rd = S + T; 
            if Rd <0
                Rd = sqrt(-1/(3*mKappa1));
            end
        else 
            D = sqrt(-D);
            S = sqrt(R*R + D*D)^(1/3);
            T = atan2(D, R)/3;
            Rd = -S*cos(T) + sqrt(3.0)*S*(sin(T));
        end
        lambda = Rd./Ru;
        Xd = Xu * lambda;
        Yd = Yu * lambda;
    end
end