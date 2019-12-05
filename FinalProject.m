close all; clear; clc;
%% get data
data = load("springMassData.mat");
DM = table2array(data.SpringMassData);
OM = DM;
%% plot DM (distance matrix)
figure(1);
for i = 2:4
    plot(DM(:,1),DM(:,i));
    hold on;
end
legend('Trial 1','Trial 2', 'Trial 3');
hold off;
%% get speed of the spring approximation
SM = zeros(100,4);
for c = 1:4
    for r =  1:100
        if c == 1
            SM(r,c) = (DM(r + 1,c) + DM(r,c))/2;
        else
        
            SM(r,c) = DM(r + 1,c) - DM(r,c);
        end
    end
end
%% plot SM(speed matrix)
figure(2);
for i = 2:4
    plot(SM(:,1),SM(:,i));
    hold on;
end
hold off;
%% find the point where the spring changes direction: TP(turning point) 
TP = {[]; []; []};

for t = 1:3
    CPtime = [];
    CPvalue = [];
    for i = 1:100
        if SM(i,t+1) <= 0.2 && i > 2 &&i < 99
            averageAround7 = 0;
            averageAround2 = 0;
            if i < 9
                for j = 1:15
                    averageAround7 = averageAround7 + SM(j, t+1);
                end
            elseif i > 92
                for j = 86:100
                    averageAround7 = averageAround7 + SM(j, t+1);
                end
            else 
                for j = i-7:i+7 
                    averageAround7 = averageAround7 + SM(j, t+1);
                end
            end
            
            for j = i-2:i+2
                averageAround2 = averageAround2 + SM(j, t+1);
            end
            
            cond1 = averageAround2 < averageAround7 * 0.2;
            cond2 = averageAround7 > 0.1;

            condAll = cond1 && cond2;
            
            if condAll
                CPtime = [CPtime SM(i,1)];
                CPvalue = [CPvalue SM(i,t + 1)];
               % TP{t,1} = [TP{t,1} SM(i,1)];
            end
        end
    end
    
    CPintervalTime = [];
    CPintervalValue = []; 
    for k = 1:size(CPtime, 2)
        if k == 1
            CPintervalTime = CPtime(1,k);
            CPintervalValue = CPvalue(1,k);             
        elseif CPintervalTime(1,end) > (CPtime(1,k) - 0.1)
            CPintervalTime = [CPintervalTime CPtime(1,k)];
            CPintervalValue = [CPintervalValue CPvalue(1,k)];
        else 
            TP{t,1} = [TP{t,1} mean(CPintervalTime, 2)];

            CPintervalTime = CPtime(1,k);
            CPintervalValue = CPvalue(1,k);
        end
        
        if k == size(CPtime, 2)
            TP{t,1} = [TP{t,1} mean(CPintervalTime, 2)];
        end
    end
end

%% find in the plot
for i = 1:3
    figure(i+2)
    plot(DM(:,1),DM(:,i + 1));
    hold on;
    for j = 1 : size(TP{i,1},2)
        line([TP{i,1}(j), TP{i,1}(j)],[0 2],'LineWidth',1);
    end
end

%% Change distance data to displacement data

for t = 1:3
    for i = TP{t,1}
        fistInIntervalBool = true;
        for j = 1 : size(DM,1)
            if DM(j,1) > i
                if fistInIntervalBool == true
                    firstInInterval = DM(j,t + 1);
                    fistInIntervalBool = false;
                end
                
                DM(j,t + 1) = DM(j,t + 1) * -1 + 2 * firstInInterval;
            end
        end
    end
end

%% plot displacement data
figure(6);

for i = 2:4
    plot(DM(:,1),DM(:,i));
    hold on;
end
hold off;

%% trimed displacement data
LNCD = zeros(1,3);%last notiable change in direction for each set
finalData = {[] [];[] [];[] []};

for i = 1:3
    LNCD = TP{i,1}(1,end);
    keepIndex = DM(:,1) < LNCD + 1;
    finalData{i,1} = DM(1:sum(keepIndex),1);
    finalData{i,2} = DM(1:sum(keepIndex),i + 1);
end
%% plot the new trimed displacement data
figure(7)
for i = 1:3
    plot(finalData{i,1}, finalData{i,2});
    hold on;
end
legend('Trial 1','Trial 2', 'Trial 3');
hold off;

