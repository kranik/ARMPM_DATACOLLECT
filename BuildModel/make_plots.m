#Add colormap and benchmark names to graph
%figure;
%[x1, y1] = bar(1:2:60,ODROID_big_avg(:,3),0.5)
%[x2, y2] = bar(1:2:60,ODROID_big_avg(:,3)./ODROID_big_avg(:,1),0.001);
%[AX,H1,H2] = plotyy(x1,y1,x2,y2);
%set(AX,{'ycolor'},{'r';'b'})
%title ("Totall energy used by ODROID running cBench");
%xlabel ("Microbenchmarks");
%ylabel ("Energy (J)");


figure;
hold on;
[x1, y1] = bar(ODROID_LITTLE_avg(:,2),0.5);
#HF = fill(x1,y1,colormap(rainbow(30))');
#set(HF,'facealpha',0.3);
[x2, y2] = bar(ODROID_LITTLE_avg(:,2)./ODROID_LITTLE_avg(:,1),0.001);
#[AX,H1,H2] = plotyy([[0;0;0;0],x1,[31;31;31;31]],[[0;0;0;0],y1,[0;0;0;0]],[[0;0;0;0],x2,[31;31;31;31]],[[0;0;0;0],y2,[0;0;0;0]]);
[AX,H1,H2] = plotyy(x1,y1,x2,y2);
set(0, 'DefaulttextInterpreter', 'none')
title ("Totall energy used by ODROID running cBench");
xlabel ("Microbenchmark Execution Order");
xlim(AX(1),[-40 32]);
xlim(AX(2),[-40 32]);
axis(AX(1),"ticy");
axis(AX(2),"ticy");
ylabel (AX(1),"Energy (J)");
ylabel (AX(2),"Power (W)");
set(AX(1),'ycolor','black');
set(AX(2),'ycolor','black');
set(H2,'LineWidth',1);
set(H2,'Color','black');
set(H1,"LineWidth",1.5);

[A,B,C,D,E,F,G,H,I,J,K,L] = textread ('TC2/big/Run_1/benchmarks_data_big.dat','%s %d %d %d %d %d %d %d %d %d %d %d','headerlines',2);
A(10,:) = [];
#set (gcf (), "currentaxes", AX(1));
legend( A,"location","west" );
legend("boxoff");
#hc = get (gcf, 'children');
#for i = 1:30
	#set(hc(i,1),'color',flipud(colormap(rainbow(30)))(i,:));
	#set(hc(i,1),'interpreter',"none");
#endfor;
#get(hc(31,1))
#set(hc(31,1),'visible','off')

#bar(ODROID_LITTLE_avg(:,3))
#bar(TC2_big_avg(:,4))
#bar(TC2_LITTLE_avg(:,3))

print -dpng "test.png"
 
close;