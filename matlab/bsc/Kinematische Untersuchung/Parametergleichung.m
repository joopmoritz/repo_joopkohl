clc 
clear all
close all

%% Berechnung der Übersetzung aus dem Verhältnis der Radien
L=30; %Hälfte des Abstandes der Drehpunkte
e=2.1; %Exzentrität in mm
syms phi1;
assume(0<=phi1 & phi1<=2*pi);

%Vergleichsberechnung der Übersetzung nach der Verschiebungsgleichung 
R1= sqrt(L^2-(e^2)*sin(phi1)^2)-e*cos(phi1);
R2= 2*L-R1;
i21=R1/R2;

% plotten der Vergleichsübersetzung
figure('Name','Übersetzung aus den Radienverhältnissen','NumberTitle','off');
fplot(i21,[0 2*pi]);
grid on 
grid minor
title('Übersetzung der ersten Stufe'); 
xlabel( 'Drehwinkel [rad]' );
ylabel( 'R1/R2' );


%% Bestimmen der Grenzen von eta
alpha0=pi/9; %Eingriffwinkel angegeben in rad
epsilon=0.07; %Exzentriziität bestimmt über e/2Rw

syms eta;
syms xi;
assume(0<=xi & xi<=2*pi);

%aufstellen der Gleichung zur Berechnung von eta
u=sin(eta)-eta*cos(alpha0)*cos(alpha0-eta);
v=cos(eta)-eta*cos(alpha0)*sin(alpha0-eta); %untere Grenze von eta=0, da gelten muss, dass v<=1.
F=-u+sqrt(1-(v)^2);
G=-u-sqrt(1-(v)^2);

%Bestimmen der oberen Grenzen von eta
eta1_0=vpasolve(F==epsilon,[0 0.01]); %bestimmen der oberen Grenze von eta für die erste Hälfte
eta2_0=vpasolve(abs(G)==epsilon,[0 0.01]);%bestimmen der oberen Grenze von eta für die zweite Hälfte 

%Definieren der linken Seite des Gleichungssystem
f=epsilon*sin(xi);

%plotten: Vergleich xi und eta
%plotten von epsilon*sin(xi)
figure('Name','Gegenüberstellung von epsilon und xi','NumberTitle','off'); %aus dem Vergleich können die grenzen von eta bestimmt werden
subplot(1,2,1);
plotf= fplot(f,[0 2*pi]);
%ploteinstellungen 
plotf.Color='k';
plotf.LineWidth= 2;

x= xlabel({'$\xi\ [rad]$'},'interpreter','latex');
y= ylabel({'$relative\ Exzentrizit\ddot{a}t$'},'interpreter','latex');
set(gca,'XTick',0:pi/2:2*pi);
set(gca,'XTickLabel',{'0','$\displaystyle\frac{\pi}{2}$','$\pi$','$\displaystyle\frac{3}{2}\pi$','$2\pi$'});
set(gca,'YTick',-0.07:0.01:0.07);
set(gca,'YTickLabel',{'${-}\varepsilon$','','','','','','','0','','','','','','','$\varepsilon$'},'FontSize',16);
lgd= legend(gca, 'string', {'$\varepsilon sin{\xi}$'},'interpreter','latex');
xy= gca;
xy.XAxis.FontSize=20;
xy.YAxis.FontSize=20;

y.FontSize=22;
x.FontSize=22;
lgd.FontSize= 20;
lgd.Location= 'northeast';
axis([0 2*pi -0.08 0.08]);
grid on 
grid minor
set(gca,'TickLabelInterpreter','latex');


%plotten von F(eta) und G(eta)
subplot(1,2,2);
fp1=fplot(F,[0 0.0079059945063581827517626432472524]);
fp1.Color='k';
fp1.LineWidth= 2; 
hold on 
fp2= fplot(G,[0 0.007513097448788212804640032146361]);
fp2.Color='k';
fp2.LineStyle='--';
fp2.LineWidth= 2;
%ploteinstellungen 
grid on 
grid minor

