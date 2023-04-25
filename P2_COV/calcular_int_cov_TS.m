function [alfa_optimo, alfas, porcentaje_datos,I,I_] = calcular_int_cov_TS(x_optim_ent, x_optim_test, x_optim_val, model, Y, y_hat_,y_hat,target_porcentaje)

    X = calcular_h(x_optim_ent, model.b, model.a);
    X_ = calcular_h(x_optim_test, model.b, model.a);
    Y_h = calcular_h(Y.test, model.b, model.a);
    error = y_hat_ - Y.test;
    [delta_y, sigma] = calcular_Cov_fuzzy(X, X_, model.g, Y_h, error);
    I = calculo_izk(delta_y, X_);
   [alfa_optimo, alfas, porcentaje_datos] = calcular_alfa(y_hat_, Y.test, I, target_porcentaje);
    X_2 = calcular_h(x_optim_val, model.b, model.a);
    Y_h2 = calcular_h(Y.val, model.b, model.a);
    [delta_y_] = calcular_Cov_fuzzy(X, X_2, model.g, Y_h2, error, sigma);
    I_ = calculo_izk(delta_y_, X_2);
    
    %y_hat - Y.val

    % Imprimimos el valor óptimo de alfa
    disp(['El valor óptimo de alfa es ', num2str(alfa_optimo)]);
    

        y_upper = y_hat + alfa_optimo * I_;
        y_lower = y_hat - alfa_optimo * I_;
        
        graficar_intervalos(Y.val, y_hat, y_upper, y_lower);

        
end

