function [hS, sec_data, sec_shape, sec_color] = DF_Sections2(strain,msk,n_depth,n_cols,s_bins, debug)
% a function to break up the acquired strain map into a grid

%% VERSION HISTORY
% CREATED 11/18/18 BY SS
% CHANGED 2/5/18 BY SS
%       - CHANGED HISTOGRAM COMPUTATION TO BE OPTIONAL
%       - SPLIT METHODS OF DEPTH-WISE SECTIONING
% CHANGED 2/8/18 BY SS
%       - CHANGED FUNCTION TO DIRECTLY TAKE IN STRAIN AND MASK
%       - ADDED HEIGHT SECTIONING
%       - THIS FUNCTION NOW CALLS DF_ExtractRowData DIRECTLY
% CHANGED 5/4/18 BY SS
%       - SECTIONING BUG FIXES
%       - NOW CAN SECTION AS A GRID
% CHANGED 9/17/19 BY SS
%       - GRID DEFORMS PROPERLY TO SAMPLE WIDTH
% VERSION 2.0 - 10/13/20
%       - COMPLETELY RE-WORKED GRID FUNCTIONALITY
%       - GRID NOW DEFORMS PROPERLY TO SAMPLE WIDTH *AND* HEIGHT

%% SAFETY & PREPARATION
if ~exist('debug','var')
    debug = 0;
end
%debug = 1; 
assert(n_cols > 0);
assert(n_depth > 0);
assert(size(size(msk),2) == 2);
[x y] = size(msk);
sec_data = cell(n_depth, n_cols);

%% ACQUIRE BOUNDARIES
[left, right, top, bot] = DF_FindSides(msk);
[corner_tl, corner_br] = DF_FindCorners(msk);
u_ratio_c = 5;       % update col/row adjustment every <value> pixels. lower value = more sensitive to shape, but noisier
u_ratio_r = 3;

%% VERTICAL/COLUMN BOUNDARIES
if n_cols ~= 1
    cols = NaN(x,n_cols-1);
    [~, width_t] = NomLength(top);
    [~, width_b] = NomLength(bot);

    col_width_top = DivideUp(width_t,n_cols);
    col_width_bot = DivideUp(width_b,n_cols);

    % upper and lower column boundaries
    for i = 1:n_cols-1
        cols(corner_tl(1),i) = top(1,2) + sum(col_width_top(1:i));
        cols(corner_br(1),i) = bot(1,2) + sum(col_width_bot(1:i));
    end

    col_ind_top = zeros(n_cols-1,2);
    col_ind_bot = zeros(n_cols-1,2);

    % fill into edges of mask, find where the mask starts and ends
    for i = 1:n_cols-1
        % fill from top
        j = 1;
        val = top(1,2) + sum(col_width_top(1:i));
        while(~msk(j,val))
            cols(j,i) = val;
            j = j+1;
        end
        cols(j,i) = val;
        col_ind_top(i,:) = [j val];

        % fill from bottom
        j = y;
        val = bot(1,2) + sum(col_width_bot(1:i));
        while(~msk(j,val))
            cols(j,i) = val;
            j = j - 1;
        end
        cols(j,i) = val;
        col_ind_bot(i,:) = [j val];
    end

    % compute each column, one at a time
    for i = 1:n_cols-1
        % x values of where the columns START (top) and end (BOT)
        x_t = col_ind_top(i,1);
        x_b = col_ind_bot(i,1);

        % y values for the same
        y_t = col_ind_top(i,2);
        y_b = col_ind_bot(i,2);

        % height for the current column
        h = x_b - x_t;
        % how many times to update each column adjustment
        n_update = (corner_br(1) - corner_tl(1))/u_ratio_c;
        temp_col_updates = DivideUp(h,round(n_update),'even');

        % the column's positions are updated several times throughout the height
        % each update is calculated to where it should be, and a line it drawn
        % to it from the previous update
        % therefore, each calculation must know where it starts vs where it ends

        % calculate the updates for each column
        x_prev = x_t;
        y_prev = y_t; 
        for j = 1:size(temp_col_updates,1)
            % corner case if we're at the end
            if j == size(temp_col_updates,1)
                x_next = x_b;
                y_next = y_b;
            else
                x_next = x_t + sum(temp_col_updates(1:j));
                ly = [];
                ry = [];

    %             for k = x_prev:x_next
    %                 %ly = [ly; left(FindClosest(left(:,1),k),2);];
    %                 t = DF_FindEdge(msk,[k y_prev],'left');
    %                 ly = [ly; t(2)];
    %                 %ry = [ry; right(FindClosest(right(:,1),k),2);];
    %                 t = DF_FindEdge(msk,[k y_prev],'right');
    %                 ry = [ry; t(2)];
    %             end
                ly = left(FindClosest(left(:,1),x_next),2);
    %             ly = left(find(left(:,1) == x_next),2);
    %             if isempty(ly)
    %                 ly = DF_FindEdge(msk,[x_prev y_prev],'left');
    %                 ly = ly(2);
    %             end
                ry = right(FindClosest(right(:,1),x_next),2);
    %             ry = right(find(right(:,1) == x_next),2);
    %             if isempty(ry)
    %                 ry = DF_FindEdge(msk,[x_prev y_prev],'right');
    %                 ry = ry(2);
    %             end
                % figure out how wide each column should be in the current update
                ly = round(mean(ly(:)));
                ry = round(mean(ry(:)));
                temp_col_widths = DivideUp(ry-ly,n_cols);

                y_next = ly + sum(temp_col_widths(1:i));
            end

            shift_x = x_next - x_prev;
            shift_y = y_next - y_prev;
            shift = ShiftHelper(DivideUp(abs(shift_x),abs(shift_y),'even'));
            assert(x_prev+size(shift,1) == x_next);

            for k = 1:size(shift,1)
                cols(x_prev+k,i) = y_prev + shift(k)*sign(shift_y);
            end

            x_prev = x_next;
            y_prev = y_next;
        end
    end

    if debug
        assignin('base','cols',cols);