x= xlabel({'$\eta\ [rad]$'},'interpreter','latex');
y= ylabel({'$relative\ Exzentrizit\ddot{a}t$'},'interpreter','latex');
set(gca,'YTick',-0.07:0.01:0.07);
set(gca,'YTickLabel',{'${-}\varepsilon$','','','','','','','0','','','','','','','$\varepsilon$'},'FontSize',16);
set(gca,'XTick',[0,0.007513097448788212804640032146361,0.0079059945063581827517626432472524]);
set(gca,'XTickLabel',{'$\eta_{0}$','$\eta_{2}$','$\eta_{1}$'},'FontSize',20);
lgd= legend(gca, 'string', {'$\ -u+ \sqrt{1-v^2}$','$\ u- \sqrt{1-v^2}$'},'interpreter','latex');

xy= gca;
xy.XAxis.FontSize=20;
xy.YAxis.FontSize=20;
y.FontSize=22;
x.FontSize=22;
lgd.FontSize= 20;
set(gca,'TickLabelInterpreter','latex');

lgd.Location= 'northwest';
axis([0 0.008 -0.08 0.08]);
disp(eta1_0);
disp(eta2_0);

%% Bestimmen von xi erste Hälft 0<xi<pi
syms xi1
xi1(eta)=[atan((F)/sqrt((epsilon^2)-(F^2))), pi-atan((F)/sqrt((epsilon^2)-(F^2)))]; %zwei formeln da pq-Formel und einem x-wert zwei y-Werte zu geordnet sind

%% Bestimmen von xi zweite Hälft pi<xi<2pi
syms xi2
xi2(eta)=[pi-atan((G)/sqrt((epsilon^2)-(G^2))),2*pi+atan((G)/sqrt((epsilon^2)-(G^2)))];
syms xi
figure('Name','xi in Abhängigkeit von eta','NumberTitle','off');
xi(eta)=[xi1,xi2];

%plotten von xi(eta)
fplot(xi(eta),[0 0.0079059945063581827517626432472524],'LineWidth',2);
x= xlabel({'$\eta\ [rad]$'},'interpreter','latex');
y= ylabel({'$\xi\ [rad]$'},'interpreter','latex');
lgd= legend(gca, 'string', {'$\xi_{1}$','$\xi_{2}$','$\xi_{3}$','$\xi_{4}$'},'interpreter','latex');

 
set(gca,'YTick',0:pi/2:2*pi);
set(gca,'YTickLabel',{'0','$\displaystyle\frac{\pi}{2}$','$\pi$','$\displaystyle\frac{3}{2}\pi$','$2\pi$'});
set(gca,'TickLabelInterpreter','latex');

xy= gca;
xy.XAxis.FontSize=20;
xy.YAxis.FontSize=20;


y.FontSize=22;
x.FontSize=22;
lgd.FontSize= 20;

grid on 
grid minor
%% Bestimmung von Teta aus den Abhängigkeiten xi=(teta2+teta1)/2 und eta=(teta2-teta1)/2

syms teta1 %Winkel zwischen der Linen vom Drehpunkt zum Mittelpunkt nach Rotation, wenn xyo Koordinatensystem dynamisch. x-Achse beschreibt die Eingriffslinie
syms teta2

teta1(eta)=xi(eta)-eta; % Winkel des treibenden Rades

%plotten von Theta1(eta)
figure('Name','Verdrehwinkel relativ zur x-Achse','NumberTitle','off')
subplot(1,2,1)
fplot(teta1,[0 0.0079059945063581827517626432472524],'LineWidth',2);
x= xlabel({'$\eta\ [rad]$'},'interpreter','latex');
y= ylabel({'$\theta_{1}\ [rad]$'},'interpreter','latex');
lgd= legend(gca, 'string', {'$\theta_{1,1}$','$\theta_{1,2}$','$\theta_{1,3}$','$\theta_{1,4}$'},'interpreter','latex');
set(gca,'YTick',0:pi/2:2*pi);
set(gca,'YTickLabel',{'0','$\displaystyle\frac{\pi}{2}$','$\pi$','$\displaystyle\frac{3}{2}\pi$','$2\pi$'});
set(gca,'TickLabelInterpreter','latex');
xy= gca;
xy.XAxis.FontSize=20;
xy.YAxis.FontSize=20;


