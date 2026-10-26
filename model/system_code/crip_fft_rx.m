function x_hat = crip_fft_rx(y, Lambda)
%CRIP_FFT_RX  CRIP receiver core operation (single-tap equalizer + Re-Im).
%
%   x_hat = CRIP_FFT_RX(y, Lambda)
%
%   Takes one received time-domain block y (length N),
%   computes the N-point DFT, applies the single-tap frequency-domain
%   equalizer 1./Lambda (Lambda = channel eigenvalues, i.e. fft(h,N)),
%   and subtracts the imaginary part from the real part of the
%   equalized spectrum to recover the original real data symbols
%   (Eq. 14-21 in Hacioglu/Turk/Albayrak). Works identically for
%   E-CRIP and O-CRIP, since both produce the same received vector
%   after the channel (Eqs. 10-12 of the paper).
%
%   Inputs:
%     y      - real column/row vector, length N, received samples (CP removed)
%     Lambda - complex column/row vector, length N, channel eigenvalues
%              (Lambda = fft(h, N)). Pass Lambda = ones(N,1) for an
%              ideal / AWGN-only channel (no equalization needed).
%   Output:
%     x_hat  - real column vector, length N, recovered (noisy) data symbols

    y = y(:);
    Lambda = Lambda(:);

    R  = fft(y);            % DFT of received block
    RR = R ./ Lambda;        % single-tap equalization

    x_hat = real(RR) - imag(RR);
end
