function [grp_num, per_grp, grp_name, scans, smooth, im_size, n_depth, n_cols, s_bins, p_bins, frames, exclude] = DF_ScanParam(scans_to_use)
% a function to help organize and pass the parameters to the depth fraction, multi-scan analysis

%bFGF
if strcmp(scans_to_use, 'bfgf')
    grp_name = ['culture'; 'degrade'];  % cohort names
    scans(1,:) = [231, 233, 235];
    scans(2,:) = [232, 234, 236];
    grp_num = size(scans, 1);
    per_grp = size(scans, 2);
    smooth = 10;    % smoothing cycles
    im_size = 128;  % image size
    
    n_depth = 10;     % number of depth sections
    n_cols = 10;
    % bins for strain components (12)
    s_bins(1,:) = [-0.04 -0.03 -0.02 -0.01 -0.005 0 0.005 0.01 0.02 0.03 0.04];       %Exx bins
    s_bins(2,:) = [-0.04 -0.03 -0.02 -0.01 -0.005 0 0.005 0.01 0.02 0.03 0.04];       %Eyy bins
    s_bins(3,:) = [-0.04 -0.03 -0.02 -0.01 -0.005 0 0.005 0.01 0.02 0.03 0.04];       %Ezz bins
    s_bins(4,:) = [-0.03 -0.02 -0.015 -0.01 -0.005 0 0.005 0.01 0.015 0.02 0.03];     %Exy bins
    s_bins(5,:) = [-0.04 -0.03 -0.02 -0.01 -0.005 0 0.005 0.01 0.02 0.03 0.04];       %Exz bins
    s_bins(6,:) = [-0.04 -0.03 -0.02 -0.01 -0.005 0 0.005 0.01 0.02 0.03 0.04];       %Eyz bins
    % bins for principal strains (6)
    p_bins(1,:) = [0 0.01 0.02 0.03 0.06];                                            %Ep1 bins
    p_bins(2,:) = [-0.06 -0.03 -0.02 -0.01 0];                                        %Ep2 bins
    p_bins(3,:) = [0.01 0.02 0.025 0.03 0.04];                                        %Ep3 bins
    
    frames = 1;     % number of frames
    
% so far, round 1-2 of the inflammatory data
elseif strcmp(scans_to_use, 'inf')
    grp_name = ['control'; 'culture'; 'degrade'];
    scans(1,:) = [261, 262, 263, 271, 272, 273];
    scans(2,:) = [264, 266, 269, 275, 276, 279];
    scans(3,:) = [265, 267, 268, 274, 277, 278];
    
    %exclude{1} = 'J9-LP1';
    %exclude{2} = 'J9-LP3';
    
    grp_num = size(scans, 1);
    per_grp = size(scans, 2);
    
    smooth = 10;
    im_size = 128;
    frames = 1;
    
    n_depth = 10;
    n_cols = 10;
    s_bins = [];
    p_bins = [];
% a test group of the inflammatory joints, using different conditions
elseif strcmp(scans_to_use, 'inf_test')
    grp_name = ['x0';'x1';'x2'];
    scans(1,:) = [285,287];
    scans(2,:) = [286,284];
    scans(3,:) = [281,283];
    
    grp_num = size(scans, 1);
    per_grp = size(scans, 2);
    
    smooth = 10;
    im_size = 128;
    frames = 1;
    
    n_depth = 10;
    n_cols = 10;
    s_bins = [];
    p_bins = [];
% just testing the phantoms
elseif strcmp(scans_to_use, 'phantom')
    grp_name = ['1'; '2'; '3';];
    scans(1,:) = [311,312,313];
    scans(2,:) = [314,315,316];
    scans(3,:) = [317,318,319];
    
    grp_num = size(scans, 1);
    per_grp = size(scans, 2);
    
    smooth = 10;
    im_size = 256;
    frames = 1;
    
    n_depth = 8;
    n_cols = 10;
    s_bins = [];
    p_bins = [];
elseif strcmp(scans_to_use, 'phantom2')
    grp_name = ['intact';'defect';];
    scans = [342; 341];
    
    grp_num = 2;
    per_grp = 1;
    
    smooth = 20;
    im_size = 256;
    n_depth = 4;
    n_cols = 8;
    s_bins = [];
    p_bins = [];
elseif strcmp(scans_to_use, 'agarose')
    grp_name = ['--2--'; '--4--';'21-42';'22-41';'41-22';'42-21';];
    scans = [2;4;2142;2241;4122;4221;];

    grp_num = size(scans, 1);
    per_grp = 1;
    
    smooth = 20;
    im_size = 256;
    frames = 1;
    
    n_depth = 3;
    n_cols = 6;
    s_bins = [];
    p_bins = [];
elseif strcmp(scans_to_use, 'agarose_pool')
    grp_name = ['--2--'; '--4--';];
    scans = [2,2142,2241;4,4122,4221;];

    grp_num = size(scans, 1);
    per_grp = 3;
    
    smooth = 20;
    im_size = 256;
    frames = 1;
    
    n_depth = 10;
    n_cols = 1;
    s_bins = [];
    p_bins = [];
elseif strcmp(scans_to_use, 'agarose_pool2')
    grp_name = ['--2--'; '--4--';'self2';];
    scans = [2142,2241;4122,4221;2,2;];

    grp_num = size(scans, 1);
    per_grp = 2;
    
    smooth = 20;
    im_size = 256;
    frames = 1;
    
    n_depth = 20;
    n_cols = 20;
    s_bins = [];
    p_bins = [];
end


% to cover my ass because sometimes I forget things
if ~exist('n_depth', 'var')
    n_depth = 10;
end

if ~exist('n_cols', 'var')
    n_cols = 10;
end

if ~exist('im_size', 'var')
    im_size = 128;
end

if ~exist('frames', 'var')
    frames = 1;
end

if ~exist('exclude', 'var')
    exclude = {};
end


