clear;
close all;
clc;

%% 读入数据
[signal, fs] = audioread('pure.wav');  % 读入示例音频文件
N = length(signal);
t = (0:N-1)/fs; % 生成时间向量
SNR = 5; % 信噪比大小

% 生成噪声
noise = randn(N, 1); % 使用随机噪声代替原来的噪声
noise = noise / norm(noise, 2) .* 10^(-SNR/20) * norm(signal);     
x = signal + noise; % 产生固定信噪比的带噪语音

%% 谱减法
noise_estimated = x(1:0.5*fs, 1); % 将前0.5秒的信号作为估计的噪声
fft_x = fft(x); % 对加噪语音进行FFT
phase_fft_x = angle(fft_x); % 取带噪语音的相位作为最终相位
fft_noise_estimated = fft(noise_estimated); % 对噪声进行FFT
mag_signal = abs(fft_x) - sum(abs(fft_noise_estimated)) / length(fft_noise_estimated); % 恢复出来的幅度
mag_signal(mag_signal < 0) = 0; % 将小于0的部分置为0

%% 恢复语音信号
fft_s = mag_signal .* exp(1i .* phase_fft_x);
s = ifft(fft_s);

% 确保信号是列向量
signal = signal(:);
x = x(:);
s = real(s(:));

% 重新生成时间向量，以便与所有信号长度匹配
t_signal = (0:length(signal)-1)/fs;
t_x = (0:length(x)-1)/fs;
t_s = (0:length(s)-1)/fs;

figure(1)
subplot(321);
plot(t_signal, signal);
axis([0 3 -1.5 1.5]);
title('示例音频'); xlabel('时间/s'); ylabel('幅度');

subplot(323);
plot(t_x, x);
axis([0 3 -1.5 1.5]);
title('带噪语音'); xlabel('时间/s'); ylabel('幅度');

subplot(325);
plot(t_s, s);
axis([0 3 -1.5 1.5]);
title('谱减法增强后的语音'); xlabel('时间/s'); ylabel('幅度');

subplot(322);
spectrogram(signal, 256, 128, 256, fs, 'yaxis');
subplot(324);
spectrogram(x, 256, 128, 256, fs, 'yaxis');
subplot(326);
spectrogram(s, 256, 128, 256, fs, 'yaxis');

%% 播放声音
disp('播放示例音频');
sound(signal, fs); % 播放示例音频
pause(N/fs + 1); % 等待示例音频播放完成

disp('播放带噪音频');
sound(x, fs); % 播放带噪音频
pause(N/fs + 1); % 等待带噪音频播放完成

disp('播放增强后的语音');
sound(s, fs); % 播放增强后的语音
