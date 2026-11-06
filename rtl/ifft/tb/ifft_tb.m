clear; clc;

ifft_bins = 64;
fraction_bits = 12;
S = 2^fraction_bits;

rng(42); %for random generator

pam_levels = (-7:2:7)/8; % normailized with gray encoding
input_float = pam_levels(randi(numel(pam_levels),ifft_bins,1));

%Quantization of the input
input_int = roundTiesToEven(input_float*S);
input_quantized = double(input_int)/S;

%INPUT QUANTIZATION ERROR
error_input = input_quantized -  input_float;

input_max_error = max(abs(error_input));
input_rmse = sqrt(mean(abs(error_input).^2));

% IDEAL OUTPUT
output_float_ref = ifft(input_float, ifft_bins);

% QUANTIZED INPUT WITH FLOATING POINT IFFT
output_quantized_ref = ifft(input_quantized, ifft_bins);

%% FIXED POINT RTL_OUTPUT
rtl_int = readmatrix('ifft_rtl_output.csv');

ouput_rtl = (rtl_int(:,1)+ li*rtl_int(:,2))/S;

error_ifft = output_rtl - output_quantized_ref;

ifft_max_error = max(abs(error_ifft));
ifft_rmse = sqrt(mean(abs(error_ifft).^2));

%% Total error through the flow

total_error = output_rtl - output_float_ref;
total_max_error = max(abs(total_error));
total_error_rmse = sqrt(mean(abs(total_error).^2));

reference_rmse = sqrt(mean(abs(output_float_ref).^2));

if reference_rmse > 0
    total_evm_precent = 100 * total_error_rmse / reference_rmse;
else
    total_evm_precent = NaN;
end

%% Display the resutls
fprintf('\nINPUT QUANTIZATION');
fprintf('MAX ERROR = %.10g\n',input_max_error);
fprintf('RMSE = %.10g\n', input_rmse);

fprintf('\nIFFT IMPLEMENTATION ERROR');
fprintf('MAX ERROR = %.10g\n',ifft_max_error);
fprintf('RMSE = %.10g\n', ifft_rmse);

fprintf('\nTOTAL END TO END ERROR');
fprintf('MAX ERROR = %.10g\n',total_max_error);
fprintf('RMSE = %.10g\n', total_error_rmse);
fprintf('Total EVM     = %.6f %%\n', total_evm_percent);


fprintf('Total EVM     = %.6f %%\n', total_evm_percent);

figure;

subplot(3,1,1);
stem(abs(error_input));
title('Input Quantization Error');
ylabel('|e_x|');
grid on;

subplot(3,1,2);
stem(abs(error_ifft));
title('IFFT Implementation Error');
ylabel('|e_{IFFT}|');
grid on;

subplot(3,1,3);
stem(abs(total_error));
title('Total End-to-End Error');
ylabel('|e_{total}|');
xlabel('Sample index');
grid on;