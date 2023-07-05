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
ylabel('Posición [cm]', 'FontSize', 15);


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

% END OF FILE %