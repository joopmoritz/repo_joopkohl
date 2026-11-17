function [blade_mod] = tubercle_optimierungssetup(pfad_profile,A,number_tubercle)
%% Section 1 ~ Einlesen der Dateien

blade=readmatrix(pfad_profile,'FileType','text');

%Aufteilen der Profilschnitte in einzelne Matrizen
idx=isnan(blade(:,1));
profilenumber=find(idx);

anzahl_profil= length(profilenumber); %Bestimmen Anzahl der Profile

cProfile={};
for i=2:anzahl_profil
    cProfile{i-1,1}=blade(profilenumber(i-1)+1:profilenumber(i)-1,:);
end
cProfile{i,1}=blade(profilenumber(i)+1:length(blade(:,1)),:);


anzahl_profil_neu = 7*number_tubercle+1;  

if A>= 0.001
 anzahl_profil_neu = 9*number_tubercle+1;     
end 

if A>= 0.002
 anzahl_profil_neu = 11*number_tubercle+1;     
end 

%% Section 1.1 ~ Interpolieren der Profilquerschnitte

if anzahl_profil_neu > anzahl_profil                                        %if-Bedingung für die Interpolation der weiterer Profilquerschnitte

for i= 1:length([cProfile{1,1}(:,1)])                                       %For-Schleife zur Interpolation der x, y, z-Koordinaten 
for j= 1:anzahl_profil                                                      %For-Schleife zur Auswahl der Profilquereschnitte
    x(i,j)= [cProfile{j,1}(i,1)];                                           %Aufstellen der x-Werte je Punkt im Profilquerschnitt
    y(i,j)= [cProfile{j,1}(i,3)];                                           %Aufstellen der y-Werte je Punkt im Profilquerschnitt
    z(i,j)= [cProfile{j,1}(i,2)];                                           %Aufstellen der z-Werte je Punkt im Profilquerschnitt
end 

cProfile_int_x(i,:)= spline(1:anzahl_profil,x(i,:),linspace(1,anzahl_profil,anzahl_profil_neu));  %Interpolieren der x-Werte in Abhängigkeit der gewählten Querschnittszahl
cProfile_int_y(i,:)= spline(1:anzahl_profil,y(i,:),linspace(1,anzahl_profil,anzahl_profil_neu));  %Interpolieren der y-Werte in Abhängigkeit der gewählten Querschnittszahl
cProfile_int_z(i,:)= spline(1:anzahl_profil,z(i,:),linspace(1,anzahl_profil,anzahl_profil_neu));  %Interpolieren der z-Werte in Abhängigkeit der gewählten Querschnittszahl

end


anzahl_profil= anzahl_profil_neu;                                           %Überschreiben der Profilanzahl 

for i= 1:anzahl_profil                                                      %For-Schleife zum Aufstellen eines neues Cell-Array mit Profilquerschnitten
[cProfile_int{i,1}(:,1)]= cProfile_int_x(:,i);                              %x-Werte der Profilquerschnitte
[cProfile_int{i,1}(:,3)]= cProfile_int_y(:,i);                              %Y-Werte der Profilquerschnitte
[cProfile_int{i,1}(:,2)]= cProfile_int_z(:,i);                              %Z-Werte der Profilquerschnitte
end 


% for i= 1:anzahl_profil                                                      %Plotten der Profilquerschnitte mit den interpolierten 
%  plot3([cProfile_int{i,1}(:,1)],[cProfile_int{i,1}(:,3)],[cProfile_int{i,1}(:,2)],'r.')
% end 

cProfile_int{end,1}=cProfile{end,1};                                        %Deklariren des Endwerts
cProfile= cProfile_int;                                                     %Überschreiben des Cell-Arrays
end


%% Section 2 ~ Bestimmung der Vorderkante

for i=1:anzahl_profil %Zähler gegen Länge des Cell-Array laufen lassen 
    
    le_y(i) = min([cProfile{i,1}(:,3)]);                            % Y-Wert an Vorderkante (leading edge = le) 
    row(i) = find([cProfile{i,1}(:,3)]== le_y(i));                  % Position des Y-Werts
    le_x(i)= [cProfile{i,1}(row(:,1),1)];                           % X-Wert an Vorderkante 
    le_z(i)= [cProfile{i,1}(row(:,1),2)];                           % Z-Wert an Vorderkante                   
            
end

