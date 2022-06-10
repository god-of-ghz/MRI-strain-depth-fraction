function [ind] =  FindClosest(a,b)
% helper function to find the index of the value in a  that is *closest* to b

%% VERSION HISTORY
% CREATED 10/17/20 BY SS

%% SAFETY & PREPARATION
% skipping safety for now because I code hard, fast, & close to the metal
diff = inf;
ind = [];
[x y z] = size(a);

%% FIND MINIMUM DIFFERENCE
for i = 1:x
    for j = 1:y
        for k = 1:z
            val = abs(a(i,j,k)-b);
            if val < diff
                diff = val;
                ind = [i j k];
            end
        end
    end
end

%% CONVERT TO A LINEAR INDEX 
ind = sub2ind([x y z],ind(1),ind(2),ind(3));