%% move the plot so it fits the initial condition

% flip the first graph
finalData{1,2} = finalData{1,2} * -1;

% add 1 to the first graph
finalData{1,2} = finalData{1,2} + 1;

% add 0.5 to the second graph
finalData{2,2} = finalData{2,2} + 0.5;

% flip the third graph
finalData{3,2} = finalData{3,2} * -1;

% subtract 0.75 from the third graph
finalData{3,2} = finalData{3,2} - 0.75;

%% plot the processed final data(with initial condition)
figure(8)
for i = 1:3
    plot(finalData{i,1}, finalData{i,2});
    hold on;
end
legend('Trial 1','Trial 2', 'Trial 3');
hold off;
%looks very nice, exactly what I expected 
%% use the final processed data estimate for the parameters(first attempt)....finally!!!

startPoints = [1 1 1];

f = {{},{},{}};

f{1,1} = fit(finalData{1,1}, finalData{1,2}, ...
    'exp(-(b/(2*m))*x)*(cos(w*x) + (b/(2*w*m)) * sin(w*x) )', ...
    'Start', startPoints);

f{1,2} = fit(finalData{2,1}, finalData{2,2}, ...
    'exp(-(b/(2*m))*x)*(0.5*cos(w*x) + ((1+(b/(2*m))*0.5)/w) * sin(w*x) )', ...
    'Start', startPoints);

f{1,3} = fit(finalData{3,1}, finalData{3,2}, ...
    'exp(-(b/(2*m))*x)*(-0.75*cos(w*x) + ((-2.5-0.75*(b/(2*m)))/w) * sin(w*x) )', ...
    'Start', [1 1 1]);

for i = 1:3
    figure(i + 8);
    plot(finalData{i,1}, finalData{i,2});
    hold on;
    plot(f{i});
    hold off;
end

%% use the final processed data estimate for the parameters(first attempt)....finally!!!
startPoints = [1 1];

f2 = {{},{},{}};

f2{1,1} = fit(finalData{1,1}, finalData{1,2}, ...
    'exp(-s*x)*(cos(w*x) + (s/w) * sin(w*x))', ...
    'Start', startPoints);

f2{1,2} = fit(finalData{2,1}, finalData{2,2}, ...
    'exp(-s*x)*(0.5*cos(w*x) + ((1+s*0.5)/w) * sin(w*x))', ...
    'Start', startPoints);

f2{1,3} = fit(finalData{3,1}, finalData{3,2}, ...
    'exp(-s*x)*(-0.75*cos(w*x) + ((-2.5-0.75*s)/w) * sin(w*x))', ...
    'Start', startPoints);

for i = 1:3
    figure(i + 11);
    plot(finalData{i,1}, finalData{i,2});
    hold on;
    plot(f2{i});
    hold off;
end

%% recreate the function and check 
NM = zeros(101,4);
NM(:,1) = DM(:,1);

fun1 = @(x) abs(exp(-x) * (-10/3) .* sin(3*x));
for i = 1:101 
    NM(i,2) = integral(fun1,0,NM(i,1));
end
figure(15);
plot(NM(:,1), NM(:,2));
hold on;
plot(OM(:,1), OM(:,2));
legend('recreated without noise', 'original data')
hold off;

fun2 = @(x) abs(exp(-x) .* (-2 * sin(3*x) + cos(3*x))) ;
for i = 1:101 
    NM(i,3) = integral(fun2,0,NM(i,1));
end
figure(16);
plot(NM(:,1), NM(:,3));
hold on;
plot(OM(:,1), OM(:,3));
legend('recreated without noise', 'original data')
hold off;

fun3 = @(x) abs(exp(-x) .* ((10/3) * sin(3*x) - (5/2) * cos(3*x)));
for i = 1:101 
    NM(i,4) = integral(fun3,0,NM(i,1));
end
figure(17);
plot(NM(:,1), NM(:,4));
hold on;
plot(OM(:,1), OM(:,4));
legend('recreated without noise', 'original data')
hold off;
%% add noise to the function
cellArrayOfNOM = cell(10,10);
for i = 1:10
    for j = 1:10
        NOM = zeros(101,4);
        NOM(:,1) = NM(:,1);
        NOM(:,2:4) = NM(:,2:4) + 0.001*1.5*i*randn(101,3);
        cellArrayOfNOM(i,j) = {NOM};
    end
end














