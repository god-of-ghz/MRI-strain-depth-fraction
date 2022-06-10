function [hS, sec_data, sec_shape, sec_color] = DF_Sections(strain, mask, n_depth, n_cols, s_bins, method)
% a function to break up the acquired image into sections by depth, and obtain their histogram

% this function expects strain to be a SINGLE 2D image
% it also expects a mask

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


%% PREPARATION
% safety
strain = squeeze(strain);
mask = squeeze(mask);
sec_shape = [];
sec_color = [];
assert(max(size(size(strain))) == 2);   % we have A SINGLE 2D image
assert(max(size(size(mask))) == 2);     % we have A SINGLE 2D mask
[x y] = size(strain);
[a b] = size(mask);
assert(x == a & y == b);                % and they are the exact same size

if isempty(n_depth)
    n_depth = 10;                       % default # of sections is 10
end
if isempty(n_cols)                      % default # of columns is 10
    n_cols = 10;
end

if isempty(method)
    method = 'height';                 % default method for sectioning
end

r_data = DF_ExtractRowData(strain, mask);   % grab the row data
r_ind = 1;                                  % an index for the row data

n_rows = size(r_data, 2);               % number of rows
count = cell_count(r_data);             % get the number of values (for dividing them up)
base_val = round(count / n_depth);      % the approximate number of pixels each section should be
sec_data = cell(n_depth, 1);       % a new cell array. each cell is the whole section

to_debug = 0;                           % a parameter to quickly set debugging (as needed)


%% DEPTH/SPATIAL SECTIONING
if strcmp(method,'npixels')             % split rows by number of pixels (area)
    for i = 1:n_depth                   % for each depth section
        if r_ind > n_rows                   % for safety
            continue;
        end

        sec_data(i) = r_data(r_ind);        % initialize the current section
        r_ind = r_ind + 1;                  % increment row index

        if r_ind > n_rows                   % for safety, because I'm lazy
            continue;
        end


        c1 = cell_count(sec_data(i));          % count of the current row
        c2 = c1 + cell_count(r_data(r_ind));   % count of the current row + the next one
        diff1 = abs(c1 - base_val);         % difference between the current size and intended size
        diff2 = abs(c2 - base_val);         % difference between adding the next row VS intended size

        while (diff1 > diff2 && r_ind <= n_rows)            % while the difference is greater or the same...
            sec_data(i) = {[sec_data{i} r_data{r_ind}]};    % append another row to the current section
            r_ind = r_ind + 1;                              % increment row index

            if r_ind > n_rows
                continue;
            end

            % recheck the differences. if the difference is low enough now, this section is done.
            c1 = cell_count(sec_data(i));          
            c2 = c1 + cell_count(r_data(r_ind));   
            diff1 = abs(c1 - base_val);         
            diff2 = abs(c2 - base_val);       
        end
    end
elseif strcmp(method,'height')          % split rows by geometric height
    % SS 2/8/19 I'm lazy for now, so the horizontal center will always be 60
    % SS 8/14/19 I'm still lazy, so the horizontal center will always be the center of the overall image
    h_rows = [];                        % the actual rows in the height calculation
    center = round(x/2);                        % the left-right center of the image
    for i = 1:y
        if mask(i,center)               % if the mask is good at this point
            h_rows = [h_rows; i];       % add this row to the height
        end
    end
    
    row_vals = DivideUp(max(size(h_rows)), n_depth);    % get the # to add to each section
    levels = zeros(1, n_depth);                         % a holder for where each level 'stops'
    for i = 1:n_depth
        % starting from the first height row, iteratively add the row
        % values to get each level's threshold
        levels(i) = h_rows(1) - 1 + sum(row_vals(1:i));
    end
    
    for i = 1:n_depth
        % add to current section until threshold is reached
        % OR
        while(r_ind <= levels(i) || (r_ind >= levels(end) && r_ind <= x))   
            temp = [];              % holder for row
            for j = 1:x             % for each row, go through all the columns
                if mask(r_ind, j)   % find where the mask says its ok
                    temp = [temp strain(r_ind, j)];     % add to the holder
                    
                    % for verification
                    strain(r_ind, j) = i;
                end
            end
            if ~isempty(temp)       % if we found anything in this row
                sec_data(i) = {[sec_data{i} temp]};     % add it to the current section
            end
            r_ind = r_ind + 1;      % increment the row index
            
            %bug fix for a corner case, when section 10 only has 1 row
            if r_ind == levels(end) && i == (n_depth - 1)
                i = n_depth;
            end    
        end
    end
    
    % for debugging
    assignin('base', 'modified_strain', strain);
    %assignin('base','HEIGHT_h_rows', h_rows);
    %assignin('base','HEIGHT_row_vals', row_vals);
    %assignin('base','HEIGHT_levels', levels);
    
