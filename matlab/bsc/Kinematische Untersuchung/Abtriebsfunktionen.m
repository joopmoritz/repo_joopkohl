clc 
clear all
close all

%% Funktionen in Abhängigkeit von Phi0; übernommen von CurveFitting
syms phi0 
assume(phi0>=0 & phi0 <=2*pi);
n=20;
w0=2*pi*n;
syms phi0_G2 %ersten Zahnrad von zweiten getriebe um 90° verschoben
phi0_g2=phi0+pi;
syms t;
%% Übersetztung
% Bestimmt über sum sine
coeff_i =[1.7365,0.3404,0.4996,0.8741,0.6148,2.7783,0.0070,1.8493,1.7659];
as_i=coeff_i(:,[1 4 7]);
bs_i=coeff_i(:,[2 5 8]);
cs_i=coeff_i(:,[3 6 9]);

i_s(phi0) = as_i(:,1)*sin(bs_i(:,1)*phi0+cs_i(:,1)) + as_i(:,2)*sin(bs_i(:,2)*phi0+cs_i(:,2)) + as_i(:,3)*sin(bs_i(:,3)*phi0+cs_i(:,3));

%Bestimmt über Fourier 

coeff_i_f =[1.001810720618519,0.141082224645619,-0.005018980499315,0.008980511502603,0.001129294097981,0.988650365656891];


a_i_f=coeff_i_f(:,[1 2 4]);
b_i_f=coeff_i_f(:,[3 5]);
w_i_f=coeff_i_f(:,6);

i_f(phi0) =  a_i_f(:,1) + a_i_f(:,2)*cos(phi0*w_i_f) + b_i_f(:,1)*sin(phi0*w_i_f) + a_i_f(:,3)*cos(2*phi0*w_i_f) + b_i_f(:,2)*sin(2*phi0*w_i_f);

%Bestimmt über Fourier 8pi 

coeff_i_8pi =[1.0000 ,0.1398,-0.0001 ,0.0098 ,0.0018,1.0000];


a_i=coeff_i_8pi(:,[1 2 4]);
b_i=coeff_i_8pi(:,[3 5]);
w_i=coeff_i_8pi(:,6);

i(phi0) =  a_i(:,1) + a_i(:,2)*cos(phi0*w_i) + b_i(:,1)*sin(phi0*w_i) + a_i(:,3)*cos(2*phi0*w_i) + b_i(:,2)*sin(2*phi0*w_i);
%% Phi1
a_phi1=1;

phi1(phi0)=a_phi1*phi0;
%% Phi2

coeff_phi2 =[3.1478,-3.9926,2.3048, 0.8254,0.4580,-0.0179,0.0904, 0.0376,-0.0128,0.3333]; %31.3106    0.0332   -0.0036    0.1989    0.8345    0.5585

a_phi2=coeff_phi2(:,[1 2 4 6 8]);
b_phi2=coeff_phi2(:,[3 5 7 9]);
w_phi2=coeff_phi2(:,10);

phi2(phi0)=  a_phi2(:,1) + a_phi2(:,2)*cos(phi0*w_phi2) + b_phi2(:,1)*sin(phi0*w_phi2) + a_phi2(:,3)*cos(2*phi0*w_phi2) + b_phi2(:,2)*sin(2*phi0*w_phi2)+ a_phi2(:,4)*cos(3*phi0*w_phi2) +b_phi2(:,3)*sin(3*phi0*w_phi2)+a_phi2(:,5)*cos(4*phi0*w_phi2) + b_phi2(:,4)*sin(4*phi0*w_phi2);
%% Phi4
coeff_phi4 =[3.4341,-4.1556,1.2717,0.6229, 0.9563, 0.0431,0.1336, 0.0559,-0.0069, 0.3704]; %31.3106    0.0332   -0.0036    0.1989    0.8345    0.5585

a_phi4=coeff_phi4(:,[1 2 4 6 8]);
b_phi4=coeff_phi4(:,[3 5 7 9]);
w_phi4=coeff_phi4(:,10);

