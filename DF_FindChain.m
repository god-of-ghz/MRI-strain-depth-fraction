function [main_chain, chains] = DF_FindChain(points)
% helper function to find the longest series of touching points (a chain)

%% VERSION HISTORY
% CREATED 10/13/20 BY SS
% MODIFIED 10/16/20 BY SS
%   - MISC BUG FIXES

%% SAFETY AND PREPARATION
chains = cell(1);           % holder for ALL the chains
n_chain = 1;                % the current chain # we're using
n_pts = size(points,1);     % the # of points to analyze
temp_chain = [];            % a holder for the current chain we're building

max_chain = 1;              % the length of the longest chain yet

%% COMPUTE CHAINS
for i = 1:n_pts-1
    % assign the current point to the temp chain (every point will ALWAYS
    % belong in a chain, even if that one point is the entire chain)
    temp_chain = [temp_chain; points(i,:)];
    
    % measure distance between it and the next point
    d = DistancePts(points(i+1,:),points(i,:));
    
    % if they are not adjacent, they are not touching
    if d > sqrt(2) || i == n_pts-1
        % therefore, this chain is finished and add it to the holder for
        % all the chains
        chains(n_chain) = {temp_chain};
        
        % move onto the next chain
        n_chain = n_chain + 1;
        
        % if this is the biggest chain we've found yet, assign it as the
        % largest chain to return
        if size(temp_chain,1) > max_chain
            max_chain = size(temp_chain,1);
            main_chain = temp_chain;
        end
        
        % clear the temporary holder to start the new chain
        temp_chain = [];
    end
end

% % if we haven't assigned the chain by the end
% if ~exist('main_chain', 'var')
%     % assign the current chain (because it never terminated)
%     main_chain = temp_chain;
% end