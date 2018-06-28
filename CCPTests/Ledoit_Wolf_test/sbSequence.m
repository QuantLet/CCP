function [sequence] = sbSequence(T,bAv,length)
% Computes a stationary bootstrap sequence applied to (1:T)
% Inputs: 
    % T
    % bAv = average block size
    % length = lenght of bootstrap sequence (equal to T by default)
% Outputs:
    % sequence = bootstrap sequence
% Note:
    % 
    
    if (nargin < 3)
        length = T;
    end
    indexSequence = [1:T,1:T]';
    sequence = zeros(length+T,1);
    current = 0;
    while (current < length)
        start = randperm(T);
        start = start(1);
        b = geornd(1/bAv)+1;
        sequence((current+1):(current+b)) = indexSequence(start:(start+b-1));
        current = current+b;
    end
    sequence = sequence(1:length);
end
