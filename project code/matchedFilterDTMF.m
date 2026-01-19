function [corrVal] = matchedFilterDTMF(x, fs, freq)
    N = length(x);
    t = (0:N-1) / fs;
    ref = sin(2*pi*freq*t);
    corrVal = abs(sum(x .* ref));
end
