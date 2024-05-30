% Specify the file name
filename = 'CarDatabase.xlsx';
clear p p2
% Specify the sheet name or index (e.g., 'Sheet1' or 1 for the first sheet)
sheet = 'Optimum Updated';

% Specify the range of data to read (e.g., 'A1:C10' for rows 1 to 10 and columns A to C)
range = 'A2:J10';

% Read the matrix from the specified sheet and range
data = readtable(filename, 'Sheet', sheet, 'Range', range);

% Display the data
disp(data);

figure;
hold on;
p(1)=plot(linspace(0,100,2),linspace(0,100,2),"--b");
names = strcat("(",data.Var1,") ",data.Var2);
col = cell(height(names), 1);  % Preallocate col as a cell arraycol = cell(height(names), 1);  % Preallocate col as a cell array
for i =1:height(names)-2
    col{i} =[rand(1),rand(1),rand(1)];
    p(end+1)=plot(data.Var5(i),data.Var3(i),'o',MarkerFaceColor=col{i},MarkerEdgeColor=col{i},MarkerSize=10);
    errorbar(data.Var5(i),data.Var3(i),data.Var10(i),data.Var10(i),"vertical",Color=col{i},LineWidth=4)
end
xlim([min(data.Var5)*0.8,max(data.Var5)*1.2]);
ylim([min(data.Var3)*0.8,max(data.Var3)*1.2]);
xlabel("Actual Time [$s$]")
ylabel("Predicted Time [$s$]")
title("Acceleration")
legend(p,["$y=x$",names']);


figure;
hold on;
p2(1)=plot(linspace(0,100,2),linspace(0,100,2),"--b");
for i =1:height(names)-2
    p2(end+1)=plot(data.Var6(i),data.Var7(i),'o',MarkerFaceColor=col{i},MarkerEdgeColor=col{i},MarkerSize=10);
    errorbar(data.Var6(i),data.Var7(i),data.Var10(i),data.Var10(i),"vertical",Color=col{i},LineWidth=4)
end
xlim([min(data.Var6)*0.8,max(data.Var6)*1.2]);
ylim([min(data.Var7)*0.8,max(data.Var7)*1.2]);
xlabel("Actual Time [$s$]")
ylabel("Predicted Time [$s$]")
legend(p2,["$y=x$",names']);
title("Skidpad")

prettier();