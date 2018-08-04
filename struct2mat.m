function matData = struct2mat(structData,nonGtFlag)
if nargin < 2, nonGtFlag = true; end
if nonGtFlag, flag = -1; else, flag = 0; end
matData = [];
for k = 1: size(structData.W,1)
    for id = 1: size(structData.W,2)
        if structData.W(k,id)~=0
            weight = structData.W(k,id);
            height = structData.H(k,id);
            left = structData.Xi(k,id) - weight/2;
            top = structData.Yi(k,id) - height;
            tmp = [k id left top weight height flag -1 -1 -1 -1];
            matData = [matData; tmp]; %#ok<AGROW>
        end
    end
end
end