addpath("ejercicio_control_inteligente-ejercicio_1")

data_1 = load('data_1.mat');
data_2 = load('data_2.mat');
data_3 = load('data_3.mat');
data_4 = load('data_4.mat');
data_5 = load('data_5.mat');

data_1 = data_1.simout(1800:end,:);
data_2 = data_2.simout(1800:end,:);
data_3 = data_3.simout(1800:end,:);
data_4 = data_4.simout(1800:end,:);
data_5 = data_5.simout(1800:end,:);


%%
% Se comienzan reduciendo la cantidad de datos en el tiempo

in_1 = data_reduction(data_1(:,1),0.01,0.1);
in_2 = data_reduction(data_2(:,1),0.01,0.1);
in_3 = data_reduction(data_3(:,1),0.01,0.1);
in_4 = data_reduction(data_4(:,1),0.01,0.1);
in_5 = data_reduction(data_5(:,1),0.01,0.1);

out_1 = data_reduction(data_1(:,2),0.01,0.1);
out_2 = data_reduction(data_2(:,2),0.01,0.1);
out_3 = data_reduction(data_3(:,2),0.01,0.1);
out_4 = data_reduction(data_4(:,2),0.01,0.1);
out_5 = data_reduction(data_5(:,2),0.01,0.1);

time_1 = zeros([length(in_1(:,1)), 1]);
time_2 = zeros([length(in_2(:,1)), 1]);
time_3 = zeros([length(in_3(:,1)), 1]);
time_4 = zeros([length(in_4(:,1)), 1]);
time_5 = zeros([length(in_5(:,1)), 1]);

for i = 1:length(time_1)
   time_1(i) = 0.1*(i-1); 
end
for i = 1:length(time_2)
   time_2(i) = 0.1*(i-1); 
end
for i = 1:length(time_3)
   time_3(i) = 0.1*(i-1); 
end
for i = 1:length(time_4)
   time_4(i) = 0.1*(i-1); 
end
for i = 1:length(time_5)
   time_5(i) = 0.1*(i-1); 
end

%% Se plotean los datos de entrada y salida
figure(1);clf
plot(time_1, out_1, time_1, in_1, 'Linewidth', 2)
title('Respuesta APRBS del sistema', 'FontSize', 18)
xlabel('Tiempo [k]', 'FontSize', 15) 
ylabel('Altura [m]', 'FontSize', 15)
legend('Salida', 'Entrada')
grid on
ax = gca;
ax.FontSize = 15;
set(gcf,'color','w');


%% Ahora se obtienen las matrices x, y

max_regs = 10;
max_clusters = 10;

