function T_2 = T_2_prediction(T_1_k, T_2_k, delta_t)

c1 = 2.508e6;
c2 = 4.636e7;
cp = 1012;
R = 1.7e-3;
R_a = 1.3e-3;
delta = 0.7;
delta_temperatura = 13; % °C
w = wgn(1, 1, 0.001, 'linear');


% T_2(k+1)
T_2 = T_2_k + delta_t/c2*((T_1_k - T_2_k)/R + w);