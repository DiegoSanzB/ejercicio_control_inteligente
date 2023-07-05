function [t_ode, x] = step(ref, ini, fin, x0, sigma_s, sigma_p)
    [t_ode, x] = ode45(@maglev_PD_ruido, [ini fin], x0, [], ref, sigma_s, sigma_p);     
end
