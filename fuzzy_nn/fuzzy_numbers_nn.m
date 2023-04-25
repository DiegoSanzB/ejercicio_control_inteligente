function pso_result = fuzzy_numbers_nn(net, layers, x, Y, n1, n2, alfa)    
% Function to minimize
J = @(s) fuzzy_function_nn(net,x,Y,alfa,n1,n2,s);

% PSO
nvars = 2*layers;
lb = zeros(nvars,1);
ub = zeros(nvars,1)+10;
options = optimoptions('particleswarm','SwarmSize',100, 'Display', 'iter', 'FunctionTolerance', 1e-3, 'MaxStallIterations', 15, 'UseParallel', true);
pso_result = particleswarm(J, nvars, lb, ub, options);
end