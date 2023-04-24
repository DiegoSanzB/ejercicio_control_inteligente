function picp = compute_picp(model, x, Y, s_l, s_u)
% Computes PICP of x given a model and spreds
% y_hat = ysim(x, model.a, model.b, model.g);
[y_hat_lower, y_hat_upper] = ysim_lower_upper(x, model.a, model.b, model.g, s_l, s_u);

[n, ~] = size(x);

picp = sum(y_hat_lower < Y.val & Y.val < y_hat_upper)/n;
end