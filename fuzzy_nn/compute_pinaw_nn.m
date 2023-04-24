function pinaw = compute_pinaw_nn(net, x, Y, s_l, s_u)
% Computes PINAW of x given a model and spreds

[y_hat_lower, y_hat_upper] = ysim_lower_upper_nn(net, x, s_l, s_u);

[n, ~] = size(x);
r = max(Y.val) - min(Y.val);

pinaw = 0;

for i = 1:n
    pinaw = pinaw + y_hat_upper(1,i) - y_hat_lower(1,i);
end

pinaw = pinaw/(n*r);

end