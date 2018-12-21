%====================================================================== 
%
% DETECT_PARTICLES: detect particle-shaped features in frame images
%
% SYNTAX:  peak = detect_particles(orig,w,cutoff,pth,v)
%
% INPUTS:  orig     original image to detect features in
%          w        global size parameter, >particle radius and 
%                   <interparticle spacing
%          cutoff   probability cutoff for non-particle discrimination
%          pth      percentile threshold for maxima selection
%          v        visualization parameters [viz, nfig] as:
%                   viz=1 if intermediate visualization is needed
%                   nfig: figure number for first image
%
% After detection, a 1-cell list of a matrix is returned in
% "peak". peak{1} contains the particle information
% for the present frame stored in a matrix:
%
%         peak{1}(:,1)    x (col)-positions of particles
%         peak{1}(:,2)    y (row)-positions of particles
%         peak{1}(:,3)    zero order intensity moments
%         peak{1}(:,4)    second order intensity moments
%         peak{1}(:,5)    *** unused ***
%         peak{1}(:,6)    *** empty *** to be filled by linker
%
% USES:  saturate.m
%
% Ivo Sbalzarini, 12.2.2003
% Institute of Computational Science, Swiss Federal
% Institute of Technology (ETH) Zurich. 
% E-mail: sbalzarini@inf.ethz.ch
%
% based on an algorithm by Crocker & Grier:
%     Crocker, J.C. & Grier, D.G., Methods of digital video microscopy
%     for colloidal studies, J. colloid interface sci., 1996, 
%     179: 298-310.
%====================================================================== 

function peak = detect_particles_old(orig,w,cutoff,pth,v)

viz = v(1);
nfig = v(2);

% correlation length of camera noise (usu. set to unity)
lambdan = 1;

