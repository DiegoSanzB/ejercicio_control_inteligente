clear all
close all
clc

%% Creamos datos y los ploteamos

addpath("Toolbox TS NN\Toolbox difuso")
addpath("P2_COV")

% Generamos data
% U = generate_aprbs(0.01, 100, 0.5, 5, -2, 2);
% U2 = U + normrnd(0,0.1,[1, 10001]);

% Cargamos data
U2 = readmatrix('APRBS.csv');
data = generate_data(0, 0, U2);

% Gráfico de U2 a la izquierda
figure()
plot(U2(1:2000));
grid on;
title('APRBS', 'FontSize', 18);
xlabel('Muestras', 'FontSize', 15);
ylabel('Amplitud', 'FontSize', 15);
ax1 = gca;
ax1.FontSize = 15;
set(gcf, 'color', 'w');
figure
% Gráfico de data a la derecha, mostrando solo 2000 datos

plot(data(1:2000));
grid on;
title('Datos generados con APRBS', 'FontSize', 18);
xlabel('Muestras', 'FontSize', 15);
ylabel('y(k)', 'FontSize', 15);
ax2 = gca;
ax2.FontSize = 15;

set(gcf, 'color', 'w');


%% Parametros del modelo
max_regs = 10;
max_clusters = 10;
porcentajes = [60 20 20]; % entrenamiento validación test

[y, x] = autoregresores(data, U2, max_regs, max_regs);

[Y.ent, Y.test, Y.val, X.ent, X.test, X.val] = separar_datos(y, x, porcentajes);

%% Optimizar modelo - Reglas
[err_test, err_ent] = clusters_optimo(Y.test, Y.ent, X.test, X.ent, max_clusters);
figure()
plot(err_test, 'b','LineWidth', 2)
hold on
plot(err_ent, 'r','LineWidth', 2)

% Encontrar el punto más bajo del gráfico de error de test y agregar un círculo
[min_error_test, idx_optimo] = min(err_test);
plot(idx_optimo, min_error_test, 'bo', 'MarkerSize', 10, 'LineWidth', 2, 'MarkerFaceColor', 'b');

title('Error de test y entrenamiento', 'FontSize', 18)
xlabel('Número de reglas', 'FontSize', 15)
ylabel('Error', 'FontSize', 15)

% Agregar el número de reglas óptimo en la leyenda
legend('Error de test', 'Error de entrenamiento', sprintf('Reglas óptimas = %d', idx_optimo))

ax = gca;
ax.FontSize = 15;
grid on
set(gcf,'color','w');

%% Optimizar modelo - Regresores
clusters = 6; % numero de clusters elegido anteriormente
num_iter = 20; % Número de iteraciones
[rmse_values,y_hat,model,x_optim_ent, x_optim_test, x_optim_val, eliminated_regressors,minJ] = optimize_model(Y, X, clusters, num_iter);
y_hat_ = ysim(x_optim_test, model.a, model.b, model.g);

%% Calculo del intervalo difuso con el método de la covarianza
target_porcentaje_alfa = 0.90;
[alfa_optimo, alfas, porcentaje_datos,I,I_] = calcular_int_cov_TS(x_optim_ent, x_optim_test, x_optim_val, model, Y, y_hat_,y_hat,target_porcentaje_alfa);

%% Predicciones a 1,8 y 16 pasos
pred_alfa(X,Y,5,1,eliminated_regressors,0.9,x_optim_ent,x_optim_test,x_optim_val,model, 1);
pred_alfa(X,Y,5,8,eliminated_regressors,0.9,x_optim_ent,x_optim_test,x_optim_val,model, 1);
pred_alfa(X,Y,5,16,eliminated_regressors,0.9,x_optim_ent,x_optim_test,x_optim_val,model, 1);

%% Método de Números Difusos a 1 paso
addpath('fuzzy_ts')
s = fuzzy_numbers(model,x_optim_test,Y.test,100,200,0.1);
n = length(s);    
s_l = s(1:n/2);
s_u = s(n/2+1:end);

[y_hat_lower, y_hat_upper] = ysim_lower_upper(x_optim_test, model.a, model.b, model.g, s_l, s_u);

%% Ploteamos predicción con intervalos a 1 paso
figure()
x = 1: length(Y.test);
plot(Y.test, '.b');
hold on
plot(y_hat_lower, 'k', 'LineWidth', .1);
hold on
plot(y_hat_upper, 'k', 'LineWidth', .1);
x2 = [x, fliplr(x)];
inBetween = [y_hat_lower', fliplr(y_hat_upper')];
fill(x2, inBetween, 'black', 'FaceAlpha', 0.3, 'EdgeColor', 'red', 'EdgeAlpha', 0.2, 'DisplayName', 'Intervalo de confianza');

