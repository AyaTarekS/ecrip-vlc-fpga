function x = remove_cp(y, Ncp)
%REMOVE_CP  Strip the cyclic prefix from a received block.
%
%   x = REMOVE_CP(y, Ncp)
%
%   Inputs:
%     y   - column/row vector, length N+Ncp
%     Ncp - cyclic prefix length that was added at the transmitter
%   Output:
%     x   - column vector, length N: y with the first Ncp samples removed

    y = y(:);
    if Ncp < 0 || Ncp >= length(y)
        error('remove_cp:invalidNcp', 'Ncp must satisfy 0 <= Ncp < length(y).');
    end
    x = y(Ncp+1:end);
end
