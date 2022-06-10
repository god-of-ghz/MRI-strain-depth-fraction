function [bin_data] = DF_Histogram(data, bin_thresh)
% a function to quickly bin data based on the desired threshold values per bin

% how the bin thresholds are expected to be set up: 
% 1st bin is everything lower than it
% 2nd bin is everything between 1st and 2nd
% 3rd is everything between 2nd and 3rd, and so on
% Last bin is everything above it
% So for example, if I have 5 values in 'bin_thresh', 1, 2, 3, 4 & 5
% The actual binds will be <1, 1-2, 2-3, 3-4, 4-5, >5 (6 actual bins)
% Always use < current value and >= previous value (where applicable)

%% FOR DEBUGGING/SAFETY
%disp(bin_thresh)
assert(~isempty(data));                 % if this fails, no data was actually passed here

%% INITIALIZE VARIABLES
n_vals = max(size(data));                   % the larger dimension is the amount of data
n_thresh = max(size(bin_thresh));           % # of threshold values
n_bins = n_thresh + 1;                       % # of bins is # of thresholds + 1
bin_vals = zeros(1, n_bins);                 % integer count for each bin (start at 0)
bin_data = zeros(1, n_bins);                 % total percentage of each bin


%% ASSEMBLE BIN COUNTS
for i = 1:n_vals                        % run through the data
    if data(i) < bin_thresh(1)          % first value
        bin_vals(1) = bin_vals(1) + 1;
    elseif data(i) >= bin_thresh(end)   % last value
        bin_vals(end) = bin_vals(end) + 1;
    else
        for j = 2:n_thresh              % otherwise, check the others in the middle
            if data(i) < bin_thresh(j) && data(i) >= bin_thresh(j-1)
                bin_vals(j) = bin_vals(j) + 1;
            end
        end
    end
end

%% COMPUTE PERCENTAGE FOR EACH BIN
% disp(sum(bin_vals))
% disp(n_vals)
%
assert(sum(bin_vals(:)) == n_vals)     % to make sure every single data point was counted ONCE (mainly for debugging)
                                       % if this fails its usually because the bins are not in correct low-high order

for i = 1:n_bins
    bin_data(i) = bin_vals(i) / n_vals; % a decimal number indicating a percentage
end