xlabel('Tiempo [k]', 'FontSize', 15)
ylabel('Salida y(k)', 'FontSize', 15)
set(gcf, 'color', 'w');
grid on
title('Comparación de datos reales e intervalo de confianza, método de números difusos', 'FontSize', 18);
legend('show');
legend('Valor real', 'Intervalo de confianza')
% PINAW y PICP
rmse(y_hat_, Y.test)
mae(abs(y_hat_ - Y.test))
compute_picp(model, x_optim_test, Y.test, s_l, s_u)
compute_pinaw(model, x_optim_test, Y.test, s_l, s_u)

%% Predicción intervalos difusos a 8 pasos
n_pasos = 8;
n_auto = 3; % ajustar numero de regresores de salida
y_8_pasos = predict_n_pasos(X.test, model,n_pasos,n_auto, eliminated_regressors, 1);

s_8_pasos = fuzzy_numbers(model,x_optim_test(1:end-n_pasos, :),y_8_pasos,100,200,0.1);

n_8_pasos = length(s_8_pasos);
s_l_8_pasos = s_8_pasos(1:n_8_pasos/2);
s_u_8_pasos = s_8_pasos(n_8_pasos/2+1:end);

[y_hat_lower_8_pasos, y_hat_upper_8_pasos] = ysim_lower_upper(x_optim_test(n_pasos+1:end, :), model.a, model.b, model.g, s_l_8_pasos, s_u_8_pasos);

%% Ploteamos predicción a 8 pasos con intervalos
figure()
x = 1: length(y_8_pasos);
plot(Y.test(n_pasos+1:end, :), '.b');
hold on
plot(y_hat_lower_8_pasos, 'k', 'LineWidth', .1);
hold on
plot(y_hat_upper_8_pasos, 'k', 'LineWidth', .1);
x2 = [x, fliplr(x)];
inBetween = [y_hat_lower_8_pasos', fliplr(y_hat_upper_8_pasos')];
fill(x2, inBetween, 'black', 'FaceAlpha', 0.3, 'EdgeColor', 'red', 'EdgeAlpha', 0.2, 'DisplayName', 'Intervalo de confianza');

xlabel('Tiempo [k]', 'FontSize', 15)
ylabel('Salida y(k)', 'FontSize', 15)
set(gcf, 'color', 'w');
grid on
title('Comparación de datos reales e intervalo de confianza a 8 pasos, método de números difusos', 'FontSize', 18);
legend('show');
legend('Valor real', 'Intervalo de confianza')
% PINAW y PICP
rmse(y_8_pasos, Y.test(n_pasos+1:end, :))
mae(abs(y_8_pasos - Y.test(n_pasos+1:end, :)))
compute_picp(model, x_optim_test(1:end-n_pasos, :), y_8_pasos, s_l_8_pasos, s_u_8_pasos)
compute_pinaw(model, x_optim_test(1:end-n_pasos, :), y_8_pasos, s_l_8_pasos, s_u_8_pasos)

%% Predicción intervalos difusos a 16 pasos
n_pasos = 16;
n_auto = 3; % ajustar numero de regresores de salida
y_16_pasos = predict_n_pasos(X.test, model,n_pasos,n_auto, eliminated_regressors, 1);

s_16_pasos = fuzzy_numbers(model,x_optim_test(1:end-n_pasos, :),y_16_pasos,100,200,0.1);

n_16_pasos = length(s_16_pasos);
s_l_16_pasos = s_16_pasos(1:n_16_pasos/2);
s_u_16_pasos = s_16_pasos(n_16_pasos/2+1:end);

[y_hat_lower_16_pasos, y_hat_upper_16_pasos] = ysim_lower_upper(x_optim_test(n_pasos+1:end, :), model.a, model.b, model.g, s_l_16_pasos, s_u_16_pasos);

%% Ploteamos predicción a 16 pasos con intervalos
figure()
x = 1: length(y_16_pasos);
plot(Y.test(n_pasos+1:end, :), '.b');
hold on
plot(y_hat_lower_16_pasos, 'k', 'LineWidth', .1);
hold on
plot(y_hat_upper_16_pasos, 'k', 'LineWidth', .1);
x2 = [x, fliplr(x)];
inBetween = [y_hat_lower_16_pasos', fliplr(y_hat_upper_16_pasos')];
fill(x2, inBetween, 'black', 'FaceAlpha', 0.3, 'EdgeColor', 'red', 'EdgeAlpha', 0.2, 'DisplayName', 'Intervalo de confianza');

xlabel('Tiempo [k]', 'FontSize', 15)
ylabel('Salida y(k)', 'FontSize', 15)
set(gcf, 'color', 'w');
grid on
title('Comparación de datos reales e intervalo de confianza a 16 pasos, método de números difusos', 'FontSize', 18);
legend('show');
legend('Valor real', 'Intervalo de confianza')
% PINAW y PICP
rmse(y_16_pasos, Y.test(n_pasos+1:end, :))
mae(abs(y_16_pasos - Y.test(n_pasos+1:end, :)))
compute_picp(model, x_optim_test(1:end-n_pasos, :), y_16_pasos, s_l_16_pasos, s_u_16_pasos)
compute_pinaw(model, x_optim_test(1:end-n_pasos, :), y_16_pasos, s_l_16_pasos, s_u_16_pasos)
