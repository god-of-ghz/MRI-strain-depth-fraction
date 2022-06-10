function [x, y] = NomLength(chain)
% a helper function to determine the maximum nominal dimensions of a chain
% X is the top-bottom HEIGHT
% Y is the left-right WIDTH
% expects the 'chain' to be an array of neighboring 2D points in the [x y] format
% ex: [1 2; 3 4; 5 6; 7 8; 9 10;];

%% VERSION HISTORY
% CREATED 10/14/20 BY SS

%% PARAMETERS
n_pts = size(chain,1);

x_max = 0;
x_min = inf;

y_max = 0;
y_min = inf;

%% DETERMINE MAXIMUM DIMENSIONS
for i = 1:n_pts
    pt = chain(i,:);
    if pt(1) > x_max
        x_max = pt(1);
    end
    if pt(1) < x_min
        x_min = pt(1);
    end
    if pt(2) > y_max
        y_max = pt(2);
    end
    if pt(2) < y_min
        y_min = pt(2);
    end
end

%% RETURN RESULT
x = x_max - x_min;
y = y_max - y_min;