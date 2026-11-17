clc
clear all 
close all 

%% Daten einladen 

%% Einladen der Geschwindigkeit RT
 
%Einladen der Geschwinkdigkeitsverläufe der Tuberkel-Schaufeln
RT_T1= readtable(['*\' ...                                                   
    'Abgabe\Auswertung\Betriebspunkt_m08_n77000\Geschwindigkeit\veloTBRT_axT1_span00833.csv'],'ReadVariableNames', false);
RT_T4= readtable(['*\' ...
    'Abgabe\Auswertung\Betriebspunkt_m08_n77000\Geschwindigkeit\veloTBRT_axT4_span05833.csv'],'ReadVariableNames', false);

%Einladen der Geschwinkdigkeitsverläufe der Basisgeometrie
ST_T1= readtable(['*' ...
    '\Abgabe\Auswertung\Betriebspunkt_m08_n77000\Geschwindigkeit\veloLEANRT_axT1_span00833.csv'],'ReadVariableNames', false);
ST_T4= readtable(['*' ...
    '\Abgabe\Auswertung\Betriebspunkt_m08_n77000\Geschwindigkeit\veloLEANRT_axT4_span05833.csv'],'ReadVariableNames', false);


%Tabelle in Vektoren umschreiben
streamRT1= table2array(RT_T1(:,1));     veloRT1= table2array(RT_T1(:,2));
streamRT4= table2array(RT_T4(:,1));     veloRT4= table2array(RT_T4(:,2));

streamST1= table2array(ST_T1(:,1));     veloST1= table2array(ST_T1(:,2));
streamST4= table2array(ST_T4(:,1));     veloST4= table2array(ST_T4(:,2));

% Plotten der Geschwindigkeitverläufe
figure('Name','Geschwindigkeitsverlauf T4')
 subplot(2,1,1)
 plot(streamRT4,veloRT4,'-.k')
 grid on
 grid minor 
 legend('Geschwindigkeitsverlauf an der Tuberkel-Schaufel','Interpreter','Latex')
 ylabel('Geschw. in $\textrm{m}\textrm{s}^{-1}$','Interpreter','Latex')
 ylim([0 390])
 xlim([-0.05 1.05])
 yticks([0 100 200 300 350])
 xticks(0:0.1:1);
fig()
 subplot(2,1,2)
 plot(streamST4,veloST4,'-k')
 grid on
 grid minor 
 legend('Geschwindigkeitsverlauf an der Basisgeometrie','Interpreter','Latex')
 xlabel('normierte Rotor-Schaufell\"ange','Interpreter','Latex')
 ylabel('Geschw. in $\textrm{m}\textrm{s}^{-1}$','Interpreter','Latex')
 xlim([-0.05 1.05])
  xticks(0:0.1:1);
 ylim([0 390])
 yticks([0 100 200 300 350])
 fig()

 figure('Name','Geschwindigkeitsverlauf T1')
  subplot(2,1,1)
 plot(streamRT1,veloRT1,'-.k')
 grid on
 grid minor 
 legend('Geschwindigkeitsverlauf an der Tuberkel-Schaufel','Interpreter','Latex')
 ylabel('Geschw. in $\textrm{m}\textrm{s}^{-1}$','Interpreter','Latex')
 ylim([0 300])
 xlim([-0.05 1.05])
 yticks([0 100 200 250])
 xticks(0:0.1:1);
fig()

 subplot(2,1,2)
 plot(streamST1,veloST1,'-k')
 grid on
 grid minor 
 legend('Geschwindigkeitsverlauf an der Basisgeometrie','Interpreter','Latex')
 xlabel('normierte Rotor-Schaufell\"ange','Interpreter','Latex')
 ylabel('Geschw. in $\textrm{m}\textrm{s}^{-1}$','Interpreter','Latex')
 xlim([-0.05 1.05])
  xticks(0:0.1:1);
 ylim([0 300])
 yticks([0 100 200 250])
 fig()


 %% Einladen der Geschwindigkeit ST

