function [left, right, top, bottom] = DF_FindSides(msk)
% a helper function to find the sides of an image using its mask (assumes roughly rectangular shape)

%% VERSION HISTORY
% CREATED 10/12/20 BY SS
% MODIFIED 10/15/20 BY SS
%   - if top or bottom sides overlap with the left/right, it gives those
%   points to the left/right sides, and removes them from the top/bottom

%% SAFETY & PREPARATION
assert(size(size(msk),2) == 2);

[x, y] = size(msk);
left = [];
right = [];
top = [];
bottom = [];

remove_duplicate = 1;

%% FIND LEFT & RIGHT SIDE CANDIDATES
for i = 1:x
    L = 1;
    R = y;
    while(~msk(i,L))
        L = L + 1;
        if L == y
            break;
        end
    end
    while(~msk(i,R))
        R = R - 1;
        if R == 1
            break;
        end
    end
    if L ~= y
        left = [left;[i L];];
    end
    if R ~= 1
        right = [right; [i R];];
    end
end
    

%% FIND TOP AND BOTTOM CANDIDATES
for i = 1:y
    T = 1;
    B = x;
    while(~msk(T,i))
        T = T + 1;
        if T == x
            break;
        end
    end
    while(~msk(B,i))
        B = B - 1;
        if B == 1
            break;
        end
    end
    if T ~= x
        top = [top; [T i];];
    end
    if B ~= 1
        bottom = [bottom; [B i];];
    end
end

%% FIND THE MAIN CHAINS (i.e. the longest continuous sides)
[left, ~] = DF_FindChain(left);
[right,~] = DF_FindChain(right);
[top,~] = DF_FindChain(top);
[bottom,~] = DF_FindChain(bottom);

%% REMOVE POINTS FROM TOP/BOTTOM THAT OVERLAP WITH THE RIGHT/LEFT SIDES
if remove_duplicate
    % top
    remove_ind = [];
    for i = 1:size(top,1)
        for j = 1:size(left,1)
            if top(i,1) == left(j,1) && top(i,2) == left(j,2)
                remove_ind = [remove_ind; i;];
            end
        end
        for j = 1:size(right,1)
            if top(i,1) == right(j,1) && top(i,2) == right(j,2)
                remove_ind = [remove_ind; i;];
            end
        end
    end
    top(remove_ind,:) = [];
    
    % bottom
    remove_ind = [];
    for i = 1:size(bottom,1)
        for j = 1:size(left,1)
            if bottom(i,1) == left(j,1) && bottom(i,2) == left(j,2)
                remove_ind = [remove_ind; i;];
            end
        end
        for j = 1:size(right,1)
            if bottom(i,1) == right(j,1) && bottom(i,2) == right(j,2)
                remove_ind = [remove_ind; i;];
            end
        end
    end
    bottom(remove_ind,:) = [];
end