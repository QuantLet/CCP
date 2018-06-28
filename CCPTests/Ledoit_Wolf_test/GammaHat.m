function [gammaHat]=GammaHat(vhat,j)
dimensions = size(vhat);
T = dimensions(1);
p = dimensions(2);
gammaHat = zeros(p);
    if j >= T 
        error('j must be smaller than the row dimension!');
    else
    for i= (j + 1):T
        gammaHat = gammaHat + vhat(i,:)'*vhat(i-j,:);
    end
    end
    gammaHat = gammaHat/T;
end
