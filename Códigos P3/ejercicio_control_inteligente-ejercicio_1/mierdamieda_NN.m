X = x_optim_ent;

X_ = x_optim_test;

sigma = calcular_Cov_nn(net_optim_structure, X, X_); 

target_porcentaje = 0.95;

[alfa_optimo, alfas, porcentaje_datos] = calcular_alfa(y_hat_, Y.test', sigma'*0.1, target_porcentaje);

