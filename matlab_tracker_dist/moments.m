%====================================================================== 
%
% MOMENTS: Calculates the scaling coefficients of the moments of the
%          particle displacement over time.
%
% SYNTAX:  gamma = moments(trajectories,dx,dt)
%
% INPUTS:   trajectories     vector of cells defining the 
%                           trajectories of all particles in the
%                           following synatx:
%
%           trajectories{t}(:,1)    frame number of traj. t
%           trajectories{t}(:,2)    x postitions of traj. t
%           trajectories{t}(:,3)    y positions of traj. t
%
%           dx               length of a pixel in physical units of um
%           dt               time between frames in sec
% OUPUTS:
% The function returns a matrix TrajectoryData 
%           TrajectoryData[,1] trajectory ID
%           TrajectoryData[,2] trajectory frames length 
%           TrajectoryData[,3] trajectory Diffusion coefficient mkm^2/s
%           TrajectoryData[,4] trajectory RMS Diffusion
%           TrajectoryData[,5] trajectory MSS slope
%           TrajectoryData[,6] trajectory RMS MSS
%           
%
%
% based on matlab version of Mosaik by Ivo Sbalzarini, 30.7.2003
% updated 21.12.2018
%
%====================================================================== 

function TrajectoryData = moments(trajs,dx,dt)
% vector of real values telling which
% moments of the displacement are to be
% computed
moments=1:10;

% delt vector of integer delta t (in frames) values for 
% which the displacements are to be computed.

% determine maximum length in fraemes among trajectories 
MaxFrame = max(cellfun('size',trajs,1)); 
MaxDelt=floor(MaxFrame/3);
delt=1:MaxDelt;



TrajectoryData=zeros(length(trajs),6);
gamma = zeros(length(moments),1);
MSS = zeros(length(moments),1);
RMS_D=zeros(length(moments),1);


for idx=1:length(trajs)
    traj = trajs{idx};
    tlen = size(traj,1);
    
    % calculate moments for one trajectory
    MSD = -1*ones(length(moments),length(delt));
    D = zeros(length(moments),1);
    RMS_D=zeros(length(moments),1);

    for imoment=1:length(moments)
        moment = moments(imoment);
        
        for it=1:length(delt)
            td = delt(it);
            if (3*td <= tlen)
                dv = (traj([1+td:1:tlen],2)-traj([1:1:tlen-td],2)).^2 + ...
                (traj([1+td:1:tlen],3)-traj([1:1:tlen-td],3)).^2;
                dv = dx.*dx.*dv;   % convert to physical units
                dv = dv.^(moment/2);
                MSD(moment,it) = sum(dv)/length(dv);
            end
        end
        
        %----------------------------------------%
        % calculate gamma and diffusion coeff
        dt_index=find(MSD(moment,:)>-0.5);
        t=dt*delt(dt_index); % convert to physical units
        m=MSD(moment,dt_index);
        A = [log(t'), ones(size(t'))];
        a = pinv(A)*log(m');
        alpha = a(1);
        gamma(imoment) = alpha;
        D(imoment) = 0.25*exp(a(2));
        %a2=fitlm(log(t),log(m),'linear')
        
        RMS_D(imoment) = sum((log(m)-(a(1)*log(t)+a(2))).^2);
        RMS_D(imoment) = sqrt(RMS_D(imoment)/length(t));

    end
    
    %----------------------------------------%
    % calculate MSS
    B = [moments', ones(size(moments'))];
    b = pinv(B)*gamma;
    MSS(idx) = b(1);
    RMS_MSS(idx) = sqrt(sum((gamma'-(b(1)*moments+b(2))).^2)/length(moments));
    
    %------------------------------------------%
    TrajectoryData(idx,1)=idx;
    TrajectoryData(idx,2)=tlen;
    TrajectoryData(idx,3)=D(2);
    TrajectoryData(idx,4)=RMS_D(2);
    TrajectoryData(idx,5)=MSS(idx);
    TrajectoryData(idx,6)=RMS_MSS(idx);
    
    %------------------------------------------%
    % plot trajectory, Diffusion constant, MSS
%     figure(idx)
%     subplot(1,3,1)
%     line(traj(:,2),traj(:,3))
%     title(sprintf('trajectory %d:',idx))
%             
%     subplot(1,3,2)
%     dt_index=find(MSD(2,:)>-0.5)
%     t=dt*delt(dt_index) % convert to physical units
%     m=MSD(2,dt_index)
%     A = [log(t'), ones(size(t'))];
%     a = pinv(A)*log(m');
%     mm = min(log(t));
%     uu = max(log(t));
%     hold on;
%     plot(log(t),log(m),'*')
%     xlabel('log(\Deltat)    log([s])');
%     ylabel(sprintf('log(MSD)    log([\\mum]^%d)',moment));
%     plot([mm; uu], [a(1)*mm+a(2); a(1)*uu+a(2)], 'b--')
%     title(sprintf('moment %d:D=%.2f, RMS=%f',moment,D(2),RMS_D(2)))
%     hold off;    
%     
%     subplot(1,3,3)
%     hold on
%     plot(moments,gamma,'*')
%     maxmoment = moments(length(moments));
%     mm = min(moments);
%     uu = max(moments);
%     plot([mm; uu], [b(1)*mm+b(2); b(1)*uu+b(2)],'b--')
%     plot([0,maxmoment],[0,0.5*maxmoment],'r--')
%     xlabel('p')
%     ylabel('\gamma_p')
%     title(sprintf('MSS=%.2f',MSS(idx)))
%     hold off
%     
%     %set(gcf,'position',[x0,y0,width,height])
%     set(gcf,'position',[100,100,1500,500])
%     
%     pause;
end

return






