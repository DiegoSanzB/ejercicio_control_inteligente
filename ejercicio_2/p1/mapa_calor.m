clear all
close all
clc
warning off

n_iterations_pso = 2:1:30;  % Cambiar este vector para probar diferentes números de iteraciones
swarm_sizes = 2:1:30;   % Cambiar este vector para probar diferentes tamaños de enjambre
population_size = 1:1:30;  % Cambiar este vector para probar diferentes tamaños de población
n_iterations_ga = 1:1:30; % Cambiar este vector para probar diferentes números de iteraciones

% Cargar resultados de PSO desde el archivo Excel
pso_data = readtable('pso_results_final.xlsx');

% Cargar resultados de GA desde el archivo Excel
ga_data = readtable('ga_results_final.xlsx');

% Crear matrices para almacenar los datos de f(x,y) y tiempo de ejecución
f_star_pso = zeros(length(swarm_sizes), length(n_iterations_pso));
time_pso = zeros(length(swarm_sizes), length(n_iterations_pso));
f_star_ga = zeros(length(population_size), length(n_iterations_ga));
time_ga = zeros(length(population_size), length(n_iterations_ga));

% Llenar las matrices con los datos de f(x,y) y tiempo de ejecución
for i = 1:size(pso_data, 1)
    swarm_size_idx = pso_data.SwarmSize(i) - 1;
    n_iter_idx = pso_data.N_meroDeIteraciones(i) - 1;
    f_star_pso(swarm_size_idx, n_iter_idx) = pso_data.f_(i);
    time_pso(swarm_size_idx, n_iter_idx) = pso_data.TiempoDeEjecuci_n(i);
end

for i = 1:size(ga_data, 1)
    pop_size_idx = ga_data.Tama_oDeLaPoblaci_n(i);
    n_iter_idx = ga_data.N_meroDeIteraciones(i);
    f_star_ga(pop_size_idx, n_iter_idx) = ga_data.f_(i);
    time_ga(pop_size_idx, n_iter_idx) = ga_data.TiempoDeEjecuci_n(i);
end

% Crear mapas de calor para PSO
figure;
set(gcf, 'color', 'white');  % Establece el color de fondo de la figura a blanco
subplot(1, 2, 1);
imagesc(f_star_pso);
c1 = colorbar;
ylabel(c1, 'f(x,y)','FontSize', 16)
title('Mapa de calor de f(x,y) (PSO)','FontSize', 16);
xlabel('Número de Iteraciones','FontSize', 16);
ylabel('Tamaño del Enjambre','FontSize', 16);
set(gca, 'YTick', 1:length(swarm_sizes), 'YTickLabel', 2:max(swarm_sizes), 'XTick', 1:length(n_iterations_pso), 'XTickLabel', 2:max(n_iterations_pso));

subplot(1, 2, 2);
imagesc(time_pso);
c2 = colorbar;
ylabel(c2, 'Tiempo de ejecución','FontSize', 16);
title('Mapa de calor de Tiempo de Ejecución (PSO)','FontSize', 16);
xlabel('Número de Iteraciones','FontSize', 16);
ylabel('Tamaño del Enjambre','FontSize', 16);
set(gca, 'YTick', 1:length(swarm_sizes), 'YTickLabel', 2:max(swarm_sizes), 'XTick', 1:length(n_iterations_pso), 'XTickLabel', 2:max(n_iterations_pso));

% Crear mapas de calor para GA
figure;
set(gcf, 'color', 'white');  % Establece el color de fondo de la figura a blanco
subplot(1, 2, 1);
imagesc(f_star_ga);
c3 = colorbar;
ylabel(c3, 'f(x, y)','FontSize', 16);
title('Mapa de calor de f(x,y) (GA)','FontSize', 16);
xlabel('Número de Iteraciones','FontSize', 16);
ylabel('Tamaño de la Población','FontSize', 16);
set(gca, 'YTick', 1:length(population_size), 'YTickLabel', 1:max(population_size), 'XTick', 1:length(n_iterations_ga), 'XTickLabel',1:max(n_iterations_ga));

subplot(1, 2, 2);
imagesc(time_ga);
c4 = colorbar;
ylabel(c4, 'Tiempo de ejecución','FontSize', 16);
title('Mapa de calor de Tiempo de Ejecución (GA)','FontSize', 16);
xlabel('Número de Iteraciones','FontSize', 16);
ylabel('Tamaño de la Población','FontSize', 16);
set(gca, 'YTick', 1:length(population_size), 'YTickLabel', 1:max(population_size), 'XTick', 1:length(n_iterations_ga), 'XTickLabel', 1:max(n_iterations_ga));

