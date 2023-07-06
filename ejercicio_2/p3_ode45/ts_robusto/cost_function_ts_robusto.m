function cost = cost_function_ts_robusto(u, lambda, ref, x0, u0, model, s_l, s_u, eliminated_regressors, u_prev)
    cost = 0;
    
    n = length(u);
    regs = length(x0);
    x_regs = zeros(1, regs+n);
    x_regs(1, 1:regs) = x0;
    u_regs = zeros(1, regs+n);
    u_regs(1, 1:regs) = u0;

    for i = 1:n
        X = [x_regs(1, i:i+regs-1), u_regs(1, i:i+regs-1)];
        X(:,eliminated_regressors) = [];
        % x1 = Euler_Maglev(x0(1), x0(2), u(i), u(i-1), T_c);
        [x1, x1_upper] = ysim_lower_upper(X, model.a, model.b, model.g, s_l, s_u);
        cost = cost + (ref - x1)^2 + lambda *(u(i) - u_prev)^2;
        
        x_regs(1, i+regs) = x1;
        u_regs(1, i+regs) = u(i);
        u_prev = u(i);

        % x0(1, 2:end) = x0(1, 1:end-1);
        % x0(1, 1) = x1;
        % u0(1, 2:end) = u0(1, 1:end-1);
        % u0(1, 1) = u(i);
    end
    % figure;
    % plot(x_regs)
end
