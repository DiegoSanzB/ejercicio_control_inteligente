function pso_result = fuzzy_numbers(model, x, Y, n1, n2, alfa)    
% Function to minimize
J = @(s) fuzzy_function(model,x,Y,alfa,n1,n2,s);

% PSO
[r,p] = size(model.a);
nvars = 2*r*p;
lb = zeros(nvars,1);
ub = zeros(nvars,1)+1;
options = optimoptions('particleswarm','SwarmSize',100, 'Display', 'iter', 'FunctionTolerance', 1e-3, 'MaxStallIterations', 15, 'UseParallel', true);
pso_result = particleswarm(J, nvars, lb, ub, options);
end