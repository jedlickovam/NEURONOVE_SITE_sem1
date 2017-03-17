function fce = activ(epsilon)

lambda = 0.2;
fce = (2/(1+exp(-lambda*epsilon)))-1;

end
