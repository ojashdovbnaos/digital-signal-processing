function [mag] = fftDTMF(x, fs, freq)
    N = length(x);
    X = fft(x);
    freqResolution = fs / N;
    idx = round(freq / freqResolution) + 1;  
    mag = abs(X(idx));
end
