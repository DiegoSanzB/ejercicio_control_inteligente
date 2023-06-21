
function [t_ode, X, U] = main_2
    function dx = maglev_PD(t, x, u)
        g = 9.8;
        k_mag = 1.24E-3;
        K_d = 10;
        K_p = 1;

        x1 = x(1);
        x2 = x(2);

        assert(x(1)~=0,'X1 es cero')

        dx1 = x2;
        dx2 = g - k_mag/x1^2 * (K_p * (200*u - x1) - K_d * x2)^2;

        dx = [dx1; dx2];
    end

    function [t_ode, x] = step(ref, ini, fin, x0)
        [t_ode, x] = ode45(@maglev_PD, [ini fin], x0, [], ref);     
    end

    function cost = cost_function(u, lambda, ref, T_c, x0)
        cost = 0;
        for i = 1:length(u)
            [~, x] = step(u(i), 0, T_c, x0);
            cost = cost + (ref - x(end,1)).^2 + x(end,2).^2 + lambda * u(i);
            x0 = x(end,:);
        end
    end


    % Calibración del step
    T_sim_ = 5;
    
    % Damos un primer paso
    [t_ode, x] = step(-0.5, 0, T_sim_, [-0.02, 0]);
    figure
    plot(x(:,1));
    
    % Tiempo que demora en estabilizar
    T_c = 0.005;
    T_sim = 1;
    
    % variables del pso
    nvars = 25; % número de variables de decisión
    lb = ones(1,nvars) *-1; % límite inferior
    ub = ones(1,nvars) *-0.0001;  % límite superior
    options = optimoptions('particleswarm', 'SwarmSize', 10, 'FunctionTolerance', 1e-4, 'MaxStallIterations', 15);

    
    % Iteramos por las distintas acciones de control
    x0 = [-0.02, 0];
    lambda = 0.01;
    ref = -0.03;

    U = [];
    X = [];
    
    count = 0;
    u = ones(1, nvars) * -0.5;  % inicializa u para la primera iteración
    for ii = 0:T_c:T_sim
        ii

        count = count + 1;

        % Función de costo que se utilizará en PSO
        fun = @(u) cost_function(u, lambda, ref, T_c, x0);

        % Crea una matriz inicial para el enjambre basándose en u
        initial_swarm = repmat(u, [options.SwarmSize, 1]);
        options.InitialSwarmMatrix = initial_swarm;

        % Aplica PSO para optimizar u
        u = particleswarm(fun, nvars, lb, ub, options);

        % Simulamos la acción de control
        [t_ode, x] = ode45(@maglev_PD, [0 T_c], x0, [], u(1));

        % Actualizamos condiciones iniciales

        x0 = x(end, :)  ; % Actualiza el estado inicial para el próximo paso

        U = [U; repmat(u(1), size(x, 1), 1)];
        X = [X; x];

    end
    
    % Gráfica de las salidas y las entradas de control
    figure;
    subplot(3,1,1);
    plot(X(:, 1)*100);
    title('Output');
    subplot(3,1,2);
    plot(U*100);
    title('Control input');
    subplot(3,1,3);
    plot(X(:,1)-ref);
    title('Error');
    
end