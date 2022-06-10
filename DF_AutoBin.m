function [d_bins, s_bins] = DF_AutoBin(dX, dY, dZ, strains, masks, method)
% a function to automatically generate bins for area fraction assessment

% initialize bin holders
d_bins = zeros(3, 5, size(dX, 3));   % 3 directions, 5 bins, 1 per frame
s_bins = [];            % really varies, can't anticipate yet

if isempty(method) || strcmp(method, 'std') % default method, use standard deviation & mean
    if ~isempty(dX)
        mean_val = mean(dX(find(masks(:,:,1))));
        std_val = std(dX(find(masks(:,:,1))));
        for i = 1:5
            d_bins(1, i, :) = mean_val + (std_val*(i-3));
        end
    end
    
    if ~isempty(dY)
        mean_val = mean(dY(find(masks(:,:,1))));
        std_val = std(dY(find(masks(:,:,1))));
        for i = 1:5
            d_bins(2, i, :) = mean_val + (std_val*(i-3));
        end
    end
    
    if ~isempty(dZ)
        mean_val = mean(dZ(find(masks(:,:,1))));
        std_val = std(dZ(find(masks(:,:,1))));
        for i = 1:5
            d_bins(3, i, :) = mean_val + (std_val*(i-3));
        end
    end
    
    % 11/13/18 - SS: too lazy for now, its still a fixed set of bins
    if ~isempty(strains)
        for i = 1:size(strains, 3)      % per strain direction
            for j = 1:size(strains, 4)  % per frame
                s_bins(i, :, j) = [-0.10 -0.05 -0.01 0 0.01 0.05 0.10];
            end
        end
    end   
elseif strcmp(method, 'maxmin')             % simpler method, use max/min values
    if ~isempty(dX)
        max_val = max(dX(find(masks(:,:,1))));
        min_val = min(dX(find(masks(:,:,1))));
        for i = 1:5
            d_bins(1, i, :) = min_val + (max_val - min_val)/4 * (i-1);
        end
    end
    
    if ~isempty(dY)
        max_val = max(dY(find(masks(:,:,1))));
        min_val = min(dY(find(masks(:,:,1))));
        for i = 1:5
            d_bins(2, i, :) = min_val + (max_val - min_val)/4 * (i-1);
        end
    end
    
    if ~isempty(dZ)
        max_val = max(dZ(find(masks(:,:,1))));
        min_val = min(dZ(find(masks(:,:,1))));
        for i = 1:5
            d_bins(3, i, :) = min_val + (max_val - min_val)/4 * (i-1);
        end
    end
    
    if ~isempty(strains)
        for i = 1:size(strains, 3)
            for j = 1:size(strains, 4)
                s_bins(i, :, j) = [-0.10 -0.05 -0.01 0 0.01 0.05 0.10];
            end
        end
    end   
elseif strcmp(method, 'preset')             % use basic, preset bins
    for i = 1:3
        d_bins(i, :) = [-1 0.66 0.33 0 0.33 0.66 1];
    end
    if ~isempty(strains)
        for i = 1:size(strains, 3)
            for j = 1:size(strains, 4)
                s_bins(i, :, j) = [-0.10 -0.05 -0.01 0 0.01 0.05 0.10];
            end
        end
    end   
end

% if autobinning was done, save the bins to workspace for later access
if ~isempty(dX) || ~isempty(dY) || ~isempty(dZ) 
    assignin('base', 'autobin_d', d_bins);
end
if ~isempty(strains)
    assignin('base', 'autobin_s', s_bins);
end