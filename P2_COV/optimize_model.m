function [min_rmse, best_y_hat, modelf, best_x_optim_ent, best_x_optim_test,  best_x_optim_val, eliminated_regressors, minJ, p] = optimize_model(Y, X, clusters, num_iter)
% optimize_model: Función para optimizar un modelo mediante la eliminación iterativa de regresores.
%
% Entradas:
% Y: Matriz de salida de los datos.
% X: Matriz de entrada de los datos.
% clusters: Número de clusters utilizados para la creación del modelo.
% num_iter: Número de iteraciones para la eliminación de regresores.
%
% Salidas:
% min_rmse: Menor valor de la raíz cuadrada del error cuadrático medio (RMSE).
% y_hat: Vector de valores predichos.
% modelf: Modelo Takagi-Sugeno.
% best_x_optim_ent: Mejor matriz de entrada para los datos de entrenamiento.
% best_x_optim_test: Mejor matriz de entrada para los datos de prueba.
% eliminated_regressors: Vector que contiene los índices de los regresores eliminados.
% minJ: Vector que contiene los índices de los valores mínimos de la sensibilidad.
% p: Sensibilidad de los datos de prueba.

  % Crear celdas para almacenar gráficos temporales
    temp_bar_plots = cell(1, num_iter);
    temp_val_plots = cell(1, num_iter);
    % Inicializar las matrices x_optim_ent y x_optim_val utilizando num_iter
    
    x_optim_ent  = X.ent(:, 1:num_iter);
    x_optim_test = X.test(:, 1:num_iter);
    x_optim_val  = X.val(:, 1:num_iter);
    
    % Inicializar celdas para almacenar la historia de x_optim_ent, x_optim_test y y_hat
    x_optim_ent_hist  = cell(1, num_iter);
    x_optim_test_hist = cell(1, num_iter);
    x_optim_val_hist  = cell(1, num_iter);
    y_hat_hist = cell(1, num_iter);

    % Vector para almacenar los valores de la raíz cuadrada del error cuadrático medio
    rmse_values = zeros(1, num_iter);

    % Vector para almacenar los regresores eliminados
    eliminated_regressors = zeros(1, num_iter);

    % Vector de índices originales
    original_indices = 1:num_iter;
    % Vector para almacenar los regresores restantes
    regressors_remaining_cell = cell(1, num_iter);
    regressors_remaining_cell{1} = 1:num_iter;
    % Vector para almacenar los regresores restantes
    regressors_remaining = 1:num_iter;
    for iter = 1:num_iter
        % Guardar las matrices x_optim_ent y x_optim_test en sus respectivas celdas
        x_optim_ent_hist{iter} = x_optim_ent;
        x_optim_test_hist{iter}= x_optim_test;
        x_optim_val_hist{iter} =  x_optim_val;

        % Calcular la sensibilidad
            
        [p, indices] = sensibilidad(Y.test, x_optim_test, clusters);
        
        % Encontrar el índice del valor mínimo
        min_val = min(indices);
        min_idx = find(indices == min_val);
        minJ(iter) = min_idx;

        % Guardar el regresor eliminado
        eliminated_regressor = original_indices(min_idx(1));
        eliminated_regressors(iter) = eliminated_regressor;

        % Eliminar el índice de la lista de índices originales
        original_indices(min_idx) = [];
        
          % Actualizar los regresores restantes
        regressors_remaining = setdiff(regressors_remaining, eliminated_regressor);
        regressors_remaining_cell{iter+1} = regressors_remaining;

        
        % Entrenar el modelo
        [model, ~] = TakagiSugeno(Y.ent, x_optim_ent, clusters, [1 2 2]);
        
        % Realizar predicciones
        y_hat = ysim(x_optim_test, model.a, model.b, model.g);

        % Guardar y_hat en su celda
        y_hat_hist{iter} = y_hat;
        
        % Calcular la raíz cuadrada del error cuadrático medio y guardar en el vector
        rmse_values(iter) = sqrt(mean((Y.test-y_hat).^2));
        
        % Eliminar el valor mínimo de las matrices x_optim_ent y x_optim_val
        x_optim_ent(:, min_idx) = [];
        x_optim_test(:, min_idx) = [];
        x_optim_val(:, min_idx) = [];
        % Guardar gráficos de barras e índices de sensibilidad
        
            temp_bar_plots{iter} = indices;
      
        % Guardar gráficos de valores reales vs. valores esperados
   
            temp_val_plots{iter} = {Y.test, y_hat};
        
    end
    
    % Encontrar el índice del menor RMSE
    [~, min_rmse_idx] = min(rmse_values);

    % Recuperar las matrices x_optim_ent y x_optim_test correspondientes al menor RMSE
    best_x_optim_ent = x_optim_ent_hist{min_rmse_idx};
    best_x_optim_test = x_optim_test_hist{min_rmse_idx};
    best_x_optim_val = x_optim_val_hist{min_rmse_idx};
    
    [modelf, ~] = TakagiSugeno(Y.ent, best_x_optim_ent, clusters, [1 2 2]);

    % Recuperar y_hat correspondiente al menor RMSE
    best_y_hat = ysim(best_x_optim_val, modelf.a, modelf.b, modelf.g);

    % Devolver el menor RMSE
    min_rmse = rmse_values(min_rmse_idx);
    
    eliminated_regressors = eliminated_regressors(1,1:min_rmse_idx-1);
   

