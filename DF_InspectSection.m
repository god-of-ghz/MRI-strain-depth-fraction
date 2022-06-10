function [] = DF_InspectSection(pars, sec_data, x, y, dir, to_exclude)
% manually inspect a specific section, look at each scan's contribution to that section and examine the exclusion of any number of scans from it

%% VERSION HISTORY
% CREATED 6/25/19 BY SS

%% SETUP AND PREPARATION
if pars.n_depth < y
    error('Invalid X section choice');
end
if pars.n_cols < x
    error('Invalid Y section choice');
end
if size(pars.names,1) < dir
    error('Invalid strain choice');
end

to_save = 0;

% bins to use for histogram analysis
%bins = -0.2:0.01:0.2;
bins = -0.5:0.02:0.5;

%% COMPILE DATA
% holder for the data to examine
sec_temp = cell(pars.grp_num, pars.per_grp,pars.frames);

% compile that data together
for i = 1:pars.grp_num
    for j = 1:pars.per_grp
        for n = 1:pars.frames
            sec_temp(i,j,n) = sec_data(i,j,dir,n,y,x);      % x and y are reversed because Y = rows, X = columns
        end
    end
end

%% COMPILE HISTOGRAM FOR EACH DIRECTION
for n = 1:pars.frames
    for i = 1:pars.grp_num
        figure;                     % make new figure
        cur_hist = gcf;             % get a handle for it
        legendcell = {};            % declare the legend
        for j = 1:pars.per_grp
            if cell_find(to_exclude, pars.subjects{i,j})    % see if the current subject is marked to be excluded
                continue;
            end
            legendcell = [legendcell; pars.subjects(i,j)];  % if it's not, add it to the legend
            histogram(sec_data{i,j,dir,n,y,x},bins);        % then make its histogram, hold for more histograms
            hold on
        end
        f_title = [pars.names(dir,:) ' ' pars.groups(i,:) ': column ' num2str(x) ', row ' num2str(y) ', frame ' num2str(n)];
        figure(cur_hist), title(f_title);
        %F = legend(pars.subjects(i,:));
        F = legend(legendcell);
        
        % SS, 8/6/19 adding hard coded save for help with CMBBE abstract (bFGF), compiled strain histograms 
        if to_save
            filepath = ['DF_data\' pars.names(dir,:) '-' num2str(y) '-' pars.groups(i,:) '-all'];
            saveas(gcf, filepath, 'svg');
        end
        hold off
    end
end


% SS, 8/6/19 adding hard coded save for help with CMBBE abstract (bFGF), individual strain histograms 
hex(1,:) = [0 0.4470 0.7410];
hex(2,:) = [0.8500 0.3250 0.0980];
hex(3,:) = [0.9290 0.6940 0.1250];  
hex(4,:) = [0.4940 0.1840 0.5560];
hex(5,:) = [0.4660 0.6740 0.1880];
hex(6,:) = [0.3010 0.7450 0.9330];

if to_save
    for n = 1:pars.frames
        for i = 1:pars.grp_num
            legendcell = {};            % declare the legend
            for j = 1:pars.per_grp
                if cell_find(to_exclude, pars.subjects{i,j})    % see if the current subject is marked to be excluded
                    continue;
                end
                legendcell = pars.subjects(i,j);  % if it's not, add it to the legend
                histogram(sec_data{i,j,dir,n,y,x},bins, 'FaceColor', hex(j,:));        % make the histogram, and the right color
                %hold on
                f_title = [pars.names(dir,:) ' ' pars.groups(i,:) ': column ' num2str(x) ', row ' num2str(y) ', frame ' num2str(n)];
                figure(cur_hist), title(f_title), ylim([0 40]);
                F = legend(legendcell);
                
                filepath = ['DF_data\' pars.names(dir,:) '-' num2str(y) '-' pars.groups(i,:) '-' legendcell{1}];
                saveas(gcf, filepath, 'svg');
            end
        end
    end
end


