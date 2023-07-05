function sine_wave = generate_sine(T_sim, T_c, x_i, x_f, Vc, f, A)
    % T_sim: Tiempo total de simulación
    % T_c: Tiempo de muestreo
    % x_i: Amplitud inicial de la señal senoidal
    % x_f: Amplitud final de la señal senoidal
    % Vc: Valor central de la señal senoidal
    % f: Frecuencia de la señal senoidal
    % A: Amplitud de la señal senoidal
    
    % Calcular el número total de puntos en la señal senoidal
    n_points = floor(T_sim / T_c) + 1;
    
    % Crear un vector para almacenar los valores de la señal senoidal
    sine_wave = zeros(1, n_points);
    
    % Calcular la pendiente de la amplitud
    slope = (x_f - x_i) / T_sim;
    
    % Llenar el vector de la señal senoidal con los valores correspondientes
    for i = 1:n_points
        % Calcular el tiempo actual
        t = (i - 1) * T_c;
        
        % Calcular la amplitud actual
        current_amplitude = slope * t + x_i;
        
        % Calcular el valor de la señal senoidal en el tiempo actual
        sine_wave(i) = Vc + current_amplitude * A * sin(2 * pi * f * t);
    end
end
