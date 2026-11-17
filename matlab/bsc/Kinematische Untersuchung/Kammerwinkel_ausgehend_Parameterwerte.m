clc 
clear all
close all

syms phi0
syms c
n=20;
w0=2*pi*n;
%% Gesamtübersetzung der Rotoren 
iges_rotor1(phi0)=((49*cos(2*phi0))/5000 + (9*sin(2*phi0))/5000 + (699*cos(phi0))/5000 - sin(phi0)/10000 + 1)^3/4;
iges_rotor2(phi0)=-((49*cos(2*phi0))/5000 + (9*sin(2*phi0))/5000 - (699*cos(phi0 + pi/2))/5000 + sin(phi0 + pi/2)/10000 - 1)^3/4;
iges_rotor180(phi0)=((49*cos(2*phi0))/5000 + (9*sin(2*phi0))/5000 - (699*cos(phi0))/5000 + sin(phi0)/10000 + 1)^3/4;

%% Winkelgeschwindigkeiten der Rotoren 

w_Rotor1(phi0)= w0*iges_rotor1;
w_Rotor2(phi0)= w0*iges_rotor2;
w_Rotor180(phi0)= w0*iges_rotor180;

y= vpasolve((vpaintegral(w_Rotor1(phi0)+c,0,2*pi))==0);
w_ver_1(phi0)=w_Rotor1(phi0)+y; % Verschiebung der Winkelgeschwindikeit, da gelten muss Integral von w_rel=0 in den Grenzen 0 bis 2*pi
w_ver_2(phi0)=w_Rotor180(phi0)+y;
%% Matrizen einladen, wurden in Skript Übersetzung ermittelt 
phiR1=load('Rotor1.txt'); %errechneter Drehwinel des Rotor1 über eta 
phiR2=load('Rotor2.txt'); %errechneter Drehwinkel des Rotor2 über eta 
phi1=load('phi1.txt'); % errechnete Eingangsdrehwinkel über eta 
Hauptwelle=[phi1(:,1)',phi1(:,2)',phi1(:,3)',phi1(:,4)'];

z= length(phiR1);

%Erstellen von Spalten Vektoren 
%Rotor1
phiR11=phiR1(:,1);
phiR12=phiR1(:,2);
phiR13=phiR1(:,3);
phiR14=phiR1(:,4);
%Rotor2 180° phasenverschoben 
phiR21=phiR2(:,1);
phiR22=phiR2(:,2);
phiR23=phiR2(:,3);
phiR24=phiR2(:,4);
%Eingangsdrehwinkel
phiH11=phi1(:,1);
phiH12=phi1(:,2);
phiH13=phi1(:,3);
phiH14=phi1(:,4);
%% Bestimmung des Kammerwinkels

gamma_anfang1=21*(pi/180);
gamma_anfang2=21*(pi/180);

for k=1:1:(z)
 
%Kammerwinkel der ersten Kammer, Rotor1 läuft vor Rotor2 läuft nach 
gamma11(k)= gamma_anfang1 + (phiR11(k)-phiR21(k)); 
gamma12(k)= gamma_anfang1 + (phiR12(k)-phiR22(k));
gamma13(k)= gamma_anfang1 + (phiR13(k)-phiR23(k));
gamma14(k)= gamma_anfang1 + (phiR14(k)-phiR24(k));

%Kammerwinkel der zweiten Kammer, Rotor2 läuft vor Rotor1 läuft nach 
gamma21(k)= gamma_anfang2 - (phiR11(k)-phiR21(k));
gamma22(k)= gamma_anfang2 - (phiR12(k)-phiR22(k));
gamma23(k)= gamma_anfang2 - (phiR13(k)-phiR23(k));
gamma24(k)= gamma_anfang2 - (phiR14(k)-phiR24(k));

end 

%Aufstellen des Kammerwinkels von 0-2pi
kammerwinkel1=[gamma11,gamma12,gamma13,gamma14]*(180/pi);
kammerwinkel2=[gamma21,gamma22,gamma23,gamma24]*(180/pi);

