function [y_lower, y_upper] = ysim_lower_upper_nn(net,X,s_l,s_u)
% Creates the model's lower and upper predicctions
ymax = net.input_ymax;
ymin = net.input_ymin;
xmax = net.input_xmax;
xmin = net.input_xmin;
input_preprocessed = (ymax-ymin) * (X'-xmin) ./ (xmax-xmin) + ymin;
% Pass it through the ANN matrix multiplication
y1 = tanh(net.IW * input_preprocessed + net.b1);
y_lower_norm = net.LW * y1 + net.b2 - s_l*abs(y1);
y_upper_norm = net.LW * y1 + net.b2 + s_u*abs(y1);
ymax = net.output_ymax;
ymin = net.output_ymin;
xmax = net.output_xmax;
xmin = net.output_xmin;
y_lower = (y_lower_norm-ymin) .* (xmax-xmin) /(ymax-ymin) + xmin;
y_upper = (y_upper_norm-ymin) .* (xmax-xmin) /(ymax-ymin) + xmin;
end