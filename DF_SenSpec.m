function [sensitivity, specificity, ss_maps] = DF_SenSpec(maps,comb,p,p_vals,sig_level)
% function to determine sensitivity and specificity of comparisons based on known differences

%% PARAMETER SETUP
n_comb = size(comb,1);
diff_map = zeros(p.n_depth,p.n_cols,n_comb);

for c = 1:n_comb
    % find the two maps to evaluate        
    map1 = comb(c,1);
    map2 = comb(c,2);
    for i = 1:p.n_depth
        for j = 1:p.n_cols
            % go cell by cell, determine if the materials match
            if maps(i,j,map1) ~= maps(i,j,map2)
                diff_map(i,j,c) = 1;
            end
        end
    end
end

%% PERFORM COMPARISON AND COMPILE STATS
% https://online.stat.psu.edu/stat507/lesson/10/10.3
A = 0;   % true positive
B = 0;   % false positive
C = 0;   % false negative
D = 0;   % true negative

map_A = zeros(p.n_depth,p.n_cols);
map_B = zeros(p.n_depth,p.n_cols);
map_C = zeros(p.n_depth,p.n_cols);
map_D = zeros(p.n_depth,p.n_cols);

for i = 1:p.n_depth
    for j = 1:p.n_cols
        for k = 1:3
            for c = 1:n_comb
                % if there's a difference...
                if diff_map(i,j,c)
                    % ...increment true positive
                    A = A+1;
                    map_A(i,j) = map_A(i,j) + 1;
                    % if we do NOT mark this as different...
                    if p_vals(i,j,k,c) > sig_level
                        % ...increment false negative
                        C = C+1;
                        map_C(i,j) = map_C(i,j)+1;
                    end
                % if there is not a difference...
                else
                    % ...increment true negative
                    D = D+1;
                    map_D(i,j) = map_D(i,j)+1;
                    % if we DO mark this as different...
                    if p_vals(i,j,k,c) <= sig_level
                        % ...increment false positive
                        B = B+1;
                        map_B(i,j) = map_B(i,j)+1;
                    end
                end
            end
        end
    end
end

%% COMPUTE RESULTS
sensitivity = A/(A+C);
specificity = D/(D+B);

ss_maps = zeros(p.n_depth,p.n_cols,2);
for i = 1:p.n_depth
    for j = 1:p.n_cols
        ss_maps(i,j,1) = map_A(i,j)/(map_A(i,j)+map_C(i,j));
        ss_maps(i,j,2) = map_D(i,j)/(map_D(i,j)+map_B(i,j));
    end
end