%Plotten des Kammerwinkels in Bezug auf die verschobenen Winkelgeschwindigkeiten
fig= figure( 'Name', 'relative Winkelgeschwindigkeiten und Kammerwinkel' );
left_color = [0 0 0];
right_color = [0 0 0];
set(fig,'defaultAxesColorOrder',[left_color; right_color]);

yyaxis right 
plot(Hauptwelle,kammerwinkel1,'k','LineWidth',2);
hold on 
plot2= plot(Hauptwelle,kammerwinkel2,'k','LineWidth',2);
plot2.LineStyle = '--';
hold on 
axis([0 (2*pi) 6 35]);
yr= ylabel('$resultierender\ Kammerwinkel\ [^\circ] $','interpreter','latex');
set(gca,'YTick',0:5:35);


yyaxis left
fplot1= fplot(w_ver_1,[0 2*pi],'LineWidth',2);
fplot1.Color= 'b';
hold on 
fplot2= fplot(w_ver_2,[0 2*pi],'r','LineWidth',2);
fplot2.LineStyle= '-';
yl= ylabel('$relative\ Winkelgeschwindigkeit\ [\displaystyle\frac{1}{s}]$','interpreter','latex');
axis([0 (2*pi) -15 25]);
grid on 
grid minor

lgd= legend(gca, 'string', {'$\dot \phi_{Rotor1\ relativ}$', '$\dot \phi_{Rotor2\ relativ}$', '$\gamma_{1}$','$\gamma_{2}$'},'interpreter','latex');
x= xlabel({'$Hauptwellenwinkel\ [rad]$'},'interpreter','latex','FontSize',16);


set(gca,'TickLabelInterpreter','latex');
set(gca,'XTick',0:pi/2:2*pi);
set(gca,'XTickLabel',{'0','$\displaystyle\frac{\pi}{2}$','$\pi$','$\displaystyle\frac{3}{2}\pi$','$2\pi$'});

xyy= gca;
xyy.FontSize=20;

yr.FontSize=22;
yl.FontSize=22;
x.FontSize=22;
lgd.FontSize= 20;

%Ausgeben der Extremstellen 
disp('-------------------------------');
disp('Maximaler Winkel der ersten Kammer');
disp(max(double(kammerwinkel1)));
disp('Minimaler Winkel der ersten Kammer');
disp(min(double(kammerwinkel1)));
disp('Maximaler Winkel der zweiten Kammer');
disp(max(double(kammerwinkel2)));
disp('Minimaler Winkel der zweiten Kammer');
disp(min(double(kammerwinkel2)));
disp('-------------------------------');
%% Bestimmung des akkumulierten Kammerwinkels

anfang_akku1=0;
anfang_akku2=0;

x=1;
for n=1:1:(z)
    %Berechnen des Winkels des ersten Rotors bezogen auf null 
    gamma_akku11(n)= (anfang_akku1 + (phiR11(n)-phiH11(n)/4)*180/pi);
    gamma_akku12(n)= (anfang_akku1 + (phiR12(n)-phiH12(n)/4)*180/pi);
    gamma_akku13(n)= (anfang_akku1 + (phiR13(n)-phiH13(n)/4)*180/pi);
    gamma_akku14(n)= (anfang_akku1 + (phiR14(n)-phiH14(n)/4)*180/pi);
    
    %Berechnen des Winkels des zweiten Rotors bezogen auf null 
    gamma_akku21(n)= (anfang_akku1 + (phiR21(n)-phiH11(n)/4)*180/pi);
    gamma_akku22(n)= (anfang_akku1 + (phiR22(n)-phiH12(n)/4)*180/pi);
    gamma_akku23(n)= (anfang_akku1 + (phiR23(n)-phiH13(n)/4)*180/pi);
    gamma_akku24(n)= (anfang_akku1 + (phiR24(n)-phiH14(n)/4)*180/pi);
 
    
    %anfang_akku1=gamma_akku1(n);
    %anfang_akku2=gamma_akku2(n);
    x=x+1;
end

