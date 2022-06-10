function [h_disp, h_strain] = DepthFraction(dX, dY, dZ, strains, masks, d_bins, s_bins, n_depth, s_type)
% function to generate an area fraction of displacements and strains by depth
%% VERSION HISTORY
% CREATED 11/05/18 by SS
% REPLACED ROW EXTRACTION WITH UNIQUE FUNCTION 2/5/18 BY SS

%% CHECKS & VARIABLE ASSIGNMENT
if ~isempty(dX)
    im_size = size(dX, 1);
elseif ~isempty(dY)
    im_size = size(dY, 1);
elseif ~isempty(dZ)
    im_size = size(dZ, 1);
elseif ~isempty(strains)
    im_size = size(strains, 1);
else
    disp('No valid displacements to use')
    return;
end

%% MASKS
if isempty(masks)                       % if no mask given, use entire image
    masks = ones(im_size, im_size);     
    frames = 1;                         % and then assume 1 frame
else
    frames = size(masks, 3);            % otherwise, grab the # of frames
    % for safety
    if ~isempty(dX)                 % displacement check
        assert(size(masks,3) == size(dX, 3));
    end
    if ~isempty(strains)            % strain check
        assert(size(masks, 3) ==  size(strains, 4));
    end
end

%% DECLARATION OF MATRICES
h_disp = [];
h_strain = [];

%% AUTO-BINNING
% if no bins were assigned, auto-generate a set of bins 
% (literally just guessing based on min/max vals and then rounding...)
if isempty(d_bins)                      % bins for displacement data
    %disp('No displacement bins specified! Estimating!');
    [d_bins, ~] = DF_AutoBin(dX, dY, dZ, [], masks, []);
end

if isempty(s_bins)                      % bins for strain data
    %disp('No strain bins specified! Using preset bins');
    [~, s_bins] = DF_AutoBin([], [], [], strains, masks, []);
end

% also copy/multiply the bins if I was lazy and only input a single set
% displacement bins
if size(d_bins, 1) == 1                 % copy to X Y and Z
    d_bins(2, :) = d_bins(1,:);
    d_bins(3, :) = d_bins(1,:);
end
if size(d_bins, 3) == 1                 % copy to all frames
    for i = 1:frames
        d_bins(:,:,i) = d_bins(:,:,1);
    end
    assignin('base', 'autobin_d', d_bins);
end

% strain bins
if size(s_bins, 1) == 1                 % copy to all strain directions                 
    for i = 1:6
        s_bins(i, :) = s_bins(1, :);
    end
end
if size(s_bins, 3) == 1
    for i = 1:frames
        s_bins(:,:,i) = s_bins(:,:,1);
    end
    assignin('base', 'autobin_s', s_bins);
end



%% DISPLACEMENT AREA FRACTION
% NONFUNCTIONAL AS OF 20180204
% for X
if ~isempty(dX)
    hX_frames = [];
    for k = 1:frames                % per frame
        hX = [];
        for i = 1:im_size           % per column
            temp = [];
            for j = 1:im_size       % per row
                if masks(i, j, k)     % if this is a valid pixel...
                    temp = [temp; dX(i, j, k);];    % compile the current row of data to use
                end
            end
            if ~isempty(temp)               % only compute/add if something was compiled
                h = DF_Histogram(temp, d_bins(1, :));  % compute the histogram for the current row
                hX = [hX; h;];              % add that histogram to the result for this frame
            end
        end
        hX_frames(:,:,k) = hX;
    end
    assignin('base', 'hX_frames', hX_frames);
    h_disp(:,:,:,1) = hX_frames;
end

% for Y
if ~isempty(dY)
    hY_frames = [];
    for k = 1:frames                % per frame
        hY = [];
        for i = 1:im_size           % per column
            temp = [];
            for j = 1:im_size       % per row
                if masks(i, j, k)     % if this is a valid pixel...
                    temp = [temp; dY(i, j, k);];    % compile the current row of data to use
                end
            end
            if ~isempty(temp)               % only compute/add if something was compiled
                h = DF_Histogram(temp, d_bins(2, :));  % compute the histogram for the current row
                hY = [hY; h;];              % add that histogram to the result for this frame
            end
        end
        hY_frames(:,:,k) = hY;
    end
    assignin('base', 'hY_frames', hY_frames);
    h_disp(:,:,:,2) = hY_frames;
end
 
% for Z
if ~isempty(dZ)
    hZ_frames = [];
    for k = 1:frames                % per frame
        hZ = [];
        for i = 1:im_size           % per column
            temp = [];
            for j = 1:im_size       % per row
                if masks(i, j, k)     % if this is a valid pixel...
                    temp = [temp; dZ(i, j, k);];    % compile the current row of data to use
                end
            end
            if ~isempty(temp)               % only compute/add if something was compiled
                h = DF_Histogram(temp, d_bins(3, :));  % compute the histogram for the current row
                hZ = [hZ; h;];              % add that histogram to the result for this frame
            end
        end
        hZ_frames(:,:,k) = hZ;
    end
    assignin('base', 'hZ_frames', hZ_frames);
    h_disp(:,:,:,3) = hZ_frames;
end

%assignin('base', 'histogram_results', h_disp);

%% STRAIN AREA FRACTION
if ~isempty(strains)
    h_strain = [];                          % all the strain data
    for m = 1:frames                        % for every frame
        hS_frame = [];                          % frame holder
        for k = 1:size(strains, 3)          % for every strain direction
            hS = [];                            % strain dir holder
            %sec_data = {};                  % holder for the data, divided into sections for depth-wise averaging
            
            %r_data = DF_ExtractRowData(strains(:,:,k,m), masks(:,:,m));
            % divide up the data into the sections to be averaged
            % and obtain the histogram for it
            [hS, ~] = DF_Sections(strains(:,:,k,m), masks(:,:,m), n_depth, s_bins(k, :, m),'height');
            % compile all the strain directions
            hS_frame(:,:,k) = hS;
        end
        % compile all the frames
        h_strain(:,:,:,m) = hS_frame;
    end
end

%% DISPLAY DF DATA
VizData_DF(h_strain, s_bins, strains, s_type, 1, 0);

