 
for ii = 0:T_c:T_sim
    
    
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