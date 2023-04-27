function [e_rmse, e_mae,e_2] = rmse_mae(y_hat, y_val)
    
    e_m = zeros(length(y_hat));
    e_2 = zeros(length(y_hat));

    for i = 1:length(y_hat)
        e_m(i) = y_hat(i) - y_val(i);
        e_2(i) = (y_hat(i) - y_val(i))^2;
    end

    e_rmse = sqrt(sum(e_2)/length(y_hat));
    e_mae = mae(e_m);

    disp(['El RMSE del modelo es: ', num2str(e_rmse)])
    disp(['El MAE del modelo es: ', num2str(e_mae)])
    
    figure();clf
    tiledlayout(2,1)

    % Top plot
    nexttile
    plot(y_val, 'Linewidth', 2)
    hold on
    plot(y_hat, 'Linewidth', 2)
    title('Predicciones del modelo optimizado', 'FontSize', 18)
    xlabel('Tiempo [k]', 'FontSize', 15) 
    ylabel('Salida y[k]', 'FontSize', 15)
    legend('Salida Real', 'Salida Predicha')
    grid on
    ax = gca;
    ax.FontSize = 15;
    set(gcf,'color','w');
    
    % Bottom plot
    nexttile
    plot(e_2, 'Linewidth', 2)
    title('Zonas de error cuadrático en el tiempo')
    xlabel('Tiempo [k]', 'FontSize', 15) 
    ylabel('Error', 'FontSize', 15)
    grid on
    ax = gca;
    ax.FontSize = 15;
    set(gcf,'color','w');
end