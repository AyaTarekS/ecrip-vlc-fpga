function [ber, nErrors] = compute_ber(bitsTx, bitsRx)
%COMPUTE_BER  Bit error rate between transmitted and received bit streams.
%
%   [ber, nErrors] = COMPUTE_BER(bitsTx, bitsRx)
%
%   Inputs:
%     bitsTx, bitsRx - equal-length vectors of 0/1
%   Outputs:
%     ber     - bit error rate, nErrors / length(bitsTx)
%     nErrors - number of bit errors

    bitsTx = bitsTx(:);
    bitsRx = bitsRx(:);
    if length(bitsTx) ~= length(bitsRx)
        error('compute_ber:lengthMismatch', 'bitsTx and bitsRx must have the same length.');
    end
    nErrors = sum(bitsTx ~= bitsRx);
    ber = nErrors / length(bitsTx);
end
