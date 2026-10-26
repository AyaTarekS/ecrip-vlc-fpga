function s_FP = crip_ifft_tx(x)
%CRIP_IFFT_TX  E-CRIP transmitter core operation.
%
%   s_FP = CRIP_IFFT_TX(x)
%
%   Takes one block of N real-valued data symbols x (all N subcarriers
%   loaded with real M-PAM symbols), computes the N-point IDFT,
%   and sums the real and imaginary parts of the IDFT output to obtain
%   a real-valued, transmittable OFDM time-domain signal (E-CRIP, Eq.).
%
%   Input:
%     x    - real column/row vector, length N (data symbols per subcarrier)
%   Output:
%     s_FP - real column vector, length N (E-CRIP time-domain samples)

    x = x(:);
    S_F  = ifft(x);    % complex IDFT output, S_F = S_FR + j*S_FI
    s_FP = real(S_F) + imag(S_F);
end
