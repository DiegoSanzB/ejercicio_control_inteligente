function T_1 = T_1_prediction(T_1_k, T_2_k, T_a, U, delta_t)

c1 = 2.508e6;
c2 = 4.636e7;
cp = 1012;
R = 1.7e-3;
R_a = 1.3e-3;
delta = 0.7;
delta_temperatura = 13; % °C
w = wgn(1, 1, 0.001, 'linear');

B = cp*(1 - delta)*(T_a - T_1_k);

% T_1(k+1)
T_1 = T_1_k + delta_t/c1*(U*(B + delta_temperatura*cp) + (T_2_k - T_1_k)/R + (T_a - T_1_k)/R_a + w);