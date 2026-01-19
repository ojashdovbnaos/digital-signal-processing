function testDTMFNumber()
    % ========== 1. Basic Setup ==========
    fs = 8000;                 % Sampling rate (Hz)
    digitDuration = 0.25;      % Duration of each digit (seconds)
    phoneNumber = '5483887086';% Phone number to test (DTMF sequence)
    
    % Mapping of each digit to its low and high frequencies (Hz)
    dtmfMap = containers.Map(...
       {'1','2','3','4','5','6','7','8','9','0','*','#'}, ...
       {[697,1209],[697,1336],[697,1477],...
        [770,1209],[770,1336],[770,1477],...
        [852,1209],[852,1336],[852,1477],...
        [941,1336],[941,1209],[941,1477]});
    
    % All frequencies to detect (8 common + 1633 for potential extensions)
    freqs = [697, 770, 852, 941, 1209, 1336, 1477, 1633];
    
    % ========== 2. Generate the Entire DTMF Signal ==========
    t_per_digit = 0:1/fs:digitDuration - 1/fs;  % Time vector for each digit
    fullSignal = [];   % Concatenated waveform of all digits
    
    for i = 1:length(phoneNumber)
        digit = phoneNumber(i);
        % Get the low and high frequencies for this digit from dtmfMap
        if isKey(dtmfMap, digit)
            tones = dtmfMap(digit);
            f_low  = tones(1);
            f_high = tones(2);
        else
            warning('Unknown digit: %s, treat as silence.', digit);
            f_low  = 0;
            f_high = 0;
        end
        
        % Generate the DTMF signal for this digit (low + high frequency)
        sigLow  = sin(2*pi*f_low * t_per_digit);
        sigHigh = sin(2*pi*f_high * t_per_digit);
        sigDTMF = sigLow + sigHigh;
        
        % Append to fullSignal
        fullSignal = [fullSignal, sigDTMF];
    end
    
    % ========== 3. Frame and Detect (Goertzel/Matched/FFT) ==========
    Ndigits = length(phoneNumber); 
    samplesPerDigit = length(t_per_digit);  % digitDuration * fs
    
    % Pre-allocate results storage (amplitude detection for all 8 frequencies in each frame)
    G_all = zeros(Ndigits, length(freqs));
    M_all = zeros(Ndigits, length(freqs));
    F_all = zeros(Ndigits, length(freqs));
    
    % Detect for each digit (frame)
    for d = 1:Ndigits
        % Extract the sample segment for the d-th digit
        startIdx = (d-1)*samplesPerDigit + 1;
        endIdx   = d*samplesPerDigit;
        frameSig = fullSignal(startIdx:endIdx);
        
        % Detect amplitudes at all frequencies using three methods
        for fIdx = 1:length(freqs)
            G_all(d, fIdx) = goertzelDTMF(frameSig, fs, freqs(fIdx));
            M_all(d, fIdx) = matchedFilterDTMF(frameSig, fs, freqs(fIdx));
            F_all(d, fIdx) = fftDTMF(frameSig, fs, freqs(fIdx));
        end
    end
    
    % ========== 4. Print or Visualize Detection Results ==========
    % Create a simple table to show: for each digit frame, find the max low and high frequencies
    detectedDigits_G = cell(1, Ndigits);
    detectedDigits_M = cell(1, Ndigits);
    detectedDigits_F = cell(1, Ndigits);
    
    for d = 1:Ndigits
        % Goertzel
        [~, idxLow]  = max(G_all(d, 1:4));    % Low frequencies (697,770,852,941)
        [~, idxHigh] = max(G_all(d, 5:8));    % High frequencies (1209,1336,1477,1633)
        fLow  = freqs(idxLow);
        fHigh = freqs(4 + idxHigh);
        detectedDigits_G{d} = dtmfFreq2digit(fLow, fHigh);
        
        % Matched
        [~, idxLow]  = max(M_all(d, 1:4));
        [~, idxHigh] = max(M_all(d, 5:8));
        fLow  = freqs(idxLow);
        fHigh = freqs(4 + idxHigh);
        detectedDigits_M{d} = dtmfFreq2digit(fLow, fHigh);

        % FFT
        [~, idxLow]  = max(F_all(d, 1:4));
        [~, idxHigh] = max(F_all(d, 5:8));
        fLow  = freqs(idxLow);
        fHigh = freqs(4 + idxHigh);
        detectedDigits_F{d} = dtmfFreq2digit(fLow, fHigh);
    end
    
    % Display detection results
    disp('============= Detection Results Comparison =============');
    disp(table((1:Ndigits)', phoneNumber', ...
         detectedDigits_G', detectedDigits_M', detectedDigits_F', ...
         'VariableNames', {'Index','Original','Goertzel','Matched','FFT'}));
    
    % ========== 5. Plot Comparison of Amplitude Values for Each Frame ==========
    % Example: Compare amplitude values for the first digit frame at 8 frequencies
    figure('Name','DTMF Detection Comparison','NumberTitle','off');
    digitIndexToShow = 1;  % Example: View the first digit
    subplot(3,1,1);
    stem(freqs, G_all(digitIndexToShow,:), 'LineWidth',1.5,'Marker','o');
    title(['Goertzel: Digit=' phoneNumber(digitIndexToShow)]); 
    xlabel('Frequency (Hz)'); ylabel('Amplitude'); grid on;
    
    subplot(3,1,2);
    stem(freqs, M_all(digitIndexToShow,:), 'r','LineWidth',1.5,'Marker','o');
    title(['Matched Filter: Digit=' phoneNumber(digitIndexToShow)]); 
    xlabel('Frequency (Hz)'); ylabel('Amplitude'); grid on;
    
    subplot(3,1,3);
    stem(freqs, F_all(digitIndexToShow,:), 'g','LineWidth',1.5,'Marker','o');
    title(['FFT: Digit=' phoneNumber(digitIndexToShow)]); 
    xlabel('Frequency (Hz)'); ylabel('Amplitude'); grid on;
    
    % ========== 6. Compare Execution Times (Optional) ==========
    % Test the average processing time for one frame (one digit) across 500 iterations
    frameSigTest = fullSignal(1:samplesPerDigit);
    numIter = 500;
    
    % -- Single frame, single method (detect 8 frequencies) ---
    tic;
    for i=1:numIter
        for fIdx=1:length(freqs)
            goertzelDTMF(frameSigTest, fs, freqs(fIdx));
        end
    end
    timeGoertzel = toc / numIter;
    
    tic;
    for i=1:numIter
        for fIdx=1:length(freqs)
            matchedFilterDTMF(frameSigTest, fs, freqs(fIdx));
        end
    end
    timeMatched = toc / numIter;
    
    tic;
    for i=1:numIter
        X = fft(frameSigTest);   % Use one FFT to capture all frequencies
        for fIdx=1:length(freqs)
            % Retrieve amplitude
            freqResolution = fs / length(frameSigTest);
            idx = round(freqs(fIdx) / freqResolution) + 1;
            abs(X(idx));
        end
    end
    timeFFT = toc / numIter;
    
    disp('============= Execution Time Comparison =============');
    disp(table(timeGoertzel, timeMatched, timeFFT, ...
        'VariableNames',{'Goertzel_1digit','Matched_1digit','FFT_1digit'}));