elseif strcmp(method,'nrows')          % split the rows by their number only
    row_vals = DivideUp(n_rows, n_depth);   % grab the # of rows to use per section
    %assignin('base', 'rows_corrected', row_vals);
    
    % compile and add the section data
    for i = 1:n_depth                           % for each depth
        for j = r_ind:(r_ind + row_vals(i) - 1) % take the calculated number of rows (based on row_vals)
            sec_data(i) = {[sec_data{i} r_data{j}]};    % add them all to the current section
        end
        r_ind = r_ind + row_vals(i);            % increment to the next set of rows to use
    end
    
elseif strcmp(method,'grid')         % use the corners to make a grid-like pattern
    % redefine sec data, to avoid breaking older methods
    sec_data = cell(n_depth, n_cols);
    sec_shape = strain;             % holder for the grid overlaid on strain map
    sec_color = strain;             % holder for the colored grid
    
    %% row division
    % SS 5/5/19 I'm still lazy, so the horizontal center will always be 60
    % SS 8/14/19 I'm still lazy, so the horizontal center will always be the center of the overall image
    h_rows = [];                        % the actual rows in the height calculation
    center = round(x/2);                        % the left-right center of the image
    for i = 1:y
        if mask(i,center)               % if the mask is good at this point
            h_rows = [h_rows; i];       % add this row to the height
        end
    end
    height = max(size(h_rows));
   
    row_vals = DivideUp(height, n_depth, 'end');    % get the # to add to each section
    h_levels = zeros(n_depth-1, 1);                       % a holder for where each level 'stops'
    for i = 1:n_depth-1
        % starting from the first height row, iteratively add the row
        % values to get each level's threshold
        h_levels(i) = h_rows(1) - 1 + sum(row_vals(1:i));
    end
    
    %% column division
    
    % figure out width of each row (needed to determine position of columns)
    r_width = zeros(n_depth-1, 1);
    for i = 1:n_depth-1
        w = 0;              % holder for the current width
        for j = 1:y
            if mask(h_levels(i),j)    % if its a valid pixel, add 1
                w = w+1;
            end
        end
        r_width(i) = w;     % store that width at the end of each row
    end
   
    % populate the indices of all the relevant rows
    r_rows = cell(n_depth-1, 1);
    for i = 1:n_depth-1
        for j = 1:y
            if mask(h_levels(i), j)
                r_rows{i} = [r_rows{i} j];
            end
        end
    end
   
    % determine the width of each section at each level
    r_vals = zeros(n_depth-1, n_cols);
    for i = 1:n_depth-1
        r_vals(i,:) = DivideUp(r_width(i), n_cols, 'center');
    end
    
    % determine the vertical indices of these shifts
    r_levels = zeros(n_depth-1,n_cols-1);
    for i = 1:n_depth-1;
        temp = r_rows{i};
        for j = 1:n_cols-1
            r_levels(i,j) = temp(1) - 1 + sum(r_vals(i, 1:j));
        end
    end
    
    % subtract the one level from the next to obtain the left/right shift necessary per point pair
    r_diffs = zeros(n_depth-2, n_cols-1);
    for i = 1:n_depth-2
        r_diffs(i,:) = r_levels(i,:) - r_levels(i+1,:);
    end
    
    % prepare the necessary columnar threshold for every single row (ALL rows of the mask, not just the depth sections)
    r_shift = zeros(height, n_cols-1);
    r_ind = 0;                                  % index for the current row we're on, starts at 0 for a reason
    d_ind = 1;                                  % index for the current 'difference' row we're using
    for i = 1:height
        if r_ind == 0                           % if we haven't hit the first actual depth section
            r_shift(i,:) = r_levels(1,:);       % just use the first row's levels
            if h_rows(i+1) == h_levels(1)
                r_ind = 1;
            end
        elseif r_ind == n_depth-1                   % if we're beyond the last depth section
            r_shift(i,:) = r_levels(end,:);         % just use the last one's levels
        elseif h_rows(i) == h_levels(r_ind)         % when we finally reach the threshold level...
            r_shift(i,:) = r_levels(r_ind,:);
            diff = abs(h_levels(r_ind+1) - h_levels(r_ind))+1;
            start = i;
            finish = i+diff-1;
            
            for j = 1:n_cols-1
                cur_diff = r_diffs(d_ind, j);
                shift_grps = DivideUp(diff, abs(cur_diff)+1, 'center');        % compute the groups of pixels to shift
                cur_shift = ShiftHelper(shift_grps);         % correct and compute each pixel's shift level
                r_shift(start:finish, j) = r_shift(i,j)-(cur_shift-1).*sign(cur_diff);
            end
            
            r_ind = r_ind+1;                    % iterate those indices
            d_ind = d_ind+1;    
        end
    end
    
    %disp('loop end reached')
  
