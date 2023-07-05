function [t_ode, x] = step(ref, ini, fin, x0)
    [t_ode, x] = ode45(@maglev_PD, [ini fin], x0, [], ref);     
end
