function [r, noiseVar] = add_awgn(signal, EbN0_dB, bitsPerSample)
%ADD_AWGN  Add real AWGN noise to a real signal for a target Eb/N0.
%
%   [r, noiseVar] = ADD_AWGN(signal, EbN0_dB, bitsPerSample)
%
%   Inputs:
%     signal        - real column/row vector (e.g. the real CRIP OFDM
%                     time-domain stream, electrical domain, no DC bias)
%     EbN0_dB       - desired energy-per-bit to noise-density ratio, in dB
%     bitsPerSample - average number of information bits carried per
%                     sample of `signal` (e.g. log2(M) for CRIP, since
%                     one real data symbol maps to one transmitted real
%                     sample per subcarrier)
%   Outputs:
%     r             - signal + real Gaussian noise, same size as signal
%     noiseVar      - the noise variance that was used
%
%   Method: signal power is estimated directly from the given vector
%   (mean square). Eb = Ps / bitsPerSample. For a real baseband signal,
%   all noise power sits in one real dimension, so
%       noiseVar = Eb / 10^(EbN0_dB/10)  =  Ps / (bitsPerSample * 10^(EbN0_dB/10)).

    signal = signal(:);
    if bitsPerSample <= 0
        error('add_awgn:invalidBits', 'bitsPerSample must be positive.');
    end

    Ps = mean(signal.^2);
    Eb = Ps / bitsPerSample;
    noiseVar = Eb / 10^(EbN0_dB/10);

    noise = sqrt(noiseVar) * randn(size(signal));
    r = signal + noise;
end
