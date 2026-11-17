function fig()
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


 % set(findall(gcf,'-property','FontSize'),'FontSize',24)
 ax= gca;
 fp= gcf;
 ax.FontSize= 20;
 ax.MinorGridLineWidth= 0.5;
 ax.GridLineWidth=1;
 ax.LineWidth= 1;
 ax.TickLabelInterpreter= 'latex';
 ax.XLabel.FontSize= 24;
 ax.YLabel.FontSize= 24;
 ax.Legend.FontSize= 24;
 set(findall(gca, 'Type', 'Line'),'LineWidth',2);
 set(findall(gca, 'Type', 'Line'),'MarkerSize',20);
end

