function [xsol] = fitnessfunction(x)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%% Deklarieren der Variablen
A= x(1)/10000;
number_tubercle= x(2);
status= 0;
%Initailiserien der Stoffkenngrößen für die Berechnung von der Enthalpie 
cp= 1006;                                                                   %in J/(kg*K)
% cp= 1004.9;                                                                 %in J/(kg*K); berechnet aus Flugzuegtriebwerke (1004.9344J/kgK)
T_1tot= 288;                                                                %K
kappa= 1.4;             
%% Aufrufen der Tuberkelfunktion

tubercle_rt('Z:\Profildateien\Rotor\profile.curve',A,number_tubercle); %Rotorgeometrie einladen

%% Aufrufen von ANSYS

initime= clock;                                                             %Initialisierung der Startzeit
limit= 14400;                                                                %Deklarieren des Zeitlimits in Sekunden
programstatus=0;                                                            %Initialisieren der IF-Bedingung 



while etime(clock,initime) < limit                                          %while-Loop zum Abwarten der Zeit --> realisisert durch ambersand (& am Ende des System()-Befehls)
    if programstatus==0                                                     %If-Bedingung zum ausführen des system()-Befehls
        system(' "C:\Program Files\ANSYS Inc\v221\Framework\bin\Win64\RunWB2.exe" -B -F "Z:\Simulation\Optimierungssetup\Optimierungssetup.wbpj" -R "Z:\Simulation\Optimierung_JournalSkript.wbjn" &');
        programstatus=1;                                                    %Hochsetzten der Variable damit Befehlszeile nur einmal ausgeführt wird
    end
    [~,result] = system('tasklist /FI "imagename eq AnsysFW.exe" /fo table /nh');       %Abfrage der laufenden Programme
    status= strfind(lower(result),lower('AnsysFW.exe'));                                %status setzten ob programm noch läuft,wenn nicht ist status leer
    
    if isempty(status) == 1                                                 %If Bedingung für frühzeitige enden der while-schleife wenn programm sich selbst geschlossen hat
        break
    end
end

%% Beenden des Programm 

if status > 0                                                               %If-Bedingung zum löschen des lock-files
    system('TASKKILL -f -im "AnsysFW.exe"');
    delete('Z:\Simulation\Optimierungssetup\Optimierungssetup_files\.lock');
end 
%% Einlesen der Ergebnisse

[~,ergebnis]=xlsread('Z:\Simulation\Optimierungssetup\Ergebnisse\ergebnisneu.csv','ergebnisneu','A8');  %Einladen der Ergebnisse aus Ansys

komma= strfind(ergebnis,',');                                               %Unterteilen des Strings
pos= cell2mat(komma);                                                       %Bestimmen der Position der Ergebnisse im String
p_ratio= str2num(ergebnis{1}(pos(1)+1:pos(2)-1));                           %Rausschreiben des Druckverhältnisses 
eta= str2num(ergebnis{1}(pos(2)+1:end));                                    %Rausschreiben des Wirkungsgrades


%% Ausgabe der Ergebnisse

if status > 0                                                               %IF-Bedingung, dass Rechnung abgebrochen ist                                                                                                                                   
    p_ratio= NaN;
    eta= NaN;   
    sum= NaN;
    xsol= 1;
    vermerk= 'Rechnung abgebrochen';
     
else                                                                        %Bedingung, dass Rechnung erfolgreich war
    status= 0; 
    vermerk= 'Rechnung erfolgreich';
    eta_ref= 0.88467;                                                       %Referenzwert für den Wirkungsgrad aus Simulation mit der Basisgeometrie                                                       
    p_ratio_ref= 1.77216;                                                   %Referenzwert für das Druckverhältnis aus Simulation mit der Basisgeometrie
    eta_norm= eta/eta_ref;                                                  %Normierung des Wirkungsgrads über den Referenzwert        
    p_ratio_norm= p_ratio/p_ratio_ref;                                      %Normierung des Druckverhältnisses über den Referenzwert
   sum= eta_norm+p_ratio_norm;                                              %Berchnung der Summe     
    xsol= -sum;                                                             %Schreiben der normierten Summe als Bewertungkriterium
end

%% Rausschreiben der Ergebnisse 

speicher= xlsread('ergebnisspeicher.xlsx','Tabelle1');                      %Variable zur Bestimmung der beschreibbaren zeile 

