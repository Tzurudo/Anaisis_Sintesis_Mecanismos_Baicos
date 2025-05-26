% Análisis de posición de un mecanismo 4-barras (M4L) 
% por el método algebraico  
% Autor: Tzurudo 

clear; close all; clc;

%% Entrada de parámetros
a = input('Longitud del eslabón 2 (motor) [a]: ');
b = input('Longitud del eslabón 3 (acoplador) [b]: ');
c = input('Longitud del eslabón 4 (seguidor) [c]: ');
d = input('Longitud del eslabón 1 (base) [d]: ');

%% Verificación de Grashof
eslabones = [a, b, c, d];
mas_largo = max(eslabones);
mas_corto = min(eslabones);

% Filtramos los eslabones medios
eslabones_medios = eslabones(eslabones ~= mas_largo & eslabones ~= mas_corto);
medio1 = max(eslabones_medios);
medio2 = min(eslabones_medios);

% Determinación del tipo de mecanismo
suma_criterio = mas_corto + mas_largo;
suma_medios = medio1 + medio2;

if suma_criterio < suma_medios
    tipo = 'Grashof Clase I';
elseif suma_criterio == suma_medios
    tipo = 'Grashof Especial';
else
    tipo = 'No Grashof';
end
fprintf('\nTipo de mecanismo: %s\n', tipo);

%% Configuración de ángulos
theta2 = 0:5:360; % Ángulo de entrada en grados
n_posiciones = length(theta2);

%% Cálculo de coordenadas
% Puntos fijos
O = [0, 0];      % Origen (eslabón fijo)
Q = [d, 0];      % Pivote fijo eslabón 4

% Punto A (extremidad eslabón 2)
Ax = a * cosd(theta2);
Ay = a * sind(theta2);

%% Solución algebraica para posición del punto B
% Coeficientes ecuación cuadrática
S_term = (a^2 - b^2 + c^2 - d^2) ./ (2*(Ax - d));
P_coeff = (Ay.^2)./((Ax - d).^2) + 1;
Q_coeff = (2*Ay.*(d - S_term))./(Ax - d);
R_coeff = (d - S_term).^2 - c^2;

% Discriminante para verificar soluciones reales
discriminante = Q_coeff.^2 - 4*P_coeff.*R_coeff;
if any(discriminante < 0)
    error('Configuración no alcanzable en algunos ángulos!');
end

% Soluciones para coordenadas By
By1 = (-Q_coeff + sqrt(discriminante)) ./ (2*P_coeff);
By2 = (-Q_coeff - sqrt(discriminante)) ./ (2*P_coeff);

% Coordenadas Bx correspondientes
Bx1 = S_term - (Ay.*By1)./(Ax - d);
Bx2 = S_term - (Ay.*By2)./(Ax - d);

%% Cálculo de ángulos de los eslabones
theta3_1 = atan2d(By1 - Ay, Bx1 - Ax); % Eslabón 3 (configuración abierta)
theta3_2 = atan2d(By2 - Ay, Bx2 - Ax); % Eslabón 3 (configuración cruzada)
theta4_1 = atan2d(By1, d - Bx1);      % Eslabón 4 (configuración abierta)
theta4_2 = atan2d(By2, d - Bx2);      % Eslabón 4 (configuración cruzada)

%% Configuración de la animación
figure('Name','Simulación Mecanismo 4 Barras','NumberTitle','off')
h = axes;
hold on
axis equal
grid on
title(sprintf('Mecanismo 4 Barras - %s', tipo))
xlabel('X'), ylabel('Y')

% Límites dinámicos del área de trabajo
margen = 0.2;
x_lim = [min([0, Ax, Bx1, Bx2])-margen, max([d, Ax, Bx1, Bx2])+margen];
y_lim = [min([0, Ay, By1, By2])-margen, max([0, Ay, By1, By2])+margen];
axis([x_lim y_lim]);

% Elementos gráficos
manivela = plot([O(1), Ax(1)], [O(2), Ay(1)], 'r-o', 'LineWidth', 2);
acoplador = plot([Ax(1), Bx1(1)], [Ay(1), By1(1)], 'g-o', 'LineWidth', 2);
seguidor = plot([Bx1(1), Q(1)], [By1(1), Q(2)], 'b-o', 'LineWidth', 2);
trayectoria_A = plot(Ax(1), Ay(1), 'k:', 'LineWidth', 1);
trayectoria_B = plot(Bx1(1), By1(1), 'k:', 'LineWidth', 1);

%% Animación
for k = 1:n_posiciones
    % Actualizar posiciones
    set(manivela, 'XData', [O(1), Ax(k)], 'YData', [O(2), Ay(k)])
    set(acoplador, 'XData', [Ax(k), Bx1(k)], 'YData', [Ay(k), By1(k)])
    set(seguidor, 'XData', [Bx1(k), Q(1)], 'YData', [By1(k), Q(2)])
    
    % Actualizar trayectorias
    set(trayectoria_A, 'XData', Ax(1:k), 'YData', Ay(1:k))
    set(trayectoria_B, 'XData', Bx1(1:k), 'YData', By1(1:k))
    
    % Actualizar dibujo
    drawnow
    pause(0.05)
end
