function X = myFFT(x)
    % myFFT: Iterative implementation of Cooley-Tukey radix-2 FFT, avoiding the built-in fft()
    % x : Complex input sequence (length N=2^m)
    % X : Complex frequency spectrum (should theoretically match fft(x))
    
    N = length(x);
    % 1) Check if N is a power of 2
    if bitand(N, N-1) ~= 0
        error('myFFT only works for length = 2^m (power of two).');
    end
    
    % 2) Bit-reversal ordering
    X = bitReverseCopy(x);
    
    % 3) Iterative butterfly computation
    %    Number of stages = log2(N), Butterfly size at stage s = 2^s
    log2N = log2(N);
    for s = 1:log2N
        m = 2^s;            % Current stage butterfly size
        half_m = m / 2;     
        
        % Twiddle factor step for this stage
        w_step = exp(-1i * 2*pi / m);
        
        % Process groups from 1 to N, each group of size m
        for k = 0 : half_m-1
            % Twiddle factor for current k
            w_k = w_step^k;  
            
            % Group start index, increments by m: 1, 1+m, 1+2m, ...
            for groupStart = 1 : m : N
                idxTop = groupStart + k;        
                idxBot = idxTop + half_m;       
                
                % Butterfly computation
                t = w_k * X(idxBot);
                u = X(idxTop);
                
                X(idxTop) = u + t;
                X(idxBot) = u - t;
            end
        end
    end
end

function Xbitrev = bitReverseCopy(x)
    % bitReverseCopy: Reorder x into bit-reversed index positions
    N = length(x);
    Xbitrev = zeros(size(x));
    log2N = log2(N);
    
    for n = 0 : N-1
        r = bitrev(n, log2N); 
        % +1 because MATLAB uses 1-based indexing
        Xbitrev(r + 1) = x(n + 1); 
    end
end

function r = bitrev(n, bits)
    % bitrev: Reverse the lower 'bits' of integer n
    r = 0;
    for i = 1 : bits
        r = bitshift(r, 1) + bitand(n, 1);
        n = bitshift(n, -1);
    end
end