y.FontSize=22;
x.FontSize=22;
lgd.FontSize= 20;

grid on 
grid minor


%plotten Theta2(eta)
teta2(eta)=xi(eta)+eta; %Winkel es angetriebenen Rades 
subplot(1,2,2)
fplot(teta2(eta),[0 0.0079059945063581827517626432472524],'LineWidth',2);
x= xlabel({'$\eta\ [rad]$'},'interpreter','latex');
y= ylabel({'$\theta_{2}\ [rad]$'},'interpreter','latex');
lgd= legend(gca, 'string', {'$\theta_{2,1}$','$\theta_{2,2}$','$\theta_{2,3}$','$\theta_{2,4}$'},'interpreter','latex');

set(gca,'YTick',0:pi/2:2*pi);
set(gca,'YTickLabel',{'0','$\displaystyle\frac{\pi}{2}$','$\pi$','$\displaystyle\frac{3}{2}\pi$','$2\pi$'});
set(gca,'TickLabelInterpreter','latex');
xy= gca;
xy.XAxis.FontSize=16;
xy.YAxis.FontSize=16;


y.FontSize=22;
x.FontSize=22;
lgd.FontSize= 20;

grid on 
grid minor
%% Bestimmung des Eingriffswinkels alpha
syms alpha1
alpha1=atan((sin(alpha0)-eta*cos(alpha0)+epsilon*sin(xi1)*cos(alpha0-eta))./(cos(alpha0)-epsilon*sin(xi1)*sin(alpha0-eta)))*(180/pi);
syms alpha2
alpha2=atan((sin(alpha0)-eta*cos(alpha0)+epsilon*sin(xi2)*cos(alpha0-eta))./(cos(alpha0)-epsilon*sin(xi2)*sin(alpha0-eta)))*(180/pi);

%Definieren des Betriebseingriffswinkels
alpha=[alpha1,alpha2]*(pi/180);
%% Bestimmung der Übersetzung 
syms i
i=(cos(alpha0)+epsilon.*cos(alpha0+teta1))./(cos(alpha0)-epsilon.*cos(alpha0-teta2));

%Plotten der Übersetzung 

figure('Name','Übersetzung in Abhängigkeit zu eta','NumberTitle','off')
fplot(i,[0 0.0079059945063581827517626432472524],'LineWidth',2);

set(gca,'TickLabelInterpreter','latex');
x= xlabel({'$\eta\ [rad]$'},'interpreter','latex');
y= ylabel({'$\ddot{U}bersetzung\ i_{21}$'},'interpreter','latex');
lgd= legend(gca, 'string', {'$i_{21,1}$','$i_{21,2}$','$i_{21,3}$','$i_{21,4}$'},'interpreter','latex');



xy= gca;
xy.XAxis.FontSize=20;
xy.YAxis.FontSize=20;


y.FontSize=22;
x.FontSize=22;
lgd.FontSize= 20;

grid on 
grid minor
%% Bestimmung Drehwinkel 
syms phi1(eta)
syms phi2(eta)

%Bestimmung der Drehwinkel 
%Zahnrad 1 
phi1(eta)=teta1+alpha0-alpha;
%Zahnrad 2 und 3
phi2(eta)=teta2-alpha0+alpha;
phi3=phi2;
%Zahnrad 4 und 5
phi4(eta)=(phi2./phi1).*phi2;
%Zahnrad 6 und 7 
phi6(eta)=(phi2./phi1).*phi4;
%Definieren Übersetzung der gleichmäßig übersetzenden Getriebestufen 
R7=15;
R8=30;
i87=R7/R8; 
i109=i87;
%Zahnrad 8 und 9
phi8=i87*phi6;
%Zahnrad 10
phi10=phi8*i109;

