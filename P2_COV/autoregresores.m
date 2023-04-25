function [y, x] = autoregresores(data, U, regs_y, regs_u)
n = length(data);
y = data(regs_y+1 :n);
x = zeros([n-regs_y, regs_y+regs_u]);

for i = 1:regs_y
    x(:, i) = data(regs_y - i + 1 :n - i);
end

for j = 1:regs_u
    x(:, regs_y + j) = U(:, regs_u - j + 1 :n - j);
end
end