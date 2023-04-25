clear all
close all
clc

%% Creamos datos y los ploteamos

addpath("Toolbox TS NN\Toolbox NN")
addpath("P2_COV")

% Generamos data
% U = generate_aprbs(0.01, 100, 0.5, 5, -2, 2);
% U2 = U + normrnd(0,0.1,[1, 10001]);

% Cargamos data
U2 = readmatrix('APRBS.csv');
data = generate_data(0, 0, U2);

%% Parametros del modelo
max_regs = 10;
max_clusters = 10;
porcentajes = [60 20 20]; % entrenamiento validación test

[y, x] = autoregresores(data, U2, max_regs, max_regs);

[Y.ent, Y.test, Y.val, X.ent, X.test, X.val] = separar_datos(y, x, porcentajes);


%% Optimizar modelo - Reglas

% Se calcula el error de test para todas las configuraciones de neuronas en
% capa oculta
% Aqui se calcula el error solo con 15, que fue el optimo precalculado
% Se debe encontrar el optimo mediante iteraciones

min_h_layer = 10; % Define el mínimo número de capas ocultas que quieres probar
max_h_layer = 20; % Define el máximo número de capas ocultas que quieres probar
n_layers = max_h_layer - min_h_layer + 1;
errors = zeros(n_layers, 1); % Pre-allocate array to store errors