%         %assignin('base','col_ind_top',col_ind_top);
%         %assignin('base','col_ind_bot',col_ind_bot);
%         figure, imagesc(msk), title('columns'), axis equal off, hold on
%         for j = 1:n_cols-1
%             color = 'r+';
%             for i = 1:x
%                 if ~isnan(cols(i,j))
%                     plot(cols(i,j),i,color, 'MarkerSize', 3, 'LineWidth', 0.5)
%                 else
%                     color = 'c+';
%                 end
%             end
%         end
    end
else
    cols = [];
end

%% HORIZONTAL BOUNDARIES
if n_depth ~= 1
    rows = NaN(n_depth-1,y);
    [height_l,~] = NomLength(left);
    [height_r,~] = NomLength(right);

    row_height_left = DivideUp(height_l,n_depth);
    row_height_right = DivideUp(height_r,n_depth);

    % left and right row boundaries
    for i = 1:n_depth-1
        rows(i,corner_tl(2)) = left(1,1) + sum(row_height_left(1:i));
        rows(i,corner_br(2)) = right(1,1) + sum(row_height_right(1:i));
    end

    row_ind_left = zeros(n_depth-1,2);
    row_ind_right = zeros(n_depth-1,2);

    % fill edges of mask, find where the row markers start and end
    for i = 1:n_depth-1
        % fill from left
        j = 1;
        val = left(1,1) + sum(row_height_left(1:i));
        while ~msk(val,j)
            rows(i,j) = val;
            j = j+1;
        end
        rows(i,j) = val;
        row_ind_left(i,:) = [val j];

        % fill from right
        j = x;
        val = right(1,1) + sum(row_height_right(1:i));
        while ~msk(val,j)
            rows(i,j) = val;
            j = j-1;
        end
        rows(i,j) = val;
        row_ind_right(i,:) = [val j];
    end

    % compute each row, one at a time
    for i = 1:n_depth-1
        %x values of where the rows start
        x_l = row_ind_left(i,1);
        x_r = row_ind_right(i,1);

        % y values for the same
        y_l = row_ind_left(i,2);
        y_r = row_ind_right(i,2);

        % width for the current row
        w = y_r - y_l;
        % how many times to update row width
        n_update = (corner_br(2) - corner_tl(2))/u_ratio_r;
        temp_row_updates = DivideUp(w,round(n_update),'even');

        % calculate updates
        x_prev = x_l;
        y_prev = y_l;
        for j = 1:size(temp_row_updates,1)
            % corner case if we're at the end
            if j == size(temp_row_updates,1)
                x_next = x_r;
                y_next = y_r;
            else
                y_next = y_l + sum(temp_row_updates(1:j));
                tx = [];
                bx = [];

                tx = top(FindClosest(top(:,2),y_next),1);
                bx = bot(FindClosest(bot(:,2),y_next),1);

                tx = round(mean(tx(:)));
                bx = round(mean(bx(:)));
                temp_row_heights = DivideUp(bx-tx,n_depth);

                x_next = tx + sum(temp_row_heights(1:i));
            end

            shift_x = x_next - x_prev;
            shift_y = y_next - y_prev;
            shift = ShiftHelper(DivideUp(abs(shift_y),abs(shift_x),'even'));
            assert(y_prev+size(shift,1) == y_next);

            for k = 1:size(shift,1)
                rows(i,y_prev+k) = x_prev + shift(k)*sign(shift_x);
            end

            x_prev = x_next;
            y_prev = y_next;
        end
    end

    if debug
          assignin('base','rows',rows);
