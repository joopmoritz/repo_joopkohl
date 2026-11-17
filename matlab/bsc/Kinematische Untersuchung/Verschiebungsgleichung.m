clc 
clear all
close all

%% Berechnung der Übersetzung aus dem Verhältnis der Radien Stufe 1-2 

L=30; %Hälfte des Abstandes der Drehpunkte
e=2.1; %Exzentrität in mm
e0=0;
n=20;
w=2*pi*n;

syms phi0;
assume(0<= phi0 & phi0<=2*pi);
syms phi1;
%syms phi2;
syms i21;
syms t;
syms c;

%phi1=w*t;
%phi1=phi0;
R1(phi0)= sqrt((L^2)-(e^2)*(sin(phi0))^2)-e*cos(phi0);
R2(phi0)=(2*L)-sqrt((L^2)-(e^2)*(sin(phi0)))+e*cos(phi0);
i21(phi0)=R1/R2;

R1_e0= sqrt(L^2-(e0^2)*(sin(phi1))^2)-e0*cos(phi1);
R2_e0=(2*L)-sqrt((L^2)-(e0^2)*(sin(phi1))^2)+e0*cos(phi1);
i21_e0=R1_e0/R2_e0;


figure('Name','Übersetzung aus den Radienverhältnissen R1/R2','NumberTitle','off');
fplot((i21),[0 2*pi]);
grid on 
grid minor
title('Übersetzung der ersten Stufe'); 
xlabel( 'Drehwinkel [rad]' );
ylabel( 'R1/R2' );
hold on 
fplot(i21_e0,[0 2*pi]);
set(gca,'XTick',0:pi/2:8*pi); 
set(gca,'XTickLabel',{'0','','\pi','','2\pi','','3\pi','','4\pi','','5\pi','','6\pi','','7\pi','','8\pi'});

% C=-0.015464826717012646461708788691206; %Bestimmt über vpasolve(phi2(2*pi)==2*pi) mit phi2(phi0)=int(i21,0,2*pi)+c
phi2(phi0)= int(i21(phi0),phi0); %Integrieren der Übersetzung von 0 bis phi1, vpasolve(phi2_richtig(2*pi)==2*pi, phi2_richtig(pi)==pi, phi2_richtig(0)==0), konstante hinzufügen 

%fplot(i21(phi2_richtig),[0 2*pi]);
figure('Name','Drehwinkel Rotor1 in Abhängigkeit der Hauptwellenumdrehung','NumberTitle','off')
%fplot(phi2,[0 2*pi]);
t=title('Drehwinkel der Zahnräder in Abhängigkeit des treibenden Rades'); %vermutlich falsch, da einfach mit der Übersetzung multipliziert.
x=xlabel({'$\phi_{treibend}\ [rad]$'},'interpreter','latex');
y=ylabel( {'$\phi_{angetrieben}\ [rad]$'},'interpreter','latex' );
grid on 
grid minor
hold on 
phi2_e0= int(i21_e0);
fp= fplot(phi2_e0,[0  2*pi],'r');
fp.LineStyle='-.';
fplot(phi2,[0 2*pi],'b');
phi2_e0= int(i21_e0);





%% Berechnung der Übersetzung aus dem Verhältnis der Radien Stufe 3-4
syms phi3
syms phi4

%phi3=phi2;
R3=R1; %hinter einander liegende Zahnräder sind jeweils um 180° verdreht, der wirkende Radius von jeweil zwei weiteren Zahnrädern konstant.
R4=R2;
i43=i21;
% C1=-0.093017389077987988186705601861729; %Bestimmt über vpasolve(phi4(2*pi)==2*pi) mit phi4(phi0)=int(i21^2,0,2*pi)+c
phi4(phi0)= int(i21^2);

hold on
%fplot(phi2,[0 2*pi]);
fplot(phi4,[0 2*pi]);

%% Berechnung der Übersetzung aus dem Verhältnis der Radien Stufe 5-6
syms phi5
syms phi6

%phi5=phi4;
R5=R1;
R6=R2;
i65=i21;
% C2=-0.23380348688784819307927620121775; %Bestimmt über vpasolve(phi6(2*pi)==2*pi) mit phi6(phi0)=int(i21^3,0,2*pi)+c
phi6(phi0)=int(i21^3,phi0);

hold on 
fplot(phi6(phi0),[0 2*pi]);

%% Berechnung der Übersetzung aus dem Verhältnis der Radien Stufe 7-8
syms phi7
syms phi8

