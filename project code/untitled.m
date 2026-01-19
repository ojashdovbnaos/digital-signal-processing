function compareDTMFMethods()
    % =========== 1. 生成测试信号 ===========
    fs = 8000;          
    duration = 0.25;     
    t = 0:1/fs:duration-1/fs;
    % DTMF '5'的两个频率
    tone_low = 770;
    tone_high = 1336;
    x = sin(2*pi*tone_low*t) + sin(2*pi*tone_high*t);

    % 要检测的频率
    freqs = [697, 770, 852, 941, 1209, 1336, 1477, 1633];

    % =========== 2. 幅度计算 ===========
    goertzelVals = zeros(1, length(freqs));
    matchedVals  = zeros(1, length(freqs));
    fftVals      = zeros(1, length(freqs));

    for i = 1:length(freqs)
        goertzelVals(i) = goertzelDTMF(x, fs, freqs(i));
        matchedVals(i)  = matchedFilterDTMF(x, fs, freqs(i));
        fftVals(i)      = fftDTMF(x, fs, freqs(i));
    end

    % =========== 3. 绘制幅度对比图 ===========
    figure('Name','DTMF Detection Amplitude Comparison','NumberTitle','off');
    subplot(3,1,1);
    stem(freqs, goertzelVals, 'LineWidth',1.5,'Marker','o');
    title('Goertzel: amplitude for each freq'); xlabel('Frequency (Hz)'); ylabel('Amplitude');
    grid on;

    subplot(3,1,2);
    stem(freqs, matchedVals, 'r','LineWidth',1.5,'Marker','o');
    title('Matched Filter: amplitude for each freq'); xlabel('Frequency (Hz)'); ylabel('Amplitude');
    grid on;

    subplot(3,1,3);
    stem(freqs, fftVals, 'g','LineWidth',1.5,'Marker','o');
    title('FFT: amplitude for each freq'); xlabel('Frequency (Hz)'); ylabel('Amplitude');
    grid on;

    % =========== 4. 简易复杂度/时间比较 ===========

    % 4.1 仅检测单频率的平均耗时 (重复多次取平均)
    testFreq = 770;  % 随便选一个目标频率
    numIter = 1024;  % 为了获得稳定平均值

    % --- Goertzel ---
    tic;
    for ii = 1:numIter
        goertzelDTMF(x, fs, testFreq);
    end
    timeGoertzel = toc / numIter;  % 单次平均耗时

    % --- Matched Filter ---
    tic;
    for ii = 1:numIter
        matchedFilterDTMF(x, fs, testFreq);
    end
    timeMatched = toc / numIter;

    % --- FFT ---
    tic;
    for ii = 1:numIter
        fftDTMF(x, fs, testFreq);
    end
    timeFFT = toc / numIter;

    % 4.2 检测全部频率（8个）的平均耗时
    numIter2 = 102400;
    % --- Goertzel 全频 ---
    tic;
    for ii = 1:numIter2
        for ff = 1:length(freqs)
            goertzelDTMF(x, fs, freqs(ff));
        end
    end
    timeGoertzelAll = toc / numIter2;

    % --- Matched Filter 全频 ---
    tic;
    for ii = 1:numIter2
        for ff = 1:length(freqs)
            matchedFilterDTMF(x, fs, freqs(ff));
        end
    end
    timeMatchedAll = toc / numIter2;

    % --- FFT 全频 ---
    tic;
    for ii = 1:numIter2
        % 1次FFT + 读取8个bin
        X = fft(x);
        for ff = 1:length(freqs)
            freqResolution = fs / length(x);
            idx = round(freqs(ff) / freqResolution) + 1;
            abs(X(idx));
        end
    end
    timeFFTAll = toc / numIter2;

    % =========== 5. 输出结果 ===========
    disp('=== 单频率平均耗时 (秒) ===');
    disp(table(timeGoertzel, timeMatched, timeFFT, ...
        'VariableNames', {'Goertzel','MatchedFilter','FFT'}));

    disp('=== 8个频率平均耗时 (秒) ===');
    disp(table(timeGoertzelAll, timeMatchedAll, timeFFTAll, ...
        'VariableNames', {'Goertzel_AllFreq','Matched_AllFreq','FFT_AllFreq'}));
end
