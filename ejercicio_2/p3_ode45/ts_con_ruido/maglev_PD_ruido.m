function dx = maglev_PD_ruido(t, x, u, sigma_s, sigma_p)
    g = 9.8;
    k_mag = 1.24E-3;
    K_d = 10;
    K_p = 1;

    x1 = x(1);
    x2 = x(2);

    assert(x(1)~=0,'X1 es cero')

    dx1 = x2 +  normrnd(0, sigma_p, 1);
    dx2 = g - k_mag/x1^2 * (K_p * (100*u - x1 +  normrnd(0, sigma_s, 1)) - K_d * x2)^2 +  normrnd(0, sigma_p, 1);

    dx = [dx1; dx2];
end

