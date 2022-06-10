% script to automatically run and compare DENSE-FId scans DF data via various statistical tests

%% VERSION HISTORY
% CREATED 2/5/2019 BY SS
% MODIFIED 4/25/19 BY SS
%   - AUTOMATED SCAN COMPARISON COMBINATIONS
%   - IMPROVED KSTEST & T-TEST COMPARISON
% MODIFIED 5/7/19 BY SS
%   - EXPANDED TO GRID-LIKE ANALYSIS
% MODIFIED 6/28/19 BY SS
%   - ALLOWS MANUAL EXCLUSION OF SAMPLES FROM ANALYSIS
% MODIFIED 8/15/19 BY SS
%   - NOW DRAWS LINES OVER STRAIN MAPS TO SHOW GRID ANALYSIS

%% SCRIPT PARAMETERS
scans_to_use = 'agarose';

[grp_num, per_grp, grp_name, scans, smooth, im_size, n_depth, n_cols, s_bins, p_bins, frames, exclude] = DF_ScanParam(scans_to_use);

comb = nchoosek(1:grp_num, 2);  % the test combinations, e.g. grp 1 vs grp 2, then grp 1 vs 3, grp 2 vs 3 and so on.
n_comb = size(comb, 1);         % number of test combinations
sig_level = 0.05/(n_comb*n_cols*n_depth*frames);

ns_bins = max(size(s_bins)) + 1;        % # of bins for strain components
np_bins = max(size(p_bins)) + 1;        % # of bins for principal strains

stats = 'mwutest';

% assemble the parameters to quickly pass if needed
p.grp_num = grp_num;                    % # of groups
p.per_grp = per_grp;                    % samples per group
p.im_size = im_size;                    % image size
p.n_depth = n_depth;                    % # of depth sections
p.n_cols = n_cols;                      % # of column sections
p.ns_bins = ns_bins;                    % strain bins (deprecated)
p.np_bins = np_bins;                    % principal strain bins (deprecated)
p.frames = frames;                      % # of frames
p.comb = nchoosek(1:grp_num, 2);        % the group combinations
p.groups = grp_name;                    % the names of the test groups
p.names = ['EP1'; 'EP2'; 'SHR';];       % the names of the strains
p.n_comb = size(p.comb, 1);             % # of comparison combinations
p.subjects = cell(grp_num, per_grp);    % the names of ALL the sample subjects, in order
p.exclude = exclude;                    % which samples to EXCLUDE from analysis

% safety check
%assert([grp_num per_grp] == size(scans));

%% COMPILE MULTI-SCAN STRAIN DATA

% multi-scans holders, 6 dimensions, in order
%       1 - number of cohorts
%       2 - scans/samples per cohort
%       3 - image size 1
%       4 - image size 2
%       5 - # of strain directions (pretty much always 3 or 6)
%       6 - # of frames
                %   i       j       :       :   k       m

disp_ms = zeros(grp_num,per_grp,im_size,im_size,2,frames);      % displacements
strain_ms = zeros(grp_num,per_grp,im_size,im_size,6,frames);    % strain components
ps_ms = zeros(grp_num,per_grp,im_size,im_size,3,frames);        % principal strains
mask_ms = zeros(grp_num,per_grp,im_size,im_size,frames);        % masks

filepath = 'C:\Users\Sameer\OneDrive - Rensselaer Polytechnic Institute\Documents\DENSE_m\scans_temp\';

%% LOAD STRAINS
for i = 1:grp_num
    for j = 1:per_grp
        % load the file
        filename = ['DENSE-' num2str(scans(i,j)) '-' num2str(smooth) '.mat'];
        %filename = [filepath 'DENSE-' num2str(scans(i,:)) '-' num2str(smooth) '.mat'];
        disp(['Loading: ' filename])
        load([filepath filename],'strain','strainP','msk','pars','disps');
        %[~, h_strain_ms(i,j,:,:,:)] = DepthFraction([],[],[],strain,msk,[],[],n_depth);
        % add the strain data to our big data structure
        disp_ms(i,j,:,:,:,:) = disps(:,:,:,:);
        strain_ms(i,j,:,:,:,:) = strain(:,:,:,:);
        ps_ms(i,j,:,:,:,:) = strainP(:,:,:,:);
        
        % add the masks
        mask_ms(i,j,:,:,:) = msk(:,:,:);
        
        % build the list of the subjects, IN ORDER. Used for manual data analysis/exclusion
        p.subjects(i,j) = {pars.subject};
    end