end

% ========== Helper Functions: Goertzel, Matched, FFT ==========

function [mag] = goertzelDTMF(x, fs, freq)
    N = length(x);
    k = round(freq * N / fs);
    w = 2*pi*k/N;
    coeff = 2*cos(w);
    s_prev = 0; s_prev2 = 0;
    for n = 1:N
        s = x(n) + coeff*s_prev - s_prev2;
        s_prev2 = s_prev;
        s_prev = s;
    end
    real_part = s_prev - s_prev2*cos(w);
    imag_part = s_prev2*sin(w);
    mag = sqrt(real_part^2 + imag_part^2);
end

function [corrVal] = matchedFilterDTMF(x, fs, freq)
    N = length(x);
    t = (0:N-1)/fs;
    ref = sin(2*pi*freq*t);
    corrVal = abs(sum(x .* ref));
end

function [mag] = fftDTMF(x, fs, freq)
    N = length(x);
    X = fft(x);
    freqResolution = fs/N;
    idx = round(freq/freqResolution) + 1;  % MATLAB uses 1-based indexing
    mag = abs(X(idx));
end

% ========== Map Detected Low + High Frequencies Back to Digits ==========
% This example only matches the 8+4 common DTMF frequencies. If there are
% deviations or variations, consider setting "approximate match" or thresholds.
function digit = dtmfFreq2digit(fLow, fHigh)
    % Simplified reverse mapping table
    DTMF_TABLE = [
        697,1209,'1'; 697,1336,'2'; 697,1477,'3';
        770,1209,'4'; 770,1336,'5'; 770,1477,'6';
        852,1209,'7'; 852,1336,'8'; 852,1477,'9';
        941,1336,'0'; 941,1209,'*'; 941,1477,'#';
    ];
    digit = '?';  % Default unknown
    for i = 1:size(DTMF_TABLE,1)
        if (DTMF_TABLE(i,1) == fLow && DTMF_TABLE(i,2) == fHigh) || ...
           (DTMF_TABLE(i,1) == fHigh && DTMF_TABLE(i,2) == fLow)
            digit = DTMF_TABLE(i,3);
            break;
        end
    end
end
