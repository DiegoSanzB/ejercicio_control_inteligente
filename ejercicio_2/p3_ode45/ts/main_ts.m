clear
close all
clc

%% Load Data and Model %%
addpath('ejercicio_2/p3_ode45/')
addpath('ejercicio_2/toolbox_difuso/')
load('ejercicio_2/p3_ode45/ts/maglev_ts_model.mat')
load('ejercicio_2/p3_ode45/ts/regresores_eliminados_modelo_ts.mat')


% Constantes
T_c = 0.001;
T_sim = 2;
nvars = 50; % número de variables de decisión
lb = ones(1, nvars) *-5; % límite inferior
ub = ones(1, nvars) * 5 ;  % límite superior
options = optimoptions('particleswarm', 'SwarmSize', 50, 'FunctionTolerance', 1e-4, 'MaxStallIterations', 25, 'UseParallel', true);
% Variables
lambda = 0.00001;
  
min_freq = 0.2;
max_freq = 5;

min_amplitude = 0;
max_amplitude = 0.03;

aprbs = generate_aprbs(T_c, T_sim, min_freq, max_freq, min_amplitude, max_amplitude);
ref = abs(aprbs)*-1;
% ref = generate_ramp(T_sim, T_c, -1*max_amplitude, -1*min_amplitude);
ref = generate_sine(T_sim, T_c, -0.01, -0.01, -0.03, min_freq, -1);
plot(ref*100)
U = [];
X = [];
count = 0;
u = ones(1, nvars) * -0.02;  % inicializa u para la primera iteración

%% Inicializamos x0 y u0 para modelo TS
regs = 10;
x0 = -0.02;
x0 = x0*ones(1, regs);
u0 = -0.02*ones(1, regs);
u_prev = -0.02;
%% Iteramos por las distintas acciones de control
for ii = 1:length(ref)
    disp(ii)
    count = count + 1;

    % Función de costo que se utilizará en PSO
    fun = @(u) cost_function_ts(u, lambda, ref(ii), x0, u0, model, eliminated_regressors, u_prev);

    % Crea una matriz inicial para el enjambre basándose en u
    initial_swarm = repmat(u, [options.SwarmSize, 1]);
    options.InitialSwarmMatrix = initial_swarm;

    % Aplica PSO para optimizar u
    u = particleswarm(fun, nvars, lb, ub, options);

    % Simulamos la acción de control
    
    [t_ode, x] = step(u(1), 0, T_c, [x0(1) x0(2)]);
    % Actualizamos condiciones iniciales
    % x0 = [x(end,1), x(end,2)]; % Actualiza el estado inicial para el próximo paso
    x0(1, 2:end) = x0(1, 1:end-1);
    x0(1, 1) = x(end,1);
    u0(1, 2:end) = u0(1, 1:end-1);
    u0(1, 1) = u(1);
    u_prev = u(1);

    U = [U; u(1)];
    X = [X; [x(end,1), x(end,2)]];
    disp(x(end,1))
end

%% Graficos
% Gráfica de las salidas y las entradas de control
figure;

% Gráfico de salida y referencia
subplot(3,1,1);
t_ts = 0:T_c:T_sim; % Creando un vector de tiempo
plot(t_ts, X(:, 1)*100, 'b', t_ts, ones(size(t_ts)).*ref*100, 'r--');
title('Output and Reference');
legend('Output', 'Reference');

% Gráfico de entrada de control
subplot(3,1,2);
plot(t_ts, U*100);
title('Control input');

% Gráfico del error
subplot(3,1,3);
plot(t_ts, (X(:,1)-ref')*100);
title('Error');