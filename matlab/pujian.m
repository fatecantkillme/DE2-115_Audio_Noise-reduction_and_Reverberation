clear;
close all;
clc;

%% 读入数据
[signal, fs] = audioread('pure.wav');  % 读入示例音频文件
signal=signal(:,1);
N = length(signal);
t = (0:N-1)/fs; % 生成时间向量
SNR = 3.5; % 信噪比大小

% 生成噪声
noise = randn(N, 1); % 使用随机噪声代替原来的噪声
noise = noise / norm(noise, 2) .* 10^(-SNR/20) * norm(signal); 

x = signal + noise; % 产生固定信噪比的带噪语音

s = spectral_subtraction(x, fs);

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
pause(N/fs + 1); % 等待带噪音频播放完成pause(10);
disp('播放增强后的语音');
sound(s, fs); % 播放增强后的语音
snr1=SNR_Calc(signal,s);
snr2=SNR_Calc(signal,x);
disp(snr1);
disp(snr2);

function snr=SNR_Calc(I,In)
% 计算带噪语音信号的信噪比
% I 是纯语音信号
% In 是带噪的语音信号
% 信噪比计算公式是
% snr=10*log10(Esignal/Enoise)
I=I(:)';                             % 把数据转为一列
In=In(:)';
          % 信号的能量
Ps = bandpower(I);

% 然后计算噪声信号的功率，即带噪信号与纯净信号之差
Pn = bandpower(In - I);                     % 噪声的能量
snr=10*log10(Ps/Pn);                 % 信号的能量与噪声的能量之比，再求分贝值
end
function enhanced_signal = spectral_subtraction(x, fs, frame_size, overlap)
    % 设计低通滤波器 
    fc = 10000; % 截止频率（Hz） 
    [b, a] = butter(6, fc/(fs/2), 'low'); % 设计6阶巴特沃斯低通滤波器
    x = filter(b, a, x);
    
    % 参数设置
    if nargin < 3
        frame_size = 0.02; % 默认帧长为20ms
    end
    if nargin < 4
        overlap = 0.5; % 默认重叠率为50%
    end
    frame_len = round(frame_size * fs);
    frame_step = round(frame_len * (1 - overlap));
    num_frames = ceil((length(x) - frame_len) / frame_step) + 1;

    % 加窗分帧
    window = hann(frame_len);
    frames = zeros(num_frames, frame_len);
    for i = 1:num_frames
        start = (i-1) * frame_step + 1;
        end_idx = min(start + frame_len - 1, length(x));
        frames(i, 1:(end_idx-start+1)) = x(start:end_idx) .* window(1:(end_idx-start+1));
    end

    % 估计噪声
    noise_estimated = mean(frames(1:5, :), 1); % 前5帧作为噪声估计

    % 频谱减法
    enhanced_frames = zeros(size(frames));
    decay_factor = 0.9; % 衰减因子
    alpha = 0.98; % 平滑因子
    for i = 1:num_frames
        fft_frame = fft(frames(i, :));
        fft_noise = fft(noise_estimated, length(fft_frame));
        mag_signal = abs(fft_frame) - abs(fft_noise);
        mag_signal(mag_signal < 0) = 0;
        % 计算后验信噪比
        post_snr = mag_signal.^2 ./ abs(fft_noise).^2; 
        % 计算先验信噪比 
        if i == 1
            prior_snr = post_snr;
        else
            prior_snr = alpha * (enhanced_frames(i-1, :).^2 ./ abs(fft_noise).^2) + (1 - alpha) * max(post_snr - 1, 0);
        end
        % 计算增益
        gain = prior_snr ./ (1 + prior_snr);

        % 判断是否有语音
        if is_speech_frame(frames(i, :))
            enhanced_frames(i, :) = real(ifft(gain .* fft_frame));
            decay_factor = 0.9;
        else
            % 对于相邻的帧进行减弱处理
            enhanced_frames(i, :) = real(ifft(gain .* fft_frame)) *decay_factor ;
            decay_factor = decay_factor * 0.9; % 逐渐减弱
        end
    end

    % 重构信号
    enhanced_signal = zeros(length(x), 1);
    for i = 1:num_frames
        start = (i-1) * frame_step + 1;
        end_idx = min(start + frame_len - 1, length(x));
        enhanced_signal(start:end_idx) = enhanced_signal(start:end_idx) + enhanced_frames(i, 1:(end_idx-start+1))';
    end
end

function is_speech = is_speech_frame(frame)
    % 简单的语音活动检测逻辑
    energy_threshold = 0.08; % 能量阈值
    frame_energy = sum(frame .^ 2);
    is_speech = frame_energy > energy_threshold;
end



