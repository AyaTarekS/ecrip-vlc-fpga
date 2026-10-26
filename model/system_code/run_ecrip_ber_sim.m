% RUN_ECRIP_BER_SIM
% End-to-end E-CRIP OFDM simulation over a real multipath channel,
% comparing BER vs Eb/N0 against an ideal (AWGN-only, no multipath) case.
%
% Pipeline per frame:
%   bits -> pam_mod -> x (N real symbols)
%        -> crip_ifft_tx -> s_FP (N real samples)
%        -> add_cp -> (N+Ncp samples)
%   [concatenate all frames into one continuous stream]
%        -> apply_channel (real FIR multipath h)
%        -> add_awgn
%   [split back into per-frame blocks]
%        -> remove_cp -> y (N samples)
%        -> crip_fft_rx (FFT, equalize by Lambda=fft(h,N), Re-Im) -> x_hat
%        -> pam_demod -> bits_hat
%   compare bits vs bits_hat -> BER

clear; clc;
addpath(pwd);

%% --- Simulation parameters ---
N      = 64;                 % number of subcarriers / IFFT size
Ncp    = 8;                 % cyclic prefix length (must be >= length(h)-1)
M      = 8;                  % PAM order -> k = log2(M) bits/symbol
k      = log2(M);
nFrames = 2000;               % number of OFDM frames per Eb/N0 point
EbN0_dB_range = 0:2:20;

% Real multipath channel impulse response (optical/VLC-style, real & causal).
% Normalized so sum(h)=1 (unit DC gain) to keep received power comparable
% across the "with multipath" and "AWGN-only" cases.
h_raw = [1, 0.4, 0.2];         % 3-tap real FIR channel
h = h_raw / sum(h_raw);
assert(Ncp >= length(h)-1, 'Ncp must be >= length(h)-1 to avoid inter-block ISI.');

Lambda = fft(h(:), N);        % channel eigenvalues for the single-tap equalizer
Lambda_ideal = ones(N,1);     % "no channel" equalizer for the AWGN-only case

berMultipath = zeros(size(EbN0_dB_range));
berAWGNonly  = zeros(size(EbN0_dB_range));

bitsPerFrame = N * k;

for idx = 1:length(EbN0_dB_range)
    EbN0_dB = EbN0_dB_range(idx);

    %% ---- Build all frames ----
    bitsAll = randi([0 1], bitsPerFrame * nFrames, 1);

    txStream = zeros(nFrames*(N+Ncp), 1);
    for f = 1:nFrames
        bitIdx = (f-1)*bitsPerFrame + (1:bitsPerFrame);
        x  = pam_mod(bitsAll(bitIdx), M);          % N real data symbols
        s  = crip_ifft_tx(x);                      % E-CRIP real time-domain block
        sc = add_cp(s, Ncp);                        % add cyclic prefix
        streamIdx = (f-1)*(N+Ncp) + (1:(N+Ncp));
        txStream(streamIdx) = sc;
    end

    %% ---- Case 1: real multipath channel + AWGN ----
    rMP = apply_channel(txStream, h);
    rMP = add_awgn(rMP, EbN0_dB, k);

    bitsHatMP = zeros(size(bitsAll));
    for f = 1:nFrames
        streamIdx = (f-1)*(N+Ncp) + (1:(N+Ncp));
        yblock = rMP(streamIdx);
        y = remove_cp(yblock, Ncp);
        x_hat = crip_fft_rx(y, Lambda);
        bitIdx = (f-1)*bitsPerFrame + (1:bitsPerFrame);
        bitsHatMP(bitIdx) = pam_demod(x_hat, M);
    end
    berMultipath(idx) = compute_ber(bitsAll, bitsHatMP);

    %% ---- Case 2: AWGN only (no multipath), sanity/reference case ----
    rAW = add_awgn(txStream, EbN0_dB, k);

    bitsHatAW = zeros(size(bitsAll));
    for f = 1:nFrames
        streamIdx = (f-1)*(N+Ncp) + (1:(N+Ncp));
        yblock = rAW(streamIdx);
        y = remove_cp(yblock, Ncp);
        x_hat = crip_fft_rx(y, Lambda_ideal);
        bitIdx = (f-1)*bitsPerFrame + (1:bitsPerFrame);
        bitsHatAW(bitIdx) = pam_demod(x_hat, M);
    end
    berAWGNonly(idx) = compute_ber(bitsAll, bitsHatAW);

    fprintf('Eb/N0 = %5.1f dB | BER (multipath) = %.3e | BER (AWGN only) = %.3e\n', ...
            EbN0_dB, berMultipath(idx), berAWGNonly(idx));
end

%% ---- Plot ----
figure;
semilogy(EbN0_dB_range, berAWGNonly, '-o', 'LineWidth', 1.5); hold on;
semilogy(EbN0_dB_range, berMultipath, '-s', 'LineWidth', 1.5);
grid on;
xlabel('E_b/N_0 (dB)');
ylabel('Bit Error Rate');
legend('E-CRIP, AWGN only', 'E-CRIP, multipath + single-tap equalizer', 'Location','southwest');
title(sprintf('E-CRIP OFDM BER, N=%d, M-PAM (M=%d), Ncp=%d', N, M, Ncp));