%Einladen der Geschwinkdigkeitsverläufe der Tuberkel-Schaufeln
TBST_T1= readtable(['*' ...
    '\Abgabe\Auswertung\Betriebspunkt_m08_n77000\Geschwindigkeit\veloTBST_axT1_span0167.csv'],'ReadVariableNames', false);
TBST_T2= readtable(['*' ...
    'Abgabe\Auswertung\Betriebspunkt_m08_n77000\Geschwindigkeit\veloTBST_axT2_span05.csv'],'ReadVariableNames', false);

%Einladen der Geschwinkdigkeitsverläufe der Basisgeometrie
LEANST_T1= readtable(['*' ...
    '\Abgabe\Auswertung\Betriebspunkt_m08_n77000\Geschwindigkeit\veloLEANST_axT1_span0167.csv'],'ReadVariableNames', false);
LEANST_T2= readtable(['*' ...
    '\Abgabe\Auswertung\Betriebspunkt_m08_n77000\Geschwindigkeit\veloLEANST_axT2_span05.csv'],'ReadVariableNames', false);

%Tabellen in Vektoren umschreiben 
streamSTT1_TB= table2array(TBST_T1(:,1));     veloSTT1_TB= table2array(TBST_T1(:,2));
streamSTT2_TB= table2array(TBST_T2(:,1));     veloSTT2_TB= table2array(TBST_T2(:,2));

streamSTT1_LEAN= table2array(LEANST_T1(:,1));     veloSTT1_LEAN= table2array(LEANST_T1(:,2));
streamSTT2_LEAN= table2array(LEANST_T2(:,1));     veloSTT2_LEAN= table2array(LEANST_T2(:,2));

% Plotten der Geschwindigkeitverläufe
figure('Name','Geschwindigkeitsverlauf ST T2')
 subplot(2,1,1)
 plot(streamSTT2_TB,veloSTT2_TB,'-.k')
 grid on
 grid minor 
 legend('Geschwindigkeitsverlauf an der Tuberkel-Schaufel','Interpreter','Latex')
 ylabel('Geschw. in $\textrm{m}\textrm{s}^{-1}$','Interpreter','Latex')
 ylim([0 320])
 xlim([-0.05 1.05])
 yticks([0 100 200 300])
 xticks(0:0.1:1);

fig()
 subplot(2,1,2)
 plot(streamSTT2_LEAN,veloSTT2_LEAN,'-k')
 grid on
 grid minor 
 legend('Geschwindigkeitsverlauf an der Basisgeometrie','Interpreter','Latex')
 xlabel('normierte Stator-Schaufell\"ange','Interpreter','Latex')
 ylabel('Geschw. in $\textrm{m}\textrm{s}^{-1}$','Interpreter','Latex')
 xlim([-0.05 1.05])
  xticks(0:0.1:1);
 ylim([0 320])
 yticks([0 100 200 300])
 fig()

 figure('Name','Geschwindigkeitsverlauf ST T1')
  subplot(2,1,1)
 plot(streamSTT1_TB,veloSTT1_TB,'-.k')
 grid on
 grid minor 
 legend('Geschwindigkeitsverlauf an der Tuberkel-Schaufel','Interpreter','Latex')
 ylabel('Geschw. in $\textrm{m}\textrm{s}^{-1}$','Interpreter','Latex')
 ylim([0 250])
 xlim([-0.05 1.05])
 yticks([0 100 200 250])
 xticks(0:0.1:1);
fig()

 subplot(2,1,2)
 plot(streamSTT1_LEAN,veloSTT1_LEAN,'-k')
 grid on
 grid minor 
 legend('Geschwindigkeitsverlauf an der Basisgeometrie','Interpreter','Latex')
 xlabel('normierte Stator-Schaufell\"ange','Interpreter','Latex')
 ylabel('Geschw. in $\textrm{m}\textrm{s}^{-1}$','Interpreter','Latex')
 xlim([-0.05 1.05])
  xticks(0:0.1:1);
 ylim([0 250])
 yticks([0 100 200 250])
 fig()


