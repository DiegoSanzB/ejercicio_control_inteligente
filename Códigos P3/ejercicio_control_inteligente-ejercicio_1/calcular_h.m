function h = calcular_h(X, mu_barra, sigma)

    % Esta función calcula el grado de activación normalizado de las reglas
    % Entradas: X (datos de entrada), mu_barra (centros de las funciones de membresía), sigma (anchos de las funciones de membresía)
    % Salida: h (grados de activación normalizados)

    num_datos  = size(X, 1);
    num_reglas = size(mu_barra, 1);
    num_regres = size(X, 2);

    h = zeros(num_regres, num_datos, num_reglas);

    for i = 1:num_datos
        for j = 1:num_reglas
            sum_activacion = 0;
            for r = 1:num_regres
                activacion = exp(-0.5 * ((X(i, r) - mu_barra(j, r)) / sigma(j, r))^2);
                h(r, i, j) = activacion;
                sum_activacion = sum_activacion + activacion;
            end
            h(:, i, j) = h(:, i, j) / sum_activacion;
        end
    end
end
