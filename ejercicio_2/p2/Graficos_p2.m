% Cargar los datos desde los archivos .mat
T_1_out = load('T_1_out.mat');
ref_out = load('ref_out.mat');
u_out = load('u_out.mat'); % Cargar la señal de control

% Extraer la time series
T_1_out = T_1_out.T_1_out;

% Extraer datos de la señal de control
u_out_ts = u_out.u_out; % Extraer la time series de la estructura
u_time = u_out_ts.Time / 60; % Convertir a min
u_data = u_out_ts.Data;

% Extraer el vector de la estructura
ref = ref_out.ref;

% Extraer y reformatear los datos de la time series
T_1_out_time = T_1_out.Time / 60; % Convertir a min
T_1_out_data = squeeze(T_1_out.Data); % Utilizar squeeze para eliminar dimensiones singulares

% Crear un gráfico
fig = figure;
fig.Color = 'white'; % Fondo blanco

% Graficar T_1_out
plot(T_1_out_time, T_1_out_data, 'LineWidth', 2);
hold on;

% Graficar ref_out
ref_time = 0:180; % Crear un vector de tiempo para ref en min
plot(ref_time, ref(1:181,:), 'LineWidth', 2);

% Agregar títulos y etiquetas a los ejes
title('Comparación de la Temperatura Ambiente y la Referencia', 'FontSize', 16);
xlabel('Tiempo (min)', 'FontSize', 16);
ylabel('Temperatura (°C)', 'FontSize', 16);

% Agregar leyendas
legend('Temperatura medida', 'Temperatura de referencia', 'FontSize', 14);

% Ajustar los ejes para que solo tengan el largo de los vectores
axis([0, max(T_1_out_time), min(min(T_1_out_data), min(ref(1:181,:))), max(max(T_1_out_data), max(ref(1:181,:)))]);

% Asegurarse de que el gráfico sea visible
hold off;
grid on;

% Crear un gráfico
fig = figure;
fig.Color = 'white'; % Fondo blanco

% Subplot superior: Error de medición
subplot(2, 1, 1);
ref_time = 0:180; % Crear un vector de tiempo para ref en min
T_1_out_resampled = interp1(T_1_out_time, T_1_out_data, ref_time); % Resample T_1_out_data
error = ref(1:181,:) - T_1_out_resampled'; % Calcular el error
plot(ref_time, error, 'LineWidth', 2);
title('Error de Medición', 'FontSize', 16);
xlabel('Tiempo (min)', 'FontSize', 16);
ylabel('Error (°C)', 'FontSize', 16);
grid on;

% Subplot inferior: Señal de control
subplot(2, 1, 2);
plot(u_time, u_data, 'r', 'LineWidth', 2); % 'r' especifica el color rojo
title('Señal de Control', 'FontSize', 16);
xlabel('Tiempo (min)', 'FontSize', 16);
ylabel('Señal de Control', 'FontSize', 16);
grid on;

% Crear un gráfico solo para la referencia
fig3 = figure;
fig3.Color = 'white';
plot(ref_time, ref(1:181,:), 'LineWidth', 2);
title('Referencia', 'FontSize', 16);
xlabel('Tiempo (min)', 'FontSize', 16);
ylabel('Temperatura (°C)', 'FontSize', 16);
grid on;

% Ajustar los límites del eje y
ref_min = min(ref(1:181,:)) - 2;
ref_max = max(ref(1:181,:)) + 2;
ylim([ref_min ref_max]);
