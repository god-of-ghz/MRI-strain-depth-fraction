function [end_pt] = DF_FindEdge(msk, start_pt, dir)
% a helper function to find the edge of a mask from a starting point, given a direction

%% VERSION HISTORY
% CREATED 10/16/20 BY SS

%% SAFETY AND PARAMETERS
% input mask must be 2D
assert(size(size(msk),2) == 2);
% input point must be 2D, [x y] format
assert(size(start_pt,2) == 2);
assert(size(start_pt,1) == 1);

% using a 'directional iterator' here
% moves the point by just adding the iterator to the point 
% iterator is based on the desired direction
if strcmp(dir,'l') || strcmp(dir,'left')
    dir_itr = [0 -1];
elseif strcmp(dir,'r') || strcmp(dir,'right')
    dir_itr = [0 1];
elseif strcmp(dir,'u') || strcmp(dir,'up')
    dir_itr = [-1 0];
elseif strcmp(dir,'d') || strcmp(dir,'down')
    dir_itr = [1 0];
else
    error('Direction not recognized. Please use left, right, up, or down.');
end

if ~msk(start_pt(1),start_pt(2))
    error('Starting point must be within the ROI of the mask.')
end

%% FIND THE EDGE
cur_pt = start_pt;

% while we're still in the mask
while(msk(cur_pt(1),cur_pt(2)))
    % keep adding the directional iterator
    cur_pt = cur_pt + dir_itr;
end

% once we've left the loop, it means we've left the mask, so we have to 'go back' one pixel
end_pt = cur_pt - dir_itr;
