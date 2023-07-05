clear
close all
clc

%% Load Data %%
addpath('ejercicio_2/p3_ode45/')
addpath('ejercicio_2/p3_ode45/ts/')
addpath('ejercicio_2/toolbox_difuso/')

load('maglev_pd_ode_45_data.mat')
data_posicion = simout(1,:).';
load('aprbs.mat')
U = aprbs;

figure()
plot(data_posicion);
hold on
plot(U);
grid on;
title('Datos de Levitador Magnetico simulado con ode 45', 'FontSize', 18);
xlabel('Tiempo [k]', 'FontSize', 15);
ylabel('Posición [m]', 'FontSize', 15);


%% Parámetros del modelo %%
max_regs = 10;
max_clusters = 10;
porcentajes = [60 20 20];
[y, x] = autoregresores(data_posicion, U, max_regs, max_regs);

[Y.ent, Y.test, Y.val, X_fmin.ent, X_fmin.test, X_fmin.val] = separar_datos(y, x, porcentajes);

%% Optimizar modelo - Reglas %%
[err_test, err_ent] = clusters_optimo(Y.test, Y.ent, X_fmin.test, X_fmin.ent, max_clusters);
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

%% Optimizar modelo - Regresores %%
clusters = 2; % numero de clusters elegido anteriormente
num_iter = 20; % Número de iteraciones
[rmse_values,y_hat,model,x_optim_ent, x_optim_test, x_optim_val, eliminated_regressors, minJ] = optimize_model(Y, X_fmin, clusters, num_iter);

%% Plot Predicciones %%
y_hat_ = ysim(x_optim_test, model.a, model.b, model.g);

figure()
plot(Y.test, 'b')
hold on
plot(y_hat_, 'r')
hold off
legend('Valor real', 'Valor predicho')
xlabel('Número de muestras', 'FontSize', 15)
ylabel('Valores', 'FontSize', 15)
set(gcf, 'color', 'w');
grid on
title('Predicción a 1 paso en test', 'FontSize', 18);

%% Save Model %%
save('ejercicio_2/p3_ode45/ts/maglev_ts_model.mat', 'model');
save('ejercicio_2/p3_ode45/ts/regresores_eliminados_modelo_ts.mat', 'eliminated_regressors');

%% Intervalos Difusos %%
addpath('ejercicio_1/fuzzy_ts/')

s = fuzzy_numbers(model, x_optim_val,Y.val ,100 ,200 ,0.1);
n = length(s);    
s_l = s(1:n/2);
s_u = s(n/2+1:end);

[y_hat_lower, y_hat_upper] = ysim_lower_upper(x_optim_test, model.a, model.b, model.g, s_l, s_u);

%% Plot predicción de intervalos a 1 paso %%
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

%% Guardamos spreads %%
save('ejercicio_2/p3_ode45/ts/spreads_ts_model.mat', 's');

% END OF FILE %