% Aufstellen der Rotorwinkel bezogen auf null Grad 
kammerwinkel1_akku=[gamma_akku11,gamma_akku12,gamma_akku13,gamma_akku14];
kammerwinkel2_akku=[gamma_akku21,gamma_akku22,gamma_akku23,gamma_akku24];


fig=figure( 'Name', 'Kammerwinkel und akkumulierter Kammerwinkel' );
left_color = [0 0 0];
right_color = [0 0 0];
set(fig,'defaultAxesColorOrder',[left_color; right_color]);

yyaxis right 
plot(Hauptwelle,kammerwinkel1,'k','LineWidth',2);
hold on 
plot2= plot(Hauptwelle,kammerwinkel2,'k','LineWidth',2);
plot2.LineStyle = '--';
yr= ylabel('$resultierender\ Kammerwinkel\ [^\circ]$','interpreter','latex');
axis([0 (2*pi) 6 35]);

yyaxis left 
plot(Hauptwelle,kammerwinkel1_akku,'b','LineWidth',2);
hold on 
plot2= plot(Hauptwelle,kammerwinkel2_akku,'r','LineWidth',2);
plot2.LineStyle= '-';
yl= ylabel('$akkumulierter\ Kammerwinkel\ [^\circ]$','interpreter','latex');

set(gca,'TickLabelInterpreter','latex');
set(gca,'XTick',0:pi/2:2*pi);
set(gca,'XTickLabel',{'0','$\displaystyle\frac{\pi}{2}$','$\pi$','$\displaystyle\frac{3}{2}\pi$','$2\pi$'});

lgd= legend(gca, 'string', {'$\phi_{Rotor1\ akkumuliert}$', '$\phi_{Rotor2\ akkumuliert}$', '$\gamma_{1}$','$\gamma_{2}$'},'interpreter','latex');
x= xlabel({'$Hauptwellenwinkel\ [rad]$'},'interpreter','latex');

xyy= gca;
xyy.FontSize=20;


yr.FontSize=22;
yl.FontSize=22;
x.FontSize=22;
lgd.FontSize= 20;

grid on 
grid minor
disp('-------------------------------');
disp('Maximaler akkumulierter Winkel von Rotor1');
disp(max(double(kammerwinkel1_akku)));
disp('Minimaler akkumulierter Winkel von Rotor1');
disp(min(double(kammerwinkel1_akku)));
disp('Maximaler akkumulierter Winkel von Rotor2');
disp(max(double(kammerwinkel2_akku)));
disp('Minimaler akkumulierter Winkel von Rotor2');
disp(min(double(kammerwinkel2_akku)));
disp('-------------------------------');
%%
hauptwelle_8pi=[Hauptwelle,Hauptwelle+2*pi,Hauptwelle+4*pi,Hauptwelle+6*pi,Hauptwelle+8*pi];
kw1_akku_8pi=[kammerwinkel1_akku,kammerwinkel1_akku,kammerwinkel1_akku,kammerwinkel1_akku,kammerwinkel1_akku];
Rotor=[phiR1,phiR1,phiR1,phiR1,phiR1,phiR1,phiR1,phiR1,phiR1,phiR1,phiR1,phiR1,phiR1,phiR1,phiR1,phiR1,phiR1,phiR1,phiR1]; 
kw=[kammerwinkel1,kammerwinkel1,kammerwinkel1,kammerwinkel1,kammerwinkel1,kammerwinkel1,kammerwinkel1,kammerwinkel1,kammerwinkel1,kammerwinkel1,kammerwinkel1,kammerwinkel1,kammerwinkel1,kammerwinkel1,kammerwinkel1,kammerwinkel1,kammerwinkel1,kammerwinkel1,kammerwinkel1];
%% Funktion erstellen 
%% Fit: 'akkumulierter Winkel des ersten Rotors'.
[xData, yData] = prepareCurveData( Hauptwelle, kammerwinkel1_akku );

% Set up fittype and options.
ft = fittype( 'fourier6' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0 0 0 0 0 0 0 0 0 0 0 0 0 0.333333333333333];