% Ignorar la primera fila de f_star_ga y time_ga
f_star_ga = f_star_ga(2:end, 2:end);
time_ga = time_ga(2:end, 2:end);

% Ahora, f_star_ga y f_star_pso, así como time_ga y time_pso deben tener el mismo tamaño (29x29)

% Crear gráfico de dispersión para comparar la salida f(x,y) entre PSO y GA
figure;
set(gcf, 'color', 'white');
scatter(reshape(f_star_pso, 1, []), reshape(f_star_ga, 1, []), 'filled');
xlabel('f(x,y) PSO', 'FontSize', 16);
ylabel('f(x,y) GA', 'FontSize', 16);
title('Comparación de f(x,y) entre PSO y GA', 'FontSize', 16);
grid on;

% Crear gráfico de dispersión para comparar el tiempo de ejecución entre PSO y GA
figure;
set(gcf, 'color', 'white');
scatter(reshape(time_pso, 1, []), reshape(time_ga, 1, []), 'filled');
xlabel('Tiempo de ejecución PSO', 'FontSize', 16);
ylabel('Tiempo de ejecución GA', 'FontSize', 16);
title('Comparación de Tiempo de Ejecución entre PSO y GA', 'FontSize', 16);
grid on;

% Ahora, f_star_ga y f_star_pso, así como time_ga y time_pso deben tener el mismo tamaño (29x29)
%%
% Crear gráfico de dispersión para comparar f(x,y) y tiempo de ejecución
figure;
set(gcf, 'color', 'white');

% Puntos para PSO
scatter(reshape(time_pso, 1, []), reshape(f_star_pso, 1, []), 'filled', 'MarkerFaceColor', 'r');
hold on;

% Puntos para GA
scatter(reshape(time_ga, 1, []), reshape(f_star_ga, 1, []), 'filled', 'MarkerFaceColor', 'b');

xlabel('Tiempo de Ejecución', 'FontSize', 16);
ylabel('f(x, y)', 'FontSize', 16);
title('Comparación de f(x, y) y Tiempo de Ejecución entre PSO y GA', 'FontSize', 16);
legend('PSO', 'GA', 'Location', 'best', 'FontSize', 16);
grid on;

f_min = -19.20850; % Debes definir esto como el valor mínimo conocido de la función

% Calcula los errores
errores_pso = f_star_pso(:) - f_min;
errores_ga = f_star_ga(:) - f_min;

figure;
set(gcf, 'color', 'white'); % Establece el color de fondo de la figura a blanco

% Crea un histograma para los errores de PSO
subplot(1, 2, 1);
num_bins_pso = round(sqrt(numel(errores_pso)));
histogram(errores_pso, num_bins_pso, 'Normalization', 'count'); % O simplemente: histogram(errores_pso, num_bins_pso);
title('Histograma de Errores (PSO)');
xlabel('Error');
ylabel('Frecuencia');

% Crea un histograma para los errores de GA
subplot(1, 2, 2);
num_bins_ga = round(sqrt(numel(errores_ga)));
histogram(errores_ga, num_bins_ga, 'Normalization', 'count'); % O simplemente: histogram(errores_ga, num_bins_ga);
title('Histograma de Errores (GA)');
xlabel('Error');
ylabel('Frecuencia');

figure;
set(gcf, 'color', 'white');  % Establece el color de fondo de la figura a blanco

% Mapa de calor para PSO
subplot(1, 2, 1);
imagesc(f_star_pso);
c1 = colorbar;
ylabel(c1, 'f(x,y)','FontSize', 16)
title('Mapa de calor de f(x,y) óptima (PSO)','FontSize', 16);
xlabel('Número de Iteraciones','FontSize', 16);
ylabel('Tamaño del Enjambre','FontSize', 16);
set(gca, 'YTick', 1:length(swarm_sizes), 'YTickLabel', 2:max(swarm_sizes), 'XTick', 1:length(n_iterations_pso), 'XTickLabel', 2:max(n_iterations_pso));

% Mapa de calor para GA
subplot(1, 2, 2);
imagesc(f_star_ga);
c2 = colorbar;
ylabel(c2, 'f(x,y)','FontSize', 16)
title('Mapa de calor de f(x,y) óptima (GA)','FontSize', 16);
xlabel('Número de Iteraciones','FontSize', 16);
ylabel('Tamaño de la Población','FontSize', 16);
set(gca, 'YTick', 1:length(population_size), 'YTickLabel', 1:max(population_size), 'XTick', 1:length(n_iterations_ga), 'XTickLabel', 1:max(n_iterations_ga));