[y1,x1] = autoregresores(out_1,in_1',max_regs, max_regs);
[y2,x2] = autoregresores(out_2,in_2',max_regs, max_regs);
[y3,x3] = autoregresores(out_3,in_3',max_regs, max_regs);
[y4,x4] = autoregresores(out_4,in_4',max_regs, max_regs);
[y5,x5] = autoregresores(out_5,in_5',max_regs, max_regs);

% Se concatenan para generar los datos de entrenamiento-test-validación

X.ent = [x1;x2;x3];
Y.ent = [y1;y2;y3];

X.test = x4;
Y.test = y4;

X.val = x5;
Y.val = y5;


%% Optimizar modelo - Reglas

[err_test, err_ent] = clusters_optimo(Y.test, Y.ent, X.test, X.ent, max_clusters);

figure(2);clf
plot(err_test, 'b', 'Linewidth', 2)
hold on
plot(err_ent, 'r', 'Linewidth', 2)
title('Error del modelo por cantidad de clusters', 'FontSize', 18)
xlabel('Tiempo [s]', 'FontSize', 15) 
ylabel('Error', 'FontSize', 15)
legend('Error Test', 'Error Entrenamiento')
grid on
ax = gca;
ax.FontSize = 15;
set(gcf,'color','w');


%% Optimizar modelo - Regresores
clusters = 2; % numero de clusters elegido anteriormente
num_iter = 20; % Número de iteraciones
[rmse_values,y_hat,model,x_optim_ent, x_optim_test, x_optim_val, eliminated_regressors,minJ] = optimize_model(Y, X, clusters, num_iter);
y_hat_ = ysim(x_optim_test, model.a, model.b, model.g);

%% Parte C: Se procede a analizar el desempeño de las predicciones
[e_rmse, e_mae] = rmse_mae(y_hat, Y.val);

%% Calculo del intervalo difuso con el método de la covarianza

target_porcentaje_alfa = 0.9;
[alfa_optimo, alfas, porcentaje_datos,I,I_] = calcular_metricas(x_optim_ent, x_optim_test, x_optim_val, model, Y, y_hat_,y_hat,target_porcentaje_alfa);


%% Se hacen las predicciones

% A 5 pasos
[y_pred_5, Y_5] = pred_alfa(X,Y,5,3,eliminated_regressors,target_porcentaje_alfa,...
                           x_optim_ent,x_optim_test,x_optim_val,model);

[e_rmse_5, e_mae_5_, e2_5] = rmse_mae(y_pred_5, Y_5.val);


%% A 10 pasos
[y_pred_10, Y_10] = pred_alfa(X,Y,10,3,eliminated_regressors,target_porcentaje_alfa,...
                           x_optim_ent,x_optim_test,x_optim_val,model);

[e_rmse_10, e_mae_10, e2_10] = rmse_mae(y_pred_10, Y_10.val);

%% A 20 pasos
[y_pred_20, Y_20] = pred_alfa(X,Y,20,3,eliminated_regressors,target_porcentaje_alfa,...
                           x_optim_ent,x_optim_test,x_optim_val,model);

[e_rmse_20, e_mae_20, e2_20] = rmse_mae(y_pred_20, Y_20.val);

%%
figure();clf
    tiledlayout(3,2)

    nexttile
    plot(y_pred_5, 'Linewidth', 2)
    hold on
    plot(Y_5.val, 'Linewidth', 2)
    title('Predicciones del modelo a 5 pasos', 'FontSize', 18)
    xlabel('Tiempo [k]', 'FontSize', 15) 
    ylabel('Salida y[k]', 'FontSize', 15)
    legend('Salida Real', 'Salida Predicha')
    grid on
    ax = gca;
    ax.FontSize = 15;
    set(gcf,'color','w');
    
    nexttile
    plot(e2_5, 'Linewidth', 2)
    title('Zonas de error cuadrático en el tiempo a 5 pasos')
    xlabel('Tiempo [k]', 'FontSize', 15) 
    ylabel('Error', 'FontSize', 15)
    grid on
    ax = gca;
    ax.FontSize = 15;
    set(gcf,'color','w');

    % para 10 pasos

    nexttile
    plot(y_pred_10, 'Linewidth', 2)
    hold on
    plot(Y_10.val, 'Linewidth', 2)
    title('Predicciones del modelo a 10 pasos', 'FontSize', 18)
    xlabel('Tiempo [k]', 'FontSize', 15) 
    ylabel('Salida y[k]', 'FontSize', 15)
    legend('Salida Real', 'Salida Predicha')
    grid on
    ax = gca;
    ax.FontSize = 15;
    set(gcf,'color','w');
    
    nexttile
    plot(e2_10, 'Linewidth', 2)
    title('Zonas de error cuadrático en el tiempo a 10 pasos')
    xlabel('Tiempo [k]', 'FontSize', 15) 
    ylabel('Error', 'FontSize', 15)
    grid on
    ax = gca;
    ax.FontSize = 15;
    set(gcf,'color','w');

    % para 20 pasos

    nexttile
    plot(y_pred_20, 'Linewidth', 2)
    hold on
    plot(Y_20.val, 'Linewidth', 2)
    title('Predicciones del modelo a 20 pasos', 'FontSize', 18)
    xlabel('Tiempo [k]', 'FontSize', 15) 
    ylabel('Salida y[k]', 'FontSize', 15)
    legend('Salida Real', 'Salida Predicha')
    grid on
    ax = gca;
    ax.FontSize = 15;
    set(gcf,'color','w');
    
    nexttile
    plot(e2_20, 'Linewidth', 2)
    title('Zonas de error cuadrático en el tiempo a 20 pasos')
    xlabel('Tiempo [k]', 'FontSize', 15) 
    ylabel('Error', 'FontSize', 15)
    grid on
    ax = gca;
    ax.FontSize = 15;
    set(gcf,'color','w');