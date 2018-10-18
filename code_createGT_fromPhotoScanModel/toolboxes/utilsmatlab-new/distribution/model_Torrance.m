function[fr]=model_Torrance(L,norms_pix)
%model_Torrance - function to calculate a bidirectional reflectance distribution function based on the Torrance-Sparrow model   
% Syntax: fr = model_Torrance(L,norms_pix)
%
% Inputs:
%    L -  light structure. the necessary fields are viewDir (Direction of
%    source light), m (roughness parameter), intens (intensity of light)
%    norms_pix - normal vectors on the surface for each pixel
% Outputs:
% fr - bidirectional reflectance distribution function
%
% Author: Raquel Jalvo
% email: raquel.jalvo@gmail.com
% Feb 2011

m=L.m;
cosbeta=(L.viewDir(1).*norms_pix(:,1)+L.viewDir(2).*norms_pix(:,2)+L.viewDir(3).*norms_pix(:,3));
tanbeta2=(1-cosbeta.^2)./cosbeta.^2;
cosbeta(cosbeta<0)=1;
D=exp(-tanbeta2./m^2)./(4*m^2*cosbeta.^2);
G=min([ones(size(cosbeta)), 2*cosbeta.^2],[],2);
F=1+cosbeta;
fr=D.*G.*F./cosbeta;
