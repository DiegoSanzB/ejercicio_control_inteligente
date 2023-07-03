function [x1_, x2_, x3_] = Euler_Maglev(x1, x2,x3,r, r_, Ts)

    % Constantes físicas
    g = 9.8;
    k_mag = 1.24E-3;
    
    % Constantes del controlador
    Kp = 1;
    Kd = 10;
    
    % Dinámica
    x1_ = x1 + Ts*x2;
    x2_ = x2 + g*Ts- Ts*k_mag*(x3/x1)^2;
    x3_ = x3 + Ts*Kp*(r-x1) + Ts*Kd*((r-r_)/Ts - x2);
end