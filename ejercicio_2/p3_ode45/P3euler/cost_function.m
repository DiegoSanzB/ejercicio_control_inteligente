function cost = cost_function(u, lambda, ref, T_c, x0)
    cost = 0;
    for i = 2:length(u)
        [x1, x2] = Euler_Maglev(x0(1), x0(2), u(i), u(i-1), T_c);
        cost = cost + (ref - x1)^2 + lambda *(u(i) - u(i-1))^2;
        x0 = [x1, x2];
    end
end
