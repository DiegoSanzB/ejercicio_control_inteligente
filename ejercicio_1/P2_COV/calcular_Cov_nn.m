function sigma = calcular_Cov_nn(net, X, X_)
    
    leng = size(X,1);
    leng_ = size(X_, 1);
    
    Z = zeros(leng,size(net.b1,1));
    sigma = zeros(leng_,1);

    %Normalizamos la data de entrada
    ymax = net.input_ymax;
    ymin = net.input_ymin;
    xmax = net.input_xmax;
    xmin = net.input_xmin;
    

   % Recorremos cada instante de X
    for i = 1:leng
        input_n =(ymax-ymin) * (X(i, :)'-xmin) ./ (xmax-xmin) + ymin;
        Z(i,:) = tanh(net.IW * input_n + net.b1);
    end
    
    % Recorremos X_ para obtener los valores de Z_k
    for i = 1:leng_
        input_n =(ymax-ymin) * (X_(i, :)'-xmin) ./ (xmax-xmin) + ymin;
        Zk = tanh(net.IW * input_n + net.b1);
        sigma(i) = sqrt(1+Zk'*inv(Z'*Z)*Zk); 
    end
    
end