function J = fuzzy_function(model, x, Y, alfa, n1, n2, s)
    n = length(s);    
    s_l = s(1:n/2);
    s_u = s(n/2+1:end);
    J = n1*compute_pinaw(model,x,Y,s_l,s_u) + exp(-n2*( compute_picp(model,x,Y,s_l,s_u) - (1.0-alfa) ));
end