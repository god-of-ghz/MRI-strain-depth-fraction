function d = DistancePts(pt1, pt2)
% helper function to compute distance between two points

%% VERSION HISTORY
% CREATED 10/13/20 BY SS

%% SAFETY AND PREPARATION
pt1_dim = size(size(pt1),2);
pt2_dim = size(size(pt2),2);

assert(pt1_dim <= 3);
assert(pt2_dim == pt1_dim);


%% ASSIGN VALUES
x1 = pt1(1);
x2 = pt2(1);

y1 = pt1(2);
y2 = pt2(2);

if pt1_dim == 3
    z1 = pt1(3);
    z2 = pt2(3);
else
    z1 = 0;
    z2 = 0;
end

%% CALCULATE DISTANCE
d = sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2);

