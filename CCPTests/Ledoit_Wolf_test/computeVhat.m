function [vhat]=computeVhat(X)

nu = [mean(X(:,1)); mean(X(:,2)); mean(X(:,1).^2); mean(X(:,2).^2)];
nux = [X(:,1)-nu(1) X(:,2)-nu(2) X(:,1).^2-nu(3) X(:,2).^2-nu(4)];
vhat=nux;
end
