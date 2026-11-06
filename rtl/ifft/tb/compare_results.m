clear; clc;

%% Load MATLAB reference
load('ifft_reference.mat', 'reference_out', 'N');

reference_out = reference_out(:);

%% Read RTL output file
fid = fopen('C:\Users\ayata\ecrip-vlc-fpga\rtl\ifft\results\ifft_output_vectors.txt', 'r');
assert(fid >= 0, 'Cannot open output file');

C = textscan(fid, '%s %s');
fclose(fid);

assert(numel(C{1}) == N && numel(C{2}) == N, ...
    'Expected exactly N output samples');

%% Decode RTL output
% File column 1 = REAL [31:0]
% File column 2 = IMAG [63:32]

y_hw = complex(zeros(N,1,'single'));

for k = 1:N

    re_hex = strtrim(C{1}{k});
    im_hex = strtrim(C{2}{k});

    assert(length(re_hex) == 8 && length(im_hex) == 8, ...
        'Invalid output format at sample %d', k);

    re_bits = uint32(hex2dec(re_hex));
    im_bits = uint32(hex2dec(im_hex));

    re_value = typecast(re_bits, 'single');
    im_value = typecast(im_bits, 'single');

    y_hw(k) = complex(re_value, im_value);

end

%% Calculate bit-reversed index
LOGN = log2(N);
bitrev = zeros(N,1);

for k = 0:N-1
    b = 0;
    for j = 0:LOGN-1
        b = 2*b + bitget(k,j+1);
    end
    bitrev(k+1) = b+1;
end

%% Compare output orders

% Bit-reversed order

y_hw = y_hw(bitrev);

err = double(y_hw) - double(reference_out);

% Maximum absolute error per bin
max_error = abs(err);

% EVM per bin, normalized to the reference magnitude
evm_per_bin = zeros(N,1);

for k = 1:N

    if abs(reference_out(k)) > 0
        evm_per_bin(k) = 100 * abs(err(k)) / abs(reference_out(k));
    else
        evm_per_bin(k) = NaN;
    end

    fprintf('Bin %2d | Max error: %.9g | EVM: %.9f %%\n', ...
        k-1, max_error(k), evm_per_bin(k));

end

%% Overall metrics

rmse = sqrt(mean(abs(err).^2));
ref_rms = sqrt(mean(abs(double(reference_out)).^2));
overall_evm = 100 * rmse / ref_rms;

fprintf('\n========== OVERALL RESULTS ==========\n');
fprintf('Maximum absolute error: %.9g\n', max(max_error));
fprintf('RMSE                  : %.9g\n', rmse);
fprintf('Overall EVM           : %.9f %%\n', overall_evm);