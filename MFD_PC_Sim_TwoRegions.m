function [PHTN1_Final,PHTN2_Final,PHT_Final] = MFD_PC_Sim_TwoRegions()
%%
clear all; close all; %clc;
%% Student Setup
ExerciseIndex = input("Excerise {a/b/c/testing]:","s");
switch ExerciseIndex
    case 'a'
        RegionsControl = 1;
        n1ref = input("Enter n1ref [veh]:");
        if ((n1ref<0)||(n1ref>10000)), error('Choose different n1ref value, n1ref range [0,10000]'); end
        n2ref = 3400;
        Qijpct = input("Enter the demand scaling factor alpha:");
        if ((Qijpct<0.1)||(Qijpct>2)), error('Choose different demand scaling factor values, Demand scaling factor range [0.1,2]'); end
    case 'b'
        RegionsControl = 2;
        n1ref = input("Enter nref (for both regions) [veh]:");
        if ((n1ref<0)||(n1ref>10000)), error('Choose different nref value, nref range [0,10000]'); end
        n2ref = n1ref;
        Qijpct = input("Enter the demand scaling factor alpha:");
        if ((Qijpct<0.1)||(Qijpct>2)), error('Choose different demand scaling factor values, Demand scaling factor range [0.1,2]'); end
    case 'c'
        RegionsControl = 2;
        n1ref = input("Enter n1ref [veh]:");
        if ((n1ref<0)||(n1ref>10000)), error('Choose different n1ref value, n1ref range [0,10000]'); end
        n2ref = input("Enter n2ref [veh]:");
        if ((n2ref<0)||(n2ref>10000)), error('Choose different n2ref value, n2ref range [0,10000]'); end
        Qijpct = input("Enter the demand scaling factor alpha:");
        if ((Qijpct<0.1)||(Qijpct>2)), error('Choose different demand scaling factor values, Demand scaling factor range [0.1,2]'); end
    otherwise
        UserAnswer = input("Please modify the code manually prior to running simulation, Continue {Y/N}?","s");
        if UserAnswer=='Y'
            n1ref = 3060; %[veh]
            n2ref = 3400; %[veh]
            Qijpct = 1.0; % [%]
        else
            error('Code should be modified')
        end
