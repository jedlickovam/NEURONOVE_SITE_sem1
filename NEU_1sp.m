% 1. SP z NEU
% Marketa Jedlickova

%% Inicializace
clc
clear all

data = load('tren_m.txt');

x1 = data(:,1);   % první vstup
x2 = data(:,2);   % druhý vstup
u  = data(:,3);   % požadovaný výstup

% Vykreslení dat
figure(1)
hold on;
for i = 1:100
    if u(i)==1
        plot(x1(i),x2(i), 'x');
    else
        plot(x1(i),x2(i), 'or');
    end
end
xlim([-0.8;1.8]);
xlabel('x1')
ylim([-1.6;0]);
ylabel('x2')

%% Trénování sítì
% Dimenze: vstupni vektor I je 2, I.vrstva J je 4 a výstupni vektor M je 1

% Inicializace
x = [x1,x2];
w = [rand(1)*2-1, rand(1)*2-1;
    rand(1)*2-1, rand(1)*2-1;
    rand(1)*2-1, rand(1)*2-1; 
    rand(1)*2-1, rand(1)*2-1];                             % JxI nahodna cisla v rozmezi -1 a 1
v = [rand(1)*2-1, rand(1)*2-1, rand(1)*2-1, rand(1)*2-1];  % MxJ
b = [rand(1)*2-1;
    rand(1)*2-1;
    rand(1)*2-1;
    rand(1)*2-1];                                          % J
d =  rand(1)*2-1;                                          % M

save('inicializace.mat','w','v','b','d');

load('inicializace.mat');

lambda = 0.2;
c = 1.5;                  % konstanta uèení
Emax = 0.01;              % !!!!!  maximalni povolena chyba
p = 10000;                % !!!!!  pocet trenovacich cyklu
E = 0;     

% pocatecni chyba

% Výpocet odezvy

for q = 1 : p
    for k = 1:100
        xc = x(k,:)';
        uc = u(k,:);
        
        z = [activ(w(1,:)*xc+b(1)); activ(w(2,:)*xc+b(2)); activ(w(3,:)*xc+b(3)); activ(w(4,:)*xc+b(4))];
        y = activ(v*z + d);
        % u požadovaný výstup je již definován výše
        
        % Výpocet chyby
        E = E + (1/2)*((uc-y)'*(uc-y));
        
        % Aktualizace vah a prahù
        for j =1:4
            for i = 1:2
                % M je 1 nemusi byt suma :)
                w(j,i)= w(j,i) + c*(uc-y)*der(v*z+d)*v(j)*der(w(j,:)*xc+b(j))*xc(i);
                b(j) = b(j) + c*(uc-y)*der(v*z+d)*v(j)*der(w(j,:)*xc+b(j));
                
            end
            
            % M je 1 nemusi byt druhy for
            v(j)= v(j) + c*(uc-y)*der(v*z+d)*z(j);
            d = d + c*(uc-y)*der(v*z+d);
        end
        % Test vycerpanosti trénovací množiny ---> for cyklus
    end
    
    % Konec trénovacího cyklu
    Ec(q) = E;
    
    if Ec(q)< Emax
        w
        b
        v
        d
        Ec(q)
        q
        break;
    else
        clc
        E = 0
        Ec(q)
        q
    end
    
end

figure(2);
plot(1:q,Ec);
xlabel('Císlo trénovacího cyklu');
ylabel('Chyba Ec')
xlim([0;q]);

save('natrenovana_data.mat','c','lambda','q','w','b','v','d','Ec');

%% Vyhodnocení sítì

load('natrenovana_data.mat');

for i  = 1 : 100
    x = data(i,1:2)';
    
    z1 = activ(w(1,1:2)*x + b(1,1));
    z2 = activ(w(2,1:2)*x + b(2,1));
    z3 = activ(w(3,1:2)*x + b(3,1));
    z4 = activ(w(4,1:2)*x + b(4,1));
    
    y_real(i) =  activ(v(1)*z1 + v(2)*z2 +  v(3)*z3 +  v(4)*z4  + d); 
    
end

figure(3);
hold on
plot(1:100, data(:,3),'r');
plot(1:100, y_real);
xlabel('Cislo vzorku');
ylabel('Vystup');
legend('Zadany vystup u','Vystup natrenovane site y')
hold off


figure(4);

[X,Y]=meshgrid([-2:0.1:3], [-2:0.1:3]);

Z1 = 2./(1+exp(-lambda * (w(1,1).*X + w(1,2).*Y + b(1,1)))) - 1;
Z2 = 2./(1+exp(-lambda * (w(2,1).*X + w(2,2).*Y + b(2,1)))) - 1;
Z3 = 2./(1+exp(-lambda * (w(3,1).*X + w(3,2).*Y + b(3,1)))) - 1;
Z4 = 2./(1+exp(-lambda * (w(4,1).*X + w(4,2).*Y + b(4,1)))) - 1;

Y1 = 2./(1+exp(-lambda * (v(1).*Z1 + v(2).*Z2 +  v(3).*Z3 +  v(4).*Z4  + d))) - 1;

hold on;
for i = 1:100
    if u(i)==1
        plot(x1(i),x2(i), 'x');
    else
        plot(x1(i),x2(i), 'or');
    end
end
xlim([-0.8;1.8]);
xlabel('x1')
ylim([-1.6;0]);
ylabel('x2')
zlabel('y');
contour(X,Y,Y1);
hold off

 
