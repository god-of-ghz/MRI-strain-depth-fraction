function [r_data] = DF_ExtractRowData(strain, mask)
% a function to quickly extract JUST the row data from a given strain image using the mask
% CREATED ON 2/5/18 BY SS

%ensure this is ONE image of strain data, a SQUARE 2D image 
assert(max(size(size(strain))) == 2);
[x,y] = size(strain);
assert(x == y);

%ensure the mask fits the strain image
assert(max(size(size(mask))) == 2);
[a,b] = size(mask);
assert(a == x);
assert(b == y);

%prep
r_data = {};

%run through the data, compiling all the rows
for i = 1:x                 %per row
    temp = [];
    for j = 1:y             %per column
        if mask(i,j)        %add it if the mask says it counts
            temp = [temp strain(i,j)];
        end
    end
    if ~isempty(temp)       %if we added anything
        r_data(end+1) = {temp}; %add the whole row
    end
end