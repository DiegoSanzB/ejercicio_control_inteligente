function aprbs_signal = generate_aprbs(Ts, T_total, min_freq, max_freq, min_amplitude, max_amplitude)
    % Ts: tiempo de muestreo
    % T_total: tiempo total de la señal
    % min_freq: frecuencia mínima de cambio de la señal APRBS
    % max_freq: frecuencia máxima de cambio de la señal APRBS
    % min_amplitude: amplitud mínima de la señal
    % max_amplitude: amplitud máxima de la señal

    t = 0:Ts:T_total;
    aprbs_signal = zeros(1, length(t));
    current_time = 0;

    while current_time < T_total
        % Seleccionar una frecuencia aleatoria dentro del rango [min_freq, max_freq]
        current_freq = min_freq + (max_freq - min_freq) * rand();
        
        % Calcular el tiempo de cambio actual
        switch_time = 1 / current_freq;
        
        % Determinar los índices de inicio y finalización para el intervalo actual
        start_idx = floor(current_time / Ts) + 1;
        end_idx = floor((current_time + switch_time) / Ts);

        if end_idx > length(t)
            end_idx = length(t);
        end

        % Generar una amplitud aleatoria en el rango [min_amplitude, max_amplitude]
        amplitude = min_amplitude + (max_amplitude - min_amplitude) * rand();
        
        % Actualizar la señal APRBS con la amplitud generada
        aprbs_signal(start_idx:end_idx) = amplitude;

        % Actualizar el tiempo actual
        current_time = current_time + switch_time;
    end
end