end

%% COMPILE SECTIONAL DATA
sec_data_ms = cell(grp_num,per_grp,6,frames,n_depth,n_cols);            % sections for strain components
sec_dataP_ms = cell(grp_num,per_grp,3,frames,n_depth,n_cols);           % sections for principal strains
sec_shape = zeros(im_size,im_size,grp_num,per_grp,3,frames);            % the strain graphs with the section lines drawn on them
sec_color = zeros(im_size,im_size,grp_num,per_grp,3,frames);            % the colored graph of of the grid

for i = 1:grp_num
    for j = 1:per_grp
        % compile the section data for strain components (6)
        for k = 1:6
            for m = 1:frames
                %[~, sec_data_ms(i,j,k,m,:,:),~,~] = DF_Sections(strain_ms(i,j,:,:,k,m), mask_ms(i,j,:,:,m), n_depth, n_cols, [], 'grid');
                [~, sec_data_ms(i,j,k,m,:,:),~,~] = DF_Sections2(squeeze(strain_ms(i,j,:,:,k,m)), squeeze(mask_ms(i,j,:,:,m)), n_depth, n_cols, [], 0);
            end
        end
        % compile the section data for principal strains (3)
        for k = 1:3
            for m = 1:frames
                %[~, sec_dataP_ms(i,j,k,m,:,:),sec_shape(:,:,i,j,k,m),sec_color(:,:,i,j,k,m)] = DF_Sections(ps_ms(i,j,:,:,k,m), mask_ms(i,j,:,:,m), n_depth, n_cols, [], 'grid');
                % show the grid divisions?
                if k == 2
                    debug = 1;
                else
                    debug = 0;
                end
                debug = 0;
                [~, sec_dataP_ms(i,j,k,m,:,:),sec_shape(:,:,i,j,k,m),sec_color(:,:,i,j,k,m)] = DF_Sections2(squeeze(ps_ms(i,j,:,:,k,m)), squeeze(mask_ms(i,j,:,:,m)), n_depth, n_cols, [], debug);
            end
        end
    end
end

%% POOL SECTIONAL DATA
sec_data_pool = cell(grp_num,6,frames,n_depth,n_cols);                 % pool for strain components
sec_dataP_pool = cell(grp_num,3,frames,n_depth,n_cols);                % pool for principal strains

for i = 1:grp_num
    % strain components
    pool_temp = cell(6,frames,n_depth,n_cols);
    for j = 1:per_grp
        % INTERCEPT DATA TO BE EXCLUDED
        % if the subject matching the current index is on the exclusion list
        % it is not pooled with the other data
        if cell_find(exclude, p.subjects{i,j})  
            continue;
        end
        pool_temp = cell_pool(pool_temp, sec_data_ms(i,j,:,:,:,:));
    end
    sec_data_pool(i,:,:,:,:) = pool_temp;
    
    % principal strains
    pool_temp = cell(3,frames,n_depth,n_cols);
    for j = 1:per_grp
        % INTERCEPT DATA TO BE EXCLUDED
        % if the subject matching the current index is on the exclusion list
        % it is not pooled with the other data
        if cell_find(exclude, p.subjects{i,j})  
            continue;
        end
        pool_temp = cell_pool(pool_temp, sec_dataP_ms(i,j,:,:,:,:));
    end
    sec_dataP_pool(i,:,:,:,:) = pool_temp;
end

%% PERFORM DF ANALYSIS - DEPRECATED

