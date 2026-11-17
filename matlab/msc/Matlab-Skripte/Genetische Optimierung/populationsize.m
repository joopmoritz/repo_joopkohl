clear 
close all
clc 

%% Aufrufen des genetischen Algorithmus
nvars=2;                                                                    %Anzahl der Eingabe Variablen 
popsize= 10;                                                                %Populationsgröße
mutationrate= 0.1;                                                          %%Muatationsrate 


for i= 1:length(popsize)
clear A
eliteCount= round(0.1*popsize(i));                                                %Matlab Recommendation
CF= 1-(mutationrate*popsize(i))/(popsize(i)-eliteCount);                          %CrossFraction --> bezieht sich auf size-eliteCount 
CR= (popsize(i)-eliteCount)/popsize(i) *CF;                                       %CrossoverRate --> bezieht sich auf die Populationgröße 

A(:,1)= randi([3 30],popsize(i),1);                                               %Intialwerte für x(1)
A(:,2)= randi([1 15],popsize(i),1);                                                %Initialwerte für x(2)
A
options = optimoptions(@ga,'InitialPopulationMatrix',A,'PopulationSize',popsize(i),'PopulationType','doubleVector', ...
                       'CrossoverFraction',CF,'EliteCount',eliteCount,'PlotFcn','gaplotbestf','MaxStallGenerations',10 ... 
                       ,'FunctionTolerance',1e-03,'MaxGenerations',100);
[werte_paar(i,:),fval, ~, output] = ga(@fitnessfunction_st_Cluster,nvars,[],[],[],[],[3;1],[30;15],[],[1 2],options);


pfad= 'populationsize.xlsx';
speicher= xlsread(pfad,'Tabelle1');


if isempty(speicher) == true
    xlswrite(pfad,i, 'Tabelle1','A2');
    xlswrite(pfad,popsize(i), 'Tabelle1','B2');
    xlswrite(pfad,mutationrate, 'Tabelle1','C2');
    xlswrite(pfad,CR, 'Tabelle1','D2');
    xlswrite(pfad,fval, 'Tabelle1','E2');
    xlswrite(pfad,werte_paar(i,1),'Tabelle1','F2');
    xlswrite(pfad,werte_paar(i,2), 'Tabelle1','G2');
    xlswrite(pfad,output.generations, 'Tabelle1','H2');
else
    [row,col]= size(speicher);
    num= row+2
    xlswrite(pfad,i, 'Tabelle1',"A" + num2str(num));
    xlswrite(pfad,popsize(i), 'Tabelle1',"B" + num2str(num));
    xlswrite(pfad,mutationrate, 'Tabelle1',"C" + num2str(num));
    xlswrite(pfad,CR, 'Tabelle1',"D" + num2str(num));
    xlswrite(pfad,fval, 'Tabelle1',"E" + num2str(num));
    xlswrite(pfad,werte_paar(i,1),'Tabelle1',"F" + num2str(num));
    xlswrite(pfad,werte_paar(i,2), 'Tabelle1',"G" + num2str(num));
    xlswrite(pfad,output.generations, 'Tabelle1',"H" + num2str(num));
end



%% Email versenden
setpref ('Internet','E_mail','email');
setpref ('Internet','SMTP_Server','smtp.gmx.net') ;
setpref('Internet','SMTP_Username','email'); 
setpref('Internet','SMTP_Password','password') ;
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class','javax.net.ssl.SSLSocketFactory')
props.setProperty('mail.smtp.socketFactory.port','465');
sendmail('email',"genetic optimization completed Interation" + num2str(i));

end