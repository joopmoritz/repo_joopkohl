function [xsol]=fitnessfunction_st_Cluster(x)

A= x(1)/10000;
number_tubercle= x(2);
status= 0;
%% Aufrufen der Tuberkelfunktion

tubercle_st('path',A,number_tubercle);     %Rotorgeometrie einladen

%% Aufrufen von ANSYS -- Vernetzung und def-Erstellen.
initime= clock;                                                             %Initialisierung der Startzeit
limit= 5400;                                                                %Deklarieren des Zeitlimits in Sekunden
programstatus=0;                                                            %Initialisieren der IF-Bedingung 

while etime(clock,initime) < limit                                          %while-Loop zum Abwarten der Zeit --> realisisert durch ambersand (& am Ende des System()-Befehls)
    if programstatus==0                                                     %If-Bedingung zum ausführen des system()-Befehls
        system(' "path" -B -F "path" -R "path" &');
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
    control= 1;
    while  isempty(control) == 0                                                            %while-Schleife umsicher zu gehen, dass Ansys wirklich geschlossen ist
        system('TASKKILL -f -im "AnsysFW.exe"');
        system('TASKKILL -f -im "solver-mpi.exe"');
        delete('path');      %lockfile löschen
        [~,result] = system('tasklist /FI "imagename eq AnsysFW.exe" /fo table /nh');       %Abfrage der laufenden Programme
        control= strfind(lower(result),lower('AnsysFW.exe'));
    end
end

%%  Cluster einloggen 

        file='CFX.def';
        host='host';
        user='user';
        password='password';

%% Def Datei auf Cluster kopieren
        ssh2_con = scp_simple_put(host,user,password,'CFX.def','dir','path',file);
        %Starte Rechnung
        command='path';                                                                     %bash Datei
        ssh2_con=ssh2_simple_command(host,user,password,command);

       %Warten bis Rechnung abgeschlossen ist
        pause(360);
        JobCheck=ssh2_simple_command(host,user,password,'squeue  -u user');
        while length(JobCheck)>1
            pause(60);
            JobCheck=ssh2_simple_command(host,user,password,'squeue  -u user');
        end

%% Auswertung

        ssh2_con=ssh2_simple_command(host,user,password,'sbatch bash-path');
        pause(60);
        JobCheck=ssh2_simple_command(host,user,password,'squeue  -u user');

        while length(JobCheck)>1
            pause(10);
            JobCheck=ssh2_simple_command(host,user,password,'squeue  -u user');
        end

%% Löschen Res Datei
        ssh2_con=ssh2_simple_command(host,user,password,'mv /bigwork *.res /bigwork user/Zwischenspeicher/');
        ssh2_con=ssh2_simple_command(host,user,password,'rm /bigwork *.res');
        ssh2_con=ssh2_simple_command(host,user,password,'rm /bigwork *.out');
        ssh2_con=ssh2_simple_command(host,user,password,'rm -r /bigwork *.dir/');
        ssh2_con=ssh2_simple_command(host,user,password,'mv /bigwork *.res /bigwork user/Optimierung/');
   
%% Ergebnis Tabelle kopieren

        ssh2_con = scp_simple_get(host,user,password,'ResultSummary.csv','Z:\Simulation','path');
        ergebnis= readtable('csv-path','ReadVariableNames',false,'HeaderLines',0);
        zw_erg(1)=ergebnis{end,3};
        zw_erg(2)=ergebnis{end,5};
        zw_erg(3)=ergebnis{end,7};
        zw_erg(4)=ergebnis{end,9};
        erg=str2double(zw_erg)/(10^6);

%         zw_erg= cell2mat(ergebnis{end,2}(1,1));
%         erg= str2num(zw_erg);   
        p_ratio= erg(1);
        eta= erg(2);
        p_ratio_ge= erg(3);
        eta_ge= erg(4);

%% Ausgabe der Ergebnisse

if status > 0                                                               %IF-Bedingung, dass Rechnung abgebrochen ist                                                                                                                                   
    p_ratio= NaN;
    eta= NaN;   
    p_ratio_ge= NaN;
    eta_ge= NaN; 
%   sum= NaN;
    xsol= 1;
    vermerk= 'Rechnung abgebrochen';
     
else                                                                        %Bedingung, dass Rechnung erfolgreich war
    status= 0; 
    vermerk= 'Rechnung erfolgreich';                                              
    p_ratio_ref= 1.727880;                                                   %Referenzwert für das Druckverhältnis aus Simulation mit der Basisgeometrie
    p_ratio_norm= p_ratio_ge/p_ratio_ref;                                   %Normierung des Druckverhältnisses über den Referenzwert
    eta_ref= 0.835548;
    eta_norm= eta_ge/eta_ref;
    xsol= -(p_ratio_norm+eta_norm);                                         %Schreiben der normierten Summe als Bewertungkriterium
end

%% Rausschreiben der Ergebnisse 

speicher= xlsread('ergebnisspeicher_st.xlsx','Tabelle1');                      %Variable zur Bestimmung der beschreibbaren zeile 

