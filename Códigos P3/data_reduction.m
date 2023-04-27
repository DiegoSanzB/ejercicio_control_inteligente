function [out] = data_reduction(data,Ts_data,Ts_new)
    k = Ts_new/Ts_data;
    L = round(length(data)/k) - 1; 
    out = zeros([L,1]);
    for i = 1:L
        values = data(k*(i-1)+1:k*i);
        out(i) = sum(values)/k;
    end
end