leading_edge= [le_x' le_y' le_z'];                                  % Koordinaten der Vorderkante

        %% Section 2.1 ~ Transformation der Vorderkante 3D --> 2D

        %Vergleichsgerade durch äußere Punkte der leading_edge
        %Geradengleichung g=g(1) + a* (g(end)-g(1))
        g_x= [le_x(1),le_x(end)];                                           %Deklarierung der Stützpunkte der Geraden in x-Richtung
        g_y= [le_y(1),le_y(end)];                                           %Deklarierung der Stützpunkte der Geraden in y-Richtung
        g_z= [le_z(1),le_z(end)];                                           %Deklarierung der Stützpunkte der Geraden in z-Richtung

        g= [g_x' g_y' g_z'];                                                %Punkte, durch welche die Gerade läuft
        u= g(end,:)'-g(1,:)';                                               %Richtungsvektor der gerade

        %Abstand zwischen Gerade und Vorderkante: 
        %(p-a)x u --> länge((p-a)x u)/länge(u)

        for i=1:anzahl_profil
            AP= leading_edge(i,:)'-g(1,:)';                                                     %Verbindungsvektor zwischen erster Punkt der Gerade und Punkt auf leading_edge
            kr_pro= cross(AP,u);                                                                %Kreuzprodukt
            d(i)= norm(kr_pro)/norm(u);                                                         %Bestimmung des Abstandes
        end

        %lotfußpunkt mit Hilfsebene bestimmen 
        %X0= a + t0*b mit t0= (p-a)*b/|b|^2
        %linke Seite der Hilfsebenengleichung (h1*x+h2*y+h3*z=r) mit [h1 h2 h3 = u]

        for i=1:anzahl_profil                                                                   %Bestimmung des Lotfußpunktes auf der Vergleichsgeraden 
            H_r= u(1)*leading_edge(i,1)+u(2)*leading_edge(i,2)+u(3)*leading_edge(i,3);          %rechte Seite der Hilfebenengleichung r= a*p1+b*p2+c*p3 mit Punkt P= [p1 p2 p]

            %Einsetzen der Koordinaten der Geraden in die Ebenengleichung
            %H= h1(g(1,1)+a*g(end,1)) + h2(g(1,2)+a*g(end,2)) + h3(g(1,3)+a*g(end,3))
            syms a1
            a1= solve((u(1)*(g(1,1)+a1*u(1))+u(2)*(g(1,2)+a1*u(2))+u(3)*(g(1,3)+a1*u(3)))==H_r,a1);
            lot_fp(i,:)= double(g(1,:)'+a1*u)';
        end

        
         %% Section 2.2 ~ Plotten der Vorderkante                                    
%         %Plotten der Vorderkante
%         figure(1)
%         subplot(1,2,1)
%         plot3(le_x, le_y, le_z,'.-','Color','r');                                           %Plotten der leading_edge einzeln                                
%         hold on 
%         plot3(g_x,g_y,g_z,'-','Color','k');                                                 %Plotten der Geraden 
% 
%         %Plotten des Lots
%         for i= 1:anzahl_profil
%             plot3([lot_fp(i,1), leading_edge(i,1)],[lot_fp(i,2), leading_edge(i,2)], ...    %Plotten des Verbindungsvektors zwischen Lotfußpunkt und leading_edge
%                 [lot_fp(i,3), leading_edge(i,3)],'--','Color','k');     
%                                                                                                                                           	
%         end
%         grid on 
%         grid minor
%         legend('$\textrm{Vorderkante}$','$\textrm{Hilfsgerade}$','$\textrm{Lotlinen}$','Interpreter','Latex');
% 
%         xlabel('$\textrm{x-Achse}$','Interpreter','Latex');
%         ylabel('$\textrm{y-Achse}$','Interpreter','Latex');
%         zlabel('$\textrm{z-Achse}$','Interpreter','Latex');

        %% Section 2.3 ~ Darstellung der Vorderkante in 2D

        %Abstand der Lotpunkte bestimmen
        lot_abstand(1)= 0;                                                  %beliebiger Ausgangswert für den relativen Abstand der Lotpunkte auf der Vergleichsgeraden
        lot_abstand_alt= 0;                                                 %Abstand zwischen den einzelnen Profilquerschitten


            for i= 1:anzahl_profil-1

            lot_abstand(i+1)=lot_abstand_alt+ sqrt((lot_fp(i+1,1)-lot_fp(i,1))^2 ...
                +(lot_fp(i+1,2)-lot_fp(i,2))^2 ... 
                +(lot_fp(i+1,3)-lot_fp(i,3))^2);  %Abstand zwischen den einzelnen Profilquerschitten
            
            lot_abstand_alt= lot_abstand(i+1);

            end              


        %Normieren der Vorderkantenbreite auf 0 & 1 bzw. Länge der Vergleichsgeraden 0= Hub und 1= Shroud
        le_hub_shroud= lot_abstand./norm(g(end,:)-g(1,:));                  %Normierte Länge der Vorderkante bzw. Abstände der Profilquerschnitte (lot_abstand)
                                                                            %Normiert durch Länge des Verbindungsvektor zwischen Anfang und Ende der Geraden: norm(g(end,:)-g(1,:)) 
                                                                            %Länge der Gerade größer als r_shround - r_hub = 0.028, da profil schräg steht                                                                    %

        
%         subplot(1,2,2)
%         plot(le_hub_shroud, d,'b.-',le_hub_shroud(1),d(1),'mx',le_hub_shroud(end),d(end),'cx'); %Plotten der in 2D tranformierte Vorderkante 
%         ax= gca; 
%         ax.YLim = [-0.0005 0.0015];
%         ax.XLim = [-0.1 1.1];
%         grid on 
%         grid minor
%         xlabel('$\textrm{normierte Vorderkanten-Breite}$','Interpreter','Latex');
%         ylabel('$\textrm{W\"{o}lbung der Vorderkante in mm}$','Interpreter','Latex');
%         legend('$\textrm{2D-transformierte Vorderkante}$','$\textrm{Hub}$','$\textrm{Shroud}$','Interpreter','Latex'); 
% 

%% Section 3 ~ Modifikation der Vorderkante

        %% Section 3.1 ~ Annäherung der Vorderkante durch geeignete Funktion 
        
        [xData, yData] = prepareCurveData( le_hub_shroud, d);
        
        % Set up fittype and options.
        ft = fittype('poly3');

        % Fit model to data.
        [fitresult, gof] = fit( xData, yData, ft );

        % Plot fit with data.
%         figure(2);
%         h = plot( fitresult, xData, yData );
%         legend( h, 'Profilquerschnitte', 'Polynom', 'Location', 'NorthEast', 'Interpreter', 'none' );
%         % Label axes
%         xlabel( 'le_hub_shroud', 'Interpreter', 'none' );
%         ylabel( 'd', 'Interpreter', 'none' );
%         grid on      
        
        
%         [fitresult, gof]= fit_leading_edge(le_hub_shroud,d , type);         %Aufrufen der Funtion zur Annäherung der Vorderkante durch Polynom
        coefficientValues= coeffvalues(fitresult);                          %Rausschreiben der Koeffizienten des Polynoms
        r_square= gof.rsquare;                                              %Rausschreiben des R-square --> Aussage über Güte der Annäherung
        fprintf('R-square:  %d \n',double(r_square));                       %Darstellen des R-squares
        
        poly_grad= length(coefficientValues)-1;                             %Grad des Polynoms
        
        stuetzp= linspace(le_hub_shroud(1), le_hub_shroud(end), 10000);     %Stützpunkte deklarieren für Funktion und Tuberkel 
        
        k= 1;                                                               %Zähler für Polynom
        le_poly_alt = 0;                                                    %Deklarieren des Zwsichenspeichers
        
        for i= poly_grad:-1:1                                               %For-Schleife fürs Aufstellen des Polynoms ohne Konstante
            
            le_poly= le_poly_alt + coefficientValues(k).*stuetzp.^(i);      %Aufsummieren des Polynoms
            le_poly_alt= le_poly;                                           %Überschreibung des zwischenspeichers
            k= k + 1;                                                       %Hochzählen des Zählers
        
        end
        
        le_poly= le_poly_alt + coefficientValues(end);                      %hinzu addieren der Konstande des Polynoms zum den x-abhängigen Termen --> vollständiges Polynom  

        
%         figure(3);                              %Plot-Vergleich der 2D-transformierten Vorderkante und des angenäherten Polynoms
%         plot(le_hub_shroud, d,'r.-', stuetzp ,le_poly,'b-')
%         xlabel('$\textrm{normierte Vorderkanten-Breite}$','Interpreter','Latex'); 
%         ylabel('$\textrm{W\"{o}lbung der Vorderkante in mm}$','Interpreter','Latex');
%         legend('$\textrm{2D-transformierte Vorderkante}$','$\textrm{angen\"{a}hertes Polynom}$','Interpreter','Latex');
%         grid on 
%         grid minor
        
        
        %% Section 3.2 ~ Modifikation der Vorderkante in 2D durch sinusförmige Tuberkel

        lambda= (le_hub_shroud(end)-le_hub_shroud(1))/number_tubercle;      %Wellenlänge abhängig von Tuberkelanzahl 
        b= 2*pi/lambda;                                                     %Parameter der Sinusfunktion mit f(x)= A*sin(b*x)

        tubercle= (le_poly + A*sin(b*stuetzp+pi/2))-A;                      %Aufstellen der Tuberkelgeometrie durch Überlagerung von Polynom und Sinus

%         figure(4)                                    %Plotten der tuberkelbesetzten Vorderkante und der Ausgangsgeometrie
%         p1= plot(stuetzp,tubercle,'b-',stuetzp ,le_poly,'r-');
%         ax= gca; 
%         ax.YLim = [-0.001 0.002];
%         ax.XLim = [-0.1 1.1];
%                 
%         hold on 
        tubercle_profile= (d + A*sin(b*le_hub_shroud+pi/2))-A;                  %bestimmen der Punkte an der tuberkelbesetzen Vorderkante für gegebene Profilquerschnitte
%               
%         for i= 1:length(le_hub_shroud)                                                  %For-Schleife zum Plotten mehrer xlines (vertikalen linien)
%     
%         X= [le_hub_shroud(i) le_hub_shroud(i)];                             %x-Werte definieren 
%         Y= [tubercle_profile(i) 0];                                         %y-Werte definieren 
%         plot(X,Y,'k--');                                                    %xline plotten 
%         hold on
%         end     
%         
%         legend('$\textrm{tuberkelbesetzte Vorderkante}$','$\textrm{Ausgangsgeometrie}$' ...
%             ,'$\textrm{Profilquerschnitte}$','Interpreter','Latex');
%         
%         xlabel('$\textrm{normierte Vorderkanten-Breite}$','Interpreter','Latex'); 
%         ylabel('$\textrm{W\"{o}lbung der Vorderkante in mm}$','Interpreter','Latex');
%         grid on 
%         grid minor 
    
        
%% Section 4 ~ Transformation von 3D in 2D    
        
 %       Bestimmung des Punktes der tuberkelbesetzten Vorderkante im Raum durch gegebenen Abstand: tubercle_profile zur Vergleichgeraden
 %       Vorgehen: Aufstellen neuer geraden Gleichung mit:
 %       Ortvektor= Lotfußpunkt
 %       Richtungsvektor= Differenz aus Punkt auf Vorderkante (leading_edge)und Lotfußpunkt (lot_fp)

        %% Section 4.1 ~ Bestimmen von Punkt im Raum der Tuberkelvorderkante je Profil
        
        richt_vek= leading_edge-lot_fp;                                     %Bestimmung des Richtungsvektors der Geraden durch Lotfußpunkt und Vorderkante
                                                                            %--> Gerade= lot_fp + a2*richt_vek

        %Formel Abstand: d= sqrt((p1-x)^2+(p2-y)^2+(p3-z)^2)
        %mit gesuchter Punkt p= [p1 p2 p3] und Lotfufpunkt= [x y z] --> für p Geradengleichung einsetzen und nach Parameter umformen
         
   
        
        for i= 2:anzahl_profil-1                                            %For-Schleife zur Berechnung der Profilpunkte an der modifizierten Vorderkante für Profil 2-20,
                                                                            %da für Profil 1 und 21 kein Abstand ziwschen leading_edge und Vergleichsgerade vorliegt
        syms a2                                                             
        
        if (tubercle_profile(i) > 0)
            
        a2= double(solve(sqrt(((lot_fp(i,1) + a2*richt_vek(i,1))-lot_fp(i,1))^2 ...             %Berechnung des Parameters der Geradengleichung 
            +((lot_fp(i,2) + a2*richt_vek(i,2))-lot_fp(i,2))^2 ... 
            +((lot_fp(i,3) + a2*richt_vek(i,3))-lot_fp(i,3))^2)==tubercle_profile(i),a2));
        
        le_mod_x(i)= double(lot_fp(i,1)+a2(2)*richt_vek(i,1));              %Schreiben der x-Koordinaten 2-20
        le_mod_y(i)= double(lot_fp(i,2)+a2(2)*richt_vek(i,2));              %Schreiben der y-Koordianten 2-20
        le_mod_z(i)= double(lot_fp(i,3)+a2(2)*richt_vek(i,3));              %Schreiben der z-Koordinaten 2-20
        a(i)= a2(2);
        
        elseif (tubercle_profile(i) < 0)                                    %für große Amplituden wird tubercle_profile negativ --> andere Bedingung für gleichungssystem
                                                                            % Verwendung von a2(1), da dann verschiebung in negative Richtung bezogen auf Lotfußpunkt erfolgt                    
       
        a2= double(solve(sqrt(((lot_fp(i,1) + a2*richt_vek(i,1))-lot_fp(i,1))^2 ...             %Berechnung des Parameters der Geradengleichung 
            +((lot_fp(i,2) + a2*richt_vek(i,2))-lot_fp(i,2))^2 ... 
            +((lot_fp(i,3) + a2*richt_vek(i,3))-lot_fp(i,3))^2)==(-tubercle_profile(i)),a2));
        
        le_mod_x(i)= double(lot_fp(i,1)+a2(1)*richt_vek(i,1));              %Schreiben der x-Koordinaten 2-20
        le_mod_y(i)= double(lot_fp(i,2)+a2(1)*richt_vek(i,2));              %Schreiben der y-Koordianten 2-20
        le_mod_z(i)= double(lot_fp(i,3)+a2(1)*richt_vek(i,3));              %Schreiben der z-Koordinaten 2-20
        a(i)= a2(1);
        end
                
        end
       
        %Bestimmung tuberkelbesetzten Vorderkante für Profil 1 & 21 durch Verschiebung einer Gerade mit dem Richtungsvektor richt_vek
        %Berechnung der Punkte 1 & 21 durch Verschiebung der Gerade des zweiten Punktes
        
        i=1;
             
        le_mod_x(1)= leading_edge(i,1);                                     %Schreiben der x-Koordinaten 1
        le_mod_y(1)= leading_edge(i,2);                                     %Schreiben der y-Koordianten 1
        le_mod_z(1)= leading_edge(i,3);                                     %Schreiben der z-Koordinaten 1
         
        i= anzahl_profil;
                
        le_mod_x(i)= leading_edge(i,1);                                     %Schreiben der x-Koordinaten 21
        le_mod_y(i)= leading_edge(i,2);                                     %Schreiben der y-Koordianten 21
        le_mod_z(i)= leading_edge(i,3);                                     %Schreiben der z-Koordinaten 21
       
        le_mod= [le_mod_x' le_mod_y' le_mod_z'];                            %Zusammenfassung zur Matrix
        
        
%         figure(5)                           %Plotten der tuberkelbesetzten Vorderkante im Raum 
%         p3= plot3(le_x,le_y,le_z,'r.-',le_mod_x,le_mod_y,le_mod_z,'c.');    %und Plotten der Basisvorderkante
%         set(p3,{'LineWidth'},{0.5;2});
%         hold on 
%         plot3(g_x,g_y,g_z,'-','Color','k');                                 %Plotten der Vergleichgerade  
% 
%         %Plotten des Lots
%         for i= 1:anzahl_profil
%             
%             plot3([lot_fp(i,1), leading_edge(i,1)],[lot_fp(i,2), ...        %Plotten des Verbindungsvektors zwischen Lotfußpunkt und leading_edge
%                   leading_edge(i,2)], [lot_fp(i,3), leading_edge(i,3)], ... 
%                   '--','Color','k');                                        
%         end
% 
%         grid on 
%         grid minor
%         xlabel('$\textrm{x-Achse}$','Interpreter','Latex');
%         ylabel('$\textrm{y-Achse}$','Interpreter','Latex');
%         zlabel('$\textrm{z-Achse}$','Interpreter','Latex');
%         legend('$\textrm{Vorderkante}$','$\textrm{modifizierte Vorderkante}$', ...
%                '$\textrm{Hilfsgerade}$','$\textrm{Lotlinien}$','Interpreter','Latex');
%         
        
        
        cProfile_mod= cProfile;                                             %Deklarieren eines Cell-Vektors für die modifizierte Vorderkante
        
        for i= 1:anzahl_profil                                              %For-Schleife zur Zuweisung der neuen Vorderkantengeometrie je Profil
            
            [cProfile_mod{i,1}(row(i),1)]= le_mod(i,1);                     %Neuschreiben der modifizierten Zeilen in x-Richung
            [cProfile_mod{i,1}(row(i),3)]= le_mod(i,2);                     %Neuschreiben der modifizierten Zeilen in y-Richtung
            [cProfile_mod{i,1}(row(i),2)]= le_mod(i,3);                     %Neuschreiben der modifizierten Zeilen in z-Richtung
        
        end
        
%% Section 5 ~ Anpassen des gesamten Bereichs Nahe der Vorderkante
%   1) Vorderkante wird nur durch eine Kurve beschrieben. Allerdings muss der gesamte Bereich nahe der Vorderkante angepasst werden, damit eine
%   Implementierung der Tuberkelgeometrie erfolgen kann
%   2) Angepasste Tuberkelgeometrie muss auf Profiloberfläche projiziert werden, da 2D transformierte LE nicht auf Profiloberfläche aufliegt ---> Profiloberfläche ist gekrümmt


        %% Section 5.1 ~ Umschreiben der einzelnen Profilvektoren in einen Vektor je Koordinate
        
        %nicht nötigt, dient nur zur Visualisierung 
        n=1;                                                                %Inkrement zur Definition der zu überschreibenden Zeilen --> Startwert
        k= length([cProfile_mod{1,1}(:,1)]);                                %Inkrement zur Definition der zu überschreibenden Zeilen --> Endwert
        
        for i= 1:anzahl_profil                                              %For-Schleife zur Überschreibung der angepassten Geometrie in einen Vektor je Koordinate
                        
        blade1_mod(n:k,1)= [cProfile_mod{i,1}(:,1)];                        %Vektor für x-Koordinate
        blade3_mod(n:k,1)= [cProfile_mod{i,1}(:,3)];                        %Vektor für y-Koordinate
        blade2_mod(n:k,1)= [cProfile_mod{i,1}(:,2)];                        %Vektor für z-Koordinate
        
        n= k+1;
        k=k+length([cProfile_mod{1,1}(:,1)]);                               %Zaehler für die Anzahl an Punkten je Profil 
        
        end
                
%         figure(6);                           %Plotten der Geometrie mit der aus 2D überführten Vorderkante
%         plot3(blade1_mod,blade3_mod,blade2_mod,'-');                        %Plotten der Profilquerschnitte
%         hold on 
%         plot3(le_mod_x,le_mod_y,le_mod_z,'r.-')                             %Plotten der 2D transformierten Vorderkante
%         xlabel('$\textrm{x-Achse}$','Interpreter','Latex');
%         ylabel('$\textrm{y-Achse}$','Interpreter','Latex');
%         zlabel('$\textrm{z-Achse}$','Interpreter','Latex');
%         grid on 
%         grid minor
%         
        %% Section 5.2 ~ Projizieren der tuberkelbesetzten Vorderkante auf Profiloberfläche
        %Vorgehen: Bestimmung des Abstandens zwischen 2D-transformierter Vorderkante und der Profiloberfläche bzw. Abstand zwischen jedem Punkt
        % und der 2D-transformierten Vorderkante auf der Saugseite.
        %Kleinste Abstand liegt dann vor, wenn Verbindungsvektor senkrecht auf Profiloberfläche steht. 
        %Um zu bestimmen, zwischen welchen Punkte die Vorderkante liegt, werden die zwei kleinsten Abstände bestimmt und dadurch gilt, dass
        % der kleinste Abstand zur 2D-transformiertenb Vorderkante zwischen diesen Punkten liegt.
                
        le2surface_min= ones(2,anzahl_profil);                              %Deklarieren eines Vektor zu Speicherung der minimalen Abstände
        le2surface_pos= zeros(2,anzahl_profil);                             %Deklarieren eines Vektor zur Speicherung der Position der minimalen Abstände 
        for i= 1:anzahl_profil                                              %For-Schleife zur Bestimmung der Punkte, welche an der modifizierten Vorderkante angrenzen 
                                                                            %, um die Lage der Vorderkante bestimmen zu können
            for k= length([cProfile{i,1}]):-1:row(i)                           %For-Schleife zum Aufrufen der einzelnen Punkte hinter der Vorderkante
                
                le2surface= sqrt(([cProfile{i,1}(k,1)]-le_mod_x(i))^2 + ... %Bestimmen des Abstandes zwischen Vorderkante und jedem k-ten Punkt
                    ([cProfile{i,1}(k,3)]-le_mod_y(i))^2 +...
                    ([cProfile{i,1}(k,2)]-le_mod_z(i))^2);
                
                if le2surface < le2surface_min(1,i)                         %if-Bedingung zum finden der minimalen Abstände
                    le2surface_min(2,i)= le2surface_min(1,i);               %Umschreiben des Vektor, damit zweit kleinster Abstand auch gespeichert wird
                    le2surface_min(1,i)= le2surface;                        %Speichern der kleinsten Abstandes
                    
                    le2surface_pos(2,i)= le2surface_pos(1,i);               %Speicherung der Position --> Vektor gibt an zwischen welchen Punkten sich der Punkt
                    le2surface_pos(1,i)= k;                                 %  auf der Profiloberfläche befindet.
                end
            end
        end
        
        num= le2surface_pos;                                                %Umschreiben des Vektor --> schneller abrufbar
        %Aufstellen der Gerade durch zwei Punkte, zwischen welchen der Punkte der modifizierten Vorderkante liegt
        %Gerade dient zur Annäherung der Profiloberfläche 
  
        for i= 1:anzahl_profil                                                              %For-Schleifen zum Aufstellen der Vektoren der Gerade zur Annäherung der Profiloberfläche
            if (leading_edge(i,2) == le_mod(i,2))                                           %Bedingung für die Tuberkelspitzen
                
                ort_vek(i,:)=  [cProfile{i,:}(row(i),:)];                                   %Ortsvektor 
                richt2_vek(i,:)= [0 0 0];                                                   %Richtungsvektor

            elseif (leading_edge(i,2) < le_mod(i,2))                                        %Bedingung für die Tuberkelsenken
                
                ort_vek(i,:)=  [cProfile{i,1}(num(1,i),:)];                                   %Ortsvektor 
                richt2_vek(i,:)= [cProfile{i,1}(num(2,i),:)]-[cProfile{i,1}(num(1,i),:)];     %Richtungsvektor
            end
        end
    

        %Projizierung der tuberkelbesetzten Vorderkante auf Profiloberflächen 
        for i=1:anzahl_profil                                                                                %For-Schleife zur Bestimmung des Lotfußpunktes auf der Profiloberfläche
        H_r2= richt2_vek(i,1)*le_mod(i,1)+richt2_vek(i,3)*le_mod(i,2)+richt2_vek(i,2)*le_mod(i,3);           %rechte Seite der Hilfebenengleichung r= a*p1+b*p2+c*p3 mit Punkt P= [p1 p2 p]

        %Einsetzen der Koordinaten der Geraden in die Ebenengleichung
        %H= h1(g(1,1)+a*g(end,1)) + h2(g(1,2)+a*g(end,2)) + h3(g(1,3)+a*g(end,3))
        syms a3
        a3= solve(richt2_vek(i,1)*(ort_vek(i,1)+a3*richt2_vek(i,1)) ...                                      %Bestimmung des Parameters der Parameter-Gleichung
            +richt2_vek(i,3)*(ort_vek(i,3)+a3*richt2_vek(i,3)) ... 
            +richt2_vek(i,2)*(ort_vek(i,2)+a3*richt2_vek(i,2))==H_r2,a3);
        
        le_mod_lot(i,:)= double(ort_vek(i,:)+a3*richt2_vek(i,:));                                             %Punkt der modifizierten Vorderkante projiziert auf Profiloberfläche
        end

%         plot3(le_mod_lot(:,1),le_mod_lot(:,3),le_mod_lot(:,2),'c.-');                                         %Plotten der auf die Profiloberfläche projizierten Vorderkante  
%         legend('$\textrm{Profilquerschnitte}$','$\textrm{2D transformierte Vorderkante}$' ... 
%                 ,'$\textrm{projizierte Vorderkante}$','Interpreter','latex');
        
        for i= 1:anzahl_profil                                              %For-Schleife zur Zuweisung der neuen Vorderkantengeometrie je Profil
            
            [cProfile_mod{i,1}(row(i),1)]= le_mod_lot(i,1);                 %Neuschreiben der modifizierten Zeilen in x-Richung
            [cProfile_mod{i,1}(row(i),3)]= le_mod_lot(i,3);                 %Neuschreiben der modifizierten Zeilen in y-Richtung
            [cProfile_mod{i,1}(row(i),2)]= le_mod_lot(i,2);                 %Neuschreiben der modifizierten Zeilen in z-Richtung
        
        end
        
        n=1;                                                                %Inkrement zur Definition der zu überschreibenden Zeilen --> Startwert
        k= length([cProfile_mod{1,1}(:,1)]);                                %Inkrement zur Definition der zu überschreibenden Zeilen --> Endwert
        
        for i= 1:anzahl_profil                                              %For-Schleife zur Überschreibung der angepassten Geometrie in einen Vektor je Koordinate
                        
        blade1_mod(n:k,1)= [cProfile_mod{i,1}(:,1)];                        %Vektor für x-Koordinate
        blade3_mod(n:k,1)= [cProfile_mod{i,1}(:,3)];                        %Vektor für y-Koordinate
        blade2_mod(n:k,1)= [cProfile_mod{i,1}(:,2)];                        %Vektor für z-Koordinate
        
        n= k+1;
        k=k+length([cProfile_mod{1,1}(:,1)]);                               %Zaehler für die Anzahl an Punkten je Profil 
        
        end
        
        %% Section 5.3 ~ Verschiebung der Vorderkante durch Parallelverschiebung der Geraden zwischen gerader und modifizierten Vorderkante
        
        %For-Schleife zur Bestimmung des Abstandes zwischen ursprünglicher Vorderkante und tuberkelbesetzter Vorderkante im Raum
        %Abstand wird benötigt über restliche Punkte zu verschieben
        
        for i= 1:anzahl_profil 
        le2le_mod(i)= sqrt((le_mod_lot(i,1)-leading_edge(i,1))^2 ...        %Abstand zwischen ursprünglicher Vorderkante und modifizierter Vorderkante im Raum
            +(le_mod_lot(i,3)-leading_edge(i,2))^2 ... 
            +(le_mod_lot(i,2)-leading_edge(i,3))^2);    
        end
        
           rvek_le2le_mod= [le_mod_lot(:,1)-leading_edge(:,1), ...          %Aufstellen des Richtungsvektors der Geraden zwisch le & le_mod_lot je Profil 
            le_mod_lot(:,3)-leading_edge(:,2), ... 
            le_mod_lot(:,2)-leading_edge(:,3)];              
       
        
        %Bestimmung des anzupassenden Bereichs der Vorderkante anhand der Steigung der y-Wert
    
       for k= 1: length([cProfile{1,1}(:,3)])-1                             %For-Schleife zur Bestimmung der Steigung der Y-Werte repräsentativ für das erste Profil 
       dy_val(k,1) = ([cProfile{1,1}(k+1,3)]-[cProfile{1,1}(k,3)])/(k+1-k);   
       end
    
        
%         figure(7);                      %Plotten der Steigung 
%         plot(1:length([cProfile{1,1}])-1,dy_val);                           %Visuelle Betrachtung --> Vorderkante zwischen 103-113
%         xlabel('$\textrm{Position}$','interpreter','latex');
%         ylabel('$\textrm{\"{A}nderungsrate}$','interpreter','latex');
%         legend('$\textrm{Differenz Y-Werte}$','Interpreter','latex');
%         grid on 
%         grid minor   
%         
                
        le_bereich_min= find(dy_val(100:120,1)== min(dy_val(100:120,1)));   %Mathematische Bestimmung des Punktes, ab welchem Voderkante beginngt
        le_bereich_max= find(dy_val(100:120,1)== max(dy_val(100:120,1)));   %Mathematische Bestimmung des Punktes, ab welchem Voderkante endet
        
        le_int= [(99 + le_bereich_min) : (99+ le_bereich_max)];             %Schreiben des Bereichs der Vorderkante in einen Vektor --> Gibt Start- und Endwert der Vorderkante an
      
        for i= 1:anzahl_profil                                              %For-Schleife zur Verschiebung der Punkte im Bereich der Vorderkante parallel zur Gerade zwischen le & le_mod_lot
                     
            for k= 1:length(le_int(1):le_int(end))                          %Inkrement zur Auswahl der Werte an Vorderkante innerhalb einer Geometrie 
                
                    if (leading_edge(i,2) == le_mod(i,2))                    %Bedingung für Tuberkelspitzen --> Verschiebung gegen Strömungsrichtung --> y gegen 0 
                        
                                              
                        le_int_mod_x(k,i)= [cProfile{i,1}(le_int(k),1)];    %Aufstellen der Matrix der verschobenen Punkte in x-Richtung
                        le_int_mod_y(k,i)= [cProfile{i,1}(le_int(k),3)];    %Aufstellen der Matrix der verschobenen Punkte in y-Richtung
                        le_int_mod_z(k,i)= [cProfile{i,1}(le_int(k),2)];    %Aufstellen der Matrix der verschobenen Punkte in z-Richtung
                        
                    elseif (leading_edge(i,2) < le_mod(i,2))                %Bedingung für Tuberkelsenken--> Verschiebung in Strömungsrichtung
                        
                        syms a4
                        
                        a4= double(solve(sqrt((([cProfile{i,1}(le_int(k),1)]+ a4*rvek_le2le_mod(i,1))-[cProfile{i,1}(le_int(k),1)])^2 ... 
                            +(([cProfile{i,1}(le_int(k),3)] + a4*rvek_le2le_mod(i,2))-[cProfile{i,1}(le_int(k),3)])^2 ... 
                            +(([cProfile{i,1}(le_int(k),2)] + a4*rvek_le2le_mod(i,3))-[cProfile{i,1}(le_int(k),2)])^2)==le2le_mod(i),a4));
                        
                        le_int_mod_x(k,i)= [cProfile{i,1}(le_int(k),1)]+a4(end)*rvek_le2le_mod(i,1);    %Aufstellen der Matrix der verschobenen Punkte in x-Richtung
                        le_int_mod_y(k,i)= [cProfile{i,1}(le_int(k),3)]+a4(end)*rvek_le2le_mod(i,2);    %Aufstellen der Matrix der verschobenen Punkte in y-Richtung
                        le_int_mod_z(k,i)= [cProfile{i,1}(le_int(k),2)]+a4(end)*rvek_le2le_mod(i,3);    %Aufstellen der Matrix der verschobenen Punkte in z-Richtung
                    end

            end
        end
      
        %% Section 5.4 ~ Überschreiben der Matrizen | Einfügen der verschobenen Punkte an Vorderkante 
        
        for i= 1:anzahl_profil                                              %For-Schleife zur Überschreibung der Vorderkante je Profil
            
        [cProfile_mod{i,1}(le_int(1):le_int(end),1)]= le_int_mod_x(:,i);    %Überschreibung der x-Werte des modifizierten Profils 
        [cProfile_mod{i,1}(le_int(1):le_int(end),3)]= le_int_mod_y(:,i);    %Überschreibung der x-Werte des modifizierten Profils
        [cProfile_mod{i,1}(le_int(1):le_int(end),2)]= le_int_mod_z(:,i);    %Überschreibung der x-Werte des modifizierten Profils
        end 
        
        
        n=1;                                                                %Inkrement zur Definition der zu überschreibenden Zeilen --> Startwert
        k= length([cProfile_mod{1,1}(:,1)]);                                %Inkrement zur Definition der zu überschreibenden Zeilen --> Endwert
                
        for i= 1:anzahl_profil                                              %For-Schleife zur Überschreibung der angepassten Geometrie in einen Vektor je Koordinate
                        
        blade1_mod(n:k,1)= [cProfile_mod{i,1}(:,1)];                        %Vektor für x-Koordinate
        blade3_mod(n:k,1)= [cProfile_mod{i,1}(:,3)];                        %Vektor für y-Koordinate
        blade2_mod(n:k,1)= [cProfile_mod{i,1}(:,2)];                        %Vektor für z-Koordinate
        
        n= k+1;
        k=k+length([cProfile_mod{1,1}(:,1)]);                               %Zaehler für die Anzahl an Punkten je Profil 
        
        end    

%         figure(8);                    %Plotten der Schaufel mit verschobener Vorderkante
%         plot3(blade1_mod,blade3_mod,blade2_mod,'.-');
%         hold on 
%         plot3(le_mod_lot(:,1),le_mod_lot(:,3),le_mod_lot(:,2),'r.');
%         grid on 
%         grid minor
%         xlabel('$\textrm{x-Achse}$','Interpreter','Latex');
%         ylabel('$\textrm{y-Achse}$','Interpreter','Latex');
%         zlabel('$\textrm{z-Achse}$','Interpreter','Latex');
%         
        %% Section 5.5 ~ Anpassen des Übergangs zwischen modifizierter Vorderkante und Profil an der Saugseite
        %Bei zu großen Amplituden liegt der punkt 112 hinter Punkt 113 oder weitere Punkte in Strömungsrichtung und
        %ebenfalls oberhalb der Profiloberfläche --> Vorderkante muss abgesenkt werden und die punkte, hinter welchen die Vorderkante gerückt ist, angepasst
        %Vorderkante liegt vorallem hinter Punkten bei steigender Profilnummer, da dort Abstand zwischen 112 und 113 kleiner wird 
        %Bedingung: sobald 112 zwischen 114 und 113 liegt, liegt 112 oberhalb der Profiloberfläche 
        
        le_int_end_lot= [];
        
        for i= 1:anzahl_profil                                                              %For-Schleife zur Projizierung des letzten Werts der Vorderkante (le_int(end)) auf Profiloberfläche
            
            if [cProfile_mod{i,1}(le_int(end),3)] > [cProfile_mod{i,1}(le_int(end)+1,3)]    %Bedingung dafür, dass Vorderkante hinter andere Werte rückt wegen zu großer Amplitude
                                                                                            
             num3= find([cProfile_mod{i,1}(le_int(end):end,3)] > [cProfile_mod{i,1}(le_int(end),3)]);    %Bestimmung der Werte des Profils, zwischen welchen der letzte Punkt der Vorderkante liegt
             le_profil_begin(i)= num3(1)+row(i)+1;                                                       %Position des Werts, ab welchem Profil ohne Vorderkante beginnt  
           
             %Gerade aufstellen zwischen den Punkten, zwischen welchen der letzte Punkt der Vorderkante liegt, um Profiloberfläche anzunähern
             richt3_vek(i,:)= [cProfile_mod{i,1}(le_profil_begin(i),:)] ...                    %Richtungsverktor aufstellen
                            - [cProfile_mod{i,1}(le_profil_begin(i)-1,:)];   
             ort2_vek(i,:)= [cProfile_mod{i,1}(le_profil_begin(i),:)];                         %Ortsvektor
             
             H_r3= richt3_vek(i,1)*[cProfile_mod{i,1}(le_int(end),1)]+ ...                  %rechte Seite der Hilfebenengleichung r= a*p1+b*p2+c*p3 mit Punkt P= [p1 p2 p] 
                   richt3_vek(i,3)*[cProfile_mod{i,1}(le_int(end),3)]+ ...                  %Hilfsebene die senkrecht auf der Geraden steht und den Punkt le_int(end) schneidet
                   richt3_vek(i,2)*[cProfile_mod{i,1}(le_int(end),2)];  
        
            syms a5
            a5= vpasolve(richt3_vek(i,1)*(ort2_vek(i,1)+a5*richt3_vek(i,1)) ...             %Bestimmung des Parameters der Geraden
            +richt3_vek(i,3)*(ort2_vek(i,3)+a5*richt3_vek(i,3)) ...
            +richt3_vek(i,2)*(ort2_vek(i,2)+a5*richt3_vek(i,2)) == H_r3,a5);
        
            le_int_end_lot(i,:)=  ort2_vek(i,:)+a5*richt3_vek(i,:);                         %Lotpunkt, projizierter Punkt auf Profilebene bestimmen    
    
            elseif leading_edge(i,:)-le_mod(i,:) ~= 0
             richt3_vek(i,:)= [cProfile_mod{i,1}(row(i)+2,:)] ...                    %Richtungsverktor aufstellen
                            - [cProfile_mod{i,1}(row(i),:)];   
             ort2_vek(i,:)= [cProfile_mod{i,1}(row(i),:)];                           %Ortsvektor
             
             H_r3= richt3_vek(i,1)*[cProfile_mod{i,1}(le_int(end),1)]+ ...                  %rechte Seite der Hilfebenengleichung r= a*p1+b*p2+c*p3 mit Punkt P= [p1 p2 p] 
                   richt3_vek(i,3)*[cProfile_mod{i,1}(le_int(end),3)]+ ...                  %Hilfsebene die senkrecht auf der Geraden steht und den Punkt le_int(end) schneidet
                   richt3_vek(i,2)*[cProfile_mod{i,1}(le_int(end),2)]; 
               
            syms a5
            a5= vpasolve(richt3_vek(i,1)*(ort2_vek(i,1)+a5*richt3_vek(i,1)) ...             %Bestimmung des Parameters der Geraden
            +richt3_vek(i,3)*(ort2_vek(i,3)+a5*richt3_vek(i,3)) ...
            +richt3_vek(i,2)*(ort2_vek(i,2)+a5*richt3_vek(i,2)) == H_r3,a5);
        
            le_int_end_lot(i,:)=  ort2_vek(i,:)+a5*richt3_vek(i,:); 
            le_profil_begin(i)= le_int(end);                                            
            
            end 
        end 
            
%         for i= 1:length(le_int_end_lot)                                                     %For-Schleife zum Plotten des projizierten Punktes auf Profrilebene
%             
%             if  le_int_end_lot(i,1) ~= 0                                                    %Bedingung für, wenn Vorderkante hinter andere Punkte gerückt ist   
%             plot3(le_int_end_lot(i,1),le_int_end_lot(i,3),le_int_end_lot(i,2),'c.');
%             end
%         end
%         
%         legend('$\textrm{Profilquerschnitte}$','$\textrm{modifizierte Vorderkante}$' ... 
%                 ,'$\textrm{angepasster Vorderkanten-Endpunkt}$','Interpreter','Latex');
%              
        num2= find(le_int_end_lot(:,1) ~= 0);                                               %Vektor der die Profilnummern enthält, bei welchen die Vorderkante angepasst werden muss
                                                            
                                                                                                                                                                           
        for i= 1:length(num2) 
            n=num2(i);
            
            richt4_vek(n,:)= le_int_end_lot(n,:)-[cProfile_mod{n,1}(le_int(end),:)];        %Richtungsvektor zwischen projizierten und urspründlichen Endpunkt der Vorderkante
            
            d_le_int_end(n)= sqrt(([cProfile_mod{n,1}(le_int(end),1)]-(le_int_end_lot(n,1)))^2 ...  %Abstand zwischen ursprünglicher Vorderkante und modifizierter Vorderkante im Raum
                                 +([cProfile_mod{n,1}(le_int(end),3)]-(le_int_end_lot(n,3)))^2 ... 
                                 +([cProfile_mod{n,1}(le_int(end),2)]-(le_int_end_lot(n,2)))^2); 
        end 
    
       for i= 1:length(num2)                                                                %For-Scheife zur Verschiebung der Vorderkante normal zur Profiloberfläche
            
           n=num2(i);                                                 
            for k= 1:length(le_int(1):le_int(end))                                          %Inkrement zur Auswahl der Werte an Vorderkante innerhalb einer Geometrie
                syms a6
                a6= double(solve(sqrt((([cProfile_mod{n,1}(le_int(k),1)] +  a6*richt4_vek(n,1))-[cProfile_mod{n,1}(le_int(k),1)])^2 ...
                    +(([cProfile_mod{n,1}(le_int(k),3)] + a6*richt4_vek(n,3))-[cProfile_mod{n,1}(le_int(k),3)])^2 ...
                    +(([cProfile_mod{n,1}(le_int(k),2)] + a6*richt4_vek(n,2))-[cProfile_mod{n,1}(le_int(k),2)])^2)==d_le_int_end(n),a6));
                
                 le_int_mod_xv(k,n)= [cProfile_mod{n,1}(le_int(k),1)]+a6(end)*richt4_vek(n,1);    %Aufstellen der Matrix der normal verschobenen Punkte in x-Richtung
                 le_int_mod_yv(k,n)= [cProfile_mod{n,1}(le_int(k),3)]+a6(end)*richt4_vek(n,3);    %Aufstellen der Matrix der normal verschobenen Punkte in y-Richtung
                 le_int_mod_zv(k,n)= [cProfile_mod{n,1}(le_int(k),2)]+a6(end)*richt4_vek(n,2);    %Aufstellen der Matrix der normal verschobenen Punkte in z-Richtung
            end
        end 
     

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Überschreiben der alten Matrizeneinträge ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
        
       
        for i= 1:length(num2)
            n=num2(i);
            for k= 1:length(le_int(1):le_int(end))                          %Inkrement zur Auswahl der Werte an Vorderkante innerhalb einer Geometrie

                [cProfile_mod{n,1}(le_int(k),1)]=  le_int_mod_xv(k,n);
                [cProfile_mod{n,1}(le_int(k),3)]=  le_int_mod_yv(k,n);
                [cProfile_mod{n,1}(le_int(k),2)]=  le_int_mod_zv(k,n);

            end
        end
 %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Überschreiben der Werte vor Vorderkante ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
        % Dadruch, dass Vorderkant in Strömungsrichtung zur Ausbildung der Tuberkelsenken verückt wurde
        %, können einige Punkte der ursprünglichen Geometrie nun vor der Vorderkante liegen
        % Deshalb müssen diese aus der Geometrie entfernt werden
        
        for i= 1:length(num2)                                               %For-Schleife zur Speicherung der neuen Profilpunkte
        n=num2(i);                                                                                                                                              
        cProfile_mod{n,1}= [cProfile_mod{n,1}([1:le_int(end) ...            %Abspeichern der Punkte ohne die Punkte, welche vor der Vorderkante liegen
                                               le_profil_begin(n):end],:)];
        end

        n=1;                                                                %Inkrement zur Definition der zu überschreibenden Zeilen --> Startwert
        k= length([cProfile_mod{1,1}(:,1)]);                                %Inkrement zur Definition der zu überschreibenden Zeilen --> Endwert
        clear blade1_mod blade2_mod blade3_mod      
        for i= 1:anzahl_profil                                              %For-Schleife zur Überschreibung der angepassten Geometrie in einen Vektor je Koordinate
                        
        blade1_mod(n:k,1)= [cProfile_mod{i,1}(:,1)];                        %Vektor für x-Koordinate
        blade3_mod(n:k,1)= [cProfile_mod{i,1}(:,3)];                        %Vektor für y-Koordinate
        blade2_mod(n:k,1)= [cProfile_mod{i,1}(:,2)];                        %Vektor für z-Koordinate
        
        n= k+1;
        if i<anzahl_profil
        j=i+1;
        else 
        j= i;
        end
        k=k+length([cProfile_mod{j,1}(:,1)]);                               %Zaehler für die Anzahl an Punkten je Profil 
        end 
       

        %% Section 5.7 ~ Anpassen des Übergangsmittels Polynoms

         % 1. Aufstellen einer Geraden zwischen punkt 105 und 106 an der Vorderkante je Profil, bei welchem die Vorderkante verrückt wurde 
         % 2. Schnittpunkt mit Profiloberfläche an Druckseite bestimmen 
         % 3. Punkt bestimmen, welcher vor Schnittpunkt liegt 
         % 4. Annähern der Steigung nach Druckseite und Vorderkante über Funktion im 2D-Raum 
         % 5. Rücktransformation in 3D 


         k=1;
         for i= 2:anzahl_profil-1                                               %For-Schleife zum Aufstellen der Geraden zur Abbildung der Steigung an Vorderkante (zwischen 104-105)
         if i == num2(k)                                                        %Bedingung das am i-ten Profil die Vorderkante verschoben wurde
         ort4_vek(i-1,:)= [cProfile_mod{i,1}(le_int(1)+3,:)];                   %Aufstellen des Ortsvektor (le_int(1)+3)
         richt5_vek(i-1,:)= [cProfile_mod{i,1}(le_int(1)+2,:)]- ...             %Aufstellen des Richtungsvektors
                        [cProfile_mod{i,1}(le_int(1)+3,:)];         
          if k < length(num2)                                                   %Bedingung um zu vermeiden, dass das Inkrement größer wird als die Länge von num2
                    k=k+1;                                                      %Inkrement für die Auswahl der Profil 
          end 
         end 
         end

         % Bestimmung des Schnittpunkt in 2D durch Gerade, welche die Steigung
         % an der Vorderkante und der Druckseite abbilden
         for j= 1:length(num2)                                                  %For-Schleife zum Bestimmen des Punktes vor dem Schnittpunkt zwischen Gerade und Profiloberfläche
         i= num2(j);                                                            %Aufrufen der geänderten Profil
         num4(j)= max(find([cProfile_mod{i,1}(1:le_int(1),1)] ...               %Bestimmung des Punktes, welcher auf der Druckseite an die Vorderkante angrenzt (anhand der x-Koordinate)
                         < [cProfile_mod{i,1}(le_int(1),1)]));
         ort5_vek(j,:)=   [cProfile_mod{i,1}(num4(j)-1,:)];                     %Aufstellen des Ortsvektor, für die Gerade zur Annäherung der Steigung auf der Druckseite des Profils
         richt6_vek(j,:)= [cProfile_mod{i,1}(num4(j),:)]-ort5_vek(j,:);         %Aufstellen des Richtungssvektor, für die Gerade zur Annäherung der Steigung auf der Druckseite des Profils

         syms a7 a8
         pars= [a7 a8];                                                         %Bestimmung des Schnittpunktes durch Gleichsetzen beider Geraden
         left_side= [ort4_vek(j,1) ort4_vek(j,3)]+ ...                          %Aufstellen der linken Seite
                    a7.*[richt5_vek(j,1) richt5_vek(j,3)];
         right_side= [ort5_vek(j,1) ort5_vek(j,3)] + ...                        %Aufstellen der rechten Seite
                      a8.*[richt6_vek(j,1) richt6_vek(j,3)];
         eqns= left_side == right_side;                                         %Aufstellen des Gleichungssystems

         [a7, a8]= solve(eqns,pars);                                            %Lösen des Gleichungssystems        
         a78(j,:)= [a7, a8];                                                    %Parameter in Vektor überschreiben 
         end   

         punkt_sch= double([ort5_vek(:,1) ort5_vek(:,3)] + ...                  %Schnittpunkt je Profil bestimmen in 2D, da in 3D Geraden windschief sind
                            a78(:,2).*[richt6_vek(:,1) richt6_vek(:,3)]); 

         for i= 1:length(num2)                                                  %For-Schleife zur Bestimmung des Punktes, welcher vor dem Schnittpunkt liegt (anhand x-Koordinate)
         j= num2(i);                                                            %Bestimmen der Profile, bei welchen die Vorderkante verschoben wurde
         num6(i)= max(find([cProfile_mod{j,1}(1:le_int(1),1)] ...               %Position des Punktes vor Schnittpunkt der Geraden in Strömungsrichtung an Druckseite
                                          < punkt_sch(i,1))); 
         end

         %Annäherung des Übergangs mittels Polynom dritten Grades in 2D
         %Startinterwall liegt zwischen le_int(1) und num6(i)-1
         %über interne Bedingungen innerhalb der Funktion wird der Endwert num6(i) solange in Strömungsrichtung verschoben bis eine geeignete Funktion gefunden wurde

         warning('off','all')
         for i= 1: length(num2)
        
        clear gof2 fitresult2
        if num6(i) >= le_int(1) && num6(i)-1 == num4(i)                     %If-Bedingung zur Überprüfung, ob eine starke Verschiebung vorliegt, 
                                                                            % wenn Bedingung false liegt eine große Verschiebung vor
        end_profile= num6(i)-1;                                             %neuen Startwert definieren, da sonst Annäherung mit Polynom nicht möglich ist

        xWerte= [[cProfile_mod{num2(i),1}(le_int(1)+3,1)] [cProfile_mod{num2(i),1}(le_int(1)+2,1)] ...    %Rausschreiben der x-Koordinaten der Punkte, über welche das Polynom angenähert wird
                 [cProfile_mod{num2(i),1}(end_profile,1)] [cProfile_mod{num2(i),1}(end_profile-1,1)]];
        yWerte= [[cProfile_mod{num2(i),1}(le_int(1)+3,3)] [cProfile_mod{num2(i),1}(le_int(1)+2,3)] ...    %Rausschreiben der y-Koordinaten der Punkte, über welche das Polynom angenähert wird
                 [cProfile_mod{num2(i),1}(end_profile,3)] [cProfile_mod{num2(i),1}(end_profile-1,3)]];

        [xData, yData] = prepareCurveData(yWerte,xWerte);                   %Deklarieren der Werte zur Ausführung des fit-Befehls

        ft = fittype( 'poly3' );                                            %Deklarieren der Art der Funktion, welche den Übergang abbilden soll
        [fitresult2, gof2] = fit( xData, yData, ft );                       %Rausschreiben der Ergebnis der Annäherung 
        coeff= coeffvalues(fitresult2);                                     %Rausschreiben der Koeffizienten 
        
    
        e_i=1;                                                              %Wert um den der letzte Wert on end_profile abweicht  

        else                                                                %wenn bedingung false, liegt eine große Verschiebung vor --> else   
        end_profile= num6(i);  
        xWerte= [[cProfile_mod{num2(i),1}(le_int(1)+3,1)] [cProfile_mod{num2(i),1}(le_int(1)+2,1)] ...    %Rausschreiben der x-Koordinaten der Punkte, über welche das Polynom angenähert wird
                 [cProfile_mod{num2(i),1}(end_profile,1)] [cProfile_mod{num2(i),1}(end_profile-1,1)]];
        yWerte= [[cProfile_mod{num2(i),1}(le_int(1)+3,3)] [cProfile_mod{num2(i),1}(le_int(1)+2,3)] ...    %Rausschreiben der y-Koordinaten der Punkte, über welche das Polynom angenähert wird
                 [cProfile_mod{num2(i),1}(end_profile,3)] [cProfile_mod{num2(i),1}(end_profile-1,3)]];
        e_i=1;
        
        [xData, yData] = prepareCurveData(yWerte,xWerte);                   %Deklarieren der Werte zur Ausführung des fit-Befehls

        ft = fittype( 'poly3' );                                            %Deklarieren der Art der Funktion, welche den Übergang abbilden soll
        [fitresult2, gof2] = fit( xData, yData, ft );                       %Rausschreiben der Ergebnisse der Interpolation 
        coeff= coeffvalues(fitresult2);                                      %Rausschreiben der Koeffizient
       

        syms x                                                              %Deklarien einer Variable zum Aufstellen der Funktion 
        f(x)= coeff(1)*x^3 + coeff(2)*x^2 + coeff(3)*x + coeff(4);          %Aufstellen der Funktion
        df(x)= diff(f(x),x);                                                %erste Ableitung
        d2f(x)= diff(df(x),x);                                              %zweite Ableitung
        wendestelle= solve(d2f(x)==0,x);                                    %Bestimmung der Wendestelle --> da Polynom dritten Grades darf Wendepunkt nicht zwischen 
                                                                            % den Punkten der Interpolation liegen (implemitiert in while-Schleife)
        while (wendestelle > yWerte(1)) && (wendestelle < yWerte(4))        %While-Schleife zur Optimierung der Anpassung, Verschiebung des Startwerts an Druckseite

        xWerte(3:4)= [[cProfile_mod{num2(i),1}(end_profile-e_i,1)]                       %Verschiebung der Punkte an Druckseite um Wert 1 in Strömungsrichtung
                      [cProfile_mod{num2(i),1}(end_profile-e_i-1,1)]];
        yWerte(3:4)= [[cProfile_mod{num2(i),1}(end_profile-e_i,3)]                       %Verschiebung der Punkte an Druckseite um Wert 1 in Strömungsrichtung
                      [cProfile_mod{num2(i),1}(end_profile-e_i-1,3)]];
        [xData, yData] = prepareCurveData(yWerte,xWerte);                   %Überschreiben der Werte zur Ausführung des fit-Befehls

        [fitresult2, gof2] = fit( xData, yData, ft );                       %Rausschreiben der Ergebnisse der Interpolations
        coeff= coeffvalues(fitresult2);                                      %Rauschreiben der Koeffizienten 
        

        syms x                                                              %Deklarieren einer Variable zum Aufstellen des Polynoms
        f(x)= coeff(1)*x^3 + coeff(2)*x^2 + coeff(3)*x + coeff(4);          %Aufstellen des Polynoms
        df(x)= diff(f(x),x);                                                %erste Ableitung
        d2f(x)= diff(df(x),x);                                              %zweite Ableitung 
        wendestelle= solve(d2f(x)==0,x);                                    %Bestimmung der Wendestelle --> zur Überprüfung ob while-Schleife erfüllt ist
        e_i=e_i+1;                                                          %Hochzählen des Inkrements, um Werte an Druckseite zu verschieben
        end                                                                         
        e_i= e_i-1;                                                         %Notwendig da sonst nach Beendigung der while-Schleife i fälschlischweise um wert 1 zu hoch wäre

        if e_i== 0                                                          %Bedingung um zu verhindern, dass trotz while Wendestelle zwischen den Werten liegt, 
        e_i=1;                                                              % da mehrer Wendestellen existieren 
        while [cProfile_mod{num2(i),1}(end_profile-e_i,1)] > ...            %durchführen solange bis Startwert des Polynoms vor Vorderkante liegt
              [cProfile_mod{num2(i),1}(le_int(1),1)]   
        xWerte(3:4)= [[cProfile_mod{num2(i),1}(end_profile-e_i,1)] ...                   %Verschiebung der Punkte an der Druckseite um Wert 1 in Strömunsgrichtung
                      [cProfile_mod{num2(i),1}(end_profile-e_i-1,1)]];
        yWerte(3:4)= [[cProfile_mod{num2(i),1}(end_profile-e_i,3)] ...                   %Verschiebung der Punkte an der Druckseite um Wert 1 in Strömunsgrichtung
                      [cProfile_mod{num2(i),1}(end_profile-e_i-1,3)]];
        [xData, yData] = prepareCurveData(yWerte,xWerte);                   %Überschreiben der Werte zur Ausführung des fit-Befehls

        [fitresult2, gof2] = fit( xData, yData, ft );                       %Rausschreiben der Ergebnisse der Interpolation 
        coeff= coeffvalues(fitresult2);                                      %Rauschschreiben der Koeffizienten 
        

        syms x                                                              %Deklarieren einer Variable zum Aufstellen des Polynoms
        f(x)= coeff(1)*x^3 + coeff(2)*x^2 + coeff(3)*x + coeff(4);          %Aufstellen des Polynoms
        df(x)= diff(f(x),x);                                                %erste Ableitung 
        d2f(x)= diff(df(x),x);                                              %zweite Ableitung 
        wendestelle= solve(d2f(x)==0,x);                                    %Bestimmen der Wendestelle

        e_i=e_i+1;                                                          %Hochzählen des Inkrements, um Werte an Druckseite zu verschieben
        end 
        e_i= e_i-1;                                                         %Notwendig da sonst nach Beendigung der while-Schleife i fälschlischweise um wert 1 zu hoch wäre
        end 
        end

         e(i)= e_i;                                                             %Wert, der angibt wie weit der Anfangswert des gefitteten Polynoms von num6 in Strömungsrichtung abweicht
         p(i,:)= coeffvalues(fitresult2);                                       %Koeffizienten der einzelnen Polynome
         r_square2(i)= gof2.rsquare;                                            %Bestimmtheitsmaß der angenäherten Polynome    
         end 

         for i= 1:length(num2)                                                  %For-Schleife zum Aufstellen der Polynome 
            syms x                                                              %deklarierung einer Variablen
            poly_fit(i)= p(i,1)*x^3 + p(i,2)*x^2 + p(i,3)*x + p(i,4);           %Aufstellen der Polynome je Profil 
         end

         for i= 1:length(num2)                                                  %For-Schleife zur Bestimmung des Punktes, welcher in y-Richtung vor der Vorderkante liegt         
         num7(i)= max(find([cProfile_mod{num2(i),1}(1:le_int(1),3)] > ...       %find-Befehl zur Ermittlung des Punktes, welcher in Strömungsrichtung größeren y-Wert als 
                           [cProfile_mod{num2(i),1}(le_int(1),3)]));            % Vorderkante aufweist
         end

         for i= 1:length(num2)                                                  %For-Schleife zur Berechnung des Übergangs zwischen Druckseite und Vorderkante durch die Polynome 
            pos{i,1}= [num6(i)-e(i):num7(i),le_int(1):le_int(1)+2];             %Definieren der Punkte, welche zwischen dem Vorderkanten-Anfang (le_int(1)) und Profil-Ende (num6-e)liegen  
            poly_link_y{i,1}= subs(poly_fit(i), ...                             %Berechnen der Punkte auf dem Polynom je Profil --> berechnen der y_werte
                                  ([cProfile_mod{num2(i),1}(pos{i,1},3)])'); 
            poly_link_x{i,1}=([cProfile_mod{num2(i),1}(pos{i,1},3)])';          %Aufstellen der dazugehörigen x-Werte
         end


%          figure(9)                              %Plotten der Profilquerschnitte mit neuem Übergang in 2D für Profil 5
%          plot([cProfile{5,1}(:,3)],[cProfile{5,1}(:,1)],'b.-');                 %Plotten der Basis-Geometrie 
%          hold on 
%          plot([cProfile_mod{5,1}(:,3)],[cProfile_mod{5,1}(:,1)],'k.-');         %Plotten des modifizierten Proils
%          plot([poly_link_x{4,1}(1,:)],[poly_link_y{4,1}(1,:)],'r.-');           %Plotten des Polynomialübergangs
%          xlabel('$\textrm{y-Werte}$','Interpreter','Latex');
%          ylabel('$\textrm{x-Werte}$','Interpreter','Latex');
%          legend('$\textrm{Basis-Profil}$','$\textrm{modifiziertes Profil}$' ... 
%                 ,'$\textrm{Polynomial\"{u}bergang}$','Interpreter','Latex');
%          grid on 
%          grid minor 
          

%          figure(10)                              %Plotten der Profilquerschnitte mit neuem Übergang in 2D für Profil 2
%          plot([cProfile{2,1}(:,3)],[cProfile{2,1}(:,1)],'b.-');                 %Plotten des Basisgeometrie     
%          hold on 
%          plot([cProfile_mod{2,1}(:,3)],[cProfile_mod{2,1}(:,1)],'k.-');         %Plotten des modifizierten Profils
%          plot([poly_link_x{1,1}(1,:)],[poly_link_y{1,1}(1,:)],'r.-');           %Plotten des Polynomialübergangs
%          xlabel('$\textrm{y-Werte}$','Interpreter','Latex');
%          ylabel('$\textrm{x-Werte}$','Interpreter','Latex');
%          legend('$\textrm{Basis-Profil}$','$\textrm{modifiziertes Profil}$' ... 
%                 ,'$\textrm{Polynomial\"{u}bergang}$','Interpreter','Latex');
%          grid on 
%          grid minor 
%             
%          figure(11)                             %Plotten der Profilquerschnitte mit neuem Übergang in 2D für Profil 2
%          plot([cProfile{13,1}(:,3)],[cProfile{13,1}(:,1)],'b.-');               %Plotten des Basis-Geometrie
%          hold on 
%          plot([cProfile_mod{13,1}(:,3)],[cProfile_mod{13,1}(:,1)],'k.-');       %Plotten des modifizierten Profil 
%          plot([poly_link_x{12,1}(1,:)],[poly_link_y{12,1}(1,:)],'r.-');         %Plotten des Polynomialübergangs
%          xlabel('$\textrm{y-Werte}$','Interpreter','Latex');
%          ylabel('$\textrm{x-Werte}$','Interpreter','Latex');
%          legend('$\textrm{Basis-Profil}$','$\textrm{modifiziertes Profil}$' ... 
%                 ,'$\textrm{Polynomial\"{u}bergang}$','Interpreter','Latex');
%          grid on 
%          grid minor 
         %% Section 5.7.1 ~ Transformieren in 3D
         %z-Koordinate der Punkte auf Polynomialübergang ist unbekannt
         %Bestimmung des Abstandes zwischen den Punkten der Basis-Geometrie und dem Polynomialübergang in 2D
         %Bestimmung der unbekannnten z-Koordinate je Profil mittels Gerade, die sich zwischen der Transformationsgeraden und des jeweiligen
         % Punktes der Basisgeometrie aufspannt

         % 1) Aufstellen einer Gerade die sich zwischen le_int(1)+2 (105) und Ende des  Polynoms num6(i)-e(i) aufspannt

         for i= 1:length(num2)                                                  %For-Schleife zum aufstellen der Transformationsgeraden je Profil
         j= num2(i);                                                            %Inkrement für die Profile, an welchen die Vorderkante modifizierte wurde
         ort6_vek(i,:)= [cProfile_mod{j,1}(le_int(1)+2,:)];                     %Ortsvektor
         richt7_vek(i,:)= [cProfile_mod{j,1}(num6(i)-e(i),:)] - ort6_vek(i,:);  %Richtungsvektor
         end

         % 2) Berechnen der Punkte auf der Geraden für die Positionen zwischen le_int(1)+2 und num6-e
         % -> y-Koordinate der Punkte ist bekannt, unbekannt sind x- und z-Koordinate
         % 3) y-Wert gleichsetzen mit Gerade und Geradenparameter bestimmen
         % 4) Mittels Geradenparameter unbekannte x- un z-Koordinate bestimmen 

         for i= 1:length(num2)                                                  %For-Schleife zur Bestimmen der Punkte des Übergangs auf der Geraden anhand des aus 2D bekannten Y-Werts
             j= num2(i);                                                        %Inkrement für die Profile, an welchen die Vorderkante modifizierte wurde

             for k= 1:length(pos{i,1})                                          %For-Schleife zur Auswahl der einzelnen Punkte je Profil
                 syms a9                                                        %Deklarieren des Parameters der Geradengleichung
                 left2_side= ort6_vek(i,3)+a9*richt7_vek(i,3);                  %Aufstellen der linken Seite des Gleichungssystems --> Transformations-Gerade
                 right2_side= [cProfile_mod{j,1}([pos{i,1}(1,k)],3)];           %Aufstellen der rechten Seite des Gleichungssystems --> Y-Wert des jeweiligen Punktes
                 eqns2= [left2_side==right2_side];                              %Aufstellen des Gleichungssystems    
                 a9=  solve(eqns2,a9);                                          %Bestimmung des Paramters
                 [g_link{i,1}(k,:)]= ort6_vek(i,:)+a9*richt7_vek(i,:);          %Berechnen des Punktes projiziert auf Transformationsgeraden
             end
         end

