clear all
close all
clc

seed = 1;
rng(seed, 'twister');

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

% Encontrar el mínimo en la matriz Z
[minZ, idxZ] = min(Z(:));
[idxX, idxY] = ind2sub(size(Z), idxZ);

% Coordenadas del mínimo
minX = X(idxX, idxY);
minY = Y(idxX, idxY);

% Gráfica de la función
figure
surf(X,Y,Z);
hold on; % Mantén la gráfica actual para agregar más elementos

% Agregar el punto mínimo como un punto rojo y etiqueta para la leyenda
hMin = scatter3(minX, minY, minZ, 100*3, 'r', 'filled'); % Agregar el punto mínimo como un punto rojo

% Agregar etiqueta de texto con los valores de x, y y z
str = sprintf('Minimo en x = %.2f, y = %.2f, f(x,y) = %.2f', minX, minY, minZ);
text(minX, minY, minZ + 1, str, 'HorizontalAlignment', 'center','FontSize', 12);

xlabel('x','FontSize', 16)
ylabel('y','FontSize', 16)
zlabel('f(x, y)','FontSize', 16)
title('Gráfica de la función f(x, y) con el mínimo marcado y etiquetado','FontSize', 16)
shading interp

% Agregar leyenda solo para el punto mínimo
legend(hMin, 'Punto mínimo','FontSize', 12);

%% fmincon

% Optimización
options = optimoptions('fmincon','Algorithm','interior-point'); % Elige el algoritmo 'interior-point'

% Número de iteraciones 
n = 20; % Cambia este valor si quieres probar más o menos puntos iniciales

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

end

% Al final del bucle for, ordenar los resultados por f* (columna 5)
resultsA = sortrows(resultsA, 5);

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

% Guardar los resultados en un archivo Excel
writetable(results_tableA, 'resultsA.xlsx');


%% ps0    

%Parámetros de la simulación
n_iterations = 2:1:30;  % Cambiar este vector para probar diferentes números de iteraciones
swarm_sizes = 2:1:30;   % Cambiar este vector para probar diferentes tamaños de enjambre

% Prealocación de matrices de resultados
results = zeros(length(n_iterations)*length(swarm_sizes), 6); % Matriz de resultados
counter = 1; % Contador para la matriz de resultados

% Bucle a través de diferentes números de iteraciones y tamaños de enjambre
for k = 1:length(swarm_sizes)
    for j = 1:length(n_iterations)
        % Parámetros de PSO
        options = optimoptions(@particleswarm, 'SwarmSize', swarm_sizes(k), 'MaxIterations', n_iterations(j), 'Display', 'off');

        % Medir el tiempo de ejecución
        tic
        [x_star, f_star] = particleswarm(f, nvars, lb, ub, options);
        time = toc;

        % Almacenar los resultados
        results(counter, :) = [swarm_sizes(k), n_iterations(j), x_star(1), x_star(2), f_star, time];
        counter = counter + 1;
    end
end

% Calcular la desviación estándar de la variable f*
std_f_star_pso = std(results(:, 5));

% Mostrar la desviación estándar de f*
fprintf('La desviación estándar de f* es %f.\n', std_f_star);

% Nombres de las columnas
headers = {'SwarmSize', 'Número de iteraciones', 'x*', 'y*', 'f*', 'Tiempo de ejecución'};

% Crear tabla de resultados
results_table = array2table(results, 'VariableNames', headers);

% Ordenar la tabla por la columna 'f*' en orden ascendente
results_table = sortrows(results_table, 'f*');

if exist('pso_results.xlsx', 'file')
    delete('pso_results.xlsx');
end

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
    end
end

% Calcular la desviación estándar de la variable f*
std_f_star_ga = std(results(:, 5));

% Nombres de las columnas
headers = {'Tamaño de la población', 'Número de iteraciones', 'x*', 'y*', 'f*', 'Tiempo de ejecución'};

if exist('ga_results.xlsx', 'file')
    delete('ga_results.xlsx');
end

% Crear tabla de resultados
results_table = array2table(results, 'VariableNames', headers);

% Ordenar la tabla por la columna 'f*' en orden ascendente
results_table = sortrows(results_table, 'f*');

% Guardar los resultados en un archivo Excel
writetable(results_table, 'ga_results.xlsx');

        