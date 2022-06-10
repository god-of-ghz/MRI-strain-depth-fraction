function legendcell = DF_MakeLegend(bins)
% a function to easily spit out a legend based on the bins

legendcell = {};
n_bins = max(size(bins));
bins = bins * 100;      % convert to percent

% negative bins
if bins(1) < 0 && bins(end) == 0
    for i = n_bins:-1:1             % these go BACKWARDS because of how 'area' arranges the values
        if i == 1
            legendcell(end + 1) = cellstr(['<' num2str(bins(i)) '%']); 
        else
            legendcell(end + 1) = cellstr([num2str(bins(i)) '% to ' num2str(bins(i-1)) '%' ]);
        end
    end
% positive bins
elseif bins(1) == 0 && bins(end) > 0
    for i = 1:n_bins
        if i == n_bins
            legendcell(end + 1) = cellstr(['>' num2str(bins(end)) '%']);
        else
            legendcell(end + 1) = cellstr([num2str(bins(i)) '% to ' num2str(bins(i + 1)) '%']);
        end
    end
% mixed bins
else
    for i = 1:n_bins + 1
        if i == 1
            legendcell(end + 1) = cellstr(['<' num2str(bins(i)) '%']);
        elseif i == n_bins + 1
            legendcell(end + 1) = cellstr(['>' num2str(bins(end)) '%']);
        else
            legendcell(end + 1) = cellstr([num2str(bins(i-1)) '% to ' num2str(bins(i)) '%']);
        end
    end
end

%assignin('base', 'legendcell', legendcell);