end
%% Settings
% MFD Parameters
a = 1.4877*10^-7;
b = -2.9815*10^-3;
c = 15.0912;
fG1 = @(n) (a.*n.^3 + b.*n.^2 + c.*n)./3600;
fG2 = @(n) (a.*n.^3 + b.*n.^2 + c.*n)./3600;
%n1ref = 3060; %[veh]
%n2ref = 3400; %[veh]
G1cr = double(fG1(n1ref)); %[veh/s]
G2cr = double(fG2(n2ref)); %[veh/s]
n1jam = 10000; %[veh]
n2jam = 10000; %[veh]
n11z = 2000; %[veh]
n12z = 3400; %[veh]
n21z = 2560; %[veh]
n22z = 1440; %[veh]
n1z = n11z+n12z; %[veh]
n2z = n21z+n22z; %[veh]
% Simulation Parameters
tf = 3600; %[sec]
% Qijpct = 1.0; % [%]
% Control Parameters
Kp = -0.00028;
Ki = +4.7e-04;
dt = 60; % [sec]
umin = 0.2; % [-]
umax = 0.8; % [-]
%% Plot MFD Curve
PlotMFDCurve(n1jam,n2jam,fG1,fG2,n1ref,n2ref,G1cr,G2cr,dt,tf)
%% ====== SIMULATION ======
% Inital Simulation
u12t(1) = 0.5;
u21t(1) = 0.5;
n11t(1) = n11z;
n12t(1) = n12z;
n21t(1) = n21z;
n22t(1) = n22z;
n1t(1) = n1z;
n2t(1) = n2z;
G1t(1) = fG1(n1t(1));
G2t(1) = fG2(n2t(1));
PassengerHourTravelledN1(1) = n1z*dt/3600;
PassengerHourTravelledN2(1) = n2z*dt/3600;
PassengerHourTravelled(1) = n1z*dt/3600+n2z*dt/3600;
e1t(1) = n1t(1) - n1ref;
e2t(1) = n2t(1) - n2ref;
% Running Simulation
for tt=1:((tf/dt))
    PlotState(tt,tf,dt,n1t,n2t,G1t,G2t,u12t,u21t,PassengerHourTravelled)
    [q11,q12,q21,q22] = GetDemand(tt*dt,tf,Qijpct);
    n11t(tt+1) = n11t(tt) + dt*(q11 + u21t(tt)*(n21t(tt)/n2t(tt))*fG2(n2t(tt)) - (n11t(tt)/n1t(tt))*fG1(n1t(tt)));
    n12t(tt+1) = n12t(tt) + dt*(q12 - u12t(tt)*(n12t(tt)/n1t(tt))*fG1(n1t(tt)));
    n21t(tt+1) = n21t(tt) + dt*(q21 - u21t(tt)*(n21t(tt)/n2t(tt))*fG2(n2t(tt)));
    n22t(tt+1) = n22t(tt) + dt*(q22 + u12t(tt)*(n12t(tt)/n1t(tt))*fG1(n1t(tt)) - (n22t(tt)/n2t(tt))*fG2(n2t(tt)));
    n1t(tt+1) = n11t(tt+1) + n12t(tt+1);
    n2t(tt+1) = n21t(tt+1) + n22t(tt+1);
    G1t(tt+1) = fG1(n1t(tt+1));
    G2t(tt+1) = fG2(n2t(tt+1));
    e1t(tt+1) = n1t(tt+1) - n1ref;
    e2t(tt+1) = n2t(tt+1) - n2ref;
    u12star(tt+1) = (u12t(tt) + Kp*(e1t(tt+1)-e1t(tt)) + Ki*e1t(tt+1));
    u12t(tt+1) = max(min(u12star(tt+1),umax),umin);
    if RegionsControl == 2
        u21star(tt+1) = (u21t(tt) + Kp*(e2t(tt+1)-e2t(tt)) + Ki*e2t(tt+1));
        u21t(tt+1) = max(min(u21star(tt+1),umax),umin);
    elseif RegionsControl == 1
        u21t(tt+1) = 1;
    end
    PassengerHourTravelledN1(tt+1) = PassengerHourTravelledN1(tt) + dt*(n1t(tt+1))/3600;
    PassengerHourTravelledN2(tt+1) = PassengerHourTravelledN2(tt) + dt*(n2t(tt+1))/3600;
    PassengerHourTravelled(tt+1) = PassengerHourTravelled(tt) + dt*(n1t(tt+1) + n2t(tt+1))/3600;
end
PlotState(tt,tf,dt,n1t,n2t,G1t,G2t,u12t,u21t,PassengerHourTravelled)
PHTN1_Final = PassengerHourTravelledN1(end);
disp(['Passenger Hour Travelled in Network 1 = ' num2str(PHTN1_Final) ' [veh.h]'])
PHTN2_Final = PassengerHourTravelledN2(end);
disp(['Passenger Hour Travelled in Network 2 = ' num2str(PHTN2_Final) ' [veh.h]'])
PHT_Final = PassengerHourTravelled(end);
disp(['Passenger Hour Travelled in System = ' num2str(PHT_Final) ' [veh.h]'])

BolPrint = input("Export Results? [Y/N]:","s");
if(BolPrint=='Y')
    if RegionsControl == 2
        print(['.\fig_PCSim_n1ref' num2str(n1ref) '_n2ref' num2str(n2ref) '_alpha' num2str(Qijpct*100) '_(' datestr(now,'yyyymmdd_hhMMss') ')'],'-dpng')
    elseif RegionsControl == 1
        print(['.\fig_PCSim_n1ref' num2str(n1ref) '_alpha' num2str(Qijpct*100) '_(' datestr(now,'yyyymmdd_hhMMss') ')'],'-dpng')
    end
    disp(['Figures exported.'])
end
end

function [q11,q12,q21,q22] = GetDemand(ttime,tf,Qijpct)
    DemandProfileTiming = [5,10,15,45,50,55,60]./60; %[min]
    DemandProfile = Qijpct.*[0.2, 0.5, 0.8, 1.5, 0.8, 0.5, 0.2]; %[%]
    for k=1:size(DemandProfileTiming,2)
        if (ttime<=(DemandProfileTiming(k)*tf))
            Qij = DemandProfile(k);
            break;
        end
    end
    q11 = 0.8*Qij; %[veh/s]
    q12 = 0.72*Qij; %[veh/s]
    q21 = 1.2*Qij; %[veh/s]
    q22 = 0.96*Qij; %[veh/s]
end

