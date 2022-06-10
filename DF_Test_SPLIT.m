% script to quickly 'split' the h_strain data

[~, h_strain] = DepthFraction([],[],[],strain,msk,[],[],10);
h_strain_neg = h_strain(:,1:4,:);
h_strain_pos = h_strain(:,5:8,:);
bin_neg = autobin_s(:, 1:4);
bin_pos = autobin_s(:, 4:7);
h_strain_neg = flip(h_strain_neg, 2);
bin_neg = flip(bin_neg, 2);

% make strain figures
%figure, imagesc(strain(:,:,1), [-0.10 0.10]), axis square off, title('Exx'), colorbar;
figure, imagesc(strain(:,:,2), [-0.10 0.10]), axis square off, title('Eyy'), colorbar;
%figure, imagesc(strain(:,:,4), [-0.10 0.10]), axis square off, title('Exy'), colorbar;

% make negative graphs
legendcell = {};
legendcell(end + 1) = cellstr(['< -0.10']);
legendcell(end + 1) = cellstr(['-0.10 to -0.05']);
legendcell(end + 1) = cellstr(['-0.05 to -0.01']);
legendcell(end + 1) = cellstr(['-0.01 to 0']);
figure, area(h_strain_neg(:,:,2)), legend(legendcell), title('Eyy - DF'), ylim([0 1]), camroll(-90), set(gca, 'XDir', 'reverse');

% make the positive ones
legendcell = {};
legendcell(end + 1) = cellstr(['0 to 0.01']);
legendcell(end + 1) = cellstr(['0.01 to 0.05']);
legendcell(end + 1) = cellstr(['0.05 to 0.10']);
legendcell(end + 1) = cellstr(['> 0.10']);
figure, area(h_strain_pos(:,:,2)), legend(legendcell), title('Eyy - DF'), ylim([0 1]), camroll(-90);
