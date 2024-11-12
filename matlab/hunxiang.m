clear;
close all;
clc;

%% 读取音频文件
[signal, fs] = audioread('quzao.wav');
N = length(signal);
t_signal = (0:N-1)/fs; % 原始信号时间向量

%% Schroeder 混响算法参数
delays = round([0.03, 0.05, 0.07, 0.09, 0.11] * fs); % 多个梳状滤波器延迟
feedbacks = [0.4, 0.5, 0.6, 0.7, 0.7]; % 降低反馈量

% 初始化输出信号
output = zeros(size(signal));

% 梳状滤波器的级联
for i = 1:length(delays)
    delay = delays(i);
    feedback = feedbacks(i);
    temp_output = zeros(size(signal));
    
    for n = 1:N
        % 计算混响
        if n > delay
            temp_output(n) = signal(n) + feedback * temp_output(n - delay);
        else
            temp_output(n) = signal(n);
        end
        
        % 添加全通滤波器处理
        if n > 1
            temp_output(n) = 0.7 * temp_output(n) + 0.3 * temp_output(n - 1); % 全通滤波器
        end
    end
    output = output + temp_output; % 累加多个滤波器的输出
end

% 低通滤波器参数
fc = 3000; % 截止频率
[b, a] = butter(6, fc/(fs/2)); % 6阶低通滤波器

% 应用低通滤波器
output = filter(b, a, output);

% 增大混响信号的音量
output = output * 1.2; % 调整增益

% 确保输出信号是列向量
output = output(:);
signal = signal(:);

%% 绘制信号图像
figure;

subplot(2, 1, 1);
plot(t_signal, signal);
title('原始信号');
xlabel('时间 (s)');
ylabel('幅度');
axis tight;

subplot(2, 1, 2);
plot(t_signal, output);
title('混响信号');
xlabel('时间 (s)');
ylabel('幅度');
axis tight;

%% 播放声音
disp('播放原始音频');
sound(signal, fs);
pause(N/fs + 1); % 等待播放完成

disp('播放混响后的音频');
sound(output, fs);
audiowrite('hunxaing.wav', output, fs);