% CURRENTLY NOT WORKING, DO NOT USE
% if n_cols == 1                                          % only useful if we're not using a grid-like analysis
%     hs = zeros(grp_num,n_depth,ns_bins,6,frames);       % histograms for strain components
%     hp = zeros(grp_num,n_depth,np_bins,3,frames);       % histograms for principal strains
%     for i = 1:grp_num
%         for j = 1:n_depth
%             for k = 1:6
%                 for m = 1:frames
%                     hs(i,j,:,k,m) = DF_Histogram(sec_data_pool{i,k,m,j},s_bins(k,:));
%                 end
%             end
%             for k = 1:3
%                 for m = 1:frames
%                     hp(i,j,:,k,m) = DF_Histogram(sec_dataP_pool{i,k,m,j},p_bins(k,:));
%                 end
%             end
%         end
%     end
% end
% 
% hs_unpooled = zeros(grp_num,per_grp,n_depth,ns_bins,6,frames);      % unpooled histogram strain data
% hp_unpooled = zeros(grp_num,per_grp,n_depth,np_bins,3,frames);      % unpooled histogram principal strain data
% nan_data = {};
% for i = 1:grp_num
%     for j = 1:per_grp
%         for n = 1:n_depth
%             for k = 1:6
%                 for m = 1:frames
%                     hs_unpooled(i,j,n,:,k,m) = DF_Histogram(sec_data_ms{i,j,k,m,n},s_bins(k,:));
%                     if isnan(hs_unpooled(i,j,n,1,k,m))
%                         disp(sec_data_ms{i,j,k,m,n})
%                         disp('NaN detected')
%                         disp([i,j,n,1,k,m])
%                     end
%                 end
%             end
%             for k = 1:3
%                 for m = 1:frames
%                     hp_unpooled(i,j,n,:,k,m) = DF_Histogram(sec_dataP_ms{i,j,k,m,n},p_bins(k,:));
%                     if isnan(hs_unpooled(i,j,n,1,k,m))
%                         disp(sec_data_ms{i,j,k,m,n})
%                         disp('NaN detected')
%                         disp([i,j,n,1,k,m])
%                     end
%                 end
%             end
%         end
%     end
% end

%% STATISTICAL ANALYSIS
% grab sectional stats (mainly for inspection/debugging)
[sec_stats, sec_sizes] = DF_SecDataStats(sec_dataP_ms,p);

% agarose mapping
if contains(scans_to_use,'agarose')
    ag_map = ones(n_depth,n_cols,grp_num)*2;
    
    % 2%
    % do nothing
    
    % 4%
    ag_map(:,:,2) = 4;
    
    % 21-42
    d_ind = 2:3;
    ag_map(d_ind,:,3) = 4;
    
    % 22-41
    d_ind = 3;
    ag_map(d_ind,:,4) = 4;
    
    % 41-22
    d_ind = 1;
    ag_map(d_ind,:,5) = 4;
    
    % 42-21
    d_ind = 1:2;
    ag_map(d_ind,:,6) = 4;   
end

% kolmogorov smirnov test
if strcmp(stats, 'kstest')
    mean_adj = 1;
    % make test combinations
    comb = nchoosek(1:grp_num, 2);  % the test combinations, e.g. grp 1 vs grp 2, then grp 1 vs 3, grp 2 vs 3 and so on.
    n_comb = size(comb, 1);         % number of test combinations
    
    % kstest significant values (1 or 0, 1 means a significant difference, 0 is no difference)
    ks_sig_s = NaN(n_depth,n_cols,6,n_comb,frames);
    ks_sig_p = NaN(n_depth,n_cols,3,n_comb,frames);
    
    % kstest p-values (the usual alpha = 0.05 signifiance level)
    ks_sp = NaN(n_depth,n_cols,6,n_comb,frames);
    ks_pp = NaN(n_depth,n_cols,3,n_comb,frames);
    
    for i = 1:n_depth
        for j = 1:n_cols
            for k = 1:6             % strain components
                for c = 1:n_comb
                    for m = 1:frames
                        % grab the relevant data
                        data1 = squeeze(sec_data_pool{comb(c,1),k,m,i,j});
                        data2 = squeeze(sec_data_pool{comb(c,2),k,m,i,j});
                        % perform mean adjustment
                        if mean_adj
                            data2 = data2 - (mean(data2) - mean(data1));
                        end
                        % run kstest
                        [ksh, ksp] = kstest2(data1, data2);
                        ks_sig_s(i,j,k,c,m) = ksh;
                        ks_sp(i,j,k,c,m) = ksp;
                    end
                end
            end
            for k = 1:3             % principal strains
                for c = 1:n_comb
                    for m = 1:frames
                        % grab the relevant data
                        data1 = squeeze(sec_dataP_pool{comb(c,1),k,m,i,j});
                        data2 = squeeze(sec_dataP_pool{comb(c,2),k,m,i,j});
                        % perform mean adjustment
                        if mean_adj
                            data2 = data2 - (mean(data2) - mean(data1));
                        end
                        % run kstest
                        [ksh, ksp] = kstest2(data1, data2);
                        ks_sig_p(i,j,k,c,m) = ksh;
                        ks_pp(i,j,k,c,m) = ksp;
                    end
                end
            end
        end
    end
    %actual results, for my convenience
    ks_result.Exx = ks_sig_s(:,:,1,:,:);
    ks_result.Eyy = ks_sig_s(:,:,2,:,:);
    ks_result.Exy = ks_sig_s(:,:,4,:,:);
    ks_result.ps = ks_sp;
    
    ks_result.EP1 = ks_sig_p(:,:,1,:,:);
    ks_result.EP2 = ks_sig_p(:,:,2,:,:);
    ks_result.EP3 = ks_sig_p(:,:,3,:,:);
    ks_result.pp = ks_pp;
    
    ss_stats = ks_pp;
