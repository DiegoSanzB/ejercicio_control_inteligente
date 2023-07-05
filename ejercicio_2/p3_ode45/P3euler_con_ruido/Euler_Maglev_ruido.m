function [x1_, x2_] = Euler_Maglev_ruido(x1, x2, r, r_, Ts)
    % Constantes físicas
    g = 9.8;
    k_mag = 1.24E-3;
    
    % Constantes del controlador
    Kp = 1;
    Kd = 10;
    
    % Dinámica
    x1_ = x1 + Ts * x2;
    x3  = Kp * (100*r - x1) + Kd * ( x2);
    x2_ = x2 + g * Ts - Ts * k_mag * (x3 / x1)^2;
    
    % Aplicar restricciones
    if x1_ > 0
        x1_ = 0;
        x2_ = 0;
    end
    
end
