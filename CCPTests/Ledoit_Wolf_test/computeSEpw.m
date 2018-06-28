function [se]=computeSEpw(ret,type) 
    ret1 = ret(:,1);
    ret2 = ret(:,2);
    T = size(ret1,1);
    mu1hat = mean(ret1);
    mu2hat = mean(ret2);
    gamma1hat = mean(ret1.^2);
    gamma2hat = mean(ret2.^2);
    gradient = zeros(4,1);
    gradient(1) = gamma1hat/(gamma1hat - mu1hat^2)^1.5;
    gradient(2) = -gamma2hat/(gamma2hat - mu2hat^2)^1.5;
    gradient(3) = -0.5 * mu1hat/(gamma1hat - mu1hat^2)^1.5;
    gradient(4) = 0.5 * mu2hat/(gamma2hat - mu2hat^2)^1.5;
    Vhat = computeVhat(ret);
    Als = zeros(4,4);
    Vstar = zeros(T-1,4);
    reg1 = Vhat(1:T-1, 1);
    reg2 = Vhat(1:T-1, 2);
    reg3 = Vhat(1:T-1, 3);
    reg4 = Vhat(1:T-1, 4);
    X=[reg1 reg2 reg3 reg4];
    for j=1:4
        [coef,resi]=regnoint(X,Vhat(2:T,j));
        Als(j,:) = coef(:,1)';
        Vstar(:,j) = resi(:,1);
    end
    
    [U,S,V]= svd(Als);
    d=diag(S);
    dadj = d;
    for i=1:4 
        if d(i) > 0.97 
            dadj(i) = 0.97;
        elseif d(i) < -0.97 
            dadj(i) = -0.97;
        end
    end
        
    Ahat = U*diag(dadj)*V';
    D=inv(eye(4) - Ahat);
    for j=1:4 
        Vstar(:,j) = Vhat(2:T,j) - (Ahat(j,:)*X')';
    end
    Psihat = computePSI(Vstar,type);
    Psihat = D*Psihat*D';
    se=sqrt((gradient'*Psihat*gradient)/T);
end