%         figure(12)                                                %Plotten der Transformationsgeraden in die Geometrie für Profil 2 
%         plot3([cProfile_mod{2,1}(:,1)], [cProfile_mod{2,1}(:,3)],[cProfile_mod{2,1}(:,2)],'b.-');       %Plotten der bisher angepassten Geometrie 
%         hold on 
%         plot3([[cProfile_mod{2,1}(le_int(1)+2,1)] [cProfile_mod{2,1}(num6(1)-e(1),1)]], ...             %Plotten der Transformationsgeraden 
%               [[cProfile_mod{2,1}(le_int(1)+2,3)] [cProfile_mod{2,1}(num6(1)-e(1),3)]], ... 
%               [[cProfile_mod{2,1}(le_int(1)+2,2)] [cProfile_mod{2,1}(num6(1)-e(1),2)]],'r.-'); 
%         plot3([g_link{1,1}(:,1)],[g_link{1,1}(:,3)],[g_link{1,1}(:,2)],'k.');                           %Plotten der projizierten Punkte auf der Geraden
%                 

         % 5) Aufstellen von einer Verbindungsgeraden zwischen Punkten des Basis-Profils und Transformationsgeraden je y-Koordinate des jeweiligen Punktes
         %    zwischen Vorderkante und Profil 

         for i= 1:length(num2)                                                              %For-Schleife zur Bestimmung der Punkte des Übergangs auf Polynom
             j= num2(i);                                                                    %Inkrement für die Profile, an welchen die Vorderkante modifizierte wurde

             for k= 1:length(pos{i,1})                                                      %For-Scheife zur Auswahl der anzupassenden Punkte je Profile
                 [ort7_vek{i,1}(k,:)]= [cProfile_mod{j,1}([pos{i,1}(1,k)],:)];              %Ortsvektor --> Punkt auf der Basis-Geometrie
                 [richt8_vek{i,1}(k,:)]= [g_link{i,1}(k,:)]-[ort7_vek{i,1}(k,:)];           %Richtungsvektor --> Mit Stützvektor: Punkt auf der Transformationsgeraden

                 syms a10                                                                   %Deklarieren des Parameter der Geradengleichung 
                 left3_side= [ort7_vek{i,1}(k,1)]+a10*[richt8_vek{i,1}(k,1)];               %Aufstellen der linken Seite --> Geradengleichung der Verbindungsgeraden
                 right3_side= [poly_link_y{i,1}(1,k)];                                      %Aufstellen der rechten Seite --> Y-Werte der Punkte auf Polynom aus dem 2D-Raum
                 if [richt8_vek{i,1}(k,1)] == 0                                             %Bedingung für Start- und Endwert der Transformationsgeraden
                     a10=1;
                 else
                     eqns3= [left3_side==right3_side];                                      %Aufstellen des Gleichungssystems
                     a10=  solve(eqns3,a10);                                                %Bestimmen des Geradenparameters    
                 end
                 [poly_link{i,1}(k,:)]= [ort7_vek{i,1}(k,:)]+a10*[richt8_vek{i,1}(k,:)];    %Berechnen der Koordinaten der Punkte auf Polynom           
             end
         end

        %Wegen Krümmen der Profile kommt es durch die Verschiebung der Vorderkante dazu, dass Punkte le_int(1) und le_int(1)+1 nicht auf Polynom liegen
        %Dies kann durch die Anpassung der z-Werte behoben werden 

        % 6) Aufstellen einer Ebene die durch den Punkte le_int(1)+2, num7 und le_int(end), um den z-Wert der Punkte le_int(1) und le_int(1)+1 anzupassen 
        %    dazu aufstellen der linken Seite der Ebenengleichung in Parameter- Form

        for i= 1:length(num2)                                                           %For-Schleife zur Verschiebung der Punkte le_int(1) und le_int(1)+1 auf Polynom durch 
                                                                                        % Anpassumg der z-Werte
            num8(i)= [pos{i,1}(1,end)]-le_int(1);                                       %Differen zwischen Endwert des Übergangs und Ende der Voderkante der Basis-Geometrie

