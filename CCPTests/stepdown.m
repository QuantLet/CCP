%
%   This Matlab program computes the step-down spanning test.
%   Input:
%   R1: TxK matrix of returns on benchmark assets
%   R2: TxN matrix of returns on test assets
%   Output:
%   Ftest: Joint test of alpha=0_N, delta=0_N
%   Ftest1: Test of alpha=0_N,
%   Ftest2: Test of delta=0_N conditional on alpha=0_N
%   pval: p-value of Ftest
%   pval1: p-value of Ftest1
%   pval2: p-value of Ftest2
%   alpha: sample estimate of alpha
%   delta: sample estimate of delta
%
function [Ftest,Ftest1,Ftest2,pval,pval1,pval2,alpha,delta] = stepdown(R1,R2)
[T,K] = size(R1);
N = size(R2,2);
mu1 = mean(R1)';
V11i = inv(cov(R1,1)); 
a1 = mu1'*V11i*mu1;
b1 = sum(V11i*mu1);
c1 = sum(sum(V11i));
d1 = a1*c1-b1^2;
G = [1+a1 b1; b1 c1];
R = [R1 R2];
mu = mean(R)';
Vi = inv(cov(R,1));
a = mu'*Vi*mu;
b = sum(Vi*mu);
c = sum(sum(Vi));
d = a*c-b^2;
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
if N==1
   Ftest = (T-K-1)*(Ui-1)/2;
else
   Ftest = (T-K-N)*(sqrt(Ui)-1)/N;
end
Ftest1 = (T-K-N)/N*(a-a1)/(1+a1);
Ftest2 = (T-K-N+1)/N*((c+d)*(1+a1)/((c1+d1)*(1+a))-1);
%
%   Compute the p-values
%
if nargout>3
   if N==1
      pval = 1-fcdf(Ftest,2,T-K-1);
   else
      pval = 1-fcdf(Ftest,2*N,2*(T-K-1));
   end
   pval1 = 1-fcdf(Ftest1,N,T-K-N);
   pval2 = 1-fcdf(Ftest2,N,T-K-N+1);
end   
if nargout>6   
   alpha = Theta(1,:)';
   delta = Theta(2,:)';
end   