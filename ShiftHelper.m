function [shifts] = ShiftHelper(unc_vals)
% specific helper function to use when DivideUp yields 0's for its sections
%% VERSION HISTORY
% CREATED 9/17/19 BY SS
% MODIFIED 10/16/20 BY SS
%   - now outputs a signed value, no longer uses absolute value of the shift

%% EXPLANATION
% normally, DivideUp returns an array of numbers indicating the different
% section lengths it created. If you wanted to divide 12 into 5 discrete
% integer sections, you would use DivideUp(42, 9) and it would return "2 2 3 2 3"
% But if you need to to divide up 12 into a number larger than itself, say
% 15, you would end up with some 'sections' with 0 in them (which is
% intended, that's the only way you could divide 12 into 15 discrete,
% integer sections) which gives you: "1 1 1 1 1 1 1 1 1 0 1 0 1 0 1".
% Another function uses these 'sections' to indicate the number of pixels
% it should shift by in order to warp a grip. So, if you divided 12 into 5,
% with "2 2 3 2 3" as the result, it means you shift the first 2 pixels by
% 0, the next 2 pixels by 1, the next *3* pixels by 2, the next 2 pixels by
% 3, and the last 3 pixels by 4. But if you have zeros in the mix, that
% breaks things. To fix that, this script was created to correct for the zeros,
% but also create the shift index so the function knows "how much" to
% shift each pixel by.

%% SAFETY & PREPARATION
if isempty(unc_vals)
    error('Must insert a non-zero number of values to correct')
end
assert(max(size(size(unc_vals))) == 2);       % ensure this is an X by 1 size matrix
num_vals = max(size(unc_vals));

shifts = [];

%% CORRECT THE VALUES AND COMPUTE THE SHIFTS
for i = 1:num_vals
    for j = 1:abs(unc_vals(i))      % use the absolute value of the shift
        shifts = [shifts; i;];      % if its a valid shift amount, indicate how many pixels to shift it
    end
end
