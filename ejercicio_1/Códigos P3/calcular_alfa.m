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

% x = 1:length(Y_);

%     % Graficar los datos reales Y
%     figure;
%     plot(x, Y, 'o', 'MarkerSize', 1.5, 'MarkerEdgeColor', 'blue', 'MarkerFaceColor', 'blue', 'DisplayName', 'Y (datos reales)');
% 
%     hold on;
% 
%     % Graficar las predicciones Y_
%     plot(x, Y_, 'x', 'MarkerSize', 1, 'MarkerEdgeColor', 'red', 'DisplayName', 'Y_ (predicciones)');
% 
%     % Transponer y_upper y y_lower si es necesario
%     if size(y_upper, 1) == 1
%         y_upper = y_upper';
%         y_lower = y_lower';
%     end
% 
%     % Rellenar el área entre el límite superior e inferior del intervalo de confianza
%     x_fill = [x, fliplr(x)];
%     y_fill = [y_lower', fliplr(y_upper')];
%     fill(x_fill, y_fill, 'C', 'FaceAlpha', 0.2, 'EdgeColor', 'R', 'DisplayName', 'Intervalo de confianza');
% 
%     % Configurar el título, los ejes y la leyenda
%     xlabel('Índice');
%     ylabel('Valor');
%     title('Comparación de datos reales, predicciones e intervalo de confianza');
%     legend('show');
%     grid on;
%     hold off;

    % Crear una nueva figura para el gráfico de alfa vs porcentaje de cobertura
    figure;
    plot(alfas, porcentaje_datos_vec, 'o-', 'MarkerSize', 1.5, 'MarkerEdgeColor', 'blue', 'MarkerFaceColor', 'blue', 'DisplayName', 'Alfa vs Porcentaje de cobertura', 'LineWidth', 2);
    xlabel('Alfa');
    ylabel('Porcentaje de cobertura');
    title('Relación entre Alfa y Porcentaje de cobertura');
    legend('show');
    grid on;

end