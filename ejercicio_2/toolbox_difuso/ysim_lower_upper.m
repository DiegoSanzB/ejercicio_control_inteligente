function [y_lower, y_upper] = ysim_lower_upper(X,a,b,g,s_l,s_u)
% Creates the model's lower and upper predicctions
% y is the vector of outputs when evaluating the TS defined by a,b,g
% X is the data matrix
% a is the cluster's Std^-1 
% b is the cluster's center
% g is the consecuence parameters
% s_l is the lower spread
% s_u is the upper spread

% Nd number of point we want to evaluate
% n is the number of regressors of the TS model

[Nd,n]=size(X);

% NR is the number of rules of the TS model
NR=size(a,1);         
y_lower=zeros(Nd,1);
y_upper=zeros(Nd,1);
         
     
for k=1:Nd 
    
    % W(r) is the activation degree of the rule r
    % mu(r,i) is the activation degree of rule r, regressor i
    W=ones(1,NR);
    mu=zeros(NR,n);
    for r=1:NR
     for i=1:n
       mu(r,i)=exp(-0.5*(a(r,i)*(X(k,i)-b(r,i)))^2);  
       W(r)=W(r)*mu(r,i);
     end
    end

    % Wn(r) is the normalized activation degree
    if sum(W)==0
        Wn=W;
    else
        Wn=W/sum(W);
    end
    
    % Now we evaluate the consequences
    [p, q] = size(g);
    s_l_reshape = reshape(s_l,p,q-1);
    s_u_reshape = reshape(s_u,p,q-1);

    yr_lower=g*[1 ;X(k,:)'] - s_l_reshape*abs(X(k,:)');
    yr_upper=g*[1 ;X(k,:)'] + s_u_reshape*abs(X(k,:)');
    
    % Finally the output
    y_lower(k,1)=Wn*yr_lower;
    y_upper(k,1)=Wn*yr_upper;
%     if y(k) < 5
%         y(k) = 0;
%     end

end

end