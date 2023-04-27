clear all
close all
clc

%% Creamos datos y los ploteamos

U2 = readmatrix('APRBS.csv');
data = generate_data(0, 0, U2);

figure()
plot(data)
grid on
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
clusters = 6; % numero de clusters elegido anteriormente
num_iter = 20; % Número de iteraciones
[rmse_values,y_hat,model,x_optim_ent, x_optim_test, x_optim_val, eliminated_regressors,minJ] = optimize_model(Y, X, clusters, num_iter);
y_hat_ = ysim(x_optim_test, model.a, model.b, model.g);

%% Calculo del intervalo difuso con el método de la covarianza

target_porcentaje_alfa = 0.95;
[alfa_optimo, alfas, porcentaje_datos,I,I_] = calcular_metricas(x_optim_ent, x_optim_test, x_optim_val, model, Y, y_hat_,y_hat,target_porcentaje_alfa);