phi4(phi0)=  a_phi4(:,1) + a_phi4(:,2)*cos(phi0*w_phi4) + b_phi4(:,1)*sin(phi0*w_phi4) + a_phi4(:,3)*cos(2*phi0*w_phi4) + b_phi4(:,2)*sin(2*phi0*w_phi4)+ a_phi4(:,4)*cos(3*phi0*w_phi4) +b_phi4(:,3)*sin(3*phi0*w_phi4)+a_phi4(:,5)*cos(4*phi0*w_phi4) + b_phi4(:,4)*sin(4*phi0*w_phi4);

%% Phi6 

coeff_phi6 =[4.4578,-4.5646,-0.1342,-0.3350,1.2646,0.2705,0.7511,0.1719,-0.0870,0.3520]; %31.3106    0.0332   -0.0036    0.1989    0.8345    0.5585

a_phi6=coeff_phi6(:,[1 2 4 6 8]);
b_phi6=coeff_phi6(:,[3 5 7 9]);
w_phi6=coeff_phi6(:,10);

phi6(phi0)=  a_phi6(:,1) + a_phi6(:,2)*cos(phi0*w_phi6) + b_phi6(:,1)*sin(phi0*w_phi6) + a_phi6(:,3)*cos(2*phi0*w_phi6) + b_phi6(:,2)*sin(2*phi0*w_phi6)+ a_phi6(:,4)*cos(3*phi0*w_phi6) +b_phi6(:,3)*sin(3*phi0*w_phi6)+a_phi6(:,5)*cos(4*phi0*w_phi6) + b_phi6(:,4)*sin(4*phi0*w_phi6);

%% Phi8

coeff_phi8 =[2.2289,-2.2823,-0.0671, -0.1675,0.6323,0.1353,0.3755,0.0860, -0.0435, 0.3520]; %31.3106    0.0332   -0.0036    0.1989    0.8345    0.5585

a_phi8=coeff_phi8(:,[1 2 4 6 8]);
b_phi8=coeff_phi8(:,[3 5 7 9]);
w_phi8=coeff_phi8(:,10);

phi8(phi0)=  a_phi8(:,1) + a_phi8(:,2)*cos(phi0*w_phi8) + b_phi8(:,1)*sin(phi0*w_phi8) + a_phi8(:,3)*cos(2*phi0*w_phi8) + b_phi8(:,2)*sin(2*phi0*w_phi8)+ a_phi8(:,4)*cos(3*phi0*w_phi8) +b_phi8(:,3)*sin(3*phi0*w_phi8)+a_phi8(:,5)*cos(4*phi0*w_phi8) + b_phi8(:,4)*sin(4*phi0*w_phi8);

%% Rotor1
coeff_phi_fourier=[1.2647,-1.1669,-0.2325,-0.2856,0.3279,0.1319,0.2964,0.0561,-0.0447,0.3333];

a_Rotor1=coeff_phi_fourier(:,[1 2 4 6 8]);
b_Rotor1=coeff_phi_fourier(:,[3 5 7 9]);
w_R1=coeff_phi_fourier(:,10);

phi_Rotor1f(phi0)=  a_Rotor1(:,1) + a_Rotor1(:,2)*cos(phi0*w_R1) + b_Rotor1(:,1)*sin(phi0*w_R1) + a_Rotor1(:,3)*cos(2*phi0*w_R1) + b_Rotor1(:,2)*sin(2*phi0*w_R1)+ a_Rotor1(:,4)*cos(3*phi0*w_R1) +b_Rotor1(:,3)*sin(3*phi0*w_R1)+a_Rotor1(:,5)*cos(4*phi0*w_R1) + b_Rotor1(:,4)*sin(4*phi0*w_R1);

%% Rotor2

%coeff_Rotor2=[0.4136,-0.7851,0.8378,0.4295,-0.0078,-0.0223,-0.1875,-0.0362,0.0202,0.4288]; 
coeff_Rotor2=[0.6907,-0.8360,-0.0286,0.0232,0.2434, 0.1346,0.0089,0.0083,-0.0604,-0.0195,-0.0050,-0.0014,0.0046,0.5813]; 

a_Rotor2=coeff_Rotor2(:,[1 2 4 6 8 10 12]);
b_Rotor2=coeff_Rotor2(:,[3 5 7 9 11 13]);
w_R2=coeff_Rotor2(:,14);

