function [alphaHat]=computeAlpha(Vhat)
    dimensions = size(Vhat);
    T = dimensions(1);
    p = dimensions(2);
    numerator = 0;
    denominator = 0;
    for i=1:p
        results= ar2(Vhat(:, i),1);
        rhohat = results.beta(2);
        sighat = sqrt(results.sige);
        numerator = numerator + 4 * rhohat^2 * sighat^4/(1 - rhohat)^8;
        denominator = denominator + sighat^4/(1 - rhohat)^4;
    end
    
    alphaHat=numerator/denominator;
end
