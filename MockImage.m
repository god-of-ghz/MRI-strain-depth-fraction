function [mock_result, sec_ind] = MockImage(im_size,roi_x, roi_y, n_depth, n_cols)
% helper function to generate a fake image with roughly centered roi and a list of pixel indices for those sections
%% VERSION HISTORY
% CREATED 5/10/19 BY SS

%% PREPARATION
mock_result = zeros(im_size, im_size);

% compute starting & ending indices for the corners
x_start = floor((im_size - roi_x - n_cols)/2);
x_end = x_start + roi_x + n_cols;

y_start = floor((im_size - roi_y - n_depth)/2);
y_end = y_start + roi_y + n_depth;

% compute where to put the lines for the grid
y_itr = (n_depth + roi_y)/n_depth;
x_itr = (n_cols + roi_x)/n_cols;
line_depth = floor(y_start+y_itr:y_itr:y_end-y_itr);
line_cols = floor(x_start+x_itr:x_itr:x_end-x_itr);

%% PLACE ROI IN IMAGE CENTER
mock_result(y_start:y_end, x_start:x_end) = 1;

%% DRAW GRID LINES
mock_result(line_depth, ones(n_depth-1,1)*(x_start:x_end)) = 0;
mock_result(ones(n_cols-1,1)*(y_start:y_end),line_cols) = 0;

%% COMPUTE SECTION INDICES
% all the image indices for each section's pixels
sec_ind = cell(n_depth,n_cols);

for i = y_start:y_end
    for j = x_start:x_end
        if mock_result(i,j)
            % check row
            for k = 1:n_depth-1
                if i < line_depth(k)
                    depth_sec = k;
                    break;
                elseif i > line_depth(end)
                    depth_sec = n_depth;
                    break;
                end
            end
            
            % check column
            for k = 1:n_cols-1
                if j < line_cols(k)
                    col_sec = k;
                    break;
                elseif j > line_cols(end)
                    col_sec = n_cols;
                    break;
                end
            end
            
            %corner case for only 1 row/column
            if n_depth == 1
                depth_sec = 1;
            end
            if n_cols == 1
                col_sec = 1;
            end
            
            % add the current pixel's indices to the appropriate section
            sec_ind(depth_sec,col_sec) = {[sec_ind{depth_sec,col_sec}; [i, j];]};
        end
    end
end