%phi7=phi6;
R7=15;
R8=30;
i87=R7/R8;
% C3=-0.11690174344392409653963810060888; %Bestimmt über vpasolve(phi8(2*pi)==pi) mit phi8(phi0)=int(i21^3*i87,0,2*pi)+c
phi8(phi0)=int(i21^3*i87);

hold on
fplot(phi8(phi0),[0 2*pi]);

%% Berechnung der Übersetzung aus dem Verhältnis der Radien Stufe 9-10
syms phi9;
syms phi10; %Drehwinkel der Rotoren

%phi9=phi8;
R9=15;
R10=30;
% C4=-0.058450871721962048269819050304438; %Bestimmt über vpasolve(phi10(2*pi)==pi/2) mit phi10(phi0)=int(i21^3*i87*i109,0,2*pi)+c
i109=R9/R10;
phi10(phi0)=int(i21^3*i87*i109,phi0);

hold on
fplot(phi10(phi0),[0 2*pi]);
% legend('Vergleichswinkel ohne Exzentrität','Phi2=Phi3','Phi4=Phi5','Phi6=Phi7','Phi8=Phi9','Drehwinkel des Rotors');
lgd= legend(gca, 'string', {'$\phi_{Zahnrad\ ohne\ Exzentrizitaet}$', '$\phi_{Zahnrad\ 2,3}$', '$\phi_{Zahnrad\ 4,5}$', '$\phi_{Zahnrad\ 6,7}$', '$\phi_{Zahnrad\ 8,9}$', '$\phi_{Rotor}$'},'interpreter','latex');
lgd.FontSize= 20;
lgd.Location= 'northwest';

set(gca,'XTick',0:pi/2:8*pi); 
 set(gca,'XTickLabel',{'0','','\pi','','2\pi','','3\pi','','4\pi','','5\pi','','6\pi','','7\pi','','8\pi'},'FontSize',12);
 set(gca,'YTick',0:pi/2:8*pi); 
 set(gca,'YTickLabel',{'0','','\pi','','2\pi','','3\pi','','4\pi','','5\pi','','6\pi','','7\pi','','8\pi'},'FontSize',12);
y.FontSize=20;
x.FontSize=20;
t.FontSize=20;

%Überprüfung der Einhaltung der Randbedingungen 
Wert2=[double(vpaintegral(i21(phi0),0,0));double(vpaintegral(i21(phi0),0,pi));double(vpaintegral(i21(phi0),0,2*pi))];
Abw2=Wert2-[0;pi;2*pi];
Wert4=[double(vpaintegral(i21^2,0,0));double(vpaintegral(i21^2,0,pi));double(vpaintegral(i21^2,0,2*pi))];
Abw4=Wert4-[0;pi;2*pi];
Wert6=[double(vpaintegral(i21^3,0,0));double(vpaintegral(i21^3,0,pi));double(vpaintegral(i21^3,0,2*pi))];
Abw6=Wert6-[0;pi;2*pi];
Wert8=[double(vpaintegral(i21^3,0,0)*0.5);double(vpaintegral(i21^3,0,pi)*0.5);double(vpaintegral(i21^3,0,2*pi)*0.5)];
Abw8=Wert8-[0;pi;2*pi];
WertR=[double(vpaintegral(i21^3,0,0)*0.25);double(vpaintegral(i21^3,0,pi)*0.25);double(vpaintegral(i21^3,0,2*pi)*0.25)];
AbwR=WertR-[0;pi;2*pi];

xlswrite('Abweichung Drehwinkel durch Integral.xlsx',Wert2,'B3:B5');
xlswrite('Abweichung Drehwinkel durch Integral.xlsx',Abw2,'B8:B10');
xlswrite('Abweichung Drehwinkel durch Integral.xlsx',Wert4,'C3:C5');
xlswrite('Abweichung Drehwinkel durch Integral.xlsx',Abw4,'C8:C10');
xlswrite('Abweichung Drehwinkel durch Integral.xlsx',Wert6,'D3:D5');
xlswrite('Abweichung Drehwinkel durch Integral.xlsx',Abw6,'D8:D10');
xlswrite('Abweichung Drehwinkel durch Integral.xlsx',Wert8,'E3:E5');
xlswrite('Abweichung Drehwinkel durch Integral.xlsx',Abw8,'E8:E10');
xlswrite('Abweichung Drehwinkel durch Integral.xlsx',WertR,'F3:F5');
xlswrite('Abweichung Drehwinkel durch Integral.xlsx',AbwR,'F8:F10');
%% Drehwinkelfunktion der Rotoren in Bezug auf den Hauptwellenwinkel
phi1_2=phi0+(pi/2);
R1_2(phi0)= sqrt((L^2)-(e^2)*(sin(phi1_2))^2)-e*cos(phi1_2);
R2_2(phi0)=(2*L)-sqrt((L^2)-(e^2)*(sin(phi1_2)))+e*cos(phi1_2);
iges_rotor1(phi0)=(i21^3)*i87*i109;
iges_rotor2(phi0)=(R1_2/R2_2)^3*i87*i109;