%             if [g_link{i,1}(end-num8(i),1)] > [cProfile_mod{num2(i),1}(le_int(1),1)]    %Bedingung zu finden der Profile, bei welchen le_int(1) und le_int(1)+1 nicht auf Polynom liegen
                P3= [cProfile_mod{num2(i),1}(le_int(end),:)];                           %Aufstellen des Stützvektors der Ebene

                if length(poly_link{i,1})-1 == num8(i)                                  %Bedingung für geringe Veschiebungen
                    P1= [poly_link{i,1}(end-num8(i),:)]-P3;                             %Aufstellen des ersten Spannvektors für geringe Verschiebungen 
                else
                    P1= [poly_link{i,1}(end-num8(i)-1,:)]-P3;                           %Aufstellen des ersten Spannvektors für große Verschiebungen 
                end
                P2= [poly_link{i,1}(end,:)]-P3;                                         %Aufstellen des zweiten Spannvektors

                for k= 0:length(num8(i))                                                %For-Schleife zur Auswahl der Punkt zwischen le_int(1) und [pos{i,1}(1,end)] (105)
                    syms a11 a12                                                        %Deklarieren der Parameter der Ebenengleichung
                    left3_side= P3(1,[1 3]) +a11 * P2(1,[1 3]) + a12 * P1(1,[1 3]);     %Aufstellen der linken Seite --> Ebenengleichung in Parameterform
                    rigth3_side= [poly_link{i,1}(end-num8(i)+k,[1 3])];                 %Aufstellen der rechten Seite --> y- und x-Werte der Punkte 
                    [a11 a12]= solve(left3_side==rigth3_side,[a11 a12]);                %Berechnen der Ebenenparameter
                    [poly_link{i,1}(end-num8(i)+k,2)]= P3(1,2) +a11*P2(1,2) + ...       %Berechen des neuen z-Werts --> y und x bleiben gleichen
                                                                a12*P1(1,2);
                end
