%% Estimate diffusion coefficient for 500nm balls
% Stokes Einstein equation

BeadRadius=0.5 %mkm

kb=1.38*1e-23 % m^2*kg/(s^2*K)
Tcelceus=27    % C
% recalculate in K
T=20+273
v=0.8509*1e-3 % dinamic viscosity Pa*s
r=500*1e-9; %m
D=(kb*T)/(6*pi*v*r); %m^2/s
% in mkm
D=D*1e12            %mkm^2/s      