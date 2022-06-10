function [] = VizData_DF(h_strain, s_bins, strains, s_type, to_split, to_save)
% a function to quickly visualize and save/display area fraction data

%% VERSION HISTORY
% CREATED 11/13/2019 BY SS
% MODIFIED TO DISPLAY ROTATED & REFORMATTED DATA 12/XX/2019 BY SS
% MODIFIED TO DISPLAY PRINCIPAL STRAINS 2/XX/2019 BY SS



%% PREARATION
%SKIP, enabling this will only do Exx, Eyy and Exy graphs, regardless what was input
skip = 1;

% prepare directory
if ~exist('DF_data', 'dir')
    mkdir 'DF_data'
end
path = 'DF_data/';

if isempty(to_save)
    to_save = 0;
end

% declaration of graphs, for naming
s_frames = size(h_strain, 4);
s_size = size(h_strain, 3);             % number of strain directions
if isempty(s_type)
    s_type = 1;
end
% for naming
if s_type == 1          % default type is 1, normal strain components
    s_titles = ['Exx'; 'Eyy'; 'Ezz'; 'Exy'; 'Exz'; 'Eyz';];     
elseif s_type == 2      % principal strains
    s_titles = ['Ep1'; 'Ep2'; 'Ep3';];
end


% based on # of strain directions present, what their names should be
s_ind = [];
if s_size == 3
    s_ind = [1; 2; 3];
elseif s_size == 6
    s_ind = [1; 2; 3; 4; 5; 6;];
else
    for i = 1:s_size
        s_ind(end + 1) = i;
    end
end

% safety, ensuring we have the same number of sets of bins as we do strain map data
if ~isempty(s_bins)
    assert(size(s_bins, 1) == s_size); 
end

%% DISPLAY DATA
for k = 1:s_frames
 
    %just for debugging/speed
    if skip && s_type == 1
        s_size = 4;
    end
    
    for i = 1:s_size
%         if i ~= 1
%             continue;
%         end
        
        if skip && s_type == 1 && i == 3 
            continue;
        end
        % the figure name
        f_title = [s_titles(s_ind(i),:) ' - frame ' num2str(k)];
        if ~isempty(strains)
            % show the strain graph w/ value limits (the smallest and largest bins)
            bin_max = max([s_bins(1) s_bins(end)]);
            bin_min = min([s_bins(1) s_bins(end)]);
            figure, imagesc(strains(:,:,s_ind(i),k), [bin_min bin_max]), axis square off, title([f_title ' - Strain']), colorbar;
            if to_save 
                saveas(gcf, [path f_title ' - Strain'], 'png');
            end
        end
        
        % if we want to split the DF analysis into negative and positive halves
        if to_split
            % split the data
            [hs_neg, hs_pos, bin_n, bin_p] = DF_Split(h_strain(:,:,i,k), s_bins(i,:,k));
            % legends
            legend_neg = DF_MakeLegend(bin_n);  % negative strains
            legend_pos = DF_MakeLegend(bin_p);  % positive strains
            
            % show negative graph
            figure, area(flip(hs_neg,2)), grid on, title(['Negative ' f_title ' - DF']), ylim([0 1]), camroll(-90), set(gca, 'XDir', 'reverse');
            H = legend(legend_neg, 'Location', 'best');
            set(H, 'FontSize',11);
            title(H, 'Strain Bins');
            if to_save
                saveas(gcf, [path f_title ' Negative - DF'], 'png');
                saveas(gcf, [path f_title ' Negative - DF'], 'epsc');
            end
            % show the positive graph
            figure, area(hs_pos), grid on, title(['Positive ' f_title ' - DF']), ylim([0 1]), camroll(-90), set(gca, 'YAxisLocation', 'right'); 
            H = legend(legend_pos, 'Location', 'best');
            set(H,'FontSize',11);
            title(H, 'Strain Bins');
            if to_save
                saveas(gcf, [path f_title ' Positive - DF'], 'png');
                saveas(gcf, [path f_title ' Positive - DF'], 'epsc');
            end
        else
            % construct legend
            legendcell = DF_MakeLegend(s_bins(i,:,k));
            %disp(s_bins(i,:,k))

            % show the DF graph
            figure, area(h_strain(:,:,i,k)), title([f_title ' - DF']), axis square, ylim([0 1]), camroll(-90), set(gca, 'YAxisLocation', 'right');
            H = legend(legendcell, 'Location', 'bestoutside');  
            set(H, 'FontSize', 11);
            title(H, 'Strain Bins');
            if to_save
                saveas(gcf, [path f_title ' - DF'], 'png');
                saveas(gcf, [path f_title ' - DF'], 'epsc');
            end
        end
    end
end

