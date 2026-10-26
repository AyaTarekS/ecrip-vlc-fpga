function y = add_cp(x, Ncp)
%ADD_CP  Prepend a cyclic prefix to a block.
%
%   y = ADD_CP(x, Ncp)
%
%   Inputs:
%     x   - column/row vector, length N (one OFDM time-domain block)
%     Ncp - cyclic prefix length (0 <= Ncp < N)
%   Output:
%     y   - column vector, length N+Ncp: the last Ncp samples of x,
%           followed by all of x.

    x = x(:);
    N = length(x);
    if Ncp < 0 || Ncp >= N
        error('add_cp:invalidNcp', 'Ncp must satisfy 0 <= Ncp < N.');
    end
    y = [x(end-Ncp+1:end); x];
end
