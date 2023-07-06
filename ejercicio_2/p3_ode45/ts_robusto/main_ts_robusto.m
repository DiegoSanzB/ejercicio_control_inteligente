clear
close all
clc

%% Load Data and Model %%
addpath('ejercicio_2/p3_ode45/')
addpath('ejercicio_2/p3_ode45/ts/')
addpath('ejercicio_2/toolbox_difuso/')
addpath('ejercicio_2/p3_ode45/Referencias')
load('ejercicio_2/p3_ode45/ts/maglev_ts_model.mat')
load('ejercicio_2/p3_ode45/ts/regresores_eliminados_modelo_ts.mat')
load('ejercicio_2/p3_ode45/ts/spreads_ts_model.mat')

load('ejercicio_2/p3_ode45/Referencias/ref_rampa.mat')
% load('ejercicio_2/p3_ode45/Referencias/ref_seno.mat')
% ref = ref + 0.025;
% Constantes
T_c = 0.001;
T_sim = 2;
nvars = 10; % número de variables de decisión
lb = ones(1, nvars) *-1; % límite inferior
ub = ones(1, nvars) * 0.1 ;  % límite superior
options = optimoptions('particleswarm', 'SwarmSize', 50, 'FunctionTolerance', 1e-4, 'MaxStallIterations', 25);
% Variables
lambda = 0.0001;
  
min_freq = 0.2;
max_freq = 5;

min_amplitude = 0;
max_amplitude = 0.03;

% aprbs = generate_aprbs(T_c, T_sim, min_freq, max_freq, min_amplitude, max_amplitude);
% ref = abs(aprbs)*-1;
% ref = generate_ramp(T_sim, T_c, -1*max_amplitude, -1*min_amplitude);
% ref = generate_sine(T_sim, T_c, -0.01, -0.01, -0.03, min_freq, -1);
% ref = ref_rampa;
plot(ref)
U = [];
X = [];
count = 0;
u = ones(1, nvars) * -0.02;  % inicializa u para la primera iteración

%% Inicializamos x0 y u0 para modelo TS
regs = 10;
x0 = -0.04;
x2 = 0;
x0 = x0*ones(1, regs);
u0 = -0.02*ones(1, regs);
u_prev = -0.02;

n = length(s);    
s_l = s(1:n/2);
s_u = s(n/2+1:end);

time = zeros(length(ref));

%% Iteramos por las distintas acciones de control
for ii = 1:length(ref)
    disp(ii)
    count = count + 1;

    % Función de costo que se utilizará en PSO
    fun = @(u) cost_function_ts_robusto(u, lambda, ref(ii), x0, u0, model, s_l, s_u, eliminated_regressors, u_prev);
    
%     Crea una matriz inicial para el enjambre basándose en u
    tic

    initial_swarm = repmat(u, [options.SwarmSize, 1]);
    options.InitialSwarmMatrix = initial_swarm;
    
    
    % Aplica PSO para optimizar u
    u = particleswarm(fun, nvars, lb, ub, options);
        
    time(ii) = toc;

    % Simulamos la acción de control
    [t_ode, x] = step(u(1), 0, T_c, [x0(1) x2]);


    % Actualizamos condiciones iniciales
    % x0 = [x(end,1), x(end,2)]; % Actualiza el estado inicial para el próximo paso
    x0(1, 2:end) = x0(1, 1:end-1);
    x0(1, 1) = x(end,1);
    u0(1, 2:end) = u0(1, 1:end-1);
    u0(1, 1) = u(1);
    u_prev = u(1);
    x2 = x(end, 2);

    U = [U; u(1)];
    X = [X; [x(end,1), x2]];
    disp(ref(ii))
    disp(x(end,1))
    disp(u(1))

    if any(abs(x(end,1)) > 1)
        disp('Algún valor de X ha superado 1 metro. Deteniendo la simulación, vuelva a simular');
        break;
    end
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