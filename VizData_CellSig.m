function [] = VizData_CellSig(sig_cells,p)
% helper function to quickly visualize heat maps of the significant number of cells

%% VERSION HISTORY
% CREATED 2/14/20 BY SS

%% PREPARATION
% none because im lazy af

to_save = 1;

%% CONSTRUCT VISUALIZATION
roi_x = round(p.im_size*0.90);
roi_y = round(p.im_size*0.66);

[~, sec_ind] = MockImage(p.im_size, roi_x, roi_y, p.n_depth, p.n_cols);

hist_img = zeros(p.im_size,p.im_size,3);

for i = 1:p.n_depth
    for j = 1:p.n_cols
        for k = 1:size(sec_ind{i,j},1)
            for m = 1:3
                ind = sec_ind{i,j}(k,:);
                hist_img(ind(1),ind(2),m) = sig_cells(i,j,m);
            end
        end
    end
end

%% DISPLAY RESULTS
p.names = {'EP1';'EP2';'Max Shear'};

% medium sea green to indian red
%med_sea_green = [60,179,113];
%indian_red = [205,92,92];
red = [255 0 0];
blue = [0 0 255];
C = custom_colormap(blue,red,14);
%C = 'jet';
% C = [60,179,113;205,92,92]./255;
% n_col
% C_excel = rgb2hsv(C);
% C_excel_interp = interp1([0 18], C_excel(:, 1), 1:18);
% C_excel = [C_excel_interp(:), repmat(C_excel(2:3), n, 1)];
% C = hsv2rgb(C_excel);

for m = 1:3
    ftitle = [p.names{m} ' - Significant Cell Map'];
    figure, imagesc(hist_img(:,:,m)), colorbar, colormap(C), axis equal off
    set(gcf,'Renderer','painters','Position',[0 40 900 1200])
    title(ftitle);
    set(gca,'FontName','Arial','FontSize',24);
    
    if to_save
        saveas(gcf,['pvals/' ftitle],'svg');
        saveas(gcf,['pvals/' ftitle],'png');
    end
end