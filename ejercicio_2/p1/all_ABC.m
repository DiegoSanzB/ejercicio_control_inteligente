clear all
close all
clc

%% Definición de la función
f = @(x) -abs(sin(x(1))*cos(x(2))*exp(abs(1 - sqrt(x(1)^2 + x(2)^2)/pi)));
lb = [-10, -10];
ub = [10, 10];
nvars = 2;             % Número de variables

% Límites de la gráfica y de la optimización
x = linspace(-10,10);
y = linspace(-10,10);
[X,Y] = meshgrid(x,y);

Z = -abs(sin(X).*cos(Y).*exp(abs(1 - sqrt(X.^2 + Y.^2)./pi)));

% Gráfica de la función
figure
surf(X,Y,Z);
xlabel('x')
ylabel('y')
zlabel('f(x, y)')
title('Gráfica de la función f(x, y)')
shading interp

%% fmincon

% Optimización
options = optimoptions('fmincon','Algorithm','interior-point'); % Elige el algoritmo 'interior-point'

% Número de iteraciones 
n = 50; % Cambia este valor si quieres probar más o menos puntos iniciales

% Inicializar matrices para almacenar los resultados
resultsA = zeros(n, 6); % Matriz de resultados para x0, y0, x*, y*, f* y tiempo

for i = 1:n
    % Valores iniciales aleatorios
    x0 = (ub - lb) .* rand(1, 2) + lb;   %contiene valores random para x0 e y0

    % Medir el tiempo de ejecución
    tic
    [x_star, f_star] = fmincon(f, x0, [], [], [], [], lb, ub, [], options);
    time = toc;

    % Almacenar los resultados
    resultsA(i, :) = [x0, x_star, f_star, time];

    % Mostrar los resultados de esta iteración
    fprintf('Iteración %d: El mínimo de f(x, y) es %f, encontrado en el punto x* = %f, y* = %f.\n', i, f_star, x_star(1), x_star(2));
    fprintf('El tiempo de ejecución fue %f segundos.\n', time);
end

% Nombres de las columnas
headers = {'x0', 'y0', 'x*', 'y*', 'f*', 'Tiempo de ejecución'};

% Borrar los archivos antiguos si existen
if exist('resultsA.csv', 'file')
    delete('resultsA.csv');
end
if exist('resultsA.xlsx', 'file')
    delete('resultsA.xlsx');
end

% Crear tabla de resultados
results_tableA = array2table(resultsA, 'VariableNames', headers);

% Guardar los resultados en un archivo CSV
writetable(results_tableA, 'resultsA.csv');

% Guardar los resultados en un archivo Excel
writetable(results_tableA, 'resultsA.xlsx');

% Mostrar el mínimo global encontrado
[f_star_min, idx] = min(resultsA(:, 5));
x_star_min = resultsA(idx, 3:4);
fprintf('El mínimo global de f(x, y) es %f, encontrado en el punto x* = %f, y* = %f.\n', f_star_min, x_star_min(1), x_star_min(2));


    
%% ps0    

%Parámetros de la simulación
n_particles = 2:1:30;   % Cambiar este vector para probar diferentes números de partículas
n_iterations = 2:1:30;  % Cambiar este vector para probar diferentes números de iteraciones
swarm_sizes = 2:1:30;   % Cambiar este vector para probar diferentes tamaños de enjambre

% Prealocación de matrices de resultados
results = zeros(length(n_particles)*length(n_iterations)*length(swarm_sizes), 7); % Matriz de resultados
counter = 1; % Contador para la matriz de resultados

% Bucle a través de diferentes números de partículas, iteraciones y tamaños de enjambre
for k = 1:length(swarm_sizes)
    for i = 1:length(n_particles)
        for j = 1:length(n_iterations)
            % Parámetros de PSO
            options = optimoptions(@particleswarm,'SwarmSize',swarm_sizes(k),'MaxIterations',n_iterations(j),'Display','off');
            
            % Medir el tiempo de ejecución
            tic
            [x_star, f_star] = particleswarm(f, nvars, lb, ub, options);
            time = toc;

            % Almacenar los resultados
            results(counter, :) = [swarm_sizes(k), n_particles(i), n_iterations(j), x_star(1), x_star(2), f_star, time];
            counter = counter + 1;

            % Mostrar los resultados de esta iteración
            fprintf('SwarmSize: %d, Partículas: %d, Iteraciones: %d\n', swarm_sizes(k), n_particles(i), n_iterations(j));
            fprintf('El máximo de f(x, y) es %f, encontrado en el punto x* = %f, y* = %f.\n', f_star, x_star(1), x_star(2));
            fprintf('El tiempo de ejecución fue %f segundos.\n\n', time);
        end
    end
