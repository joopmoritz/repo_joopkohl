clear all 
close all 
clc

%% Einladen der Lösungen

LSG_revTB= readtable('*.csv', ...    %Einlesen der Drehzahllinie mit Tuberkelschaufeln
                     'ReadVariableNames', false); 
LSG_revLEAN= readtable('*.csv', ...  %Einlesen der Drehzahllinie mit Basisgeometrie
                     'ReadVariableNames', false);

%Einlessen der Kennzahlen des Verdichters mit Tuberkel-Schaufeln
m_TB= str2double(table2array(LSG_revTB(:,11)))*10^(-6);
pi_TB= str2double(table2array(LSG_revTB(:,3)))*10^(-6);
pirs_TB= str2double(table2array(LSG_revTB(:,7)))*10^(-6);
etars_TB=str2double(table2array(LSG_revTB(:,9)))*10^(-6);
mean_pirs_TB= str2double(table2array(LSG_revTB(:,17)))*10^(-6);
mean_etars_TB=str2double(table2array(LSG_revTB(:,15)))*10^(-6);
err_pirs_TB= str2double(table2array(LSG_revTB(:,19)))*10^(-6);
err_etars_TB=str2double(table2array(LSG_revTB(:,21)))*10^(-6);

%Einlessen der Kennzahlen des Verdichters mit Basisgeometrie
m_LEAN= str2double(table2array(LSG_revLEAN(:,11)))*10^(-6);
pi_LEAN= str2double(table2array(LSG_revLEAN(:,3)))*10^(-6);
pirs_LEAN= str2double(table2array(LSG_revLEAN(:,7)))*10^(-6);
etars_LEAN=str2double(table2array(LSG_revLEAN(:,9)))*10^(-6);
mean_pirs_LEAN= str2double(table2array(LSG_revLEAN(:,17)))*10^(-6);
mean_etars_LEAN=str2double(table2array(LSG_revLEAN(:,15)))*10^(-6);
err_pirs_LEAN= str2double(table2array(LSG_revLEAN(:,19)))*10^(-6);
err_etars_LEAN=str2double(table2array(LSG_revLEAN(:,21)))*10^(-6);


[m_TB,i_TB]= sort(m_TB);                                                    %Sortieren des Massenstroms (Tuberkel-Schaufeln)
[m_LEAN,i_LEAN]= sort(m_LEAN);                                              %Sortieren des Massenstrims 

i_TB=i_TB(1:end-1,:);                                                      
i_LEAN=i_LEAN(1:end-1,:);

figure(1)
errorbar(m_TB(1:end-1),mean_pirs_TB(i_TB),err_pirs_TB(i_TB),'o-.k','LineWidth',2,'MarkerSize',10);          %Plotten des Druckverhältnisses über dem Massenstrom (Tuberkel-Schaufeln)
hold on 
errorbar(m_LEAN(1:end-1),mean_pirs_LEAN(i_LEAN),err_pirs_LEAN(i_LEAN),'o-k','LineWidth',2,'MarkerSize',10); %Plotten des Druckverhältnisses über dem Massenstrom (Basisgeometrie)
grid on 
grid minor

xlabel('Massenstrom in kg/s','Interpreter','Latex');
ylabel('Druckverh\"altnis','Interpreter','Latex');
xlim([0.77 0.85])
ylim([1.5 1.8])
legend('Tuberkel-Schaufeln','Basisgeometrie','Interpreter','Latex');
fig()

figure(2)
errorbar(m_TB(1:end-1),mean_etars_TB(i_TB),err_etars_TB(i_TB),'o-.k','LineWidth',2,'MarkerSize',10);            %Plotten des Wirkungsgrads über dem Massenstrom (Tuberkel-Schaufeln)
hold on 
errorbar(m_LEAN(1:end-1),mean_etars_LEAN(i_LEAN),err_etars_LEAN(i_LEAN),'o-k','LineWidth',2,'MarkerSize',10);   %Plotten des Wirkungsgrads über dem Massenstrom (Basisgeometrie)
xlabel('Massenstrom in kg/s','Interpreter','Latex');
ylabel('isen. Wirkungsgrad $\eta_{\textrm{s}}$','Interpreter','Latex');
legend('Tuberkel-Schaufeln','Basisgeometrie','Interpreter','Latex');
xlim([0.77 0.85])
grid on 
grid minor 
fig()

T_pi= table(m_TB(1:end-1),mean_pirs_LEAN(i_LEAN),err_pirs_LEAN(i_LEAN),mean_pirs_TB(i_TB),err_pirs_TB(i_TB))        %Rausschreiben des Druckverhältnisses (sortiert)
writetable(T_pi,'Drehzahllinie_pi.xlsx')


T_eta= table(m_TB(1:end-1),mean_etars_LEAN(i_LEAN),err_etars_LEAN(i_LEAN),mean_etars_TB(i_TB),err_etars_TB(i_TB))   %Rausschreiben des Wirkungsgrads (sortiert)
writetable(T_eta,'Drehzahllinie_eta.xlsx')