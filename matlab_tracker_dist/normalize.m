%====================================================================== 
%
% NORMALIZE: Normalizes an image to intensities between 0 and 1
%
% SYNTAX:  out = normalize(in)
%
% INPUTS:  in       a cell list of image matrices
%
% The return value is a cell list (same length as in) of 
% normalized images havin all intensity values between 0
% and 1.
%
% Ivo Sbalzarini, 12.2.2003
% Institute of Computational Science, Swiss Federal
% Institute of Technology (ETH) Zurich. 
% E-mail: sbalzarini@inf.ethz.ch
%
%====================================================================== 

function varargout = normalize(varargin)

narg = nargin;
if(narg < 1)
   disp('normalize: too few input arguments')
   return;
end

for i=1:narg;
   in = varargin{i};
  	varargout(i) = {(in-min(in(:)))/(max(in(:))-min(in(:)))};
end

return;