%             end
        end

%         hold on 
%         plot3([poly_link{1,1}(:,1)],[poly_link{1,1}(:,3)], ...                 %Plotten des Polynomialübergangs
%                [poly_link{1,1}(:,2)],'g.-');
%         grid on 
%         grid minor
%         xlabel('$\textrm{x-Achse}$','Interpreter','Latex');
%         ylabel('$\textrm{y-Achse}$','Interpreter','Latex');
%         zlabel('$\textrm{z-Achse}$','Interpreter','Latex');
%         legend('$\textrm{Profilquerschnitte}$','$\textrm{Transformationsgerade}$' ... 
%                 ,'$\textrm{projizierte Punkte}$','$\textrm{Polynomial\"{u}bergang}$','Interpreter','Latex');
        %% Section 5.8 ~ Überschreiben der Matrizen 
        % Abspeicherung des neuen Übergangs an der Druckseite ohne Punkte,
        % welche die Verschiebung vor der Vorderkante liegen

        for i= 1:length(num2)                                               %For-Schleife zur Speicherung der Profilgeometrie mit angepasstem Übergand an Druckseite
           n=num2(i);

           for k= 1:length(pos{i,1})                                        %For-Schleife zur Überschreibung der angepassten Punkte mittels Polynom 
            j= [pos{i,1}(1,k)];                                             %Inkremente für den Zugriff auf das jeweilige Profil                                                                            % bei sehr großen Amplituden dieser vor der Vorderkante liegt
           [cProfile_mod{n,1}(j,:)]= [poly_link{i,1}(k,:)];                 %Überschreiben der angepassten Werte
           end
           cProfile_mod{n,1}= [cProfile_mod{n,1}([1:num7(i) ...             %Speicherung der neuen Geometrie ohne die Punkte, welche druckseitig vor der Voderkante liegen
                                                   le_int(1):end],:)];
        end

