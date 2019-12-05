    close all; clear; clc;
    load('cellArrayOfNOM');
    results = cell(10,10);
   
for loop1 = 1:10
    for loop2 = 1:10
        %% get speed of the spring approximation
        NOM = cell2mat(cellArrayOfNOM(loop1,loop2));
        SM = zeros(100,4);
        for c = 1:4
            for r =  1:100
                if c == 1
                    SM(r,c) = (NOM(r + 1,c) + NOM(r,c))/2;
                else

                    SM(r,c) = NOM(r + 1,c) - NOM(r,c);
                end
            end
        end
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

        %% Change distance data to displacement data

        for t = 1:3
            for i = TP{t,1}
                fistInIntervalBool = true;
                for j = 1 : size(NOM,1)
                    if NOM(j,1) > i
                        if fistInIntervalBool == true
                            firstInInterval = NOM(j,t + 1);
                            fistInIntervalBool = false;
                        end

                        NOM(j,t + 1) = NOM(j,t + 1) * -1 + 2 * firstInInterval;
                    end
                end
            end
        end

        %% trimed displacement data
        LNCD = zeros(1,3);%last notiable change in direction for each set
        finalData = {[] [];[] [];[] []};

        for i = 1:3
            LNCD = TP{i,1}(1,end);
            keepIndex = NOM(:,1) < LNCD + 1;
            finalData{i,1} = NOM(1:sum(keepIndex),1);
            finalData{i,2} = NOM(1:sum(keepIndex),i + 1);
        end
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

        %% use the final processed data estimate for the parameters(first attempt)....finally!!!
        startPoints = [1 1];

        f = {{},{},{}};

        f{1,1} = fit(finalData{1,1}, finalData{1,2}, ...
            'exp(-s*x)*(cos(w*x) + (s/w) * sin(w*x))', ...
            'Start', startPoints);

        f{1,2} = fit(finalData{2,1}, finalData{2,2}, ...
            'exp(-s*x)*(0.5*cos(w*x) + ((1+s*0.5)/w) * sin(w*x))', ...
            'Start', startPoints);

        f{1,3} = fit(finalData{3,1}, finalData{3,2}, ...
            'exp(-s*x)*(-0.75*cos(w*x) + ((-2.5-0.75*s)/w) * sin(w*x))', ...
            'Start', startPoints);
        
        results(loop1, loop2) = {f}; 

    end
end
