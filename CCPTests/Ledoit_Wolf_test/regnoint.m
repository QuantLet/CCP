function [coef,resi]=regnoint(X,y)
coef=inv(X'*X)*X'*y;
resi=y-X*coef;
end
