function pred = predict_n_pasos(data, model,n_pasos,n_auto, lista_regresores_eliminados, tipo)
    
    % iteramos por los pasos
    inputs = data;
    
    for n = 1:n_pasos
        
        % Eliminamos los regresores pertinentes
        in = inputs;
        in(:,lista_regresores_eliminados) = [];
        
        %Generamos una salida con el modelo ts
        if tipo == 1
            y = ysim(in, model.a, model.b, model.g);
            
        else
            y = my_ann_evaluation(model,in');
        end
        
        % desplazamos la matriz de inputs y agregamis el instante futuro
        % primero los y
        inputs(:,2:n_auto) = inputs(:,1:n_auto-1);
        inputs(:,1) = y;
        
        % luego los u
        inputs(1:end-n,n_auto+1:end) = inputs(2:end-n+1,n_auto+1:end);
        
      
    end
    
    pred = inputs(1:end-n_pasos+1, 1);
    
end
    