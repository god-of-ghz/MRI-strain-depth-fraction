function sec_shape =  DF_GridOverlay(strain,msk,rows,cols)
% function to overlay the relevant grid data on a strain map

%% VERSION HISTORY
% CREATED 10/19/20 BY SS

%% SAFTEY AND PREPARATION
% skipped for now 10/19
[x y] = size(msk);
n_cols = size(cols,2);
n_rows = size(rows,1);

%% OVERLAY GRID
sec_shape = strain;
for i = 1:x
    for j = 1:n_cols
        if msk(i,cols(i,j))
            sec_shape(i,cols(i,j)) = NaN;
        end
    end
end

for i = 1:n_rows
    for j = 1:y
        if msk(rows(i,j),j)
            sec_shape(rows(i,j),j) = NaN;
        end
    end
end
