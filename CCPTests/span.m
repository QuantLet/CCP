%
%   This Matlab program computes the three spanning tests
%   Wald, LR, and LM test statistics as well as their
%   exact p-values.
%   Input:
%   R1: TxK matrix of returns on benchmark assets
%   R2: TxN matrix of returns on test assets
%   Output:
%   W: Wald test statistic
%   LR: Likelihood ratio statistic
%   LM: Lagrange Multiplier
%   pw: p-value of Wald test
%   plr: p-value of likelihood ratio test
%   plm: p-value of Lagrange multiplier test
%
function [W,LR,LM,pw,plr,plm] = span(R1,R2)
[T,K] = size(R1);
N = size(R2,2);
mu1 = mean(R1)';
V11i = inv(cov(R1,1)); 
a1 = mu1'*V11i*mu1;
b1 = sum(V11i*mu1);
c1 = sum(sum(V11i));
G = [1+a1 b1; b1 c1];
%                        
%   Compute \hat\alpha and \hat\delta
%                        
A = [1 zeros(1,K); 0 -ones(1,K)];          
C = [zeros(1,N); -ones(1,N)];
X = [ones(T,1) R1];
B = X\R2;   
Theta = A*B-C;       
e = R2-X*B;           
Sigma = cov(e,1);
H = Theta*inv(Sigma)*Theta';
lam = eig(H*inv(G));
%
%   Compute the three test statistics
%
Ui = prod(1+lam);
W = T*sum(lam);
LR = T*log(Ui);
LM = T*sum(lam./(1+lam));
%
%   Compute the p-values
%
if nargout>3
   if N==1
      pw = 1-fcdf((T-K-1)*W/(2*T),2,T-K-1);
      plr = pw;
      plm = pw;
   else
      pw = 1-wald(W/T,N,T-K-N+1);
      Ftest = (T-K-N)*(sqrt(Ui)-1)/N;
      plr = 1-fcdf(Ftest,2*N,2*(T-K-N));
      plm = 1-pillai2(LM/T,N,T-K-N+1);
   end
end

