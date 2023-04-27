% 
% X = calcular_h(x_optim_ent, model.b, model.a);
% 
% X_ = calcular_h(x_optim_test, model.b, model.a);
% 
% Y_h = calcular_h(Y.test, model.b, model.a);
% 
% error = y_hat_ - Y.test;
% 
% [delta_y, sigma] = calcular_Cov_fuzzy(X, X_ ,model.g,Y_h, error);
% 
% I = funcion2(delta_y, X_);
% 
% target_porcentaje = 0.95;
% 
% [alfa_optimo , alfas , porcentaje_datos] = calcular_alfa(y_hat_, Y.test, I, target_porcentaje); 
% 
% X_2 = calcular_h(x_optim_val, model.b, model.a);
% 
% Y_h2 = calcular_h(Y.val, model.b, model.a);
% 
% [delta_y_] = calcular_Cov_fuzzy(X, X_2 ,model.g,Y_h2, error,sigma);
% 
% I_ = funcion2(delta_y_,X_2);
% 
% % Imprimimos el valor óptimo de alfa
% disp(['El valor óptimo de alfa es ', num2str(alfa_optimo)]);


function [alfa_optimo, alfas, porcentaje_datos] = calcular_metricas(x_optim_ent, x_optim_test, x_optim_val, model, Y)

    X = calcular_h(x_optim_ent, model.b, model.a);
    X_ = calcular_h(x_optim_test, model.b, model.a);
    Y_h = calcular_h(Y.test, model.b, model.a);
    error = y_hat_ - Y.test;
    [delta_y, sigma] = calcular_Cov_fuzzy(X, X_, model.g, Y_h, error);
    I = funcion2(delta_y, X_);
    target_porcentaje = 0.95;
    [alfa_optimo, alfas, porcentaje_datos] = calcular_alfa(y_hat_, Y.test, I, target_porcentaje);
    X_2 = calcular_h(x_optim_val, model.b, model.a);
    Y_h2 = calcular_h(Y.val, model.b, model.a);
    [delta_y_] = calcular_Cov_fuzzy(X, X_2, model.g, Y_h2, error, sigma);
    I_ = funcion2(delta_y_, X_2);

    % Imprimimos el valor óptimo de alfa
    disp(['El valor óptimo de alfa es ', num2str(alfa_optimo)]);
end

