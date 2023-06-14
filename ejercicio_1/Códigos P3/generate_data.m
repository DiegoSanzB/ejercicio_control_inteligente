function Y = generate_data(y1, y2, U)
    n = length(U);
    
    Y = zeros(n, 1);
    Y(1) = y1;
    Y(2) = y2;

    for i = 3:n
        y_reg = (0.5 - 0.3*exp(-Y(i-1)^2))*Y(i-1) - (0.2 + 0.8*exp(-Y(i-1)^2))*Y(i-2);
        u_reg = U(i-1) + 0.2*U(i-2) + 0.1*U(i-1)*U(i-2);
        Y(i) = y_reg + u_reg + 0.5*exp(-Y(i-1)^2)*normrnd(0, 1, 1);
    end
end