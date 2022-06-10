function [pval_img, sig_count] = VizData_Spatial(data_grid, p, data_stats, sig_level)
% a function to display spatially analyzed statistical data
%% VERSION HISTORY
% CREATED 5/9/19 BY SS
% MODIFIED 5/15/19 BY SS
%   - MISC BUG FIXES
% MODIFIED 6/25/19 BY SS
%   - MISC BUG FIXES

%% PREPARATION % SAFETY
% statistical data is expected in the following format
%       1 - number of rows (n_depth, usually 10)
%       2 - number of columns (n_cols, usually 10-20)
%       3 - strains (6 for strain components, 3 for principal strains)
%       4 - combinations (comb, usually 1-3)
%       5 - frames (usually 1-4)

%assert(size(size(data_stats),2) >= 4);         % ensure we have atleast 4 dimensions
[a, b, d, e, f] = size(data_stats);             % c is skipped because I always use c as an iterator 
assert(a == p.n_depth);
assert(b == p.n_cols);
assert(d == 3 || d == 6);
assert(e == p.n_comb);
assert(f == p.frames);

if d == 6
    p.names = {'Exx';'Eyy';'Ezz';'Exy';'Exz';'Eyz';};
elseif d == 3
    p.names = {'EP1';'EP2';'Max Shear'};
end

% make the mock image/layout
roi_x = round(p.im_size*0.90);
roi_y = round(p.im_size*0.66);

to_save = 1;

% grab the mock image to use and each section's pixel indices
[~, sec_ind] = MockImage(p.im_size, roi_x, roi_y, p.n_depth, p.n_cols);

%% CONSTRUCT VISUALIZATION
%pval_img = base_img;
pval_img = zeros(p.im_size,p.im_size,d,p.n_comb,p.frames);
for i = 1:p.n_depth
    for j = 1:p.n_cols
        for k = 1:size(sec_ind{i,j},1)
            for m = 1:d
                for c = 1:p.n_comb
                    for n = 1:p.frames
                        ind = sec_ind{i,j}(k,:);
                        %pval_img(ind(1), ind(2),m,c,n) = PValColor(data_stats(i,j,m,c,n), sig_level);
                        pval_img(ind(1), ind(2),m,c,n) = log10(data_stats(i,j,m,c,n));
                    end
                end
            end
        end
    end
end


%% DISPLAY STATS
if to_save
    %set(0,'DefaultFigureVisible','off');
end
clim_P = [-0.01 0.1; -0.12 0.01; 0 0.05;];
for m = 1:d
    for c = 1:p.n_comb
        for n = 1:p.frames
            setname = [p.groups(p.comb(c,1),:) ' VS ' p.groups(p.comb(c,2),:)];
            name = p.names{m};
            ftitle = [name ' ' setname ' - Comparison'];
            
            figure('Renderer','painters','Position',[0 40 1600 500])
            sgtitle(ftitle)
            set(gca,'FontName','Arial','FontSize',12);
            
            subplot(1,2,1)
            ind_x = [p.im_size/4:p.im_size*0.75];
            ind_y = [p.im_size/4:p.im_size*0.75];
            temp = imtile(permute(data_grid(ind_x,ind_y,[p.comb(c,1) p.comb(c,2)],n,m),[1 2 4 3 5]));
            imagesc(temp), axis equal off, colorbar('southoutside'), caxis(clim_P(m,:))
            title([p.groups(p.comb(c,1),:) ' and ' p.groups(p.comb(c,2),:)])
            set(gca,'FontName','Arial','FontSize',12);
            
            subplot(1,2,2)
            imagesc(pval_img(:,:,m,c,n)), axis equal off, caxis([log10(sig_level) 0]), colorbar('southoutside');
            title(['Grid Comparison - Log of P-value'])
            set(gca,'FontName','Arial','FontSize',12);
%             [ha, ~] = tight_subplot(1,3,[0.01 0.01],[0.01 0.01],[0.01 0.01]);
%             
%             subplot(1,3,1)
%             imagesc(squeeze(data_grid(p.comb(c,1),n,:,:,m))), axis equal off;
%             title([p.groups(p.comb(c,1),:)])
%             
%             subplot(1,3,2)
%             imagesc(squeeze(data_grid(p.comb(c,2),n,:,:,m))), axis equal off;
%             title([p.groups(p.comb(c,2),:)])
%             
%             subplot(1,3,3)
%             imagesc(pval_img(:,:,m,c,n)), axis equal off, caxis([log10(sig_level) 0]), colorbar('southoutside');
%             title(['Grid Comparison - Log of P-value'])
            

            %set(gca,'FontName','Arial','FontSize',12);
            
            if to_save
                %saveas(gcf,['pvals/' ftitle],'svg');
                saveas(gcf,['pvals/' ftitle],'png');
            end
        end
    end
end

if to_save
    %set(0,'DefaultFigureVisible','on');
end

