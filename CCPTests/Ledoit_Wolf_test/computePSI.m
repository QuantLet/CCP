function [psi]=computePSI(Vhat,type) 
    T=size(Vhat,1);
    alphaHat = computeAlpha(Vhat);
    Sstar = 2.6614 * (alphaHat*T)^0.2;
    PsiHat = GammaHat(Vhat,0);
    j = 1;
    while j < Sstar
        Gamma = GammaHat(Vhat, j);
        PsiHat = PsiHat + kernelType(j/Sstar,type) * (Gamma+Gamma');
        j = j + 1;
    end
    PsiHat=(T/(T - 4))*PsiHat;
    psi=PsiHat;
end
    
