function [corner1, corner2] = DF_FindCorners(msk)
% a function to determine the rectangular size of the outer boundaries of a 2D mask
% rectangular boundaries are determined by the upper left (corner1) and
% bottom right (corner2) x and y coordinates

%% VERSION HISTORY
% CREATED 10/15/20 BY SS

%% SAFETY & PREPARATION
assert(size(size(msk),2) == 2);
[x y] = size(msk);

x_min = inf;
x_max = 0;

y_min = inf;
y_max = 0;

%% SEARCH THROUGH THE MATRIX
for i = 1:x
    for j = 1:y
        if msk(i,j)
            if i > x_max
                x_max = i;
            end
            if i < x_min
                x_min = i;
            end
            if j > y_max
                y_max = j;
            end
            if j < y_min
                y_min = j;
            end
        end
    end
end

%% ASSIGN AND RETURN VALUES
corner1 = [x_min, y_min];
corner2 = [x_max, y_max];