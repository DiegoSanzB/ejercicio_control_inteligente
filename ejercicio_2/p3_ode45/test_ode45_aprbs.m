clear
clc

Ts = 0.001;
T_total = 60;

min_freq = 0.2;
max_freq = 5;

min_amplitude = 0.005;
max_amplitude = 0.01;

aprbs = generate_aprbs(Ts, T_total, min_freq, max_freq, min_amplitude, max_amplitude);
aprbs = aprbs - (max_amplitude + min_amplitude);
plot(aprbs(1, :));

% Calibración del step
T_sim_ = 5;

% % Damos un primer paso
% [t_ode, x] = step(-0.5, 0, T_sim_, [-0.02, 0]);
% figure
% plot(x(:,1));

% Simulamos los steps de la aprbs con los tiempos de muestreo del sistema
len = length(aprbs);
time = 0:Ts:T_total;
simout = zeros(2,len);
x_0 = -0.005;
simout(1,1) = x_0;

for i = 2:len
    % Simulamos un step
    [t_ode, x] = step(aprbs(1,i),0,Ts, simout(:,i-1));
    simout(:,i) = x(end,:);    
end

plot(simout(1,:))
hold on 
plot(aprbs)