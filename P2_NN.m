clear
clc

%% Creamos datos y los ploteamos

addpath("C:\Users\mp204\OneDrive\Desktop\2023\Control Inteligente\ejercicio_control_inteligente-ejercicio_1\ejercicio_control_inteligente-ejercicio_1\Toolbox TS NN\Toolbox NN")
addpath("C:\Users\mp204\OneDrive\Desktop\2023\Control Inteligente\ejercicio_control_inteligente-ejercicio_1\ejercicio_control_inteligente-ejercicio_1\P2_COV")

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

% Se calcula el error de test para todas las configuraciones de neuronas en
% capa oculta
% Aqui se calcula el error solo con 15, que fue el optimo precalculado
% Se debe encontrar el optimo mediante iteraciones

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

% Se quita el regresor con menor sensibilidad
x_optim_ent(:, p) = [];
x_optim_val(:, p) = [];
x_optim_test(:, p) = [];

%% Entrenar modelo
net_optim = fitnet(optim_hlayer);
net_optim.trainFcn = 'trainscg';  
net_optim.trainParam.showWindow=0;
net_optim = train(net_optim,x_optim_ent',Y.ent', 'useParallel','yes');

%% Predicciones

net_optim_structure = my_ann_exporter(net_optim);
y_hat = my_ann_evaluation(net_optim_structure, x_optim_val');
y_hat_ = my_ann_evaluation(net_optim_structure, x_optim_test');

% Llamada a la función calcular_intervalos_cov
target_porcentaje = 0.95;
[alfa_optimo, alfas, porcentaje_datos] = calcular_intervalos_cov_NN(x_optim_ent, x_optim_test, x_optim_val, net_optim_structure, Y, y_hat_, y_hat, target_porcentaje);  

legend('Valor real', 'Intervalo de confianza')

%% Intervalos Difusos
addpath('fuzzy_nn')

s = fuzzy_numbers_nn(net_optim_structure, optim_hlayer, x_optim_val,Y,100,200,0.1);
n = length(s);    
s_l = s(1:n/2);
s_u = s(n/2+1:end);

[y_hat_lower, y_hat_upper] = ysim_lower_upper_nn(net_optim_structure, x_optim_val, s_l, s_u);

%% Ploteamos predicción con intervalos
figure()
x = 1: length(Y.val);
plot(Y.val, '.b');
hold on
plot(y_hat_lower, 'k', 'LineWidth', .1);
hold on
plot(y_hat_upper, 'k', 'LineWidth', .1);
x2 = [x, fliplr(x)];
inBetween = [y_hat_lower, fliplr(y_hat_upper)];
fill(x2, inBetween, 'black', 'FaceAlpha', 0.3,'EdgeColor', 'red','EdgeAlpha', 0.5, 'DisplayName', 'Intervalo de confianza');
xlabel('Índice')
ylabel('Valores')
set(gcf, 'color', 'w');
grid on
title('Comparación de datos reales e intervalo de confianza, método de números difusos');
legend('show');
legend('Valor real', 'Intervalo de confianza')
% PINAW y PICP
compute_pinaw_nn(net_optim_structure, x_optim_val, Y, s_l, s_u)
compute_picp_nn(net_optim_structure, x_optim_val, Y, s_l, s_u)



