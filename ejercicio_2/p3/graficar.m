function graficar(t_ode, X, U, ref)
    % Creamos una nueva figura con fondo blanco.
    figure('Color', 'w');
    
    % Gráfico de la salida del levitador magnético y la referencia.
    subplot(2, 1, 1);
    plot(t_ode, X(:, 1)*100, 'b', 'LineWidth', 2); 
    hold on;
    plot(t_ode, ref*ones(size(t_ode, 1))*100, 'r--', 'LineWidth', 2); 
    title('Salida del Levitador Magnético y Referencia', 'FontSize', 12);
    xlabel('Tiempo (s)', 'FontSize', 11);
    ylabel('Posición (cm)', 'FontSize', 11);
    legend('Salida', 'Referencia', 'FontSize', 11);
    grid on;
    
    % Gráfico de la señal de control U.
    subplot(2, 1, 2);
    plot(t_ode, U*100, 'k', 'LineWidth', 2); 
    title('Señal de Control', 'FontSize', 12);
    xlabel('Tiempo (s)', 'FontSize', 11);
    ylabel('U (cm)', 'FontSize', 11);
    grid on;
    
    % Ajustamos los espacios entre subplots
    set(gcf, 'Position', [50 50 800 600]);

    % Gráfico del error de control en una nueva figura.
    figure('Color', 'w');
    error = X(:,1)-ref;
    plot(t_ode, error*100, 'g', 'LineWidth', 2);
    title('Error de Control', 'FontSize', 12);
    xlabel('Tiempo (s)', 'FontSize', 11);
    ylabel('Error (cm)', 'FontSize', 11);
    grid on;
end
