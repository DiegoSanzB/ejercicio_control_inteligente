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
colorbar;
title('Mapa de calor de f(x,y) (PSO)');
xlabel('Número de Iteraciones');
ylabel('Tamaño del Enjambre');
set(gca, 'YTick', 1:length(swarm_sizes), 'YTickLabel', 2:max(swarm_sizes), 'XTick', 1:length(n_iterations_pso), 'XTickLabel', 2:max(n_iterations_pso));

subplot(1, 2, 2);
imagesc(time_pso);
colorbar;
title('Mapa de calor de Tiempo de Ejecución (PSO)');
xlabel('Número de Iteraciones');
ylabel('Tamaño del Enjambre');
set(gca, 'YTick', 1:length(swarm_sizes), 'YTickLabel', 2:max(swarm_sizes), 'XTick', 1:length(n_iterations_pso), 'XTickLabel', 2:max(n_iterations_pso));

% Crear mapas de calor para GA
figure;
set(gcf, 'color', 'white');  % Establece el color de fondo de la figura a blanco
subplot(1, 2, 1);
imagesc(f_star_ga);
colorbar;
title('Mapa de calor de f(x,y) (GA)');
xlabel('Número de Iteraciones');
ylabel('Tamaño de la Población');
set(gca, 'YTick', 1:length(population_size), 'YTickLabel', 1:max(population_size), 'XTick', 1:length(n_iterations_ga), 'XTickLabel',1:max(n_iterations_ga));

subplot(1, 2, 2);
imagesc(time_ga);
colorbar;
title('Mapa de calor de Tiempo de Ejecución (GA)');
xlabel('Número de Iteraciones');
ylabel('Tamaño de la Población');
set(gca, 'YTick', 1:length(population_size), 'YTickLabel', 1:max(population_size), 'XTick', 1:length(n_iterations_ga), 'XTickLabel', 1:max(n_iterations_ga));
