function [] = VizData_Grid(pars, sec_map)
% a function to quickly display grid data from sectioning

%% VERSION HISTORY
% CREATED 8/16/19 BY SS

%% SAFETY AND PREPARATION
% data is expect in the following dimensional order:
%   1 - image size
%   2 - image size
%   3 - group number
%   4 - sample # (within group)
%   5 - strain direction
%   6 - frame #
[a b c d e f] = size(sec_map);
assert(a == pars.im_size);
assert(b == pars.im_size);
assert(c <= pars.grp_num);
assert(d <= pars.per_grp);
assert(f <= pars.frames);

to_save = 1;

names = ['EP1'; 'EP2'; 'EP3';];
clim_P = [-0.01 0.1; -0.12 0.01; 0 0.05;];


%% DISPLAY MAPS
set(0,'DefaultFigureVisible','off');
for i = 1:c
    for j = 1:d
        for k = 1:e
            for m = 1:f
                ftitle = [names(k,:) ' Group ' num2str(i) ' ' pars.subjects{i,j}];
                figure, imagesc(sec_map(:,:,i,j,k,m)), axis equal off, title(ftitle), caxis(clim_P(k,:));
                set(gcf,'Position',[100 100 1000 650])
                set(gca,'Fontname','Arial');
                if to_save
                    path = 'grid_data';
                    if ~exist(path, 'dir')
                        mkdir (path);
                    end
                    saveas(gcf, [path '/' ftitle], 'svg');
                end
            end
        end
    end
end
set(0,'DefaultFigureVisible','on');