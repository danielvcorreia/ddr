G= [ 1 2
 1 3
 1 4
 1 5
 1 6
 1 14
 1 15
 2 3
 2 4
 2 5
 2 7
 2 8
 3 4
 3 5
 3 8
 3 9
 3 10
 4 5
 4 10
 4 11
 4 12
 4 13
 5 12
 5 13
 5 14
 6 7
 6 16
 6 17
 6 18
 6 19
 7 19
 7 20
 8 9
 8 21
 8 22
 9 10
 9 22
 9 23
 9 24
 9 25
 10 11
 10 26
 10 27
 11 27
 11 28
 11 29
 11 30
 12 30
 12 31
 12 32
 13 14
 13 33
 13 34
 13 35
 14 36
 14 37
 14 38
 15 16
 15 39
 15 40
 20 21];

%% 3.a

s = G(:,1);
t = G(:,2);
grafo = graph(s,t);
ids = 1:40;
Ish = [];

plot(grafo)

fid = fopen('exemplo1.lp','wt');
fprintf(fid, "Minimize\n");
for i=6:40
    if i<=15
        fprintf(fid, ' + 12 x%d',i);
    else
        fprintf(fid, ' + 8 x%d',i);
    end
end
       
fprintf(fid,'\nSubject to \n');
for j = 6:40
    for i= 6:40
        p = shortestpath(grafo,j,i);
        if length(p)<=3
            fprintf(fid, ' + x%d',i);
        end
    end
    fprintf(fid,' >= 1\n');
end

fprintf(fid,'Binary\n');
for i=6:40
    
    fprintf(fid, ' x%d',i);
    
end

fprintf(fid,'\nEnd\n');
fclose(fid);

%% 3.b

R = 50000; % variable %
lambda = (10*5000+25*2500)/24;
p = 30;
n = 76; % variable %
N = 10;
S = 1000;
W = 52000; % variable %
fname = 'movies.txt';

blocking = zeros(1, length(lambda));
blocking_errhigh = zeros(1, length(lambda));
blocking_errlow = zeros(1, length(lambda));

blocking_HD = zeros(1, length(lambda));
blocking_HD_errhigh = zeros(1, length(lambda));
blocking_HD_errlow = zeros(1, length(lambda));

for i = 1:length(lambda)
    for j = 1:N
        [b(j), o(j)] = simulator2(lambda(i),p,n,S,W,R,fname);
    end
    
    %90% confidence interval%
    alfa = 0.1;                          
    blocking(i) = mean(b);
    blocking_errhigh(i) = norminv(1-alfa/2) * sqrt(var(b)/N);
    blocking_errlow(i) = blocking_errhigh(i);
    
    blocking_HD(i) = mean(o);
    blocking_HD_errhigh(i) = norminv(1-alfa/2) * sqrt(var(o)/N);
    blocking_HD_errlow(i) = blocking_errhigh(i);
end

figure(1)
bar(lambda, blocking);
title('Blocking Probabilities of 4K Movies');
ylim([0, 20]);
grid on

hold on

er = errorbar(lambda, blocking, blocking_errlow, blocking_errhigh);
er.Color = [0 0 0];
er.LineStyle = 'none';

hold off

figure(2)
bar(lambda, blocking_HD);
title('Blocking Probabilities of HD Movies');
ylim([0, 20]);
grid on

hold on

er = errorbar(lambda, blocking_HD, blocking_HD_errlow, blocking_HD_errhigh);
er.Color = [0 0 0];
er.LineStyle = 'none';

hold off

fprintf('Blocking probability 4k(%%)= %.2e +-%.2e\n', blocking, blocking_errhigh)
fprintf('Blocking probability HD(%%)= %.2e +-%.2e\n', blocking_HD, blocking_HD_errhigh)