function [] = ArrangeFigure(XLabel,YLabel,XLim,YLim,BolLegend,BolHold)
    xlabel(XLabel,'FontUnits','points','interpreter','latex','FontSize',10,'FontName','Times')
    ylabel(YLabel,'FontUnits','points','interpreter','latex','FontSize',10,'FontName','Times')
    if XLim==0, xlim auto; else, xlim(XLim); end
    if YLim==0, ylim auto; else, ylim(YLim); end
    set(findall(gcf,'type','axes'),'FontUnits','points','ticklabelinterpreter','latex','FontSize',10,'FontName','Times')
    set(findall(gcf,'type','legend'),'FontUnits','points','interpreter','latex','FontSize',10,'FontName','Times')
    set(findall(gcf,'type','line'),'LineWidth',2)
    set(findall(gcf,'type','Stair'),'LineWidth',2)
    set(findall(gcf,'type','line'),'MarkerSize',4)
    set(findall(gcf,'type','line'),'MarkerFaceColor','auto')
    set(gcf,'Color','White');
    set(gca,'Color','White');
    if BolHold==0, hold off; else, hold on; end
    screen_size = get(0, 'ScreenSize');
    set(gcf, 'Position',[50 50 50+0.9*screen_size(3) 150+(9/16)*0.9*screen_size(4)]);
end

function [] = PlotMFDCurve(n1jam,n2jam,fG1,fG2,n1ref,n2ref,G1cr,G2cr,dt,tf)
    figure(1)
    subplot(2,3,1)
    plot(0:1:n1jam,fG1(0:1:n1jam),'k-','DisplayName','$G_{1}(n_{1})$'); hold on;
    plot([n1ref n1ref],[0 G1cr],'r--')
    ArrangeFigure('Accumulation $n_{1}~[\mathrm{veh}]$','Outflow $G_{1}(n_{1})~[\mathrm{veh}/\mathrm{s}]$',[0 n1jam],0,0,1)
    subplot(2,3,4)
    plot(0:1:n2jam,fG2(0:1:n2jam),'k-','DisplayName','$G_{2}(n_{2})$'); hold on;
    plot([n2ref n2ref],[0 G2cr],'r--')
    ArrangeFigure('Accumulation $n_{2}~[\mathrm{veh}]$','Outflow $G_{2}(n_{2})~[\mathrm{veh}/\mathrm{s}]$',[0 n2jam],0,0,1)
    subplot(2,3,2)
    plot([0 (tf/dt)],[n1ref n1ref],'r--')
    ArrangeFigure('control step','Accumulation $n_{1}~[\mathrm{veh}]$',[0 (tf/dt)+1],0,0,1)
    subplot(2,3,5)
    plot([0 (tf/dt)],[n2ref n2ref],'r--')
    ArrangeFigure('control step','Accumulation $n_{2}~[\mathrm{veh}]$',[0 (tf/dt)+1],0,0,1)
end

function [] = PlotState(tt,tf,dt,n1t,n2t,G1t,G2t,u12t,u21t,PassengerHourTravelled)
    figure(1)
    sgtitle(['$t=' num2str(tt*dt) '~[\mathrm{s}], \, n_{1}(t)=' num2str(round(n1t(end))) '~[\mathrm{veh}], \, n_{2}(t)=' num2str(round(n2t(end))) '~[\mathrm{veh}], \, \mathrm{PHT}=' num2str(round(PassengerHourTravelled(end))) '~[\mathrm{veh} \cdot \mathrm{h}]$'],'FontUnits','points','interpreter','latex','FontSize',10,'FontName','Times')
    subplot(2,3,1)
    plot(n1t(end),G1t(end),'b*')
    subplot(2,3,4)
    plot(n2t(end),G2t(end),'b*')
    subplot(2,3,2)
    plot(n1t,'b--*')
    ArrangeFigure('control step','Accumulation $n_{1}~[\mathrm{veh}]$',[0 (tf/dt)+1],[0 1.2*max(n1t)],0,1)
    subplot(2,3,5)
    plot(n2t,'b--*')
    ArrangeFigure('control step','Accumulation $n_{2}~[\mathrm{veh}]$',[0 (tf/dt)+1],[0 1.2*max(n2t)],0,1)
    subplot(2,3,3)
    stairs(u12t)
    ArrangeFigure('control step','$u_{12}~[-]$',[0 (tf/dt)+1],[0 1],0,0)
    subplot(2,3,6)
    stairs(u21t)
    ArrangeFigure('control step','$u_{21}~[-]$',[0 (tf/dt)+1],[0 1],0,0)
end
