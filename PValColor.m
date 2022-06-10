function [cval] = PValColor(pval, sig)
% helper function to turn p-values into intensity colors for stats visualization
%% VERSION HISTORY
% CREATED 5/12/19 BY SS


%% COLOR GUIDE
%   dark blue   =   very insignificant
%   blue        =   insignificant
%   green       =   almost significant
%   deep orange =   significant at 0.05
%   orange      =   significant at 0.01
%   yellow      =   significant at 0.001

levels = zeros(1,5);
factors = [4 2 1 0.2 0.02];
for i = 1:5
    levels(i) = factors(i)*sig;
end

if pval > levels(1)                          % not significant at all
    cval = 1;                     
elseif pval <= levels(1) && pval > levels(2)      % a little closer, but still not significant
    cval = 2;
elseif pval <= levels(2) && pval > levels(3)      % close to significant
    cval = 5;
elseif pval <= levels(3) && pval > levels(4)      % significant at p = 0.05
    cval = 8;
elseif pval <= levels(4) && pval > levels(5)     % significant at p = 0.01
    cval = 9;
elseif pval <= levels(5)                   % hella significant, p = 0.001
    cval = 10;
end


