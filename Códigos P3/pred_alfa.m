function [y_pred_val, Y_pred] = pred_alfa(X,Y,n_pasos,n_auto,elim_reg,porcen_alfa,x_optim_ent,...
                        x_optim_test,x_optim_val,model)
    
    y_pred_val = predict_n_pasos(X.val, model, n_pasos, n_auto, elim_reg, 1);
    y_pred_test = predict_n_pasos(X.test, model, n_pasos, n_auto, elim_reg, 1);

    Y_pred = Y;
    Y_pred.test = Y.test(n_pasos:end,:);
    Y_pred.val = Y.val(n_pasos:end,:);
    
    [~] = ...
    calcular_metricas(x_optim_ent, x_optim_test(1:end-n_pasos+1,:), x_optim_val(1:end-n_pasos+1,:),...
                      model,Y_pred, y_pred_test, y_pred_val, porcen_alfa);
end