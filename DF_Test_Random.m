%a script to run and test the area fraction function

%% GENERATE MOCK DATA
im_size = 128;
bins = [];
bins(1, :) = [1 2 3 4];
bins(2, :) = [1 2 3 4];
bins(3, :) = [1 2 3 4];

data_y = randn(im_size);
data_x = randn(im_size);
%figure, imagesc(data_y), axis equal, axis off, colorbar, title ('Y')
%figure, imagesc(data_x), axis equal, axis off, colorbar, title ('X')
max_y = max(data_y(:));
max_x = max(data_x(:));
for i = 1:im_size
    %data_y(i, :) = data_y(i, :) + (max_y - i/im_size);
    %data_x(:, i) = data_x(:, i) + (max_x - i/im_size);
    
    data_y(i, :) = data_y(i, :) + i/im_size;
    data_x(:, i) = data_x(:, i) + i/im_size;
end

figure, imagesc(data_x), axis equal, axis off, colorbar, title ('X')
figure, imagesc(data_y), axis equal, axis off, colorbar, title ('Y')

%% IMPORT MASKS
frames = 1;
msk = zeros(im_size, im_size, frames);
for i = 1:frames
    [msk(:,:,i), ~] = IMAGEMASK_TIF('roimsk1.tif', 10, 1, []);
end

%figure, imagesc(data_x.*msk), axis equal, axis off, colorbar, title ('X + mask')
%figure, imagesc(data_y.*msk), axis equal, axis off, colorbar, title ('Y + mask')

%% OBTAIN & DISPLAY HISTOGRAMS
% parameter order is X, Y, Z, strains, masks, disp bins, strain bins
[h_disp, h_strain] = AreaFraction(data_x, data_y, [], strain, msk, [], []);

figure, area(h_disp(:,:,1)), colorbar, title('Area Fraction X');
figure, area(h_disp(:,:,2)), colorbar, title('Area Fraction Y');