% some often used quantities
idx = [-w:1:w];     % index vector
dm = 2*w+1;         % diameter
im = repmat(idx',1,dm);
jm = repmat(idx,dm,1);
imjm2 = im.^2+jm.^2;
siz = size(orig);   % image size

%====================================================================== 
% STEP 1: Image restoration
%====================================================================== 

% build kernel K for background extraction and noise removal
% (eq. [4])
B = sum(exp(-(idx.^2/(4*lambdan^2))));
B = B^2;
K0 = 1/B*sum(exp(-(idx.^2/(2*lambdan^2))))^2-(B/(dm^2));
K = (exp(-(imjm2/(4*lambdan^2)))/B-(1/(dm^2)))/K0;

% apply convolution filter
filtered = conv2(orig,K,'same');
filtered(filtered<0)=0;

if viz == 0,
    figure(nfig)
    nfig = nfig + 1;
    imshow(orig)
    title('original image')
    figure(21);
    mfig = nfig + 1;
    imshow(filtered)
    title('after convolution filter')
end;

%====================================================================== 
% STEP 2: Locating particles
%====================================================================== 

% determining upper pth-th percentile of intensity values
pth = 0.01*pth;
[cnts,bins] = imhist(filtered);
l = length(cnts);
k = 1;
while sum(cnts(l-k:l))/sum(cnts) < pth,
    k = k + 1;
end;
thresh = bins(l-k+1);

% generate circular mask of radius w
mask = zeros(dm,dm);
mask(find(imjm2 <= w*w)) = 1;

% identify individual particles as local maxima in a
% w-neighborhood that are larger than thresh
dil = imdilate(filtered,mask);
[Rp,Cp] = find((dil-filtered)==0);
particles = zeros(siz);
V = find(filtered(sub2ind(siz,Rp,Cp))>thresh);
R = Rp(V);
C = Cp(V);
particles(sub2ind(siz,R,C)) = 1;
npart = length(R);

if viz == 1,
    figure(nfig)
    nfig = nfig + 1;
    imshow(particles)
    title('intensity maxima of particles');
end;

%====================================================================== 
% STEP 3: Refining location estimates
%====================================================================== 

% zero and second order intensity moments of all particles
m0 = zeros(npart,1);
m2 = zeros(npart,1);

% for each particle: compute zero and second order moments
% and position corrections epsx, epsy
for ipart=1:npart,
    progress=ipart/npart
    epsx = 1; epsy = 1;
    while or(abs(epsx)>0.5,abs(epsy)>0.5),
	% lower and upper index bounds for all particle neighborhoods
	% in local coordinates. Recalculate after every change in R,C
	li = 1-(R-w-saturate(R-w,1,siz(1)));
	lj = 1-(C-w-saturate(C-w,1,siz(2)));
	ui = dm-(R+w-saturate(R+w,1,siz(1)));
	uj = dm-(C+w-saturate(C+w,1,siz(2)));
	% masked image part containing the particle
	Aij = filtered(R(ipart)+li(ipart)-w-1:R(ipart)+ui(ipart)-w-1,...
	    C(ipart)+lj(ipart)-w-1:C(ipart)+uj(ipart)-w-1).* ...
	    mask(li(ipart):ui(ipart),lj(ipart):uj(ipart));
	% moments
	m0(ipart) = sum(sum(Aij));    % eq. [6]
	% eq. [7]
	m2(ipart) = sum(sum(imjm2(li(ipart):ui(ipart),lj(ipart):uj(ipart))...
	    .*Aij))/m0(ipart); 
	% position correction
	epsx = sum(sum(im(li(ipart):ui(ipart),lj(ipart):uj(ipart))...
	    .*Aij))/m0(ipart);
	epsy = sum(idx(lj(ipart):uj(ipart)).*sum(Aij))/m0(ipart);
	% if correction is > 0.5, move candidate location
	if abs(epsx)>0.5,
	    R(ipart) = R(ipart)+sign(epsx);
	end;
	if abs(epsy)>0.5,
	    C(ipart) = C(ipart)+sign(epsy);
	end;
    end; 
    % correct positions (eq. [5])
    R(ipart) = R(ipart)+epsx;
    C(ipart) = C(ipart)+epsy;
end;	

%====================================================================== 
% STEP 4: Non-particle discrimination
%====================================================================== 

sigx = 0.1;
sigy = 0.1;
prob = zeros(size(m0));
Nm = length(m0);
for i=1:Nm,
    prob(i)=sum(exp(-((m0(i)-m0).^2./(2*sigx))-((m2(i)-m2).^2./...
        (2*sigy)))/(2*pi*sigx*sigy*Nm));
end;
    
if viz == 1,
    figure(20)
    clf
    figure(nfig)
    nfig = nfig + 1;
    subplot(2,2,1)
    hold on
    m0in = m0(find(prob >= cutoff));
    m2in = m2(find(prob >= cutoff));
    plot(m0in,m2in,'go')
    m0in = m0(find(prob < cutoff));
    m2in = m2(find(prob < cutoff));
    plot(m0in,m2in,'ro')
    hold off
    xlabel('m0')
    ylabel('m2')
    subplot(2,2,2)
    hist(m0,50)
    xlabel('m0')
    subplot(2,2,3)
    hist(m2,50)
    xlabel('m2')
end;

% indices of valid particles
tmp = find(prob>=cutoff);  
% pack data into return value
npart = length(tmp);
peak = zeros(npart,6);
peak(:,2) = R(tmp);       % row position
peak(:,1) = C(tmp);       % col position
peak(:,3) = m0(tmp);      % zero order moment
peak(:,4) = m2(tmp);      % second order moment
% field 5: unused
% field 6: used by linker to store linked list indices

%====================================================================== 
% STEP 5: Visualization
%====================================================================== 

if viz == 1,
    % plot crosses at particle positions
    C = peak(:,1);
    R = peak(:,2);
    X = [[C'-2; C'+2], [C'; C']];
    Y = [[R'; R'], [R'-2; R'+2]];

    figure(nfig)
    nfig = nfig + 1
    imshow(orig)
    hold on
    hand = line(X,Y);
    set(hand(:),'Color',[1 0 0]);
    set(hand(:),'LineWidth',[1.1]);
    hold off
end;

peak = {peak};

return

