test1 = [1 2 3 4 5 1 2 3 4 5 1 2 3 4 5];
test2 = [1 3 5 7 9 1 3 5 7 9 1 3 5 7 9];
test3 = [1 4 7 10 1 4 7 10 1 4 7 10];

for i = 1:6;
    data = i+randn(1000,1);
    histogram(data);
    hold on
end



% histogram(test1)
% hold on
% histogram(test2)
% hold on
% histogram(test3)
% hold on

hist = gcf;
figure(hist), title('histogramz')