%plotten des Drehwinkel phi1 und phi2 über eta 
figure('Name','Verdrehwinkel phi1 und phi2','NumberTitle','off')
fplot(phi1,[0 0.0079059945063581827517626432472524],'LineWidth',2);
hold on 
fplot(phi1,[0 0.0079059945063581827517626432472524],'LineWidth',2,'Color',[0 0.4470 0.7410]);
hold on 
fplot(phi2,[0 0.0079059945063581827517626432472524],'LineWidth',2,'Color',[0.85 0.3250 0.0980]);

set(gca,'TickLabelInterpreter','latex');
x= xlabel({'$\eta\ [rad]$'},'interpreter','latex');
y= ylabel({'$\phi\ [rad]$'},'interpreter','latex');
lgd= legend(gca, 'string', {'$\phi_{1}$','$\phi_{2}$'},'interpreter','latex');

set(gca,'YTick',0:pi/2:2*pi);
set(gca,'YTickLabel',{'0','$\displaystyle\frac{\pi}{2}$','$\pi$','$\displaystyle\frac{3}{2}\pi$','$2\pi$'});
xy= gca;
xy.XAxis.FontSize=20;
xy.YAxis.FontSize=20;



y.FontSize=22;
x.FontSize=22;
lgd.FontSize= 20;

grid on 
grid minor

%plotten des Drehwinkel phi1, phi2, phi4 und 6 über eta 
figure('Name','Verdrehwinkel phi','NumberTitle','off')
fplot(phi1,[0 0.0079059945063581827517626432472524],'LineWidth',2);
hold on 
fplot(phi1,[0 0.0079059945063581827517626432472524],'LineWidth',2,'Color',[0 0.4470 0.7410]);
hold on 
fplot(phi2,[0 0.0079059945063581827517626432472524],'LineWidth',2,'Color',[0.85 0.3250 0.0980]);
hold on
fplot(phi4,[0 0.0079059945063581827517626432472524],'LineWidth',2,'Color',[0.9290 0.6940 0.1250]);
hold on
fplot(phi6,[0 0.0079059945063581827517626432472524],'LineWidth',2,'Color',[0.4940 0.1840 0.5560]);

set(gca,'TickLabelInterpreter','latex');
x= xlabel({'$\eta\ [rad]$'},'interpreter','latex');
y= ylabel({'$\phi\ [rad]$'},'interpreter','latex');
lgd= legend(gca, 'string', {'$\phi_{1}$','$\phi_{2}$','$\phi_{4}$','$\phi_{6}$'},'interpreter','latex');

set(gca,'YTick',0:pi/2:2*pi);
set(gca,'YTickLabel',{'0','$\displaystyle\frac{\pi}{2}$','$\pi$','$\displaystyle\frac{3}{2}\pi$','$2\pi$'});
xy= gca;
xy.XAxis.FontSize=20;
xy.YAxis.FontSize=20;



y.FontSize=22;
x.FontSize=22;
lgd.FontSize= 20;

grid on 
grid minor

%plotten des Drehwinkel phi1, phi8 und phiRotor über eta 
figure('Name','Verdrehwinkel phi8 und phi10','NumberTitle','off')
fplot(phi1,[0 0.0079059945063581827517626432472524],'LineWidth',2);
hold on 
fplot(phi1,[0 0.0079059945063581827517626432472524],'LineWidth',2,'Color',[0 0.4470 0.7410]);
hold on 
fplot(phi8,[0 0.0079059945063581827517626432472524],'LineWidth',2,'Color',[0.85 0.3250 0.0980]);
hold on 
fplot(phi10,[0 0.0079059945063581827517626432472524],'LineWidth',2,'Color',[0.9290 0.6940 0.1250]);
grid on 
grid minor

set(gca,'TickLabelInterpreter','latex');
x= xlabel({'$\eta\ [rad]$'},'interpreter','latex');
y= ylabel({'$\phi\ [rad]$'},'interpreter','latex');
lgd= legend(gca, 'string', {'$\phi_{1}$','$\phi_{8}$','$\phi_{Rotor}$'},'interpreter','latex');

