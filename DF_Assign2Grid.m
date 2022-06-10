function [row, col] = DF_Assign2Grid(pt,msk,rows,cols)
% function to place a pixel within the relevant row and column

%% VERSION HISTORY 
% CREATED 10/19/20 BY SS

%% SAFETY & PREPARATION
x = pt(1);
y = pt(2);
assert(msk(x,y) == 1);     % make sure the pixel is IN the mask
col = [];
row = [];

n_cols = size(cols, 2);
n_rows = size(rows, 1);

%% COMPUTE COLUMN
% save us some time
if n_cols == 1 || n_cols == 0
    col = 1;
else
    % initialize column
    col = 1;
    % if the pixel's y value (horizontal position) is greater than the
    % current column we're checking...
    while(y > cols(x,col) && col <= n_cols)
        col = col + 1;      % go to the next column
        if col > n_cols
            break;
        end
    end
    % if we've exited the loop, it means we've either found a column it
    % fits with
    % or reached the max column count
end

%% COMPUTE ROW
% save us some time
if n_rows == 1 || n_rows == 0
    row = 1;
else
    row = 1;
    while(x > rows(row,y) && row <= n_rows)
        row = row + 1;
        if row > n_rows
            break;
        end
    end
end