% t-test
elseif strcmp(stats, 'ttest')               % comparing max positive and negative strains
    % find max strains (positive & negative)
    s_max_s = NaN(grp_num,per_grp,6,frames,n_depth,n_cols);
    s_min_s = NaN(grp_num,per_grp,6,frames,n_depth,n_cols);
    % max/min principal strains
    s_max_p = NaN(grp_num,per_grp,3,frames,n_depth,n_cols);
    s_min_p = NaN(grp_num,per_grp,3,frames,n_depth,n_cols);
    for i = 1:grp_num
        for j = 1:per_grp
            for k = 1:6
                for m = 1:frames
                    for n = 1:n_depth
                        for o = 1:n_cols
                            temp = squeeze(sec_data_ms{i,j,k,m,n,o});
                            s_max_s(i,j,k,m,n,o) = max(temp(:));
                            s_min_s(i,j,k,m,n,o) = min(temp(:));
                        end
                    end
                end
            end
            for k = 1:3
                for m = 1:frames
                    for n = 1:n_depth
                        for o = 1:n_cols
                            temp = squeeze(sec_dataP_ms{i,j,k,m,n,o});
                            s_max_p(i,j,k,m,n,o) = max(temp(:));
                            s_min_p(i,j,k,m,n,o) = min(temp(:));
                        end
                    end
                end
            end 
        end
    end

    % determine combinations
    comb = nchoosek(1:grp_num, 2);  % the test combination pairs
    n_comb = size(comb, 1);         % number of test combinations
    
    % paired t-test, for max pos & neg strains   
    t_results_max = NaN(n_depth,n_cols,3,n_comb,frames);
    t_results_min = NaN(n_depth,n_cols,3,n_comb,frames);
    
    % principal strains
    for i = 1:n_depth
        for j = 1:n_cols
            for k = 1:3
                for c = 1:n_comb
                    for m = 1:frames
                        t_results_max(i,j,k,c,m) = ttest2(s_max_p(comb(c, 1),:,k,m,i,j),s_max_p(comb(c, 2),:,k,m,i,j));
                        t_results_min(i,j,k,c,m) = ttest2(s_min_p(comb(c, 1),:,k,m,i,j),s_min_p(comb(c, 2),:,k,m,i,j));
                    end
                end
            end
        end
    end
    
    %actual results, for my convenience
    t_result.MAX_EP1 = t_results_max(:,:,1,:,:);
    t_result.MIN_EP2 = t_results_min(:,:,2,:,:);
elseif strcmp(stats, 'mwutest')             % mann whitney U test only
    % comparing principal strains only
    mwu_pp = NaN(n_depth,n_cols,3,n_comb,frames);
    
    for i = 1:n_depth
        for j = 1:n_cols
            for k = 1:3             % principal strains
                for c = 1:n_comb
                    for m = 1:frames
                        % grab the relevant data
                        data1 = squeeze(sec_dataP_pool{comb(c,1),k,m,i,j});
                        data2 = squeeze(sec_dataP_pool{comb(c,2),k,m,i,j});

                        % run mann whitney u test
                        mwu_pp(i,j,k,c,m) = ranksum(data1,data2);
                    end
                end
            end
        end
    end
    ss_stats = mwu_pp;
elseif strcmp(stats, 'fda')
    % maybe added later? idk
end

%% VISUALIZE DATA (currently manual)
% for i = 1:5
%     bins = [bins; bins(1,:);];
% end

% strain components
%VizData_DF(squeeze(hs(1,:,:,:)),s_bins,[],1,0,1);
%VizData_DF(squeeze(hs(2,:,:,:)),s_bins,[],1,0,1);