if isempty(speicher) == true                                                %If-Bedingung für leere Exceltabelle
    xlswrite('ergebnisspeicher.xlsx',A, 'Tabelle1','A2');
    xlswrite('ergebnisspeicher.xlsx',number_tubercle, 'Tabelle1','B2');
    xlswrite('ergebnisspeicher.xlsx',p_ratio, 'Tabelle1','C2');
    xlswrite('ergebnisspeicher.xlsx',eta, 'Tabelle1','D2');
    xlswrite('ergebnisspeicher.xlsx',sum, 'Tabelle1','E2');
    xlswrite('ergebnisspeicher.xlsx',xsol, 'Tabelle1','F2');
    xlswrite('ergebnisspeicher.xlsx',{vermerk}, 'Tabelle1','G2');
    xlswrite('ergebnisspeicher.xlsx',status, 'Tabelle1','H2');
else                                                                        %Bedingung für bereits beschriebene Exceltabelle
    [row,col]= size(speicher);
    num= row+2
    p_ratio_vgl= xlsread('ergebnisspeicher.xlsx','Tabelle1',"C" + num2str(num-1));          %Laden der Vergleichswerte für das Druckverhältnis
    eta_vgl= xlsread('ergebnisspeicher.xlsx','Tabelle1',"D" + num2str(num-1));              %Laden der Vergleichswerte für den Wikrungsgrad
    A_vgl=xlsread('ergebnisspeicher.xlsx', 'Tabelle1',"A" + num2str(num-1));                %Laden der Vergleichswerte für die Amplitude
    number_tubercle_vgl=xlsread('ergebnisspeicher.xlsx','Tabelle1',"B" + num2str(num-1));   %Laden der Vergleichswerte für die Tuberkelanzahl
    
    i=2;
    while isempty(eta_vgl)==1 && isempty(p_ratio_vgl)==1                                    %Durchlaufen der Schleife falls vorherige Rechnung auch nicht erfolgreich war
    p_ratio_vgl= xlsread('ergebnisspeicher.xlsx','Tabelle1',"C" + num2str(num-i));
    eta_vgl= xlsread('ergebnisspeicher.xlsx','Tabelle1',"D" + num2str(num-i));
    A_vgl=xlsread('ergebnisspeicher.xlsx', 'Tabelle1',"A" + num2str(num-i));
    number_tubercle_vgl=xlsread('ergebnisspeicher.xlsx','Tabelle1',"B" + num2str(num-i));
    i=i+1
    end 
    

    diff_pi= p_ratio_vgl - p_ratio;                                         %Differenz des Druckverhältnisses zum Vergleichswert
    diff_eta=  eta_vgl - eta;                                               %Differenz des Wirkungsgrads zum Vergleichswert
    cond1= [diff_pi diff_eta];                                              %Aufstellen der ersten Condition
    diff_A= A-A_vgl;                                                        %Differenz der Amplitude zum Vergleichswert
    diff_number_tubercle= number_tubercle-number_tubercle_vgl;              %Differenz der Tuberkel zum Vergleichswert
    cond2= [diff_A diff_number_tubercle];                                   %Aufstellen der zweiten Condition
    
    
    if any(cond1 == 0) && any(cond2~=0)                                     %Bedingung für wenn Ergebnisse gleich aber Amplitude/Periodenanzahl unterschiedlich
        xsol=1;                                                             % ---> Rechnung nicht erfolgreich
        p_ratio= NaN;
        eta= NaN;
        sum= NaN;
        if status == 0
            status= 1;
            vermerk= 'Netz wurde nicht aktualisiert';
        end
    end
    
    xlswrite('ergebnisspeicher.xlsx',A, 'Tabelle1',"A" + num2str(num));
    xlswrite('ergebnisspeicher.xlsx',number_tubercle, 'Tabelle1',"B" + num2str(num));
    xlswrite('ergebnisspeicher.xlsx',p_ratio, 'Tabelle1',"C" + num2str(num));
    xlswrite('ergebnisspeicher.xlsx',eta, 'Tabelle1',"D" + num2str(num));
    xlswrite('ergebnisspeicher.xlsx',sum, 'Tabelle1',"E" + num2str(num));
    xlswrite('ergebnisspeicher.xlsx',xsol, 'Tabelle1',"F" + num2str(num));
    xlswrite('ergebnisspeicher.xlsx',{vermerk}, 'Tabelle1',"G" + num2str(num));
    xlswrite('ergebnisspeicher.xlsx',status, 'Tabelle1',"H" + num2str(num));
end

%% Schreiben in Seafile

tab= xlsread('ergebnisspeicher.xlsx','Tabelle1');
xlswrite('Z:\Seafile\Masterthesis\Masterarbeit\Simulation\Optimierungssetup\optimierung_bak.xlsx',tab,'Tabelle1');


end


