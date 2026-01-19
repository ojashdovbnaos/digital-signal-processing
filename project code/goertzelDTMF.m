function [mag] = goertzelDTMF(x, fs, freq)
    N = length(x);
    % 计算离散频率索引 k
    k = round(freq * N / fs);
    w = 2 * pi * k / N;
    coeff = 2 * cos(w);

    s_prev = 0;
    s_prev2 = 0;

    % 递归滤波计算
    for n = 1:N
        s = x(n) + coeff * s_prev - s_prev2;
        s_prev2 = s_prev;
        s_prev = s;
    end

    % 根据最终的 s_prev, s_prev2 得到该频率分量的实部和虚部
    real_part = s_prev - s_prev2 * cos(w);
    imag_part = s_prev2 * sin(w);

    % 幅度
    mag = sqrt(real_part^2 + imag_part^2);
end