% principal strains
%VizData_DF(squeeze(hp(1,:,:,:)),p_bins,[],2,0,0);      %control
%VizData_DF(squeeze(hp(2,:,:,:)),p_bins,[],2,0,0);      %culture
%VizData_DF(squeeze(hp(3,:,:,:)),p_bins,[],2,0,0);      %inflammatory

% stats for ks test

if strcmp(stats, 'kstest')
%     stat_table = zeros(n_comb,3);
%     excel_table = zeros(grp_num,grp_num,3);
%     for i = 1:n_comb
%         for j = 1:3
%             stat_table(i,j) = size(find(ks_pp(:,:,j,i) <= sig_level),1);
%             excel_table(comb(i,1),comb(i,2),j) = stat_table(i,j);
%             excel_table(comb(i,2),comb(i,1),j) = stat_table(i,j);
%         end
%     end
    
    % a heat map constructing the number of times that cell is marked as significant
%     sig_cells = zeros(n_depth,n_cols,3);
%     for i = 1:n_depth
%         for j = 1:n_cols
%             for k = 1:3
%                 for c = 1:n_comb
%                     % if this cell is significant
%                     if ks_pp(i,j,k,c) <= sig_level
%                         % up the counter
%                         sig_cells(i,j,k) = sig_cells(i,j,k)+1;
%                     end
%                 end
%             end
%         end
%     end
    
    %VizData_Grid(p,sec_shape);
    %VizData_Spatial(p, ks_sp, sig_level);
    
%     VizData_CellSig(sig_cells,p);
%     strain_mean_cell = zeros(3,n_depth,n_cols,grp_num,per_grp,frames);
%     strain_peak_cell = zeros(3,n_depth,n_cols,grp_num,per_grp,frames);
%     strain_mean = zeros(3,grp_num,per_grp,frames);
%     strain_peak = zeros(3,grp_num,per_grp,frames);
%     for i = 1:grp_num
%         for j = 1:per_grp
%             for k = 1:3
%                 for m = 1:frames
%                     for d = 1:n_depth
%                         for c = 1:n_cols
%                             %sec_dataP_ms = cell(grp_num,per_grp,3,frames,n_depth,n_cols);           % sections for principal strains
%                             strain_mean_cell(k,d,c,i,j,m) = mean(sec_dataP_ms{i,j,k,m,d,c},'all','omitnan');
%                             if k == 2
%                                 strain_peak_cell(k,d,c,i,j,m) = min(sec_dataP_ms{i,j,k,m,d,c});
%                             else
%                                 strain_peak_cell(k,d,c,i,j,m) = max(sec_dataP_ms{i,j,k,m,d,c});
%                             end
%                         end
%                     end
%                     %ps_ms = zeros(grp_num,per_grp,im_size,im_size,3,frames);        % principal strains
%                     %mask_ms = zeros(grp_num,per_grp,im_size,im_size,frames);        % masks
%                     ind = find(squeeze(mask_ms(i,j,:,:,m)) == 1);
%                     target = squeeze(ps_ms(i,j,:,:,k,m));
%                     data = target(ind);
%                     strain_mean(k,i,j,m) = mean(data,'all','omitnan');
%                     if k == 2
%                         strain_peak(k,i,j,m) = min(data);
%                     else
%                         strain_peak(k,i,j,m) = max(data);
%                     end
%                 end
%             end
%         end
%     end
elseif strcmp(stats, 'ttest')
    VizData_Spatial(p, t_result.MAX_EP1, sig_level);
    VizData_Spatial(p, t_result.MIN_EP2, sig_level);
end

%% SENSITIVITY AND SPECIFICITY
[sen,spec,ss_map] = DF_SenSpec(ag_map,comb,p,ss_stats,sig_level);
disp(['Statistical test: ' stats]);
disp(['Sensitivity: ' num2str(round(sen*100,2)) '%']);
disp(['Specificity: ' num2str(round(spec*100,2)) '%']);

figure, imagesc(ss_map(:,:,1)), axis equal off, colorbar, caxis([0 1]), title('Sensitivity Map')
figure, imagesc(ss_map(:,:,2)), axis equal off, colorbar, caxis([0 1]), title('Specificity Map')
VizData_Spatial(sec_shape, p, ss_stats, sig_level);
