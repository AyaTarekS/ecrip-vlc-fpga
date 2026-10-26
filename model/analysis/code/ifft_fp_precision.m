
%% IFFT precision sweep: multiple word widths and integer-bit allocations
clear; clc; close all;
rng(42);

word_widths = [8, 16, 24, 32];
int_bits_set = [1, 2, 3, 4];
N_values = [64, 128, 256];

M = 8;
Eavg = (M^2 - 1) / 3;
pam_levels = (-7:2:7) / sqrt(Eavg);

results = {};

for ni = 1:numel(N_values)
    N = N_values(ni);

    % Generate one common input for all configurations at this N.
    x_float = pam_levels(randi(numel(pam_levels), N, 1));

    y_ideal = ifft(x_float, N);
    ideal_rms = sqrt(mean(abs(y_ideal).^2));

    for wi = 1:numel(word_widths)
        W = word_widths(wi);

        for ii = 1:numel(int_bits_set)
            I = int_bits_set(ii);
            F = W - I;

            if F < 1
                continue;
            end

            S = 2^F;
            format_name = sprintf('Q%d.%d', I, F);

            % Signed W-bit integer-code limits
            code_min = -2^(W-1);
            code_max =  2^(W-1) - 1;

            % Representable numerical range and LSB
            min_value = code_min / S;
            max_value = code_max / S;
            lsb = 1 / S;

            % Quantization using round-to-nearest, ties-to-even
            x_int = roundTiesToEven(x_float * S);

            overflow_count = sum(x_int < code_min | x_int > code_max);

            % Saturate out-of-range inputs
            x_int_sat = min(max(x_int, code_min), code_max);
            x_quantized = x_int_sat / S;

            % Input quantization errors
            e_input = x_quantized - x_float;
            input_max_error = max(abs(e_input));
            input_rmse = sqrt(mean(abs(e_input).^2));

            % Floating-point IFFT with quantized input
            y_quantized = ifft(x_quantized, N);
            e_output = y_quantized - y_ideal;

            output_max_error = max(abs(e_output));
            output_rmse = sqrt(mean(abs(e_output).^2));

            if ideal_rms > 0
                evm_percent = 100 * output_rmse / ideal_rms;
            else
                evm_percent = NaN;
            end

            results(end+1,:) = { ...
                N, W, I, F, format_name, ...
                min_value, max_value, lsb, overflow_count, ...
                input_max_error, input_rmse, ...
                output_max_error, output_rmse, evm_percent};
        end
    end
end

%% Results table and CSV
T = cell2table(results, 'VariableNames', { ...
    'IFFT_N', 'WordBits', 'IntBits', 'FracBits', ...
    'Format', 'MinValue', 'MaxValue', 'LSB', ...
    'OverflowCount', 'InputMaxError', 'InputRMSE', ...
    'OutputMaxError', 'OutputRMSE', 'EVM_Percent'});

disp(T);
writetable(T, 'ifft_precision_sweep_all_widths.csv');

%% Print every tested representation
fprintf('\n===== Fixed-Point Configurations =====\n');

for wi = 1:numel(word_widths)
    W = word_widths(wi);

    fprintf('\nTotal word width: %d bits\n', W);

    for ii = 1:numel(int_bits_set)
        I = int_bits_set(ii);
        F = W - I;

        fprintf('  Q%d.%d | W=%d, I=%d, F=%d | ', ...
            I, F, W, I, F);
        fprintf('Range=[%.8f, %.8f], LSB=%.3e\n', ...
            -2^(I-1), 2^(I-1)-2^(-F), 2^(-F));
    end
end

