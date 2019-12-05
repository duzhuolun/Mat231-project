clear; clc;
load('results.mat');
M = zeros(10,10,2);
for i = 1:10 
    for j = 1:10
        resultCell(1,:) = results{i,j};
        sums = 0;
        sumw = 0;
        for k = 1:3
           sums = sums + resultCell{1,k}.s;
           sumw = sumw + resultCell{1,k}.w;
        end
        M(i,j,1) = sums/3;
        M(i,j,2) = sumw/3;
    end
end
M1 = zeros(10,10);

M1(:,:) = M(:,:,1);
% MIndex1 = (M1 > 1.2 );
% MIndex2 = (M1 < 0.8);
% M1(MIndex1) = 0;
% M1(MIndex2) = 0;

M2(:,:) = M(:,:,2);
% MIndex1 = (M2 > 3.2);
% MIndex2 = (M2 < 2.8);
% M2(MIndex1) = 0;
% M2(MIndex2) = 0;
