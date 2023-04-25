function [y_pred_val, Y_pred] = pred_alfa(X,Y,n_pasos,n_auto,elim_reg,porcen_alfa,x_optim_ent,...
                        x_optim_test,x_optim_val,model, type)
    
    y_pred_val = predict_n_pasos(X.val, model, n_pasos, n_auto, elim_reg, type);
    y_pred_test = predict_n_pasos(X.test, model, n_pasos, n_auto, elim_reg, type);

    Y_pred = Y;
    Y_pred.test = Y.test(n_pasos+1:end,:);
    Y_pred.val = Y.val(n_pasos+1:end,:);
    
    if type ==1
    
    [alfa_optimo, ~, ~,~,I_] = calcular_int_cov_TS(x_optim_ent, x_optim_test(1:end-n_pasos,:), x_optim_val(1:end-n_pasos,:),...
                      model,Y_pred, y_pred_test, y_pred_val, porcen_alfa);
    disp("PINAW: ")
    pinaw = 2*sum(I_)*alfa_optimo/(length(I_)*(max(Y.val) - min(Y.val)))

    
    else
    [~, ~, ~, y_upper, y_lower] = calcular_intervalos_cov_NN(x_optim_ent, x_optim_test(1:end-n_pasos,:), x_optim_val(1:end-n_pasos,:),...
                      model,Y_pred, y_pred_test, y_pred_val, porcen_alfa);
    disp("PINAW: ")
    n = length(y_upper);
    r = max(Y.val) - min(Y.val);
    pinaw = 0;
    for i = 1:n
        pinaw = pinaw + y_upper(i,1) - y_lower(i,1);
    end
    pinaw = pinaw/(n*r)
    end
    
    
  
end