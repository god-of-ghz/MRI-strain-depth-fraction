function [h_strain_neg, h_strain_pos, neg_bin, pos_bin] = DF_Split(h_strain, bins)
% a function to quickly split the histogram strain data into the positive
% and negative halves using the bins as a guide

%make sure this is only ONE direction of strains
assert(max(size(size(h_strain))) == 2);

%the index in which to split the data (where 0 is)
split_ind = find(~bins);

%split the bins
neg_bin = bins(1:split_ind);
pos_bin = bins(split_ind:end);

%split the data
if ~isempty(neg_bin)
    h_strain_neg = h_strain(:, 1:split_ind);
end
if ~isempty(pos_bin)
    h_strain_pos = h_strain(:, split_ind+1:end);
end