set(gca,'YTick',0:pi/2:2*pi);
set(gca,'YTickLabel',{'0','$\displaystyle\frac{\pi}{2}$','$\pi$','$\displaystyle\frac{3}{2}\pi$','$2\pi$'});
xy= gca;
xy.XAxis.FontSize=20;
xy.YAxis.FontSize=20;



y.FontSize=22;
x.FontSize=22;
lgd.FontSize= 20;

%% Berechnung Ph1 und Phi2
z=100; %Anzahl der Schritte für die Vektorberechnung
%Werte für eta festlegen 
eta_phi=[(linspace(0,0.0079,z))',(linspace(0.0079,0,z))',(linspace(0,0.0075,z))',(linspace(0.0075,0,z))']; 
pi_intervall=[(linspace(0,pi/2,z))',(linspace(pi/2,pi,z))',(linspace(pi,3*pi/2,z))',(linspace(3*pi/2,2*pi,z))'];

%eta-Matrix vektoren zuweisen 
eta_1=eta_phi(:,1);
eta_2=eta_phi(:,2);
eta_3=eta_phi(:,3);
eta_4=eta_phi(:,4);

x=1;
for k1=1:1:z
    
    phi1_z1=[double(phi1(eta_1(x)))];
    
    phi1_wert1(x)=phi1_z1(:,1);
   
    x=x+1;
end 

x=1;

for k2=1:1:z
    
    phi1_z2=[double(phi1(eta_2(x)))];

    phi1_wert2(x)=phi1_z2(:,2);
    x=x+1;
end
 
x=1;
for k3=1:1:z
    
    phi1_z3=[double(phi1(eta_3(x)))];

 phi1_wert3(x)=phi1_z3(:,3);
x=x+1;
end
 
x=1;
for k4=1:1:z
    
    phi1_z4=[double(phi1(eta_4(x)))];

 phi1_wert4(x)=phi1_z4(:,4);

x=x+1;
end

% Berechnung Phi2
x=1;
for m1=1:1:z
    
    phi2_z1=[double(phi2(eta_1(x)))];
    
    phi2_wert1(x)=phi2_z1(:,1);
   
    x=x+1;
end 

x=1;

for m2=1:1:z
    
    phi2_z2=[double(phi2(eta_2(x)))];

    phi2_wert2(x)=phi2_z2(:,2);
    x=x+1;
end
 
x=1;
for m3=1:1:z
    
    phi2_z3=[double(phi2(eta_3(x)))];

 phi2_wert3(x)=phi2_z3(:,3);
x=x+1;
end
 
x=1;
for m4=1:1:z
    
    phi2_z4=[double(phi2(eta_4(x)))];

 phi2_wert4(x)=phi2_z4(:,4);

x=x+1;
end

% %Berechnung Phi4
x=1;
for p1=1:1:z
    
    phi4_z1=[double(phi4(eta_1(x)))];
    
    phi4_wert1(x)=phi4_z1(:,1);
   
    x=x+1;
end 

x=1;

for p2=1:1:z
    
    phi4_z2=[double(phi4(eta_2(x)))];

    phi4_wert2(x)=phi4_z2(:,2);
    x=x+1;
end
 
x=1;
for p3=1:1:z
    
    phi4_z3=[double(phi4(eta_3(x)))];

 phi4_wert3(x)=phi4_z3(:,3);
x=x+1;
end
 
x=1;
for p4=1:1:z
    
    phi4_z4=[double(phi4(eta_4(x)))];

 phi4_wert4(x)=phi4_z4(:,4);

x=x+1;
end

% %Berechnung Phi6
x=1;
for q1=1:1:z
    
    phi6_z1=[double(phi6(eta_1(x)))];
    
    phi6_wert1(x)=phi6_z1(:,1);
   
    x=x+1;
end 

x=1;

for q2=1:1:z
    
    phi6_z2=[double(phi6(eta_2(x)))];

    phi6_wert2(x)=phi6_z2(:,2);
    x=x+1;
end
 
x=1;
for q3=1:1:z
    
    phi6_z3=[double(phi6(eta_3(x)))];

    phi6_wert3(x)=phi6_z3(:,3);
