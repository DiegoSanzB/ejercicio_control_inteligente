function [e_real] = rmse_real(F,A)
    n = length(F);
    e = 0;
    for i = 1:n
        e = (F(i) - A(i))^2;
    end
    e_real = sqrt(e/n);
end