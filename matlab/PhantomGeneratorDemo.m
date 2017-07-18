% Script to generate analytical phantoms that can be used to test
% reconstruction algorithms.
% If one needs to modify/add phantoms just edit PhantomLibrary.dat
% ver 0.1, 1.07.17

close all;clc;clear all;
% adding paths
addpath('../models/'); addpath('supp/'); 

ModelNo = 42; % Select a model (0 - 43  )
% Define phantom dimension
N = 512; % x-y size (squared image)

% generate the 2D phantom:
[G] = buildPhantom(ModelNo,N);
figure(1); imshow(G, []);

%%
% run this once to compile
cd supp
mex DeformObject_C.c CFLAGS="\$CFLAGS -fopenmp -Wall -std=c99" LDFLAGS="\$LDFLAGS -fopenmp"
cd ..
%%
% perform deformation according to the tranform proposed in the paper [1] (see readme file)
FocalP = 2.5; % focal point distance
RFP = 1./FocalP;
AngleTransform = 15; % angle in degrees

% deform forward
DeformType = 0; % 0 - forward deformation
G_deformed = DeformObject_C(G, RFP, AngleTransform, DeformType);
% deform back
DeformType = 1; % 1 - inverse 
G_inv = DeformObject_C(G_deformed, RFP, AngleTransform, DeformType);
figure; 
subplot(1,2,1); imshow(G_deformed, []); title('Deformed Phantom');
subplot(1,2,2); imshow(G_inv, []); title('Inversely Deformed Phantom');
MSE = norm(G_inv(:) - G(:))./norm(G(:));
fprintf('%s %f \n', 'Error (MSE)', MSE);
%%