x=x+1;
end
 
x=1;
for q4=1:1:z
    
    phi6_z4=[double(phi6(eta_4(x)))];

    phi6_wert4(x)=phi6_z4(:,4);

x=x+1;
end

%Aufstelle Arrays mit berechneten Drehwinkel
phi1_wert=[phi1_wert1',phi1_wert2',phi1_wert3',phi1_wert4'];
phi2_wert=[phi2_wert1',phi2_wert2',phi2_wert3',phi2_wert4'];
phi4_wert=[phi4_wert1',phi4_wert2',phi4_wert3',phi4_wert4'];
phi6_wert=[phi6_wert1',phi6_wert2',phi6_wert3',phi6_wert4'];

%% Berechnung der Wert der Übersetzung

x=1;

for n1=1:1:z
    
    i_z1=[double(i(eta_1(x)))];
    
    i_phi1(x)=i_z1(:,1);
   
    x=x+1;
end 

x=1;

for n2=1:1:z
    
    i_z2=[double(i(eta_2(x)))];

    i_phi2(x)=i_z2(:,2);
    x=x+1;
end
 
x=1;
for n3=1:1:z
    
    i_z3=[double(i(eta_3(x)))];

 i_phi3(x)=i_z3(:,3);
x=x+1;
end
 
x=1;
for n4=1:1:z
    
    i_z4=[double(i(eta_4(x)))];

 i_phi4(x)=i_z4(:,4);

x=x+1;
end

%Definition eines Arrays bis 8pi ==>> eine Rotorumdrehung 
phi1_wert_8pi=[phi1_wert,phi1_wert+2*pi,phi1_wert+4*pi,phi1_wert+6*pi]; % Erstellt, damit man genauere Annäherungsfunktion hat, da mehr messpunkt
i_phi_8pi=[i_phi1',i_phi2',i_phi3',i_phi4',i_phi1',i_phi2',i_phi3',i_phi4',i_phi1',i_phi2',i_phi3',i_phi4',i_phi1',i_phi2',i_phi3',i_phi4']; % Erstellt, damit man genauere Annäherungsfunktion hat, da mehr messpunkt

% Definieren Array zur annäherung über funktion 
i_phi=[i_phi1',i_phi2',i_phi3',i_phi4'];

%plotten der berechneten Punkte
figure('Name','Übersetzung über antreibende Rad','NumberTitle','off')
plot(phi1_wert,i_phi,'.','MarkerSize',10);
x= xlabel({'$Drehwinkel\ des\ ersten\ Rades [rad]$'},'interpreter','latex');
y= ylabel('$\ddot{U}bersetzung\ i_{21}$','interpreter','latex');
lgd= legend(gca, 'string', {'$i_{21,1}$','$i_{21,2}$','$i_{21,3}$','$i_{21,4}$'},'interpreter','latex');

axis([0 (2*pi) 0.85 1.2]);
set(gca,'XTick',0:pi:2*pi);
set(gca,'XTickLabel',{'0','$\pi$','$2\pi$'});
lgd.Location='southeast';
xy= gca;
xy.XAxis.FontSize=20;
xy.YAxis.FontSize=20;
set(gca,'TickLabelInterpreter','latex');

y.FontSize=22;
x.FontSize=22;
lgd.FontSize= 20;

grid on 
grid minor

%Bestimmung der Drehwinkel der gleichmäßig übersetzenden Getriebestufen 

phi7_wert=phi6_wert;
phi8_wert=phi7_wert*i87;
phi9_wert=phi8_wert;
phi10_wert=phi9_wert*i109;

%Bestimmung Winkel von Rotor2 über die Differenz
GP= phi1_wert*(1/4)
phi10R2_wert=GP-(phi10_wert-GP);
Differenz=phi10_wert-GP;

%90° verschiebung wie CAD-Modell
phiR2_90=[Differenz(:,2),Differenz(:,3),Differenz(:,4),Differenz(:,1)]+GP;

