function [sequence] = cbbSequence(T,b)
% Computes a circular block bootstrap sequence applied to (1:T)
% Inputs: 
    % T
    % b = block size
% Outputs:
    % sequence = bootstrap sequence
% Note:
    % 
    
    l = floor(T/b)+1;
    indexSequence = [1:T,1:b]';
    sequence = zeros(T+b,1);
    startPoints = randi(T,1,l);
    for (j=1:l)
        start = startPoints(j);
        sequence(((j-1)*b+1):(j*b)) = indexSequence(start:(start+b-1));
    end
    sequence = sequence(1:T);
end
