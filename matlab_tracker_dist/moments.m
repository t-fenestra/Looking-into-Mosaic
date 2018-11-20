%====================================================================== 
%
% MOMENTS: Calculates the scaling coefficients of the moments of the
%          particle displacement over time.
%
% SYNTAX:  gamma = moments(trajectories,delt,moments,dx,dt)
%
% INPUTS:  trajectories     vector of cells defining the 
%                           trajectories of all particles in the
%                           following synatx:
%
%         trajectories{t}(:,1)    frame number of traj. t
%         trajectories{t}(:,2)    x postitions of traj. t
%         trajectories{t}(:,3)    y positions of traj. t
%
%          delt             vector of integer delta t (in frames) values for 
%                           which the displacements are to be computed.
%          moments          vector of real values telling which
%                           moments of the displacement are to be
%                           computed
%          dx               length of a pixel in physical units of um
%          dt               time between frames in sec
%
% The function returns a vector gamma with gamma(i) being the time
% scaling coefficient of the displacement moment moments(i).
%
%
% Ivo Sbalzarini, 30.7.2003
% Institute of Computational Science, Swiss Federal
% Institute of Technology (ETH) Zurich. 
% E-mail: sbalzarini@inf.ethz.ch
%
%====================================================================== 

function gamma = moments(trajs,delt,moments,dx,dt)

% determine which trajectories to include in the analysis.
% Only take those which have no outliers in the step length histogram (they
% usually correspond to wrong tracking assignments) and move by more than 1
% pixel per frame (others are considered stationary and excluded from
% motion analysis).
take = [];
for itraj=1:length(trajs),
    traj = trajs{itraj};
    tlen = size(traj,1);
    slen = sqrt((traj(2:tlen,2)-traj(1:tlen-1,2)).^2+(traj(2:tlen,3)-traj(1:tlen-1,3)).^2);
    % the tracker accuracy is about 0.2 pixel
    %if and(mean(slen) >= 0.3, std(slen) < 1),
    if 1
	take = [take, itraj];
    end;
    %figure(1)
    %hist(slen,10);
    %pause 
end;
disp(sprintf('%d trajectories excluded from analysis. Remaining: %d',length(trajs)-length(take),length(take)));

gamma = zeros(length(moments),1);

for imoment=1:length(moments),
    moment = moments(imoment);

    MSD = -1*ones(length(take),length(delt));

    for idx=1:length(take),
	itraj = take(idx);
	traj = trajs{itraj};
	tlen = size(traj,1); 
	for it=1:length(delt),
	    td = delt(it);
	    if (3*td <= tlen),
		dv = (traj([1+td:1:tlen],2)-traj([1:1:tlen-td],2)).^2 + ...
		    (traj([1+td:1:tlen],3)-traj([1:1:tlen-td],3)).^2;
		dv = dx.*dx.*dv;   % convert to physical units
		dv = dv.^(moment/2);
		MSD(idx,it) = sum(dv)/length(dv);
	    end;
	end;
%	figure(1)
%	clf
%	plot(delt(find(MSD(idx,:)>-0.5)),MSD(find(MSD(idx,:)>-0.5)),'rx-')
%	title(sprintf('Trajectory %d of length %d',itraj,tlen))
%	figure(2)
%	clf
%	plot(traj(:,2),traj(:,3),'ro-')
%	pause
    end;

    warning off
    avgmsd = [];
    for it=1:length(delt),
        avgmsd = [ avgmsd'; mean(MSD(find(MSD(:,it)>-0.5),it),1) ]';
    end

    figure(imoment)
    clf
    hold on
    m = avgmsd(find(avgmsd > 0));
    t = dt.*delt(find(avgmsd>0));   % physical units
    plot(log(t),log(m))
    xlabel('log(\Deltat)    log([s])');
    ylabel(sprintf('log(MSD)    log([\\mum]^%d)',moment));
    A = [log(t'), ones(size(t'))];
    a = pinv(A)*log(m');
    alpha = a(1);
    gamma(imoment) = alpha;
    D = 0.25*exp(a(2));
    % compute RMS of residual
    RMS = sum((log(m)-(a(1)*log(t)+a(2))).^2);
    RMS = sqrt(RMS/length(t));
    mm = min(log(t));
    uu = max(log(t));
    plot([mm; uu], [a(1)*mm+a(2); a(1)*uu+a(2)], 'b--')
    title(sprintf('moment %d: alpha=%f, D=%f, RMS=%f',moment,alpha,D,RMS))
    % now fit a bilinear form in order to detect corrals
    mm = min(t);
    uu = max(t);
    x = [0.01, 0, 0.005, 5];
    x = fminsearch('bilinearfit',x,[],t,m);
    d = x(1)*x(4)+x(2)-x(3)*x(4);
    figure(20+imoment)
    plot(t,m)
    hold on
    plot([mm; x(4)+1], [x(1)*mm+x(2); x(1)*(x(4)+1)+x(2)], 'r--')
    plot([x(4)-1; uu], [x(3)*(x(4)-1)+d; x(3)*uu+d], 'r--')
    D24 = 0.25*(m(4)-m(2))/(t(4)-t(2));
    title(sprintf('moment %d: slope 1=%f, slope 2=%f, k=%f, D_2_4=%f',moment,x(1),x(3),x(4),D24))
    xlabel('\Deltat    [s]');
    ylabel(sprintf('MSD    [\\mum]^%d',moment));
    disp(sprintf('moment %d: alpha=%f   D_%d=%f um^%d/s   RMS=%f   k=%f   D_24=%f',moment,alpha,moment,D,moment,RMS,x(4),D24));
    hold off
end;

figure(length(moments)+1)
clf
hold on
plot(moments,gamma,'bo-')
maxmoment = moments(length(moments));
plot([0,maxmoment],[0,maxmoment],'r--')
plot([0,maxmoment],[0,0.5*maxmoment],'r--')
xlabel('p')
ylabel('\gamma_p')
title('Moment scaling spectrum')
hold off

return






