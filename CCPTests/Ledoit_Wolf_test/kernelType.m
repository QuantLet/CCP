function [wt]=kernelType(x,type)
switch type
        case 'G'
            % --- Parzen (Gallant) --------------------------
            if x < 0.5
                wt = 1 - 6*x^2 + 6*x^3;
            elseif x < 1
                wt = 2*(1-x)^3;
            else
                wt = 0;
            end
        case 'QS'
            % --- Quadratic Spectral -------------------------------------------
            term = 6*pi*x/5;
            
            wt = 25*(sin(term)/term - cos(term))/(12*pi^2*x^2);
        
end
