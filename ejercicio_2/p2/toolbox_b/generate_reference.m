function reference = generate_reference(temperature_array, time_array, delta_t)
% Crea una referencia tipo escalones dado los array de entrada
% 
% Entradas:
% temperature_array: amplitudes de los escalones de la referencia
% time_array: tiempo para cada uno de los escalones
% delta_t: tiempo de muestreo
% 
% Salidas:
% reference: vector con la referencia completa
% 

reference_length = 0;
steps_array = zeros(length(time_array), 1);

for i = 1:length(time_array)
    steps_array(i) = floor(time_array(i) / delta_t);
    reference_length = reference_length + steps_array(i);
end

reference = zeros(reference_length, 1);
k = 1;

for i = 1:length(temperature_array)
    current_temperature = temperature_array(i);
    current_steps = steps_array(i);
    for j = 1:current_steps
        reference(k) = current_temperature;
        k = k + 1;
    end
end

figure()
plot(reference);
grid on;
title('Referencia', 'FontSize', 18);
xlabel('Tiempo [k]', 'FontSize', 15);
ylabel('r(k) [°C]', 'FontSize', 15);