% Determinar la cantidad óptima de regresores
[~, min_rmse_idx] = min(rmse_values);
optimal_regressors = num_iter - min_rmse_idx + 1;

% Agregar gráficos de la cantidad óptima de regresores a las celdas
% temp_bar_plots{optimal_regressors} = {optimal_regressors, indices};
% temp_val_plots{optimal_regressors} = {optimal_regressors, Y.test, y_hat};

subplot_positions = [1, 2, 3, 4];
counter = 1;

for i = [1, 6, 11, min_rmse_idx]
    subplot(2, 2, subplot_positions(counter))
    bar(temp_bar_plots{i})
    xticks(1:length(regressors_remaining_cell{i}))
    xticklabels(regressors_remaining_cell{i})
    ylabel('Índice de sensibilidad')
    xlabel('Regresor')
    set(gcf, 'color', 'w');
    % Agregar leyenda solo en la última figura
    if i == min_rmse_idx
        legend('Pertenencia')
    end
    title(['RMSE = ' num2str(rmse_values(i)), ', Regresores: ' num2str(num_iter - i + 1)], 'FontSize', 12);
    grid on
    counter = counter + 1;
end

figure;

counter = 1;
for i = [1, 6, 11, min_rmse_idx]
    subplot(2, 2, subplot_positions(counter))
    plot(temp_val_plots{i}{1}, '.b')
    hold on
    plot(temp_val_plots{i}{2}, 'r')
    hold off
    legend('Valor real', 'Valor esperado')
    xlabel('Número de muestras', 'FontSize', 15)
    ylabel('Valores', 'FontSize', 15)
    set(gcf, 'color', 'w');
    grid on
    title(['Regresores: ' num2str(num_iter - i + 1)], 'FontSize', 'FontSize', 18);
    counter = counter + 1;
end

% Graficar el RMSE en función del tiempo (número de iteraciones)
figure()
plot(1:num_iter, rmse_values, '-o', 'LineWidth', 2)
hold on
plot(min_rmse_idx, rmse_values(min_rmse_idx), 'o', ...
     'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r')
hold off
xlabel('Regresores eliminados')
ylabel('RMSE')
set(gcf, 'color', 'w');
grid on
title('RMSE en función del tiempo (número de iteraciones)', 'FontSize', 16)
legend('RMSE', 'RMSE óptimo')

% Graficar el RMSE en función del tiempo (número de iteraciones)
figure()
plot(1:min_rmse_idx, rmse_values(1:min_rmse_idx), '-o', 'LineWidth', 2)
hold on
plot(min_rmse_idx, rmse_values(min_rmse_idx), 'o', ...
     'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r')
hold off
xlabel('Regresores eliminados')
ylabel('RMSE')
set(gcf, 'color', 'w');
grid on
title('RMSE en función del tiempo (número de iteraciones)', 'FontSize', 16)
legend('RMSE', 'RMSE óptimo')


end