end

% Nombres de las columnas
headers = {'SwarmSize', 'Número de partículas', 'Número de iteraciones', 'x*', 'y*', 'f*', 'Tiempo de ejecución'};

% Borrar los archivos antiguos si existen
if exist('pso_results.csv', 'file')
    delete('pso_results.csv');
end
if exist('pso_results.xlsx', 'file')
    delete('pso_results.xlsx');
end

% Crear tabla de resultados
results_table = array2table(results, 'VariableNames', headers);

% Guardar los resultados en un archivo CSV
writetable(results_table, 'pso_results.csv');

% Guardar los resultados en un archivo Excel
writetable(results_table, 'pso_results.xlsx');


%% ga

% Definición de la función
f = @(x) -abs(sin(x(1))*cos(x(2))*exp(abs(1 - sqrt(x(1)^2 + x(2)^2)/pi)));

% Parámetros de la simulación
population_size = 1:1:30;  % Cambiar este vector para probar diferentes tamaños de población
n_iterations = 1:1:30; % Cambiar este vector para probar diferentes números de iteraciones

% Prealocación de matrices de resultados
results = zeros(length(population_size)*length(n_iterations), 6); % Matriz de resultados para tamaño de la población, número de iteraciones, x*, y*, f* y tiempo
counter = 1; % Contador para la matriz de resultados

% Bucle a través de diferentes tamaños de población e iteraciones
for i = 1:length(population_size)
    for j = 1:length(n_iterations)
        % Parámetros de GA
        options = optimoptions(@ga,'PopulationSize',population_size(i),'MaxGenerations',n_iterations(j),'Display','off');
        
        % Medir el tiempo de ejecución
        tic
        [x_star, f_star] = ga(f, nvars, [], [], [], [], lb, ub, [], options);
        time = toc;

        % Almacenar los resultados
        results(counter, :) = [population_size(i), n_iterations(j), x_star, f_star, time];
        counter = counter + 1;

        % Mostrar los resultados de esta iteración
        fprintf('Tamaño de población: %d, Iteraciones: %d\n', population_size(i), n_iterations(j));
        fprintf('El máximo de f(x, y) es %f, encontrado en el punto x* = %f, y* = %f.\n', f_star, x_star(1), x_star(2));
        fprintf('El tiempo de ejecución fue %f segundos.\n\n', time);
    end
end

% Nombres de las columnas
headers = {'Tamaño de la población', 'Número de iteraciones', 'x*', 'y*', 'f*', 'Tiempo de ejecución'};

% Borrar los archivos antiguos si existen
if exist('ga_results.csv', 'file')
    delete('ga_results.csv');
end
if exist('ga_results.xlsx', 'file')
    delete('ga_results.xlsx');
end

% Crear tabla de resultados
results_table = array2table(results, 'VariableNames', headers);

% Guardar los resultados en un archivo CSV
writetable(results_table, 'ga_results.csv');

% Guardar los resultados en un archivo Excel
writetable(results_table, 'ga_results.xlsx');

% Encontrar el máximo global en los resultados
f_star_max = min(results(:, 6));

% Encontrar las combinaciones que llegaron al máximo global
optimal_combinations = results(results(:, 6) == f_star_max, :);

% Crear tabla de resultados óptimos
optimal_results_table = array2table(optimal_combinations, 'VariableNames', headers);

% Borrar el archivo antiguo si existe
if exist('pso_optimal_results.xlsx', 'file')
    delete('pso_optimal_results.xlsx');
end

% Guardar los resultados óptimos en un archivo Excel
writetable(optimal_results_table, 'pso_optimal_results.xlsx');
        