if isempty(speicher) == true                                                %If-Bedingung für leere Exceltabelle
    xlswrite('ergebnisspeicher_st.xlsx',A, 'Tabelle1','A2');
    xlswrite('ergebnisspeicher_st.xlsx',number_tubercle, 'Tabelle1','B2');
    xlswrite('ergebnisspeicher_st.xlsx',p_ratio, 'Tabelle1','C2');
    xlswrite('ergebnisspeicher_st.xlsx',eta, 'Tabelle1','D2');
    xlswrite('ergebnisspeicher_st.xlsx',p_ratio_ge, 'Tabelle1','E2');
    xlswrite('ergebnisspeicher_st.xlsx',eta_ge, 'Tabelle1','F2');
    xlswrite('ergebnisspeicher_st.xlsx',xsol, 'Tabelle1','G2');
    xlswrite('ergebnisspeicher_st.xlsx',{vermerk}, 'Tabelle1','H2');
    xlswrite('ergebnisspeicher_st.xlsx',status, 'Tabelle1','I2');
else                                                                        %Bedingung für bereits beschriebene Exceltabelle
    [row,~]= size(speicher);
    num= row+2;
    p_ratio_vgl= xlsread('ergebnisspeicher_st.xlsx','Tabelle1',"E" + num2str(num-1));          %Laden der Vergleichswerte für das Druckverhältnis
    eta_vgl= xlsread('ergebnisspeicher_st.xlsx','Tabelle1',"F" + num2str(num-1));  
    A_vgl=xlsread('ergebnisspeicher_st.xlsx', 'Tabelle1',"A" + num2str(num-1));                %Laden der Vergleichswerte für die Amplitude
    number_tubercle_vgl=xlsread('ergebnisspeicher_st.xlsx','Tabelle1',"B" + num2str(num-1));   %Laden der Vergleichswerte für die Tuberkelanzahl
    
    i=2;
    while isempty(p_ratio_vgl)==1                                            %Durchlaufen der Schleife falls vorherige Rechnung auch nicht erfolgreich war
    p_ratio_vgl= xlsread('ergebnisspeicher_st.xlsx','Tabelle1',"E" + num2str(num-i));
    eta_vgl= xlsread('ergebnisspeicher_st.xlsx','Tabelle1',"F" + num2str(num-i));
    A_vgl=xlsread('ergebnisspeicher_st.xlsx', 'Tabelle1',"A" + num2str(num-i));
    number_tubercle_vgl=xlsread('ergebnisspeicher_st.xlsx','Tabelle1',"B" + num2str(num-i));
    i=i+1;
    end 
    

    diff_pi= p_ratio_vgl - p_ratio_ge;                                      %Differenz des Druckverhältnisses zum Vergleichswert
    diff_eta= eta_vgl-eta_ge;
    cond1= [diff_pi diff_eta];                                              %Aufstellen der ersten Condition
    diff_A= A-A_vgl;                                                        %Differenz der Amplitude zum Vergleichswert
    diff_number_tubercle= number_tubercle-number_tubercle_vgl;              %Differenz der Tuberkel zum Vergleichswert
    cond2= [diff_A diff_number_tubercle];                                   %Aufstellen der zweiten Condition
    
    
    if any(cond1 == 0) && any(cond2~=0)                                     %Bedingung für wenn Ergebnisse gleich aber Amplitude/Periodenanzahl unterschiedlich
        xsol=1;                                                             % ---> Rechnung nicht erfolgreich
        p_ratio_ge= NaN;
        eta_ge= NaN;
        eta= NaN;
        p_ratio= NaN;
        if status == 0
            status= 1;
            vermerk= 'Netz wurde nicht aktualisiert';
        end
    end
    xlswrite('ergebnisspeicher_st.xlsx',A, 'Tabelle1',"A" + num2str(num));
    xlswrite('ergebnisspeicher_st.xlsx',number_tubercle, 'Tabelle1',"B" + num2str(num));
    xlswrite('ergebnisspeicher_st.xlsx',p_ratio, 'Tabelle1',"C" + num2str(num));
    xlswrite('ergebnisspeicher_st.xlsx',eta, 'Tabelle1',"D" + num2str(num));
    xlswrite('ergebnisspeicher_st.xlsx',p_ratio_ge, 'Tabelle1',"E" + num2str(num));
     xlswrite('ergebnisspeicher_st.xlsx',eta_ge, 'Tabelle1',"F" + num2str(num));
    xlswrite('ergebnisspeicher_st.xlsx',xsol, 'Tabelle1',"G" + num2str(num));
    xlswrite('ergebnisspeicher_st.xlsx',{vermerk}, 'Tabelle1',"H" + num2str(num));
    xlswrite('ergebnisspeicher_st.xlsx',status, 'Tabelle1',"I" + num2str(num));
end

%% Schreiben in Seafile

tab= xlsread('ergebnisspeicher_st.xlsx','Tabelle1');
xlswrite('xlsx-path',tab,'Tabelle1');


end

