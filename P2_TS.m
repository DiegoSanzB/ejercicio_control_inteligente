clear
clc

addpath("Toolbox TS NN")

%% Creamos datos y los ploteamos

U = generate_aprbs(0.01, 100, 0.5, 5, -2, 2);
U2 = U + normrnd(0,0.1,[1, 10001]);
data = generate_data(0, 0, U2);

figure()
plot(data)
title('Datos generados con APRBS')
xlabel('Muestras')
ylabel('y(k)')
%% Parametros del modelo

max_regs = 10;
max_clusters = 10;
porcentajes = [60 20 20]; % entrenamiento validación test

[y, x] = autoregresores(data, U2, max_regs, max_regs);

[Y.ent, Y.test, Y.val, X.ent, X.test, X.val] = separar_datos(y, x, porcentajes);

%% Optimizar modelo - Reglas
[err_test, err_ent] = clusters_optimo(Y.test, Y.ent, X.test, X.ent, max_clusters);
figure()
plot(err_test, 'b')
hold on
plot(err_ent, 'r')
legend('Error de test', 'Error de entrenamiento')

%% Optimizar modelo - Regresores
clusters = 8; % numero de clusters elegido anteriormente
[p, indices] = sensibilidad(Y.ent, X.ent, clusters);

% Elijo los primeros 3 regresores a partir del analisis anterior
x_optim_ent = X.ent(:, [1 2 3 4 11 12 13]);
x_optim_val = X.val(:, [1 2 3 4 11 12 13]);

%% Entrenar modelo
[model, ~] = TakagiSugeno(Y.ent, x_optim_ent, clusters, [1 2 2]);

%% Predicciones
y_hat = ysim(x_optim_val, model.a, model.b, model.g);

figure()
plot(Y.val, '.b')
hold on 
plot(y_hat, 'r')

legend('Valor real', 'Valor esperado')



