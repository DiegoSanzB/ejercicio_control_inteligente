function pinaw = compute_pinaw(model, x, y_test, s_l, s_u)
% Computes PINAW of x given a model and spreds

[y_hat_lower, y_hat_upper] = ysim_lower_upper(x, model.a, model.b, model.g, s_l, s_u);

[n, ~] = size(x);
r = max(y_test) - min(y_test);

pinaw = 0;

for i = 1:n
    pinaw = pinaw + y_hat_upper(i,1) - y_hat_lower(i,1);
end

pinaw = pinaw/(n*r);

end