phi_Rotor2(phi0)=  a_Rotor2(:,1) + a_Rotor2(:,2)*cos(phi0*w_R2) + b_Rotor2(:,1)*sin(phi0*w_R2) + a_Rotor2(:,3)*cos(2*phi0*w_R2) + b_Rotor2(:,2)*sin(2*phi0*w_R2) + a_Rotor2(:,4)*cos(3*phi0*w_R2) + b_Rotor2(:,3)*sin(3*phi0*w_R2)+a_Rotor2(:,5)*cos(4*phi0*w_R2) + b_Rotor2(:,4)*sin(4*phi0*w_R2)+a_Rotor2(:,6)*cos(5*phi0*w_R2) + b_Rotor2(:,5)*sin(5*phi0*w_R2)+a_Rotor2(:,7)*cos(6*phi0*w_R2) + b_Rotor2(:,6)*sin(6*phi0*w_R2);
disp(double(phi_Rotor2(pi)));
disp(double(phi_Rotor2(2*pi)));

%für 90°

coeff_Rotor2_90=[0.4055,-0.7408,0.8692,0.4801,-0.0362,-0.0287,-0.0661,0.4157];

a_Rotor2_90=coeff_Rotor2_90(:,[1 2 4 6]);
b_Rotor2_90=coeff_Rotor2_90(:,[3 5 7]);
w_R2_90=coeff_Rotor2_90(:,8);

phi_Rotor2_90(phi0)=  a_Rotor2_90(:,1) + a_Rotor2_90(:,2)*cos(phi0*w_R2_90) + b_Rotor2_90(:,1)*sin(phi0*w_R2_90) + a_Rotor2_90(:,3)*cos(2*phi0*w_R2_90) + b_Rotor2_90(:,2)*sin(2*phi0*w_R2_90)+ a_Rotor2_90(:,4)*cos(3*phi0*w_R2_90) +b_Rotor2_90(:,3)*sin(3*phi0*w_R2_90);

%% Parameter rausschreiben 