%     % find the candidates for 'top' and 'bottom' rows
%     for i = 1:x
%         for j = 1:4
%             if mask(h_rows(1)+j-2,i)
%                 top(j) = {[top{j} i]};            % the indices of the top row of pixels
%             end
%             if mask(h_rows(end)-j+2,i)
%                 bottom(j) = {[bottom{j} i]};      % the indices of the bottom row of pixels
%             end
%         end
%     end
%     
%     % pick the one with the most pixels (tends to be better representative
%     % of the overall geometry)
%     t_max = 0;
%     b_max = 0;
%     for i = 1:4
%         if cell_count(top(i)) > t_max
%             t_temp = top{i};
%         end
%         if cell_count(bottom(i)) >= b_max
%             b_temp = bottom{i};
%         end
%     end
%     top = t_temp;
%     bottom = b_temp;
%     
%     t_width = max(size(top));           % number in the top row (the width)
%     b_width = max(size(bottom));        % same for the bottom row
%     
%     % the width for each column (top & bottom)
%     t_vals = DivideUp(t_width, n_cols, 'center'); 
%     b_vals = DivideUp(b_width, n_cols, 'center');
%     
%     % the values of where each column ENDS (top & bottom)
%     t_levels = zeros(1, n_cols-1);
%     b_levels = zeros(1, n_cols-1);
%     
%     for i = 1:n_cols-1
%         t_levels(i) = top(1) - 1 + sum(t_vals(1:i));
%         b_levels(i) = bottom(1) - 1 + sum(b_vals(1:i));
%     end
%     
%     % columnar adjustment, since often the images are not perfectly square
%     % need to draw a 'line' from each level in the top row to the bottom row
%     lvl_diff = t_levels - b_levels;         % subtract the two to obtain the left/right shift necessary per point pair
%     lvl_shift = NaN(height, n_cols - 1);    % the values for the shifted threshold levels (the 'line' being drawn)
%     
%     lvl_shift(1, :) = t_levels(:);          % assign the first and last values as their respective top and bottom rows
%     lvl_shift(end, :) = b_levels(:);
%     
%     for i = 1:n_cols-1                      % for each column
%         % row_shift, the shifting pattern
%         % e.g. 43 rows, shifted over 8 pixels total, DivideUp yields:
%         % 5 5 6 5 6 5 6 5
%         % e.g. first 5 pixels are NOT shifted, next 5 are shifted 1, next 6
%         % are shifted 2, next 5 are shifted 3, etc, until the total shift is reached
%         % +1 to the difference because first and last set 'match' the final pixel 
%         row_shift = DivideUp(height, abs(lvl_diff(i))+1,'even');     
%         
%         lvl_ind = 1;                        
%         for j = 1:max(size(row_shift))
%             start = lvl_ind;                        % where to start the current amount of shifting
%             finish = lvl_ind+row_shift(j)-1;        % where to end it
%             lvl_shift(start:finish,i) = t_levels(i) - ((j - 1)*sign(lvl_diff(i)));   % perform the calculation
%             lvl_ind = lvl_ind + row_shift(j);       % iterate to the next set of rows
%         end
%     end
    
    %% section sorting
    % iterate through the image, sorting each pixel into the correct section
    % a pixel is "in" a section if its index is *lower OR equal* to the threshold value
    h_ind = 1;      % an extra index needed for the height, used in columnar sectioning
    next_row = 0;
    for i = 1:x
        for j = 1:y
            if mask(i,j)
                % find the FIRST valid section, stop once we do
                % check row section (top to bottom)
                for k = 1:n_depth - 1
                    if i <= h_levels(k)
                        depth_sec = k;
                        break;
                    elseif i > h_levels(end)
                        depth_sec = n_depth;
                        break;
                    end
                end
                
                % to handle pixels that may be above/below officially designated levels
                if i <= h_rows(1)
                    h_ind = 1;
                elseif i > h_rows(end)
                    h_ind = height;
                end
                
                % check column section (left to right)
                for k = 1:n_cols - 1
                    % using that extra index here, since every row might have a different cutoff value
                    if j <= r_shift(h_ind, k)     
                        col_sec = k;
                        break;
                    elseif j > r_shift(h_ind, end)
                        col_sec = n_cols;
                        break;
                    end
                end
                next_row = 1;           % since we used that index, mark it to be iterated when we go to the next row
                temp = strain(i, j);
                
                % to fix a corner case if either value is just 1
                if n_depth == 1;
                    depth_sec = 1;
                end
                if n_cols == 1
                   col_sec = 1;
                end
                
                sec_data(depth_sec, col_sec) = {[sec_data{depth_sec, col_sec} temp]};
                
                % for verification, only used to ensure the sectioning
                % worked correctly
                sec_color(i,j) = depth_sec + col_sec;
                
            end
        end
        % increment that index, and reset it (needs to be reset if we don't use anything in that row)
        if next_row
            next_row = 0;
            h_ind = h_ind + 1;
        end
    end
    
    %% debugging
    if to_debug
        assignin('base', 'grid_r_width', r_width);
        assignin('base','grid_r_rows', r_rows);
        assignin('base','grid_r_vals', r_vals);
        assignin('base','grid_r_levels', r_levels);
        assignin('base', 'grid_r_diffs', r_diffs);
        assignin('base', 'grid_r_shift', r_shift);
        
        assignin('base','grid_h_levels', h_levels);
        assignin('base','grid_h_rows', h_rows);

        %assignin('base', 'grid_lvl_diff', lvl_diff);
        %assignin('base', 'grid_lvl_shift', lvl_shift);

        %assignin('base', 'grid_top', top);
        %assignin('base', 'grid_bottom', bottom);
    end
    
    %% grid drawing, for verification
    sec_shape(h_levels, :) = NaN;                   % draw all rows
    sec_shape(1:h_rows(1), r_shift(1,:)) = NaN;   % draw all columns "above" the image roi
    for i = 1:max(size(h_rows))                     % draw the columns inside the roi
        sec_shape(h_rows(i), r_shift(i,:)) = NaN;
    end
    sec_shape(h_rows(end):x, r_shift(end,:)) = NaN; % draw all columns "below" the image roi
    sec_shape(find(~mask)) = 0;                     % remove extraneous grid lines
    
end

%% HISTOGRAM COMPUTATION
%if bins were entered, run the histogram
if ~isempty(s_bins)
    n_sec = max(size(sec_data));                % number of sections
    hS = zeros(n_sec, size(s_bins, 2) + 1);     % holder for the binned data
    for i = 1:n_sec
        hS(i, :) = DF_Histogram(sec_data{i}, s_bins);
    end
else
    hS = [];    %just return an empty matrix
end