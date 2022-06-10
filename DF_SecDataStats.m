function [stats, sec_sizes] = DF_SecDataStats(sec_data, pars)
% function to quickly compute stats from the sec-data-ms variable

%% VERSION HISTORY
% CREATED 10/20/20 BY SS


%% SAFETY AND PREPARATION
% safety skipped for now 10/20/20 - SS
n_sub = pars.grp_num*pars.per_grp;
%assert(n_sub == size(pars.subjects,1));

%% ASSEMBLE THE SIZES OF THE DATA
sec_sizes = zeros(n_sub,pars.n_depth,pars.n_cols);
for i = 1:pars.grp_num
    for j = 1:pars.per_grp
        ind = (pars.grp_num*(j-1) + i);
        for r = 1:pars.n_depth
            for c = 1:pars.n_cols
                sec_sizes(ind,r,c) = size(squeeze(sec_data{i,j,1,1,r,c}),2);
            end
        end
    end
end

%% MEAN & STD PER SUBJECT
stats.sub_mean = zeros(n_sub,1);
stats.sub_std = zeros(n_sub,1);

for i = 1:n_sub
    stats.sub_mean(i) = mean(sec_sizes(i,:));
    stats.sub_std(i) = std(sec_sizes(i,:));
end

%% MEAN & STD PER GRID LOCATION
stats.grid_mean = zeros(pars.n_depth, pars.n_cols);
stats.grid_std = zeros(pars.n_depth, pars.n_cols);

for i = 1:pars.n_depth
    for j = 1:pars.n_cols
        stats.grid_mean(i,j) = mean(sec_sizes(:,i,j));
        stats.grid_std(i,j) = std(sec_sizes(:,i,j));
    end
end

