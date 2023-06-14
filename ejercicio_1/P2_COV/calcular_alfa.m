function [alfa,alfas,porcentaje_datos_vec] = calcular_alfa(Y_, Y, Izk, target_porcentaje)
    % Itera para encontrar el mejor valor de alfa hasta encontrar
    % una diferencia con los datos de entrenamiento del Y%

    % Inicializa alfa y porcentaje
    alfa = 0;
    porcentaje_datos = 0;

    % Reemplaza X con el valor deseado del porcentaje (por ejemplo, 0.95)

    % Inicializa los vectores para almacenar los valores de alfa y porcentaje_datos
    alfas = [];
    porcentaje_datos_vec = [];

    % Itera para encontrar el mejor alfa
    while porcentaje_datos < target_porcentaje
        % Actualiza alfa
        alfa = alfa + 0.1; % Ajusta el incremento de alfa según sea necesario

        % Calcular la diferencia 
        y_upper = Y_ + alfa * Izk;
        y_lower = Y_ - alfa * Izk;

        % Encuentra los índices de los datos dentro del intervalo
        idx = (Y >= y_lower & (Y <= y_upper));

        % Calcula el porcentaje de datos dentro del intervalo
        porcentaje_datos = sum(idx) / length(Y);

        % Almacena los valores de alfa y porcentaje_datos en los vectores correspondientes
        alfas = [alfas, alfa];
        porcentaje_datos_vec = [porcentaje_datos_vec, porcentaje_datos];
    end

    % Crear una nueva figura para el gráfico de alfa vs porcentaje de cobertura
    figure;
    plot(alfas, porcentaje_datos_vec, 'o-', 'MarkerSize', 1.5, 'MarkerEdgeColor', 'blue', 'MarkerFaceColor', 'blue', 'DisplayName', 'Alfa vs Porcentaje de cobertura', 'LineWidth', 2);
    xlabel('Alfa','FontSize', 15);
    ylabel('Porcentaje de cobertura','FontSize', 15);
    title('Relación entre Alfa y Porcentaje de cobertura','FontSize', 18');
    legend('show');
    grid on;
end