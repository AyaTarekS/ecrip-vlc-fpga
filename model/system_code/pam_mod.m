function s = pam_mod(bits, M)
%PAM_MOD  Gray-coded M-ary PAM modulator with unit average symbol energy.
%
%   s = PAM_MOD(bits, M)
%
%   Inputs:
%     bits - column/row vector of 0/1 values. length(bits) must be a
%            multiple of log2(M).
%     M    - PAM modulation order (2, 4, 8, 16, ...).
%
%   Output:
%     s    - real column vector of PAM symbols, length = length(bits)/log2(M),
%            normalized so that mean(s.^2) = 1.
%
%   Mapping: groups of k = log2(M) bits (MSB first) are treated as a
%   natural binary index n in [0, M-1], Gray-encoded to g, and g selects
%   one of M equally spaced amplitude levels -(M-1):2:(M-1).

    k = log2(M);
    if abs(k - round(k)) > 1e-9
        error('pam_mod:invalidM', 'M must be a power of 2.');
    end
    k = round(k);

    bits = bits(:);
    if mod(length(bits), k) ~= 0
        error('pam_mod:invalidLength', ...
              'length(bits) must be a multiple of log2(M) = %d.', k);
    end

    % Each row = one symbol's k bits, MSB first
    bitGroups = reshape(bits, k, []).';        % [numSymbols x k]

    % Natural binary index per symbol
    weights = 2.^(k-1:-1:0);                   % [2^(k-1) ... 2 1]
    n = bitGroups * weights.';                 % [numSymbols x 1], values 0..M-1

    % Gray encode
    g = local_gray_encode(n, k);

    % Ideal (unnormalized) PAM levels, index 0..M-1 -> level -(M-1)..(M-1) step 2
    levels = -(M-1):2:(M-1);
    amp = levels(g + 1).';                     % select level for each symbol

    % Normalize to unit average energy: E[amp^2] for ideal M-PAM = (M^2-1)/3
    Eavg = (M^2 - 1) / 3;
    s = amp / sqrt(Eavg);
end

function g = local_gray_encode(n, k)
    % n : column vector of nonnegative integers < 2^k
    nu = uint32(n);
    g  = double(bitxor(nu, bitshift(nu, -1)));
end