% phi2
xlswrite('Koeffizienten_Drehwinkel.xlsx',a_phi2','B3:B7');
xlswrite('Koeffizienten_Drehwinkel.xlsx',b_phi2','C3:C6');
xlswrite('Koeffizienten_Drehwinkel.xlsx',w_phi2','D3:D3');

% phi4
xlswrite('Koeffizienten_Drehwinkel.xlsx',a_phi4','G3:G7');
xlswrite('Koeffizienten_Drehwinkel.xlsx',b_phi4','H3:H6');
xlswrite('Koeffizienten_Drehwinkel.xlsx',w_phi4','I3:I3');

%phi6
xlswrite('Koeffizienten_Drehwinkel.xlsx',a_phi6','L3:L7');
xlswrite('Koeffizienten_Drehwinkel.xlsx',b_phi6','M3:M6');
xlswrite('Koeffizienten_Drehwinkel.xlsx',w_phi6','N3:N3');

%phi8
xlswrite('Koeffizienten_Drehwinkel.xlsx',a_phi8','Q3:Q7');
xlswrite('Koeffizienten_Drehwinkel.xlsx',b_phi8','R3:R6');
xlswrite('Koeffizienten_Drehwinkel.xlsx',w_phi8','S3:S3');

%phiRotor
xlswrite('Koeffizienten_Drehwinkel.xlsx',a_Rotor1','V3:V7');
xlswrite('Koeffizienten_Drehwinkel.xlsx',b_Rotor1','W3:W6');
xlswrite('Koeffizienten_Drehwinkel.xlsx',w_R1','X3:X3');

%phiRotor2
xlswrite('Koeffizienten_Drehwinkel.xlsx',a_Rotor2','AA3:AA9');
xlswrite('Koeffizienten_Drehwinkel.xlsx',b_Rotor2','AB3:AB8');
xlswrite('Koeffizienten_Drehwinkel.xlsx',w_R2','AC3:AC3');

%Übersetzung
xlswrite('Koeffizienten_Drehwinkel.xlsx',a_i','AF3:AF5');
xlswrite('Koeffizienten_Drehwinkel.xlsx',b_i','AG3:AG4');
xlswrite('Koeffizienten_Drehwinkel.xlsx',w_i','AH3:AH3');
%% Übersetzung der ersten Stufe 
figure( 'Name', 'Übersetzung der ersten Stufe' );
fplot(i(phi0));
grid on 
grid minor

%x-Achse anpassen
set(gca,'TickLabelInterpreter','latex');
set(gca,'XTick',0:pi/2:2*pi);
set(gca,'XTickLabel',{'0','','\pi','','2\pi'});

% Diagrammausschnitt anpassen 
axis([0 (2*pi) 0.8 1.2]);

%legende anpassen
lgd= legend(gca, 'string', {'$\i_{21}$'},'interpreter','latex');
lgd.FontSize= 20;
lgd.Location= 'northwest';

%Beschriftung
title('Übersetzung der ersten Stufe');
xlabel('Drehwinkel des treibenden Rades [rad]');
y= ylabel('$\ddot{U}bersetzung\ i_{21}$','interpreter','latex');
y.FontSize=20;

xy= gca;
xy.XAxis.FontSize=20;
xy.YAxis.FontSize=20;
%% Drehwinkel der Zahnräder in Abhängigkeit des treibenden Rades
figure( 'Name', 'Drehwinkel der Zahnräder' );
vgl= fplot(phi1,[0 2*pi],'LineWidth',2);
hold on 
fplot(phi2(phi0),'LineWidth',2,'Color',[0.8500 0.3250 0.0980]);
hold on 
fplot(phi4(phi0),[0 2*pi],'LineWidth',2,'Color',[0.9290 0.6940 0.1250]);
hold on 
fplot(phi6(phi0),[0 2*pi],'LineWidth',2,'Color',[0.4940 0.1840 0.5560]);
hold on 
fplot(phi8(phi0),[0 2*pi],'LineWidth',2,'Color',[0.4660 0.6740 0.1880]);
hold on 
fplot(phi_Rotor1f(phi0),[0 2*pi],'LineWidth',2,'Color',[0.3010 0.7450 0.9330]);

grid on
grid minor

%Graph anpassen 
vgl.LineStyle= '-.';
vgl.Color= 'r';

%x-Achse anpassen
set(gca,'TickLabelInterpreter','latex');
set(gca,'XTick',0:pi/2:2*pi);
set(gca,'XTickLabel',{'0','$\displaystyle\frac{\pi}{2}$','$\pi$','$\displaystyle\frac{3}{2}\pi$','$2\pi$'});
set(gca,'YTick',0:pi/2:2*pi);
set(gca,'YTickLabel',{'0','$\displaystyle\frac{\pi}{2}$','$\pi$','$\displaystyle\frac{3}{2}\pi$','$2\pi$'});

% Legende anpasse
lgd= legend(gca, 'string', {'$\phi_{ohne\ Exzentrizit\ddot{a}t}$', '$\phi_{2,3}$', '$\phi_{4,5}$', '$\phi_{6,7}$', '$\phi_{8,9}$', '$\phi_{10,\ Rotor}$'},'interpreter','latex');
lgd.FontSize= 20;
lgd.Location= 'northwest';



%Beschriftung
x= xlabel({'$Drehwinkel\ des\ treibenden\ Rades\ [rad]$'},'interpreter','latex');
y= ylabel({'$Drehwinkel\ der\ getriebenen\ R\ddot{a}der\ [rad]$'},'interpreter','latex');



xy= gca;
xy.XAxis.FontSize=20;
xy.YAxis.FontSize=20;

y.FontSize=22;
x.FontSize=22;


% Darstellung der um 180 phasenverschobenen Rotoren
Vergleichsgerade(phi0)= phi0/4;
figure( 'Name', 'Drehwinkel der Rotoren' );
fplot(phi_Rotor1f(phi0),[0 2*pi],'LineWidth',2,'Color',[0 0.4470 0.7410]); 
hold on 
fplot(phi_Rotor2(phi0),[0 2*pi],'LineWidth',2,'Color',[0.6350 0.0780 0.1840]); 
hold on 
vgl= fplot(Vergleichsgerade(phi0),[0 2*pi],'LineWidth',2,'Color',[1 0 0]);
vgl.LineStyle= '-.';
%x-Achse anpassen
set(gca,'TickLabelInterpreter','latex');
set(gca,'XTick',0:pi/2:2*pi);
set(gca,'XTickLabel',{'0','$\displaystyle\frac{\pi}{2}$','$\pi$','$\displaystyle\frac{3}{2}\pi$','$2\pi$'});

% Legende anpasse
lgd= legend(gca, 'string', {'$\phi_{Rotor1}$', '$\phi_{Rotor2}$', '$\phi_{Vergleichsgerade}$'},'interpreter','latex');
lgd.FontSize= 20;
lgd.Location= 'northwest';

%Beschriftung
x= xlabel({'$Hauptwellenwinkel\ [rad]$'},'interpreter','latex');
y= ylabel({'$Drehwinkel\ der\ getriebenen\ Rotoren\ [rad]$'},'interpreter','latex');

set(gca,'YTick',0:pi/4:pi/2);
set(gca,'YTickLabel',{'0','$\displaystyle\frac{\pi}{4}$','$\displaystyle\frac{\pi}{2}$'});

xy= gca;
xy.XAxis.FontSize=20;
xy.YAxis.FontSize=20;

y.FontSize=22;
x.FontSize=22;


grid on
grid minor
%% Übersetzung der Rotoren 

iges_rotor1(phi0)=i(phi0)^3*(1/4);
iges_rotor2(phi0)=i(phi0+pi/2)^3*(1/4);
iges_rotor180(phi0)=i(phi0+pi)^3*(1/4);

figure( 'Name', 'Übersetzung der Rotoren' );
fplot(iges_rotor1,[0 8*pi],'LineWidth',2);
hold on 
fplot(iges_rotor180,[0 8*pi],'LineWidth',2);
grid on 
grid minor
%x-Achse anpassen
set(gca,'TickLabelInterpreter','latex');
set(gca,'XTick',0:pi/2:8*pi);
set(gca,'XTickLabel',{'0','','$\pi$','','$2\pi$','','$3\pi$','','$4\pi$','','$5\pi$','','$6\pi$','','$7\pi$','','$8\pi$'});

% Diagrammausschnitt anpassen 
axis([0 (8*pi) 0.15 0.4]);

% Legende anpassen
lgd= legend(gca, 'string', {'$i_{Rotor1}$', '$i_{Rotor2}$'},'interpreter','latex');
lgd.FontSize= 20;

%Beschriftung

x= xlabel({'$Hauptwellenwinkel\ [rad]$'},'interpreter','latex');
y= ylabel('$\ddot{U}bersetzung\ i_{Rotor}$','interpreter','latex');

xy= gca;
xy.XAxis.FontSize=20;
xy.YAxis.FontSize=20;

y.FontSize=28;
x.FontSize=22;

%% Winkelgeschwindigkeit

% in Abhängigkeit des Hauptwellen-Drehwinkels
w_Rotor1(phi0)= w0*iges_rotor1;
w_Rotor2(phi0)= w0*iges_rotor2;
w_Rotor180(phi0)= w0*iges_rotor180;

figure( 'Name', 'Winkelgeschwindigkeit der Rotoren' );
subplot(2,1,1);
fplot(w_Rotor1,[0 8*pi]);
hold on 
fplot(w_Rotor2,[0 8*pi]);
legend('w_{Rotor1}','w_{Rotor2}');
hold on 
grid on 
grid minor
%x-Achse anpassen
set(gca,'TickLabelInterpreter','latex');
set(gca,'XTick',0:pi/2:8*pi);
set(gca,'XTickLabel',{'0','','$\pi$','','$2\pi$','','$3\pi$','','$4\pi$','','$5\pi$','','$6\pi$','','$7\pi$','','$8\pi$'});

% Diagrammauschnitt anpassen 
axis([0 (8*pi) 15 55]);

% Legende anpasse
lgd= legend(gca, 'string', {'$\dot \phi_{Rotor1}$', '$\dot \phi_{Rotor2}$'},'interpreter','latex');


%Beschriftung
title({'$Winkelgeschwindigkeit\ in\ Abhaengigkeit\ des\ Hauptwellenwinkels$'},'interpreter','latex');
x=xlabel({'$Hauptwellenwinkel\ [rad]$'},'interpreter','latex');
y=ylabel({'$Winkelgeschwindigkeit\ der\ Rotoren\ [\displaystyle\frac{1}{s}]$'},'interpreter','latex');

xy= gca;
xy.XAxis.FontSize=16;
xy.YAxis.FontSize=16;

y.FontSize=28;
x.FontSize=22;

lgd.FontSize= 20;
% in Abhängigkeit des Hauptwellen-Drehwinkels
subplot(2,1,2);
fplot(w_Rotor1(w0*t),[0 0.2]);
hold on 
fplot(w_Rotor2(w0*t),[0 0.2]);
legend('w_{Rotor1}','w_{Rotor2}');
grid on 
grid minor
%x-Achse anpassen
set(gca,'TickLabelInterpreter','latex');
set(gca,'XTick',0:0.025:0.2);
set(gca,'XTickLabel',{'0','','0.05','','0.1','','0.15','','0.2'});

% Diagrammauschnitt anpassen 
axis([0 0.2 15 55]);

% Legende anpasse
lgd= legend(gca, 'string', {'$\dot \phi_{Rotor1}$', '$\dot \phi_{Rotor2}$'},'interpreter','latex');


%Beschriftung
title({'$Winkelgeschwindigkeit\ in\ Abhaengigkeit\ der\ Zeit$'},'interpreter','latex');
x=xlabel({'$Zeit\ [s]$'},'interpreter','latex');
y=ylabel({'$Winkelgeschwindigkeit\ der\ Rotoren\ [\displaystyle\frac{1}{s}]$'},'interpreter','latex');

xy= gca;
xy.XAxis.FontSize=16;
xy.YAxis.FontSize=16;

y.FontSize=22;
x.FontSize=22;

lgd.FontSize= 20;
%% Winkelbeschleunigung

dw_Rotor1(phi0)= diff(w_Rotor1);
dw_Rotor2(phi0)= diff(w_Rotor2);
dw_Rotor180(phi0)= diff(w_Rotor180);

figure( 'Name', 'Winkelbeschleunigung der Rotoren' );
subplot(2,1,1);
fplot(dw_Rotor1,[0 8*pi]);
hold on 
fplot(dw_Rotor2,[0 8*pi]);
hold on
grid on 
grid minor
%x-Achse anpassen
set(gca,'XTick',0:pi/2:8*pi);
set(gca,'XTickLabel',{'0','','\pi','','2\pi','','3\pi','','4\pi','','5\pi','','6\pi','','7\pi','','8\pi'});

% Diagrammauschnitt anpassen 
axis([0 (8*pi) -20 20]);

%Legende anpasse
lgd= legend(gca, 'string', {'$\ddot \phi_{Rotor1}$', '$\ddot \phi_{Rotor2}$'},'interpreter','latex');
lgd.FontSize= 20;

%Beschriftung
title('Winkelbeschleunigung in Abhängigkeit des Hauptwellenwinkels');
xlabel('Hauptwellenwinkel [rad]');
ylabel('Winkelbeschleunigung der Rotoren [s^{-2}]');

% in Abhängigkeit der Zeit 

subplot(2,1,2);
fplot(dw_Rotor1(w0*t),[0 0.2]);
hold on 
fplot(dw_Rotor2(w0*t),[0 0.2]);
grid on 
grid minor
%x-Achse anpassen
set(gca,'XTick',0:0.025:0.2);
set(gca,'XTickLabel',{'0','','0.05','','0.1','','0.15','','0.2'});

% Diagrammauschnitt anpassen 
axis([0 0.2 -20 20]);

%Legende anpasse
lgd= legend(gca, 'string', {'$\ddot \phi_{Rotor1}$', '$\ddot \phi_{Rotor2}$'},'interpreter','latex');
lgd.FontSize= 20;

%Beschriftung
title('Winkelbeschleunigung in Abhängigkeit der Zeit');
xlabel('Zeit [s]');
ylabel('Winkelbeschleunigung der Rotoren [s^{-2}]');

%% Winkelgeschwindigkeit 180°

% in Abhängigkeit des Hauptwellen-Drehwinkels

figure( 'Name', 'Winkelgeschwindigkeit der Rotoren bei 180° Verschiebung phi' );
fplot(w_Rotor1,[0 8*pi],'LineWidth',2);
hold on 
fplot(w_Rotor180,[0 8*pi],'LineWidth',2);
legend('w_{Rotor1}','w_{Rotor2}');
hold on 
grid on 
grid minor
%x-Achse anpassen
set(gca,'TickLabelInterpreter','latex');
set(gca,'XTick',0:pi/2:8*pi);
set(gca,'XTickLabel',{'0','','$\pi$','','$2\pi$','','$3\pi$','','$4\pi$','','$5\pi$','','$6\pi$','','$7\pi$','','$8\pi$'});

% Diagrammauschnitt anpassen 
axis([0 (8*pi) 15 55]);

% Legende anpasse
lgd= legend(gca, 'string', {'$\dot \phi_{Rotor1}$', '$\dot \phi_{Rotor2}$'},'interpreter','latex');


%Beschriftung
x=xlabel({'$Hauptwellenwinkel\ [rad]$'},'interpreter','latex');
y=ylabel({'$Winkelgeschwindigkeit\ der\ Rotoren\ [\displaystyle\frac{1}{s}]$'},'interpreter','latex');

xy= gca;
xy.XAxis.FontSize=20;
xy.YAxis.FontSize=20;

y.FontSize=22;
x.FontSize=22;
lgd.FontSize= 20;

% in Abhängigkeit der Zeit
figure( 'Name', 'Winkelgeschwindigkeit der Rotoren bei 180° Verschiebung zeit' );
fplot(w_Rotor1(w0*t),[0 0.2],'LineWidth',2);
hold on 
fplot(w_Rotor180(w0*t),[0 0.2],'LineWidth',2);
legend('w_{Rotor1}','w_{Rotor2}');
grid on 
grid minor
%x-Achse anpassen
set(gca,'TickLabelInterpreter','latex');
set(gca,'XTick',0:0.025:0.2);
set(gca,'XTickLabel',{'0','','0.05','','0.1','','0.15','','0.2'});

% Diagrammauschnitt anpassen 
axis([0 0.2 15 55]);

% Legende anpasse
lgd= legend(gca, 'string', {'$\dot \phi_{Rotor1}$', '$\dot \phi_{Rotor2}$'},'interpreter','latex');

%Beschriftung

x=xlabel({'$Zeit\ [s]$'},'interpreter','latex');
y=ylabel({'$Winkelgeschwindigkeit\ der\ Rotoren\ [\displaystyle\frac{1}{s}]$'},'interpreter','latex');

xy= gca;
xy.XAxis.FontSize=20;
xy.YAxis.FontSize=20;

y.FontSize=22;
x.FontSize=22;

lgd.FontSize= 20;
%% Winkelbeschleunigung 180°


figure( 'Name', 'Winkelbeschleunigung der Rotoren bei 180° Verschiebung phi' );
fplot(dw_Rotor1,[0 8*pi],'LineWidth',2);
hold on 
fplot(dw_Rotor180,[0 8*pi],'LineWidth',2);
hold on
grid on 
grid minor
%x-Achse anpassen
set(gca,'TickLabelInterpreter','latex');
set(gca,'XTick',0:pi/2:8*pi);
set(gca,'XTickLabel',{'0','','$\pi$','','$2\pi$','','$3\pi$','','$4\pi$','','$5\pi$','','$6\pi$','','$7\pi$','','$8\pi$'});

% Diagrammauschnitt anpassen 
axis([0 (8*pi) -20 20]);

%Legende anpasse
lgd= legend(gca, 'string', {'$\ddot \phi_{Rotor1}$', '$\ddot \phi_{Rotor2}$'},'interpreter','latex');

%Beschriftung

x=xlabel({'$Hauptwellenwinkel\ [rad]$'},'interpreter','latex');
y=ylabel({'$Winkelbeschleunigung\ der\ Rotoren\ [\displaystyle\frac{1}{s^2}]$'},'interpreter','latex');

xy= gca;
xy.XAxis.FontSize=20;
xy.YAxis.FontSize=20;

y.FontSize=22;
x.FontSize=22;

lgd.FontSize= 20;

% in Abhängigkeit der Zeit 
figure( 'Name', 'Winkelbeschleunigung der Rotoren bei 180° Verschiebung zeit' );
fplot(dw_Rotor1(w0*t),[0 0.2],'LineWidth',2);
hold on 
fplot(dw_Rotor180(w0*t),[0 0.2],'LineWidth',2);
grid on 
grid minor
%x-Achse anpassen
set(gca,'TickLabelInterpreter','latex');
set(gca,'XTick',0:0.025:0.2);
set(gca,'XTickLabel',{'0','','0.05','','0.1','','0.15','','0.2'});

% Diagrammauschnitt anpassen 
axis([0 0.2 -20 20]);

%Legende anpasse
lgd= legend(gca, 'string', {'$\ddot \phi_{Rotor1}$', '$\ddot \phi_{Rotor2}$'},'interpreter','latex');

%Beschriftung

x=xlabel({'$Zeit\ [s]$'},'interpreter','latex');
y=ylabel({'$Winkelbeschleunigung\ der\ Rotoren\ [\displaystyle\frac{1}{s^2}]$'},'interpreter','latex');

xy= gca;
xy.XAxis.FontSize=20;
xy.YAxis.FontSize=20;

y.FontSize=22;
x.FontSize=22;

lgd.FontSize= 20;

%% Vergleich der Winkelgeschwindigkeiten von 90° und 180° Verschiebung des Rotor2
figure( 'Name', 'Vergleich der Winkelgeschwindigkeiten' );
subplot(2,1,1);
fplot(w_Rotor1,[0 8*pi]);
hold on 
fplot(w_Rotor2,[0 8*pi]);
legend('w_{Rotor1}','w_{Rotor2}');
hold on 
grid on 
grid minor
%x-Achse anpassen
set(gca,'XTick',0:pi/2:8*pi);
set(gca,'XTickLabel',{'0','','\pi','','2\pi','','3\pi','','4\pi','','5\pi','','6\pi','','7\pi','','8\pi'});

% Diagrammauschnitt anpassen 
axis([0 (8*pi) 15 55]);

% Legende anpasse
lgd= legend(gca, 'string', {'$\dot \phi_{Rotor1}$', '$\dot \phi_{Rotor2}$'},'interpreter','latex');
lgd.FontSize= 20;

%Beschriftung
title('Winkelgeschwindigkeit in Abhängigkeit des Hauptwellenwinkels bei 1200min^-1');
xlabel('Hauptwellenwinkel [rad]');
ylabel('Winkelgeschwindigkeit der Rotoren [s^{-1}]');

%180°

subplot(2,1,2);
fplot(w_Rotor1,[0 8*pi]);
hold on 
fplot(w_Rotor180,[0 8*pi]);
legend('w_{Rotor1}','w_{Rotor2}');
hold on 
grid on 
grid minor
%x-Achse anpassen
set(gca,'XTick',0:pi/2:8*pi);
set(gca,'XTickLabel',{'0','','\pi','','2\pi','','3\pi','','4\pi','','5\pi','','6\pi','','7\pi','','8\pi'});

% Diagrammauschnitt anpassen 
axis([0 (8*pi) 15 55]);

% Legende anpasse
lgd= legend(gca, 'string', {'$\dot \phi_{Rotor1}$', '$\dot \phi_{Rotor2\ bei\ 180deg\ Verschiebung}$'},'interpreter','latex');
lgd.FontSize= 20;

%Beschriftung
title('Winkelgeschwindigkeit in Abhängigkeit des Hauptwellenwinkels bei 1200min^-1');
xlabel('Hauptwellenwinkel [rad]');
ylabel('Winkelgeschwindigkeit der Rotoren [s^{-1}]');

%% Verifizierungsrechnung

Ergebnis2= [double(phi2(0)),double(phi2(pi)),double(phi2(2*pi))];
Ergebnis4= [double(phi4(0)),double(phi4(pi)),double(phi4(2*pi))];
Ergebnis6= [double(phi6(0)),double(phi6(pi)),double(phi6(2*pi))];
Ergebnis8= [double(phi8(0)),double(phi8(pi)),double(phi8(2*pi))];
Ergebnis10= [double(phi_Rotor1f(0)),double(phi_Rotor1f(pi)),double(phi_Rotor1f(2*pi))];

xlswrite('Verifizierungsrechnung.xlsx',Ergebnis2','B3:B5');
xlswrite('Verifizierungsrechnung.xlsx',Ergebnis4','C3:C5');
xlswrite('Verifizierungsrechnung.xlsx',Ergebnis6','D3:D5');
xlswrite('Verifizierungsrechnung.xlsx',Ergebnis8','E3:E5');
xlswrite('Verifizierungsrechnung.xlsx',Ergebnis10','F3:F5');