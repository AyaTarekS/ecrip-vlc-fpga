
clear; clc;

%% Configuration
N = 64;
M = 8;

Eavg = (M^2 - 1) / 3;
pam_levels = single((-7:2:7) / sqrt(Eavg));

rng(42);

%% Generate real-valued 8-PAM input samples
idx = randi(numel(pam_levels), N, 1);
x_float = pam_levels(idx);

% Convert to single precision for the float32 HLS IP
input = complex(single(x_float), zeros(size(x_float,1), 1, 'single'));

fprintf('Theoretical average energy: %.8f\n', Eavg / Eavg);
fprintf('Actual average energy     : %.8f\n', mean(abs(input).^2));
fprintf('Energy error              : %.8f\n', abs(mean(abs(input).^2) - 1));

%% Write input vectors as 64-bit hexadecimal words
% Assumed layout:
%   bits [31:0]  = real float32
%   bits [63:32] = imaginary float32
%
% Each line contains one complex sample (8 bytes).

%% Verify input generation

fprintf('\n========== INPUT VERIFICATION ==========\n');

fprintf('Number of samples : %d\n', length(input));
fprintf('Data type         : %s\n', class(real(input)));
fprintf('Average power     : %.8f\n', mean(abs(input).^2));
fprintf('Imaginary max     : %.8f\n', max(abs(imag(input))));

fprintf('\n8-PAM levels:\n');
disp(pam_levels.');

assert(length(input) == N, 'Incorrect input length');
assert(all(imag(input) == 0), 'Input is not real-valued');
assert(abs(mean(abs(pam_levels).^2) - 1) < 1e-6, ...
    '8-PAM constellation is not normalized');

fid = fopen('ifft_input_vectors.mem', 'w');
assert(fid >= 0, 'Cannot open input file');

for k = 1:N
    real_bits = typecast(real(input(k)), 'uint32');
    imaginary_bits = typecast(imag(input(k)), 'uint32');

    word = bitor(bitshift(uint64(imaginary_bits), 32), ...
                 uint64(real_bits));

    fprintf(fid, '%016X\n', word);
end

fclose(fid);


%% Verify generated hexadecimal input file

fid = fopen('ifft_input_vectors.mem', 'r');
assert(fid >= 0, 'Cannot reopen input file');

C = textscan(fid, '%s');
fclose(fid);

assert(numel(C{1}) == N, 'Incorrect number of input words');

for k = 1:N

    word = C{1}{k};

    assert(length(word) == 16, ...
        'Invalid input word length at sample %d', k);

    % Upper 32 bits = imaginary
    % Lower 32 bits = real
    imag_bits = uint32(hex2dec(word(1:8)));
    real_bits = uint32(hex2dec(word(9:16)));

    real_check = typecast(real_bits, 'single');
    imag_check = typecast(imag_bits, 'single');

    assert(real_check == real(input(k)), ...
        'Real input mismatch at sample %d', k);

    assert(imag_check == imag(input(k)), ...
        'Imaginary input mismatch at sample %d', k);

end

disp('PASS: Input file packing and values verified.');

%% MATLAB reference: unnormalized 64-point IFFT
% HLS kernel convention: inverse IFFT has no 1/N normalization.
reference_out = single(N) * ifft(input);

%% Save reference data
save('ifft_reference.mat', 'input', 'reference_out', 'N', ...
     'M', 'pam_levels', 'Eavg');

disp('Generated ifft_input_vectors.mem and ifft_reference.mat');
disp('Input format: one 64-bit hexadecimal word per complex sample');
disp('Reference: unnormalized IFFT, MATLAB complex single precision');
