clear
close all
clc

%% (a) %%

addpath('toolbox_difuso')
addpath('toolbox_b')

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
clusters = 1; % numero de clusters elegido anteriormente
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

%% (c) Control predictivo %%
%fmincon%

% Definición de la función
lb = [0.1,0.1,0.1,0.1,0.1];
ub = [2,2,2,2,2];
hpred = 5; % Horizonte de predicción
options = optimoptions('fmincon','Algorithm','interior-point'); % Elige el algoritmo 'interior-point'
delta_t = 10;
%options = optimoptions('fmincon','Algorithm','sqp');
% Se obtienen las condiciones iniciales
T_1_0 = 18;
T_2_0 = 20;
u0 = (ub - lb)/2 + lb;

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

U_fmin = [];
X_fmin = [];
%fmincon%

for ii = 1:1:((sum(time_step)-(hpred*delta_t))/delta_t)
    ii
    
    % Función de costo que se utilizará en optimización
    fun = @(u) cost_function(u, ref(ii:ii+4), T_1_0, T_2_0, T_a_fun(ii:ii+4), delta_t);
    
    tic
    % Aplica fmincon para optimizar u
    u = fmincon(fun, u, [], [], [], [], lb, ub, [], options);
    time_fmin(ii) = toc;

    % Simulamos la acción de control
    %[T_1, T_2] = step(T_1_0,T_2_0,u(1),T_a_fun(ii), delta_t);
    %corremos la simulación para actualizar el valor de T1 y T2
    u_fmin = [delta_t*60, u(1)];
    T_a_fmin = [delta_t*60, T_a_fun(ii)];
    w1 = [delta_t*60, wgn(1, 1, 0.001, 'linear')];
    w2 = [delta_t*60, wgn(1, 1, 0.001, 'linear')];

    simout = sim("SimulinkHvac_2018a_fmin.slx");
    
    T_1 = T_1_fmin_out(2);
    T_2 = T_2_fmin_out(2);


    % Actualizamos condiciones iniciales
    T_1_0 = T_1;
    T_2_0 = T_2;

    U_fmin = [U_fmin; repmat(u(1), size(T_1, 1), 1)];
    X_fmin = [X_fmin; T_1];
end

%% Gráfica de las salidas y las entradas de control

% Crear un gráfico para la salida y la referencia
fig1 = figure;
fig1.Color = 'white'; % Fondo blanco

% Graficar la salida
plot(X_fmin(:, 1), 'LineWidth', 2);
hold on;

% Graficar la referencia
plot(ref(1:18), 'LineWidth', 2);

% Agregar títulos y etiquetas a los ejes
title('Comparación de la Temperatura Ambiente y la Referencia', 'FontSize', 16);
xlabel('Tiempo (min)', 'FontSize', 16);
ylabel('Temperatura (°C)', 'FontSize', 16);

% Agregar leyendas
legend('Temperatura medida', 'Temperatura de referencia', 'FontSize', 12);

% Asegurarse de que el gráfico sea visible
hold off;
grid on;

% Crear un gráfico para el error y la señal de control
fig2 = figure;
fig2.Color = 'white'; % Fondo blanco

% Subplot superior: Error
subplot(3, 1, 1);
error = X_fmin(:,1) - ref(1:length(X_fmin(:,1)));
plot(error, 'LineWidth', 2);
title('Error de Medición', 'FontSize', 16);
xlabel('Tiempo (min)', 'FontSize', 16);
ylabel('Error (°C)', 'FontSize', 16);
grid on;

% Subplot del medio: Señal de control
subplot(3, 1, 2);
plot(U_fmin, 'r', 'LineWidth', 2); % 'r' especifica el color rojo
title('Señal de Control', 'FontSize', 16);
xlabel('Tiempo (min)', 'FontSize', 16);
ylabel('Señal de Control', 'FontSize', 16);
grid on;

% Subplot inferior: Solo la referencia
subplot(3, 1, 3);
plot(ref(1:18), 'LineWidth', 2);
title('Referencia', 'FontSize', 16);
xlabel('Tiempo (min)', 'FontSize', 16);
ylabel('Temperatura (°C)', 'FontSize', 16);
grid on;

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