%180° Verschiebung wie notwendig
phiR2_180=[Differenz(:,3),Differenz(:,4),Differenz(:,1),Differenz(:,2)]+GP;

figure('Name','Drehwinkel in Abhängigkeit des Hauptwellenwinkels','NumberTitle','off')
%plot(phi1_wert,phi1_wert,'.','MarkerSize',10,'Color',[0 0.4470 0.7410]);
hold on 
plot(phi1_wert,phi2_wert,'.','MarkerSize',10,'Color',[0.8500 0.3250 0.0980]);
hold on 
plot(phi1_wert,phi4_wert,'.','MarkerSize',10,'Color',[0.9290 0.6940 0.1250]);
hold on 
plot(phi1_wert,phi6_wert,'.','MarkerSize',10,'Color',[0.4940 0.1840 0.5560]);
hold on 
plot(phi1_wert,phi8_wert,'.','MarkerSize',10,'Color',[0.4660 0.6740 0.1880]);
hold on 
plot(phi1_wert,phi10_wert,'.','MarkerSize',10,'Color',[0.3010 0.7450 0.9330]);
hold on 
%a=plot(phi1_wert(:,1),phi1_wert(:,1),'.','MarkerSize',10,'Color',[0 0.4470 0.7410]);
hold on 
b=plot(phi1_wert(:,1),phi2_wert(:,1),'.','MarkerSize',10,'Color',[0.8500 0.3250 0.0980]);
hold on 
c=plot(phi1_wert(:,1),phi4_wert(:,1),'.','MarkerSize',10,'Color',[0.9290 0.6940 0.1250]);
hold on 
d=plot(phi1_wert(:,1),phi6_wert(:,1),'.','MarkerSize',10,'Color',[0.4940 0.1840 0.5560]);
hold on 
e=plot(phi1_wert(:,1),phi8_wert(:,1),'.','MarkerSize',10,'Color',[0.4660 0.6740 0.1880]);
hold on 
f=plot(phi1_wert(:,1),phi10_wert(:,1),'.','MarkerSize',10,'Color',[0.3010 0.7450 0.9330]);
% plot(phi1_wert,GP);
% hold on 
% plot(phi1_wert,phiR2_180);
hold off

x= xlabel({'$Drehwinkel\ des\ ersten\ Rades\ [rad]$'},'interpreter','latex');
y= ylabel({'$Drehwinkel\ der\ getriebenen\ R\ddot{a}der\ [rad]$'},'interpreter','latex');
lgd= legend([b c d e f],{'$\phi_{2,3}$','$\phi_{4,5}$','$\phi_{6,7}$','$\phi_{8,9}$','$\phi_{10,Rotor}$'},'interpreter','latex');
lgd.Location='northwest';




axis([0 (2*pi) 0 (2*pi)]);
xy= gca;
xy.XAxis.FontSize=20;
xy.YAxis.FontSize=20;

set(gca,'TickLabelInterpreter','latex');
set(gca,'XTickLabel',{'0','$\displaystyle\frac{\pi}{2}$','$\pi$','$\displaystyle\frac{3}{2}\pi$','$2\pi$'});
set(gca,'YTick',0:pi/2:2*pi);
set(gca,'YTickLabel',{'0','$\displaystyle\frac{\pi}{2}$','$\pi$','$\displaystyle\frac{3}{2}\pi$','$2\pi$'});
set(gca,'XTick',0:pi/2:2*pi);


y.FontSize= 22;
x.FontSize=22;
lgd.FontSize= 20;

grid on 
grid minor


figure(100)
plot(phi1_wert,phi10_wert);
hold on 
plot(phi1_wert,phiR2_180);
hold on 
plot(phi1_wert,phi10R2_wert);

%% Matrizen rausschreiben 
writematrix(phi10_wert,'Rotor1.txt','Delimiter','tab')
type 'Rotor1.txt'

writematrix(phiR2_180,'Rotor2.txt','Delimiter','tab')
type 'Rotor2.txt'

writematrix(phi1_wert,'phi1.txt','Delimiter','tab')
type 'phi1.txt'