% Fit model to data.
[fitresult_kw1, ~] = fit( xData, yData, ft, opts );

% [xData, yData] = prepareCurveData( hauptwelle_8pi, kw1_akku_8pi );
% 
% % Set up fittype and options.
% ft = fittype( 'fourier6' );
% opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% opts.Display = 'Off';
% opts.StartPoint = [0 0 0 0 0 0 0 0 0 0 0 0 0 1];
% 
% % Fit model to data.
% [fitresult_kw1, gof] = fit( xData, yData, ft, opts );

% [xData, yData] = prepareCurveData( hauptwelle_8pi, kw1_akku_8pi );
% 
% % Set up fittype and options.
% ft = fittype( 'fourier2' );
% opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% opts.Display = 'Off';
% opts.StartPoint = [0 0 0 0 0 1];
% 
% % Fit model to data.
% [fitresult_kw1, gof] = fit( xData, yData, ft, opts );

% [xData, yData] = prepareCurveData( Hauptwelle, kammerwinkel1_akku );
% 
% % Set up fittype and options.
% ft = fittype( 'fourier3' );
% opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% opts.Display = 'Off';
% opts.StartPoint = [0 0 0 0 0 0 0 0.5];
% 
% % Fit model to data.
% [fitresult_kw1, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'Funktion akkumulierter Kammerwinkel' );
plot1= plot( fitresult_kw1);
plot1.Color= 'b';

% Label axes
title('angenäherte Funktionen der akkumulierten Kammerwinkel');
xlabel( 'Hauptwellewinkel [rad]');
ylabel( 'akkumulierter Kammerwinkel' );
grid on
grid minor
hold on 

%phi_kammer(phi0)= a0 + a1*cos(x*w) + b1*sin(x*w) + a2*cos(2*x*w) +b2*sin(2*x*w) + a3*cos(3*x*w) + b3*sin(3*x*w) + a4*cos(4*x*w) + b4*sin(4*x*w) + a5*cos(5*x*w) + b5*sin(5*x*w) + a6*cos(6*x*w) + b6*sin(6*x*w);
int_kw1= confint(fitresult_kw1, 0.95); %Parameter des Konfidenzintervalls angeben
coeff_kw1 = mean(int_kw1(:,1:14));

% %Parameter ausgeben 
a_kw1=coeff_kw1(:,[1 2 4 6 8 10 12]);
b_kw1=coeff_kw1(:,[3 5 7 9 11 13]);
w_kw1=coeff_kw1(:,14);

% %Intervall der Parameter ausgeben
a_int_kw1=int_kw1(:,[1 2 4 6 8 10 12]);
b_int_kw1=int_kw1(:,[3 5 7 9 11 13]);
w_int_kw1=int_kw1(:,14);


% int_kw1= confint(fitresult_kw1, 0.95); %Parameter des Konfidenzintervalls angeben
% coeff_kw1 = mean(int_kw1(:,1:6));
% 
% % %Parameter ausgeben 
% a_kw1=coeff_kw1(:,[1 2 4]);
% b_kw1=coeff_kw1(:,[3 5]);
% w_kw1=coeff_kw1(:,6);
% 
% % %Intervall der Parameter ausgeben
% a_int_kw1=int_kw1(:,[1 2 4]);
% b_int_kw1=int_kw1(:,[3 5]);
% w_int_kw1=int_kw1(:,6);

% int_kw1= confint(fitresult_kw1, 0.95); %Parameter des Konfidenzintervalls angeben
% coeff_kw1 = mean(int_kw1(:,1:8));
% 
% % %Parameter ausgeben 
% a_kw1=coeff_kw1(:,[1 2 4 6]);
% b_kw1=coeff_kw1(:,[3 5 7]);
% w_kw1=coeff_kw1(:,8);
% 
% % %Intervall der Parameter ausgeben
% a_int_kw1=int_kw1(:,[1 2 4]);
% b_int_kw1=int_kw1(:,[3 5]);
% w_int_kw1=int_kw1(:,6);