U_pso = [];
X_pso = [];
    
count = 0;

u = ones(1, nvars) * 0.5;  % inicializa u para la primera iteración
Time = zeros(1,((sum(time_step)-(hpred*delta_t))/delta_t));

mdl = 'SimulinkHvac_2018a_pso';
simIn = Simulink.SimulationInput(mdl);

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
    time_pso(ii) = toc;

    % Simulamos la acción de control
    %[T_1, T_2] = step(T_1_0,T_2_0,u(1),T_a_fun(ii), delta_t);
    %corremos la simulación para actualizar el valor de T1 y T2
    u_pso = [delta_t*60, u(1)];
    T_a_pso = [delta_t*60, T_a_fun(ii)];
    w1 = [delta_t*60, wgn(1, 1, 0.001, 'linear')];
    w2 = [delta_t*60, wgn(1, 1, 0.001, 'linear')];

    simout = sim("SimulinkHvac_2018a_pso.slx");
    
    T_1 = T_1_pso_out(2);
    T_2 = T_2_pso_out(2);

    % Actualizamos condiciones iniciales
    T_1_0 = T_1;
    T_2_0 = T_2;
    
    U_pso = [U_pso; repmat(u(1), size(T_1, 1), 1)];
    X_pso = [X_pso; T_1];
end

%% Gráfica de las salidas y las entradas de control

% Crear un gráfico para la salida y la referencia
fig3 = figure;
fig3.Color = 'white'; % Fondo blanco

% Graficar la salida
plot(X_pso(:, 1), 'LineWidth', 2);
hold on;

% Graficar la referencia
plot(ref(1:18), 'LineWidth', 2);

% Agregar títulos y etiquetas a los ejes
title('Comparación de la Temperatura Ambiente y la Referencia', 'FontSize', 16);
xlabel('Tiempo (min)', 'FontSize', 16);
ylabel('Temperatura (°C)', 'FontSize', 16);

% Agregar leyendas
legend('Temperatura medida', 'Temperatura de referencia', 'FontSize', 12);

% Asegurarse de que el gráfico sea visible
hold off;
grid on;

% Crear un gráfico para el error y la señal de control
fig4 = figure;
fig4.Color = 'white'; % Fondo blanco

% Subplot superior: Error
subplot(3, 1, 1);
error = X_pso(:,1) - ref(1:length(X_pso(:,1)));
plot(error, 'LineWidth', 2);
title('Error de Medición', 'FontSize', 16);
xlabel('Tiempo (min)', 'FontSize', 16);
ylabel('Error (°C)', 'FontSize', 16);
grid on;

% Subplot del medio: Señal de control
subplot(3, 1, 2);
plot(U_pso, 'r', 'LineWidth', 2); % 'r' especifica el color rojo
title('Señal de Control', 'FontSize', 16);
xlabel('Tiempo (min)', 'FontSize', 16);
ylabel('Señal de Control', 'FontSize', 16);
grid on;

% Subplot inferior: Solo la referencia
subplot(3, 1, 3);
plot(ref(1:18), 'LineWidth', 2);
title('Referencia', 'FontSize', 16);
xlabel('Tiempo (min)', 'FontSize', 16);
ylabel('Temperatura (°C)', 'FontSize', 16);
grid on;

%% Gráficos de comparación

% Crear un gráfico para la salidas y la referencia
fig5 = figure;
fig5.Color = 'white'; % Fondo blanco

% Graficar la salida
plot(X_pso(:, 1), 'LineWidth', 2);
hold on;

% Graficar la salida
plot(X_fmin(:, 1), 'LineWidth', 2);
hold on;

% Graficar la referencia
plot(ref(1:180), 'LineWidth', 2);

% Agregar títulos y etiquetas a los ejes
title('Comparación de la Temperatura Ambiente y la Referencia', 'FontSize', 16);
xlabel('Tiempo (min)', 'FontSize', 16);
ylabel('Temperatura (°C)', 'FontSize', 16);

% Agregar leyendas
legend('Temperatura medida pso', 'Temperatura medida fmincon', 'Temperatura de referencia', 'FontSize', 12);

% Asegurarse de que el gráfico sea visible
hold off;
grid on;

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
