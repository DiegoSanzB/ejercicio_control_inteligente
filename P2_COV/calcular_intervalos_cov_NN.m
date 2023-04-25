% X = x_optim_ent;
% 
% X_ = x_optim_test;
% 
% sigma = calcular_Cov_nn(net_optim_structure, X, X_); 
% 
% target_porcentaje = 0.95;
% 
% [alfa_optimo, alfas, porcentaje_datos] = calcular_alfa(y_hat_, Y.test', sigma'*0.1, target_porcentaje);

function [alfa_optimo, alfas, porcentaje_datos, y_upper, y_lower] = calcular_intervalos_cov_NN(x_optim_ent, x_optim_test, x_optim_val, net_optim_structure, Y, y_hat_ , y_hat, target_porcentaje)
    % Calcula el intervalo de confianza con base en la función de cobertura

    % Obtiene las predicciones
    X = x_optim_ent;
    X_ = x_optim_val;

    % Calcula la matriz de covarianza
    sigma = calcular_Cov_nn(net_optim_structure, X, X_);
    [alfa_optimo, alfas, porcentaje_datos] = calcular_alfa(y_hat, Y.val, sigma * 0.1, target_porcentaje);
    
        y_upper = y_hat + alfa_optimo * sigma * 0.1;
        y_lower = y_hat - alfa_optimo * sigma * 0.1;
        
        graficar_intervalos(Y.val', y_hat', y_upper', y_lower');
    
end
