function r = apply_channel(txStream, h)
%APPLY_CHANNEL  Pass a continuous (concatenated, CP-included) OFDM stream
%   through a real-valued multipath FIR channel.
%
%   r = APPLY_CHANNEL(txStream, h)
%
%   Inputs:
%     txStream - real column/row vector: concatenation of one or more
%                CP-prepended OFDM blocks, back to back (as actually
%                transmitted over time).
%     h        - real column/row vector: causal FIR channel impulse
%                response, h(1) = tap for delay 0. For a correct
%                single-tap frequency-domain equalizer per block, the
%                cyclic prefix length used when building txStream must
%                satisfy Ncp >= length(h)-1.
%   Output:
%     r        - real column vector, same length as txStream: causally
%                filtered stream y(n) = sum_m h(m) txStream(n-m+1),
%                i.e. filter(h,1,txStream). No noise is added here;
%                use ADD_AWGN separately.

    txStream = txStream(:);
    h = h(:);
    r = filter(h, 1, txStream);
end