%% Figures: one per integer-bit allocation
for ii = 1:numel(int_bits_set)
    I = int_bits_set(ii);

    figure('Name', sprintf('I=%d', I), 'NumberTitle', 'off');
    tiledlayout(1, 3);

    for ni = 1:numel(N_values)
        N = N_values(ni);
        nexttile;

        hold on;
        for wi = 1:numel(word_widths)
            W = word_widths(wi);
            idx = T.IFFT_N == N & ...
                  T.WordBits == W & T.IntBits == I;

            if any(idx)
                plot(T.WordBits(idx), T.OutputRMSE(idx), ...
                    'o', 'MarkerSize', 7, ...
                    'DisplayName', sprintf('%d-bit', W));
            end
        end

        % One point per width: sort before connecting the curve.
        idx = T.IFFT_N == N & T.IntBits == I;
        subT = sortrows(T(idx,:), 'WordBits');

        plot(subT.WordBits, subT.OutputRMSE, '-');

        set(gca, 'YScale', 'log');
        grid on;
        xticks(word_widths);
        xlabel('Total word width (bits)');
        ylabel('Output RMSE');
        title(sprintf('N = %d', N));
    end

    sgtitle(sprintf('Fixed-Point Precision Sweep: I = %d Integer Bits', I));
end

%% Round to nearest, ties to even function
function y = roundTiesToEven(x)
    lower = floor(x);
    fraction = x - lower;

    y = lower + (fraction > 0.5);

    tie = (fraction == 0.5);
    lower_even = (mod(lower, 2) == 0);

    y(tie & ~lower_even) = lower(tie & ~lower_even) + 1;
end


%% Find and print minimum values
% Requires the results table T created earlier.

metrics = { ...
    'InputMaxError', ...
    'InputRMSE', ...
    'OutputMaxError', ...
    'OutputRMSE', ...
    'EVM_Percent'};

fprintf('\n========== GLOBAL MINIMUM RESULTS ==========\n');

% Store the global minimum of each metric
globalSummary = cell(numel(metrics), 6);

for k = 1:numel(metrics)
    metric = metrics{k};
    values = T.(metric);

    % Ignore NaN and Inf values
    valid = isfinite(values);

    if ~any(valid)
        fprintf('%s: No valid values found.\n', metric);
        continue;
    end

    validRows = find(valid);
    [minValue, localIdx] = min(values(valid));
    bestRow = validRows(localIdx);

    fprintf('\nMetric: %s\n', metric);
    fprintf('  Minimum value : %.12g\n', minValue);
    fprintf('  IFFT size     : %d\n', T.IFFT_N(bestRow));
    fprintf('  Word width    : %d bits\n', T.WordBits(bestRow));
    fprintf('  Format        : %s\n', T.Format{bestRow});
    fprintf('  Integer bits  : %d\n', T.IntBits(bestRow));
    fprintf('  Fraction bits : %d\n', T.FracBits(bestRow));

    globalSummary(k,:) = { ...
        metric, minValue, T.IFFT_N(bestRow), ...
        T.WordBits(bestRow), T.Format{bestRow}, ...
        T.FracBits(bestRow)};
end

globalMinTable = cell2table(globalSummary, ...
    'VariableNames', {'Metric', 'MinimumValue', ...
    'IFFT_N', 'WordBits', 'Format', 'FracBits'});

disp(globalMinTable);

%% Minimum output RMSE for each IFFT size
fprintf('\n========== BEST FORMAT FOR EACH IFFT SIZE ==========\n');

bestPerN = table();

for ni = 1:numel(N_values)
    N = N_values(ni);
    idx = T.IFFT_N == N;

    subT = T(idx,:);
    [minRMSE, rowIdx] = min(subT.OutputRMSE);
    bestRow = subT(rowIdx,:);

    fprintf(['N=%d: Minimum output RMSE = %.12g, ', ...
        'Format = %s, Word width = %d bits\n'], ...
        N, minRMSE, bestRow.Format{1}, bestRow.WordBits(1));

    bestPerN = [bestPerN; bestRow];
end

disp(bestPerN(:, {'IFFT_N','WordBits','Format', ...
    'OutputRMSE','OutputMaxError','EVM_Percent'}));

%% Save everything to an Excel workbook
excelFile = 'ifft_precision_results.xlsx';

writetable(T, excelFile, 'Sheet', 'All Results');
writetable(globalMinTable, excelFile, 'Sheet', 'Global Minima');
writetable(bestPerN, excelFile, 'Sheet', 'Best Per IFFT Size');

fprintf('\nExcel workbook saved as:\n%s\n', ...
    fullfile(pwd, excelFile));