figure(5)
fplot(iges_rotor1,[0 2*pi]);
hold on 
fplot(iges_rotor2,[0 2*pi]);
grid on 
grid minor 
legend('i_{Rotor1}','i_{Rotor2}');
title('Übersetzung in Abhängigkeit des Hauptwellenwinkels'); 
xlabel( 'Hauptwellenwinkel [rad]' );
ylabel( 'Übersetzung' );
set(gca,'XTick',0:pi/2:8*pi); 
 set(gca,'XTickLabel',{'0','','\pi','','2\pi','','3\pi','','4\pi','','5\pi','','6\pi','','7\pi','','8\pi'});

phi_rotor1=int(iges_rotor1);
phi_rotor2=int(iges_rotor2);

figure('Name','Drehwinkel Rotor1 und 2 in Abhängigkeit der Hauptwellenumdrehung','NumberTitle','off')
fplot(phi_rotor1,[0 8*pi]);
hold on 
fplot(phi_rotor2,[0 8*pi]);
title('Drehwinkel der Rotoren in Abhängigkeit der Hauptwellenumdrehung'); 
xlabel( 'Hauptwellenwinkel [rad]' );
ylabel( 'Drehwinkel der Rotoren [rad]' );
grid on 
grid minor
legend('Drehwinkel Rotor1','Drehwinkel Rotor2');
set(gca,'XTick',0:pi/2:8*pi); 
 set(gca,'XTickLabel',{'0','','\pi','','2\pi','','3\pi','','4\pi','','5\pi','','6\pi','','7\pi','','8\pi'});
%% Winkelgeschwindigkeit über den Drehwinkel 

iges_rotor1(phi0)=(i21^3)*i87*i109;
iges_rotor2(phi0)=(R1_2/R2_2)^3*i87*i109;

w1=iges_rotor1*w;
w2=iges_rotor2*w;

figure('Name','Winkelgeschwindigkeit in Abhängigkeit des Drehwinkels 1200min^{-1}','NumberTitle','off')
fplot(w1,[0 8*pi]);
hold on 
fplot(w2,[0 8*pi]);
axis([0 (8*pi) 15 50]);
grid on 
grid minor
title('Winkelgeschwindigkeit in Abhängigkeit des Hauptwellenwinkels für n=1200min^-1');
ylabel('Winkelgeschwindigkeit [s^{-1}]');
xlabel('Hauptwellenwinkel [rad]');
legend('w_{Rotor1}','w_{Rotor2}');
set(gca,'XTick',0:pi/2:8*pi); 
set(gca,'XTickLabel',{'0','','\pi','','2\pi','','3\pi','','4\pi','','5\pi','','6\pi','','7\pi','','8\pi'});
%% Winkelbeschleunigung über den Drehwinkel
dw1= diff(w1);
dw2= diff(w2);

figure('Name','Winkelbeschleunigung in Abhängigkeit des Drehwinkels 1200min^{-1}','NumberTitle','off')
fplot(dw1,[0 8*pi]);
hold on 
fplot(dw2,[0 8*pi]);
axis([0 (8*pi) -20 20]);
grid on 
grid minor
title('Winkelbeschleunigung in Abhängigkeit des Hauptwellenwinkels für n=1200min^-1');
ylabel('Winkelbeschleunigung [s^{-2}]');
xlabel('Hauptwellenwinkel [rad]');
legend('w_{Rotor1}','w_{Rotor2}');
set(gca,'XTick',0:pi/2:8*pi); 
 set(gca,'XTickLabel',{'0','','\pi','','2\pi','','3\pi','','4\pi','','5\pi','','6\pi','','7\pi','','8\pi'});
 
T=(w1/iges_rotor1)/phi0;
figure('Name','Drehwinkel Rotor1 und 2 in Abhängigkeit der Zeit','NumberTitle','off')
fplot(phi_rotor1);
hold on 
%fplot(phi_rotor2(t),[0 0.05]);