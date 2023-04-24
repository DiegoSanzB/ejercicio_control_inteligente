clear all
close all
clc

%% Creamos datos y los ploteamos

addpath("C:\Users\mp204\OneDrive\Desktop\2023\Control Inteligente\ejercicio_control_inteligente-ejercicio_1\ejercicio_control_inteligente-ejercicio_1\Toolbox TS NN\Toolbox difuso")
addpath("C:\Users\mp204\OneDrive\Desktop\2023\Control Inteligente\ejercicio_control_inteligente-ejercicio_1\ejercicio_control_inteligente-ejercicio_1\P2_COV")


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
[alfa_optimo, alfas, porcentaje_datos,I,I_] = calcular_int_cov_TS(x_optim_ent, x_optim_test, x_optim_val, model, Y, y_hat_,y_hat,target_porcentaje_alfa);

%% Método de Números Difusos
addpath('fuzzy_ts')
s = fuzzy_numbers(model,x_optim_val,Y,100,200,0.1);
n = length(s);    
s_l = s(1:n/2);
s_u = s(n/2+1:end);

[y_hat_lower, y_hat_upper] = ysim_lower_upper(x_optim_val, model.a, model.b, model.g, s_l, s_u);

%% Ploteamos predicción con intervalos
figure()
x = 1: length(Y.val);
plot(Y.val, '.b');
hold on
plot(y_hat_lower, 'k', 'LineWidth', .1);
hold on
plot(y_hat_upper, 'k', 'LineWidth', .1);
x2 = [x, fliplr(x)];
inBetween = [y_hat_lower', fliplr(y_hat_upper')];
fill(x2, inBetween, 'black', 'FaceAlpha', 0.3, 'EdgeColor', 'red', 'EdgeAlpha', 0.2, 'DisplayName', 'Intervalo de confianza');

xlabel('Tiempo [k]')
ylabel('Salida y(k)')
set(gcf, 'color', 'w');
grid on
title('Comparación de datos reales e intervalo de confianza, método de números difusos');
legend('show');
legend('Valor real', 'Intervalo de confianza')
% PINAW y PICP
compute_pinaw(model, x_optim_val, Y, s_l, s_u)
compute_picp(model, x_optim_val, Y, s_l, s_u)