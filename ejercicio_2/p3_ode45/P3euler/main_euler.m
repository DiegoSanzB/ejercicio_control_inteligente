clc
clear all
close all
 
    % Constantes
    T_c = 0.001;
    T_sim = 6;
    nvars = 100; % número de variables de decisión
    lb = ones(1, nvars) *-1; % límite inferior
    ub = ones(1, nvars)*1 ;  % límite superior
    options = optimoptions('particleswarm', 'SwarmSize', 50, 'FunctionTolerance', 1e-4, 'MaxStallIterations', 25);
    
    % Variables
    x0 = [-0.04, 0];  %-0.04 funciona pero con lb en -5 y ub en 1
    lambda = 0.00001;
  
min_freq = 0.2;
max_freq = 0.5;

min_amplitude = 0.03;
max_amplitude = 0.04;

aprbs = generate_aprbs(T_c, T_sim, min_freq, max_freq, min_amplitude, max_amplitude);
ref = aprbs*-1;
ref = generate_ramp(T_sim, T_c, -1*max_amplitude, -1*min_amplitude);
% ref = generate_sine(T_sim, T_c, -0.004, -0.004, -0.038, min_freq, -1);
plot(ref*100)
    U = [];
    X = [];
    count = 0;
    u = ones(1, nvars) * -0.02;  % inicializa u para la primera iteración
    
% Iteramos por las distintas acciones de control
for ii = 1:length(ref)
    disp(ii)
    count = count + 1;

    % Función de costo que se utilizará en PSO
    fun = @(u) cost_function(u, lambda, ref(ii), T_c, x0);
    
    tic
    % Crea una matriz inicial para el enjambre basándose en u
    initial_swarm = repmat(u, [options.SwarmSize, 1]);
    options.InitialSwarmMatrix = initial_swarm;

    % Aplica PSO para optimizar u
    u = particleswarm(fun, nvars, lb, ub, options);
    time(ii) = toc;
    
    % Simulamos la acción de control
    [t_ode, x] = step(u(2), 0, T_c, [x0(1) x0(2)]);

    % Actualizamos condiciones iniciales
    x0 = [x(end,1), x(end,2)]; % Actualiza el estado inicial para el próximo paso

    % Agrega el valor de u y x a las matrices U y X
    U = [U; u(2)];
    X = [X; x0];

    % Comprueba si algún valor de x0 supera 2 y en tal caso detén la simulación
    if any(abs(x0) > 1)
        disp('Algún valor de X ha superado 1 metro. Deteniendo la simulación, vuelva a simular');
        break;
    end
end

    
    
    % Gráfica de las salidas y las entradas de control
    figure;
    
    % Gráfico de salida y referencia
    subplot(3,1,1);
    t_euler = 0:T_c:T_sim; % Creando un vector de tiempo
    plot(t_euler, X(:, 1)*100, 'b', t_euler, ones(size(t_euler)).*ref*100, 'r--');
    title('Output and Reference');
    legend('Output', 'Reference');
    
    % Gráfico de entrada de control
    subplot(3,1,2);
    plot(t_euler, U*100);
    title('Control input');
    
    % Gráfico del error
    subplot(3,1,3);
    plot(t_euler, (X(:,1)-ref')*100);
    title('Error');
    
    
    t_euler = 0:T_c:T_sim; % Creando un vector de tiempo




