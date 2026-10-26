function bits = pam_demod(r, M)
%PAM_DEMOD  Hard-decision Gray-coded M-ary PAM demodulator, inverse of PAM_MOD.
%
%   bits = PAM_DEMOD(r, M)
%
%   Inputs:
%     r - real column/row vector of received PAM symbols (same
%         unit-average-energy scaling used by PAM_MOD, i.e. mean(s.^2)=1
%         for the noiseless case).
%     M - PAM modulation order (must match the one used in PAM_MOD).
%
%   Output:
%     bits - column vector of 0/1, length = length(r) * log2(M).

    k = log2(M);
    if abs(k - round(k)) > 1e-9
        error('pam_demod:invalidM', 'M must be a power of 2.');
    end
    k = round(k);

    r = r(:);
    Eavg = (M^2 - 1) / 3;
    rScaled = r * sqrt(Eavg);                  % undo PAM_MOD normalization

    levels = -(M-1):2:(M-1);

    % Nearest-level (minimum distance) hard decision
    idx = round((rScaled - levels(1)) / 2);     % ideal index 0..M-1
    idx = min(max(idx, 0), M-1);                % clip against noise excursions
    g = idx;

    n = local_gray_decode(g, k);

    % Convert natural binary index n (0..M-1) back to k bits, MSB first
    numSym = length(n);
    bitMat = zeros(numSym, k);
    for b = 1:k
        shiftAmt = k - b;
        bitMat(:, b) = mod(floor(n / 2^shiftAmt), 2);
    end
    bits = reshape(bitMat.', [], 1);
end

function n = local_gray_decode(g, k)
    gu = uint32(g);
    n = gu;
    mask = bitshift(gu, -1);
    for i = 1:k
        n = bitxor(n, mask);
        mask = bitshift(mask, -1);
        if ~any(mask(:) > 0)
            break;
        end
    end
    n = double(n);
end