%         figure(13)                                   %Plotten der modifizierten Profil Nr. 2
%         plot3([cProfile_mod{2,1}(:,1)], [cProfile_mod{2,1}(:,3)], ...
%               [cProfile_mod{2,1}(:,2)],'b.-');
%         xlabel('$\textrm{x-Achse}$','Interpreter','Latex');
%         ylabel('$\textrm{y-Achse}$','Interpreter','Latex');
%         zlabel('$\textrm{z-Achse}$','Interpreter','Latex');
%         legend('$\textrm{Profilquerschnitte}$','Interpreter','Latex');
%         grid on 
%         grid minor 
%      
        clear blade1_mod blade2_mod blade3_mod                              %Löschen der Vektoren, da sich Länge durch die Anpassung geändert hat 
        n=1;                                                                %Inkrement zur Definition der zu überschreibenden Zeilen --> Startwert
        k= length([cProfile_mod{1,1}(:,1)]);                                %Inkrement zur Definition der zu überschreibenden Zeilen --> Endwert
           
        for i= 1:anzahl_profil                                              %For-Schleife zur Überschreibung der angepassten Geometrie in einen Vektor je Koordinate
                        
        blade1_mod(n:k,1)= [cProfile_mod{i,1}(:,1)];                        %Vektor für x-Koordinate
        blade3_mod(n:k,1)= [cProfile_mod{i,1}(:,3)];                        %Vektor für y-Koordinate
        blade2_mod(n:k,1)= [cProfile_mod{i,1}(:,2)];                        %Vektor für z-Koordinate
        n= k+1;                                                             %Neuen Startwert der Zeilen für die folgende Schleife
   
        if i<anzahl_profil                                                  %If-Bedingung damit j nicht die Länge von cProfile_mod überschreitet
        j=i+1;
        else 
        j= i;
        end
        
        k=k+length([cProfile_mod{j,1}(:,1)]);                               %Neuen Endwert der Zeilen für folgende Schleife, ohne vorherige if-Bedingung folgt Fehler bei i=21
        end 
     
        figure(14);                    %Plotten der Schaufelgeometrie mit angeglichenem Übergang an Druckseite
        plot3(blade1_mod,blade3_mod,blade2_mod,'.-');                       %Plotten der Schaufelgeometire
        hold on 
        plot3(le_mod_lot(:,1),le_mod_lot(:,3),le_mod_lot(:,2),'r.-');       %Plotten der Vorderkante
        grid on 
        grid minor
        xlabel('$\textrm{x-Achse}$','Interpreter','Latex');
        ylabel('$\textrm{y-Achse}$','Interpreter','Latex');
        zlabel('$\textrm{z-Achse}$','Interpreter','Latex');
        legend('$\textrm{Profilquerschnitte}$','$\textrm{modifizierte Vorderkante}$' ... 
                ,'Interpreter','latex');
        

        %% Section 6 ~ Rausschreiben einer .txt-dat

        clear blade_mod
        n=1;                                                                %Inkrement zur Definition der zu überschreibenden Zeilen
        k= length([cProfile_mod{1,1}(:,1)]);                                %Inkrement zur Definition der zu überschreibenden Zeilen
        for i= 1:anzahl_profil                                              %For-Schleife zur Überschreibung der angepassten Geometrie in Cell-Array
            blade_mod{n,1}= ['# Profile ' num2str(i) ' '];                  %Unterteilung der einzelnen Profile
            blade_mod{n,2}= [];                                             %Unterteilung der einzelnen Profile
            blade_mod{n,3}= [];                                             %Unterteilung der einzelnen Profile
            z=1;
            for j= n:k
                blade_mod{j+1,1}= ([cProfile_mod{i,1}(z,1)]);               %Spalte für x-Koordinate
                blade_mod{j+1,2}= ([cProfile_mod{i,1}(z,2)]);               %Spalte für z-Koordinate
                blade_mod{j+1,3}= ([cProfile_mod{i,1}(z,3)]);               %Spalte für y-Koordinate
                z= z+1;
            end
            
            n= j+2;                                                         %Hochzählen der Zeilen; Startwerte je Profil
            
            if i<anzahl_profil                                              %Bedingung für Auswahl des Profils --> ohne Bedingung würde Länge von cProfile_mod überschritten 
            k=k+1+length([cProfile_mod{i+1,1}(:,1)]);                       %Hochzählen der Zeilen; Endwert je Profil
            else
            k=k+1+length([cProfile_mod{i,1}(:,1)]);                         %Hochzählen der Zeilen; Endwert je Profil
            end
        end
        
        writecell(blade_mod,'C:\Users\Joop\Documents\GitHub\BladeMod\Optimierungssetup\blade.txt');                  %Rausschreiben der Werte in eine .txt-Datei
        
        %% Section 7 ~ Vergleich der Steigung des Basis-Profils mit dem modifizierten Profil

        for i= 1:length([cProfile{2,1}])-1                                  %For-Schleife zur Bestimmung der Differenz der Y- und X-werte zwischen zwei Punkten
            dy(i)= abs([cProfile{2,1}(i+1,3)]-[cProfile{2,1}(i,3)]);        %Bestimmung der Differenz der y-Werte aufeinanderfolgender Punkte
            dx(i)= [cProfile{2,1}(i+1,1)]-[cProfile{2,1}(i,1)];             %Bestimmung der Differenz der x-Werte aufeinanderfolgender Punkte
        end
        
        steigung_unmod= dx./dy;                                             %Steigung des Basis-Profils
        
        for  k= 1: length([cProfile_mod{2,1}])-1                            %For-Schleife zur Bestimmung der Differenz der Y- und X-werte zwischen zwei Punkten
                                                                            % am modifizierten Profil 
            dy_mod(k)= abs([cProfile_mod{2,1}(k+1,3)]- ...                  %Bestimmung der Differenz der y-Werte aufeinanderfolgender Punkte des modifizierten Profils        
                           [cProfile_mod{2,1}(k,3)]);                   
            dx_mod(k)= [cProfile_mod{2,1}(k+1,1)]-[cProfile_mod{2,1}(k,1)]; %Bestimmung der Differenz der x-Werte aufeinanderfolgender Punkte des modifizierten Profils
        end

        steigung_mod= dx_mod./dy_mod;                                       %Steigung des modifizierten Profils 
        
%         figure(15)                     %Plotten der Steigung des modifizierten Profils und des Basis-Profils Nr. 2
%         plot(1:length([cProfile{2,1}])-1,steigung_unmod,'.-');              %Plotten der Steigung des Basis-Profils 
%         hold on 
%         plot(1:length([cProfile_mod{2,1}])-1,steigung_mod,'.-');            %Plotten der Steigung des modifizierten Profils
%         grid on 
%         grid minor
%         xlabel('$\textrm{n-te Position der Steigung}$','Interpreter','Latex');
%         ylabel('$\Delta x/\Delta y$','Interpreter','Latex','FontName','Latin Modern Roman');
%         set(gca,'FontSize',14);
%         legend('$\textrm{Basis-Profil}$','$\textrm{modifiziertes Profil}$','Interpreter','Latex');

end

