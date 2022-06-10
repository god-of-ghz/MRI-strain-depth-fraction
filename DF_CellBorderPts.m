function [pts_to_mark] = DF_CellBorderPts(msk,rows,cols,row,col)
% helper function to compute the points bordering a single cell of the grid
% returns a list of points that form the perimeter of that cell

%% SAFETY & PREPARATION
x_pts = [];
y_pts = [];

x = size(cols,1);
y = size(rows,2);

n_cols = size(cols,2)+1;
n_rows = size(rows,1)+1;

%% COMPUTE WHICH SIDES TO USE
% top, bottom, left, right
side_t = 1;
side_b = 1;
side_l = 1;
side_r = 1;

if col == 1
    side_l = 0;
elseif col == n_cols
    side_r = 0;
end
if row == 1
    side_t = 0;
elseif row == n_rows
    side_b = 0;
end

%% COMPUTE CORNERS 




if col == 1
elseif col == n_cols
else
    tl_corner = [];
    tr_corner = [];
    bl_corner = [];
    br_corner = [];
    
    for i = 1:x
        % left side
        val = cols(i,col);
        if rows(row,val) == i
            bl_corner = [i val];
        elseif rows(row-1,val) == i
            tl_corner = [i val];
        end
        
        % right side
        val = cols(i-1,col);
        if rows(row,val) == i
            bl_corner = [i val];
        elseif rows(row-1,val) == i
            tl_corner = [i val];
        end
    end
end

%% ADD POINTS TO THE LIST
for i = bl_corner(2):br_corner(2)
    pts_to_mark = [pts_to_mark; [rows(row,i) i]];
end


%% COMPUTE ROW POINTS
if row == 1
elseif row == n_rows
else
end
