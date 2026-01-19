% testMyFFT.m
clear; clc;

% 1) Construct a test signal
N = 8;  % Must be a power of 2
x = rand(1, N) + 1i * rand(1, N);  % Random complex numbers

% 2) Compute FFT using custom implementation and MATLAB's built-in fft
X_my  = myFFT(x);
X_ref = fft(x);

% 3) Compare results
disp('myFFT result:');
disp(X_my);
disp('MATLAB built-in fft result:');
disp(X_ref);

% 4) Compute numerical difference
diffVal = norm(X_my - X_ref);
fprintf('Difference norm: %g\n', diffVal);

% 5) Compare execution speed (basic test)
numIter = 1e4;
tic;
for k = 1:numIter
    myFFT(x);
end
time_my = toc;

tic;
for k = 1:numIter
    fft(x);
end
time_builtin = toc;

fprintf('myFFT total time: %.4f s\n', time_my);
fprintf('Built-in fft time: %.4f s\n', time_builtin);
