% 导入CSV文件
data = readtable('C:\Users\11283\Desktop\stp1.stp.csv'); % 使用适当的文件路径
% 如果文件很大，也可以用以下代码直接转换为数组格式
dataArray = table2array(data);
% 假设 `dataArray` 的第一列是时间戳，第二列是ADC数据
time = dataArray(:, 1); % 时间戳
adcData = dataArray(:, 2); % ADC 数据
% 绘制ADC数据波形
plot(time, adcData);
xlabel('Time');
ylabel('ADC Value');
title('ADC Data from SignalTap');
