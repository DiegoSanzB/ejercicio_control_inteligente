function ramp = generate_ramp(T_sim, T_c, x_i, x_f)
    % T_sim: Tiempo total de simulación
    % T_c: Tiempo de muestreo
    % x_i: Posición inicial de la rampa
    % x_f: Posición final de la rampa
    
    % Calcular el número total de puntos en la rampa
    % Esto es igual al tiempo de simulación dividido por el tiempo de muestreo
    n_points = floor(T_sim / T_c) + 1;
    
    % Crear un vector para almacenar los valores de la rampa
    ramp = zeros(1, n_points);
    
    % Calcular la pendiente de la rampa
    % Esto se calcula como (posición final - posición inicial) / (tiempo de simulación)
    slope = (x_f - x_i) / T_sim;
    
    % Llenar el vector de la rampa con los valores correspondientes
    for i = 1:n_points
        % Calcular el tiempo actual
        t = (i - 1) * T_c;
        
        % Calcular el valor de la rampa en el tiempo actual usando la ecuación
        % de una línea: y = mx + b, donde m es la pendiente y b es la posición inicial
        ramp(i) = slope * t + x_i;
    end
end