kw1_akku(phi0)= a_kw1(:,1) + a_kw1(:,2)*cos(phi0*w_kw1) + b_kw1(:,1)*sin(phi0*w_kw1) + a_kw1(:,3)*cos(2*phi0*w_kw1) +b_kw1(:,2)*sin(2*phi0*w_kw1) + a_kw1(:,4)*cos(3*phi0*w_kw1) + b_kw1(:,3)*sin(3*phi0*w_kw1) + a_kw1(:,5)*cos(4*phi0*w_kw1) + b_kw1(:,4)*sin(4*phi0*w_kw1) + a_kw1(:,6)*cos(5*phi0*w_kw1) + b_kw1(:,5)*sin(5*phi0*w_kw1) + a_kw1(:,7)*cos(6*phi0*w_kw1) + b_kw1(:,6)*sin(6*phi0*w_kw1);
% kw1_akku(phi0)= a_kw1(:,1) + a_kw1(:,2)*cos(phi0*w_kw1) + b_kw1(:,1)*sin(phi0*w_kw1) + a_kw1(:,3)*cos(2*phi0*w_kw1) +b_kw1(:,2)*sin(2*phi0*w_kw1);
% kw1_akku(phi0)= a_kw1(:,1) + a_kw1(:,2)*cos(phi0*w_kw1) + b_kw1(:,1)*sin(phi0*w_kw1) + a_kw1(:,3)*cos(2*phi0*w_kw1) +b_kw1(:,2)*sin(2*phi0*w_kw1) + a_kw1(:,4)*cos(3*phi0*w_kw1) + b_kw1(:,3)*sin(3*phi0*w_kw1);
kw2_akku(phi0)=kw1_akku(2*pi-phi0); %Spiegeln an einer beliebigen Geraden parallel zur y, über Formel f(x)->f(2a-x), dabei ist a die stelle an der gespiegelt werden soll 
hold on 
plot2= fplot(kw2_akku(phi0),[0 2*pi],'LineWidth',2);
plot2.Color= 'r';

legend('akkumulierte Funktion für Rotor1','akkumulierte Funktion für Rotor2');
%% Extrema bestimmen 
%Rotor1
maximum_Rotor1=vpasolve((diff(kw1_akku))==0,[0 pi]);
minimum_Rotor1=vpasolve((diff(kw1_akku))==0,[pi 2*pi]);
max_kw1=kw1_akku(maximum_Rotor1);
min_kw1=kw1_akku(minimum_Rotor1);

%Rotor2
maximum_Rotor2=vpasolve((diff(kw2_akku))==0,[pi 2*pi]);
minimum_Rotor2=vpasolve((diff(kw2_akku))==0,[0 pi]);
max_kw2=kw2_akku(maximum_Rotor2);
min_kw2=kw2_akku(minimum_Rotor2);
disp('-------------------------------');
disp('ausgegebene Winkel über die angenährten Funktion');
disp('Maximaler akkumulierter Winkel von Rotor1');
disp(double(max_kw1));
disp('Minimaler akkumulierter Winkel von Rotor1');
disp(double(min_kw1));
disp('Maximaler akkumulierter Winkel von Rotor2');
disp(double(max_kw2));
disp('Minimaler akkumulierter Winkel von Rotor2');
disp(double(min_kw2));
disp('-------------------------------');

%% Koeffizienten der Funktionen rausschreiben 
[c1,trig1]=coeffs(kw1_akku);
coeff1= double(c1);

[c2,trig2]=coeffs(kw2_akku);
coeff2= double(c2);
coeff=[coeff1',coeff2'];
f=[coeff1',trig1',coeff2',trig2'];

disp('-------------------------------');
disp('Terme der Funktion des Rotor1');
disp(coeff1);
disp(trig1);
disp('-------------------------------');
disp('-------------------------------');
disp('Terme der Funktion des Rotor2');
disp(coeff2);
disp(trig2);
disp('-------------------------------');

writematrix(coeff,'koeff.txt','Delimiter','tab');
type 'koeff.txt';
