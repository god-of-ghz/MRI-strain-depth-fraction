% quick script to help me test things

%DENSE('IVD', 10);
load('DENSE-IVD-10.mat');

%DENSE(12, 10);
%load('DENSE-12-10.mat');

%DENSE(16, 10);
%load('DENSE-16-10.mat');

%close all;
[~, h_strain] = DepthFraction([],[],[],strain,msk,[],[],10);
% figure, imagesc(strain(:,:,1)), axis square, axis off, colorbar, title('Strain Y')
% figure, area(h_strain(:,:,1)), colorbar, title('Area Fraction for Y')
% figure, imagesc(strain(:,:,2)), axis square, axis off, colorbar, title('Strain X')
% figure, area(h_strain(:,:,2)), colorbar, title('Area Fraction for X')
VizData_DF(h_strain, autobin_s, strain, 0, 0);