%         %assignin('base','row_ind_left',row_ind_left);
%         %assignin('base','row_ind_right',row_ind_right);
%         figure, imagesc(msk), title('rows'), axis equal off, hold on
%         for j = 1:n_depth-1
%             color = 'k+';
%             for i = 1:y
%                 if ~isnan(rows(j,i))
%                     plot(i,rows(j,i),color,'MarkerSize',3,'LineWidth',0.5)
%                 else
%                     color = 'g+';
%                 end
%             end
%         end
    end
else
    rows = [];
end

%% SORT THE PIXELS INTO THE CELLS MADE BY THE GRID
px_row = [];
px_col = [];
sec_color = NaN(x,y);
for i = 1:x
    for j = 1:y
        if msk(i,j)
            [px_row, px_col] = DF_Assign2Grid([i j],msk,rows,cols);
            sec_data(px_row,px_col) = cell_pool(sec_data(px_row,px_col),{strain(i,j)});
            sec_color(i,j) = px_row + px_col;
        end
    end
end

%% APPLY GRID/COLORING OVERLAY
sec_shape = DF_GridOverlay(strain,msk,rows,cols);
hS = [];

%% VISUALIZE FOR DEBUGGING, AS NEEDED
if debug
    
    % plot the sides
    figure;
    subplot(2,2,1),imagesc(msk), title('top'), axis equal off, hold on
    plot(top(:,2),top(:,1),'r+', 'MarkerSize', 4, 'LineWidth', 2)
    hold off
    subplot(2,2,2),imagesc(msk), title('bottom'), axis equal off, hold on
    plot(bot(:,2),bot(:,1),'c+', 'MarkerSize', 4, 'LineWidth', 2)
    hold off
    subplot(2,2,3),imagesc(msk), title('right'), axis equal off, hold on
    plot(right(:,2),right(:,1),'g+', 'MarkerSize', 4, 'LineWidth', 2)
    hold off
    subplot(2,2,4),imagesc(msk), title('left'), axis equal off, hold on
    plot(left(:,2),left(:,1),'k+', 'MarkerSize', 4, 'LineWidth', 2)
    hold off
    %plot(tl_corner(2),tl_corner(1),'g+', 'MarkerSize', 5, 'LineWidth', 2)
    %plot(br_corner(2),br_corner(1),'b+', 'MarkerSize', 5, 'LineWidth', 2)
    
    % plot the overlay
    figure, imagesc(sec_shape), colorbar, axis equal off, title('grid overlay');
    %figure, imagesc(sec_color), axis equal off, title('grid assignment');
end