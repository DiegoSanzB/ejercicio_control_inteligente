clear
close all
clc

%% (a) %%

addpath('ejercicio_2\p2')
addpath('ejercicio_2\p2\toolbox_difuso')
addpath('ejercicio_2\p2\toolbox_b')

% Cargamos data
load('temperatura_10min.mat');

figure()
plot(temperatura);
grid on;
title('Temperatura exterior [°C]', 'FontSize', 18);
xlabel('Tiempo [k]', 'FontSize', 15);
ylabel('T_a(k)', 'FontSize', 15);

%% Parámetros del modelo %%
max_regs = 100;
max_clusters = 10;
porcentajes = [60 20 20];
[y, x] = autoregresores(temperatura, [], max_regs, 0);

[Y.ent, Y.test, Y.val, X.ent, X.test, X.val] = separar_datos(y, x, porcentajes);

%% Optimizar modelo - Reglas %%
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

%% Optimizar modelo - Regresores %%
clusters = 1; % numero de clusters elegido anteriormente
num_iter = 20; % Número de iteraciones
[rmse_values,y_hat,model,x_optim_ent, x_optim_test, x_optim_val, eliminated_regressors, minJ] = optimize_model(Y, X, clusters, num_iter);

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

%% (c) Control predictivo %%

% Definición de la función
lb = [0.1,0.1,0.1,0.1,0.1];
ub = [2,2,2,2,2];
hpred = 5; % Horizonte de predicción
options = optimoptions('fmincon','Algorithm','interior-point'); % Elige el algoritmo 'interior-point'
delta_t = 10;
% Se obtienen las condiciones iniciales
T_1_0 = 18;
T_2_0 = 20;
u0 = (ub - lb) .* rand(1, hpred) + lb;

%Adaptación de Ta al tiempo de muestreo
T_a_fun = zeros(length(y_hat_)*(10/delta_t),1);
for i = 1:(length(T_a_fun)-1)
    T_a_fun(i) = y_hat_(floor(i*delta_t/10)+1);
end

%se crea la referencia
step_amp = [20,18,25];
time_step = [60,60,60+(hpred*delta_t)];

ref = generate_reference(step_amp,time_step,delta_t);

u = ones(1, hpred) .* u0;  % inicializa u para la primera iteración

U = [];
X = [];

%fmincon%

for ii = 1:1:((sum(time_step)-(hpred*delta_t))/delta_t)
    ii
    % Función de costo que se utilizará en optimización
    fun = @(u) cost_function(u, ref(ii:ii+4), T_1_0, T_2_0, T_a_fun(ii:ii+4), delta_t);
    
    % Aplica fmincon para optimizar u
    u = fmincon(fun, u, [], [], [], [], lb, ub, [], options);

    % Simulamos la acción de control
    [T_1, T_2] = step(T_1_0,T_2_0,u(1),T_a_fun(ii), delta_t);

    % Actualizamos condiciones iniciales
    T_1_0 = T_1;
    T_2_0 = T_2;

    U = [U; repmat(u(1), size(T_1, 1), 1)];
    X = [X; T_1];
end

% Gráfica de las salidas y las entradas de control
figure;
subplot(3,1,1);
plot(X(:, 1));
title('Output');
subplot(3,1,2);
plot(U);
title('Control input');
subplot(3,1,3);
plot(X(:,1)-ref(1:length(X(:,1))));
title('Error');

%% PSO 

% Definición de la función
%lb = [0.1,0.1,0.1,0.1,0.1];
%ub = [2,2,2,2,2];
hpred = 5; % Horizonte de predicción
delta_t = 10;

% variables del pso
nvars = 5; % número de variables de decisión
lb = ones(1,nvars) *0.1; % límite inferior
ub = ones(1,nvars) *2;  % límite superior
options = optimoptions('particleswarm', 'SwarmSize', 10, 'FunctionTolerance', 1e-4, 'MaxStallIterations', 15);

% Se obtienen las condiciones iniciales
T_1_0 = 18;
T_2_0 = 20;
u0 = (ub - lb) .* rand(1, hpred) + lb;

%Adaptación de Ta al tiempo de muestreo
T_a_fun = zeros(length(y_hat_)*(10/delta_t),1);
for i = 1:(length(T_a_fun)-1)
    T_a_fun(i) = y_hat_(floor(i*delta_t/10)+1);
end

%se crea la referencia
step_amp = [20,18,25];
time_step = [60,60,60+(hpred*delta_t)];

ref = generate_reference(step_amp,time_step,delta_t);

%u = ones(1, hpred) .* u0;  % inicializa u para la primera iteración

U = [];
X = [];
    
count = 0;

u = ones(1, nvars) * 0.5;  % inicializa u para la primera iteración
Time = zeros(1,((sum(time_step)-(hpred*delta_t))/delta_t));
for ii = 1:1:((sum(time_step)-(hpred*delta_t))/delta_t)

    ii
    count = count + 1;

    % Función de costo que se utilizará en optimización
    fun = @(u) cost_function(u, ref(ii:ii+4), T_1_0, T_2_0, T_a_fun(ii:ii+4), delta_t);
    
    tic
    % Crea una matriz inicial para el enjambre basándose en u
    initial_swarm = repmat(u, [options.SwarmSize, 1]);
    options.InitialSwarmMatrix = initial_swarm;

    % Aplica PSO para optimizar u
    u = particleswarm(fun, nvars, lb, ub, options);
    time = toc;
    Time(i) = time;
    % Simulamos la acción de control
    [T_1, T_2] = step(T_1_0,T_2_0,u(1),T_a_fun(ii), delta_t);

    % Actualizamos condiciones iniciales
    T_1_0 = T_1;
    T_2_0 = T_2;

    U = [U; repmat(u(1), size(T_1, 1), 1)];
    X = [X; T_1];
end

% Gráfica de las salidas y las entradas de control
figure;
subplot(3,1,1);
plot(X(:, 1));
title('Output');
subplot(3,1,2);
plot(U);
title('Control input');
subplot(3,1,3);
plot(X(:,1)-ref(1:length(X(:,1))));
title('Error');
%%
plot(Time)

%%
function [T_1, T_2] = step(T_1_0,T_2_0,U,T_a_0, delta_t)
    T_1 = T_1_prediction(T_1_0,T_2_0,T_a_0,U,delta_t);
    T_2 = T_2_prediction(T_1_0,T_2_0,delta_t);
end

function cost = cost_function(U, ref, T_1_0, T_2_0, T_a, delta_t)
    cost = 0;
    for i = 1:length(U)
        [T_1, T_2] = step(T_1_0, T_2_0, U(i), T_a(i), delta_t);
        cost = cost + (ref(i) - T_1)^2;
        T_1_0 = T_1;
        T_2_0 = T_2;
    end
end
