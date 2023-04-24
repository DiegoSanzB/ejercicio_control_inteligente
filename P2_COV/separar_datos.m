function [Y_ent, Y_test, Y_val, X_ent, X_test, X_val] = separar_datos(y, x, porcentajes)
n = length(y);

n_ent = floor(n*porcentajes(1)/100);
n_test = floor(n*porcentajes(2)/100) + n_ent;
n_val = floor(n*porcentajes(3)/100) + n_test;

Y_ent = y(1:n_ent);
Y_test = y(n_ent+1:n_test);
Y_val = y(n_test+1:n_val-1);

X_ent = x(1:n_ent, :);
X_test = x(n_ent+1:n_test, :);
X_val = x(n_test+1:n_val-1, :);
end