function [dy, sigma] = calcular_Cov_fuzzy(X, X_, g, Y, error, sigma_fijo)

    %X  h_ent
    %X_ h_val

    N = size(X_, 2);
    num_reglas = size(g, 1);
    num_reg = size(g,2);
    cov = zeros(N,num_reglas);
    dy = zeros(N,num_reglas);
    sigma = zeros(1,num_reg);

    %i mediciones
    %j reglas

    for j = 1:num_reglas
        sum_e = 0;
        sum_ = 0;
        sum_u = 0;

        for i = 1:N
            cov(i,j) = 1 - X_(:,i,j)' * inv(X(:,:,j) * X(:,:,j)') * X_(:,i,j);

            sum_e = sum_e + Y(:,i,j) * error(i);
            sum_ = sum_ + Y(:,i,j);
            sum_u = sum_u + Y(:,i,j)^2;
        end

      e_ = sum_e/sum_;
%         e_ = sum_e;

        % Si se proporciona sigma_fijo, utilice ese valor como sigma_j y no calcule sigma_j
        if nargin == 6
            sigma_j = sigma_fijo(j);
        else
            sigma_j = 0;
            for i = 1:N
                sigma_j = sigma_j + Y(:,i,j)^2 * (error(i) - e_)^2;
            end
            sigma_j = sigma_j / (sum_u-1 - (num_reg + 1)*num_reglas);
        end

        sigma(j) = sigma_j;
        dy(:,j) = cov(:,j) .* sigma_j;
    end
end


