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

% y_hat = net_optim(x_optim_val')';

figure()
plot(Y.val, '.b')
hold on
plot(y_hat, 'r')

legend('Valor real', 'Valor esperado')

