function derivace = der(epsilon)
lambda = 0.2;

pom = (2/(1+exp(-lambda * epsilon))) -1;

derivace  = (lambda/2)*(1-pom.*pom);
end
