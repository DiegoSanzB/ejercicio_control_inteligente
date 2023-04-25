function graficar_intervalos(Y, Y_, y_upper, y_lower)
    x = 1:length(Y);

    % Graficar los datos reales Y
    figure;
    plot(x, Y, 'o', 'MarkerSize', 1.5, 'MarkerEdgeColor', 'blue', 'MarkerFaceColor', 'blue', 'DisplayName', 'Y (datos reales)');

    hold on;
%     
%     % Graficar las predicciones Y_
%     plot(x, Y_, 'x', 'MarkerSize', 2, 'MarkerEdgeColor', 'red', 'DisplayName', 'Y_ (predicciones)');

    % Transponer y_upper y y_lower si es necesario
    if size(y_upper, 1) == 1
        y_upper = y_upper';
        y_lower = y_lower';
    end

    % Rellenar el área entre el límite superior e inferior del intervalo de confianza
    x_fill = [x, fliplr(x)];
    y_fill = [y_lower', fliplr(y_upper')];
    fill(x_fill, y_fill, 'black', 'FaceAlpha', 0.3, 'EdgeColor', 'red','EdgeAlpha', 0.3, 'DisplayName', 'Intervalo de confianza');
    % Configurar el título, los ejes y la leyenda
    xlabel('Tiempo [k]','FontSize', 15)
    ylabel('Salida y(k)','FontSize', 15)
    title('Comparación de datos reales e intervalo de confianza, método covarianza','FontSize', 18);
    legend('show');
    grid on;
    set(gcf,'color','w');
    hold off;
end