for h_layer = min_h_layer:max_h_layer
    % El código dentro de este bucle es el mismo que en la respuesta anterior
    net_ent = fitnet(h_layer); 
    net_ent.trainFcn = 'trainscg'; 
    net_ent.trainParam.showWindow = 0; 
    net_ent = train(net_ent, X.ent', Y.ent', 'useParallel', 'yes');

    y_p_test = net_ent(X.test')';
    errtest = (sqrt(sum((y_p_test - Y.test).^2))) / length(Y.test);

    errors(h_layer - min_h_layer + 1) = errtest; % Guarda el error de test en el vector de errores

    fprintf('Capas ocultas: %d, Error de test: %.4f\n', h_layer, errtest); % Muestra el progreso en cada iteración
end

[min_err_test, idx] = min(errors); % Encuentra el mínimo error de test y su índice en el vector de errores
opt_h_layer = idx + min_h_layer - 1; % Calcula el número óptimo de capas ocultas
fprintf('\nNúmero óptimo de capas ocultas: %d, Mínimo error de test: %.4f\n', opt_h_layer, min_err_test);

%% Graficar errores
figure;
plot(min_h_layer:max_h_layer, errors, 'LineWidth', 2);
xlabel('Número de neuronas en la capa oculta','FontSize', 15);
ylabel('Error de test','FontSize', 15);
title('Error de test en función del número de neuronas en la capa oculta','FontSize', 18);
grid on;

% Encontrar el menor valor y su índice
[min_error, min_index] = min(errors);

% Marcar con un círculo relleno el menor valor
hold on;
plot(min_index + min_h_layer - 1, min_error, 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
hold off;

% Agregar leyenda con el menor valor
legend({'Error de test', sprintf('Menor error: %.4f (neuronas = %d)', min_error, min_index + min_h_layer - 1)}, 'FontSize', 12);


%% Modelo Optimizado
net_ent = fitnet(15); % 15 neuronas en capa oculta
net_ent.trainFcn = 'trainscg'; % Funcion de entrenamiento
net_ent.trainParam.showWindow=1; % Evita que se abra la ventana de entrenamiento
net_ent = train(net_ent,X.ent',Y.ent', 'useParallel','yes');

y_p_test = net_ent(X.test')'; % Se genera una prediccion en conjunto de test
errtest= (sqrt(sum((y_p_test-Y.test).^2)))/length(Y.test); % Se guarda el error de test

optim_hlayer = 15;
%% Optimizar modelo - Regresores
[p, indices] = sensibilidad_nn(X.ent, net_ent);

x_optim_ent = X.ent;
x_optim_val = X.val;
x_optim_test = X.test;

% No quitamos regresores
eliminated_regressors = [];

%% Entrenar modelo
net_optim = fitnet(optim_hlayer);
net_optim.trainFcn = 'trainscg';  
net_optim.trainParam.showWindow=0;
net_optim = train(net_optim,x_optim_ent',Y.ent', 'useParallel','yes');

%% Predicciones
net_optim_structure = my_ann_exporter(net_optim);
y_hat = my_ann_evaluation(net_optim_structure, x_optim_val');
y_hat_ = my_ann_evaluation(net_optim_structure, x_optim_test');

% Plot salida con modelo optimizado
figure()
plot(y_hat, '.r', 'LineWidth', .1)
hold on 
plot(Y.val, 'b', 'LineWidth', .1)
title('Salida conjunto de validación del modelo neuronal con estructura optimizada', 'FontSize', 18)
xlabel('Salida y(k)', 'FontSize', 15)
ylabel('Tiempo (k)', 'FontSize', 15)
grid on
legend('show');
legend('Salida predicha', 'Salida real')

%% Llamada a la función calcular_intervalos_cov
target_porcentaje = 0.9; 

%% Predicciones a n pasos
pred_alfa(X,Y,5,1,[],0.9,x_optim_ent,x_optim_test,x_optim_val,net_optim_structure, 0);
pred_alfa(X,Y,5,8,[],0.9,x_optim_ent,x_optim_test,x_optim_val,net_optim_structure, 0);
pred_alfa(X,Y,5,16,[],0.9,x_optim_ent,x_optim_test,x_optim_val,net_optim_structure,0);

%% Intervalos Difusos a 1 paso
addpath('fuzzy_nn')

s = fuzzy_numbers_nn(net_optim_structure, optim_hlayer, x_optim_test,Y.test,100,200,0.1);
n = length(s);
s_l = s(1:n/2);
s_u = s(n/2+1:end);

[y_hat_lower, y_hat_upper] = ysim_lower_upper_nn(net_optim_structure, x_optim_test, s_l, s_u);

%% Ploteamos predicción con intervalos a 1 paso
figure()
x = 1: length(Y.test);
plot(Y.test, '.b');
hold on
plot(y_hat_lower, 'k', 'LineWidth', .1);
hold on
plot(y_hat_upper, 'k', 'LineWidth', .1);
x2 = [x, fliplr(x)];
inBetween = [y_hat_lower, fliplr(y_hat_upper)];
fill(x2, inBetween, 'black', 'FaceAlpha', 0.3,'EdgeColor', 'red','EdgeAlpha', 0.3, 'DisplayName', 'Intervalo de confianza');
xlabel('Tiempo [k]', 'FontSize', 15)
ylabel('Salida y(k)', 'FontSize', 15)
set(gcf, 'color', 'w');
grid on
title('Comparación de datos reales e intervalo de confianza, método de números difusos', 'FontSize', 18);
legend('show');
legend('Valor real', 'Intervalo de confianza')
% PINAW y PICP
rmse(y_hat_', Y.test)
mae(abs(y_hat_' - Y.test))
compute_picp_nn(net_optim_structure, x_optim_test, Y.test, s_l, s_u)
compute_pinaw_nn(net_optim_structure, x_optim_test, Y.test, s_l, s_u)

%% Intervalos Difusos a 8 pasos
n_pasos = 8;
n_auto = 10; % ajustar numero de regresores de salida

y_8_pasos = predict_n_pasos(X.test, net_optim_structure,n_pasos,n_auto, eliminated_regressors, 0);

s_8_pasos = fuzzy_numbers_nn(net_optim_structure, optim_hlayer, x_optim_test(1:end-n_pasos, :),y_8_pasos,100,200,0.1);
n_8_pasos = length(s_8_pasos);
s_l_8_pasos = s_8_pasos(1:n_8_pasos/2);
s_u_8_pasos = s_8_pasos(n_8_pasos/2+1:end);

[y_hat_lower_8_pasos, y_hat_upper_8_pasos] = ysim_lower_upper_nn(net_optim_structure, x_optim_test(1:end-n_pasos, :), s_l_8_pasos, s_u_8_pasos);

%% Ploteamos predicción con intervalos a 8 pasos
figure()
x = 1: length(y_8_pasos);
plot(Y.test(1:end-n_pasos, :), '.b');
hold on
plot(y_hat_lower_8_pasos, 'k', 'LineWidth', .1);
hold on
plot(y_hat_upper_8_pasos, 'k', 'LineWidth', .1);
x2 = [x, fliplr(x)];
inBetween = [y_hat_lower_8_pasos, fliplr(y_hat_upper_8_pasos)];
fill(x2, inBetween, 'black', 'FaceAlpha', 0.3, 'EdgeColor', 'red', 'EdgeAlpha', 0.3, 'DisplayName', 'Intervalo de confianza');

xlabel('Tiempo [k]', 'FontSize', 15)
ylabel('Salida y(k)', 'FontSize', 15)
set(gcf, 'color', 'w');
grid on
title('Comparación de datos reales e intervalo de confianza a 8 pasos, método de números difusos', 'FontSize', 18);
legend('show');
legend('Valor real', 'Intervalo de confianza')
% PINAW y PICP
rmse(y_8_pasos, Y.test(1:end-n_pasos, :))
mae(abs(y_8_pasos - Y.test(1:end-n_pasos, :)))
compute_picp_nn(net_optim_structure, x_optim_test(1:end-n_pasos, :), y_8_pasos, s_l_8_pasos, s_u_8_pasos)
compute_pinaw_nn(net_optim_structure, x_optim_test(1:end-n_pasos, :), y_8_pasos, s_l_8_pasos, s_u_8_pasos)


%% Intervalos Difusos a 16 pasos
n_pasos = 16;

y_16_pasos = predict_n_pasos(X.test, net_optim_structure,n_pasos,n_auto, eliminated_regressors, 0);

s_16_pasos = fuzzy_numbers_nn(net_optim_structure, optim_hlayer, x_optim_test(1:end-n_pasos, :),y_16_pasos,100,200,0.1);
n_16_pasos = length(s_16_pasos);
s_l_16_pasos = s_16_pasos(1:n_16_pasos/2);
s_u_16_pasos = s_16_pasos(n_16_pasos/2+1:end);

[y_hat_lower_16_pasos, y_hat_upper_16_pasos] = ysim_lower_upper_nn(net_optim_structure, x_optim_test(1:end-n_pasos, :), s_l_16_pasos, s_u_16_pasos);

%% Ploteamos predicción con intervalos a 16 pasos
figure()
x = 1: length(y_16_pasos);
plot(Y.test(1:end-n_pasos, :), '.b');
hold on
plot(y_hat_lower_16_pasos, 'k', 'LineWidth', .1);
hold on
plot(y_hat_upper_16_pasos, 'k', 'LineWidth', .1);
x2 = [x, fliplr(x)];
inBetween = [y_hat_lower_16_pasos, fliplr(y_hat_upper_16_pasos)];
fill(x2, inBetween, 'black', 'FaceAlpha', 0.3, 'EdgeColor', 'red', 'EdgeAlpha', 0.2, 'DisplayName', 'Intervalo de confianza');

xlabel('Tiempo [k]', 'FontSize', 15)
ylabel('Salida y(k)', 'FontSize', 15)
set(gcf, 'color', 'w');
grid on
title('Comparación de datos reales e intervalo de confianza a 16 pasos, método de números difusos', 'FontSize', 18);
legend('show');
legend('Valor real', 'Intervalo de confianza')
% PINAW y PICP
rmse(y_16_pasos, Y.test(1:end-n_pasos, :))
mae(abs(y_16_pasos - Y.test(1:end-n_pasos, :)))
compute_picp_nn(net_optim_structure, x_optim_test(1:end-n_pasos, :), y_16_pasos, s_l_16_pasos, s_u_16_pasos)
compute_pinaw_nn(net_optim_structure, x_optim_test(1:end-n_pasos, :), y_16_pasos, s_l_16_pasos, s_u_16_pasos)
