% Intrinsic and Extrinsic Camera Parameters
%
% This script file can be directly excecuted under Matlab to recover the camera intrinsic and extrinsic parameters.
% IMPORTANT: This file contains neither the structure of the calibration objects nor the image coordinates of the calibration points.
%            All those complementary variables are saved in the complete matlab data file Calib_Results.mat.
% For more information regarding the calibration model visit http://www.vision.caltech.edu/bouguetj/calib_doc/


%-- Focal length:
fc = [ 3643.413156945455700 ; 3659.404579900934600 ];

%-- Principal point:
cc = [ 2272.587689478375500 ; 1518.463661035868000 ];

%-- Skew coefficient:
alpha_c = 0.000000000000000;

%-- Distortion coefficients:
kc = [ -0.069360039791116 ; -0.860901811542018 ; -0.003329641436913 ; -0.002006709464353 ; 0.000000000000000 ];

%-- Focal length uncertainty:
fc_error = [ 12.720655326923827 ; 12.468854835969307 ];

%-- Principal point uncertainty:
cc_error = [ 20.112414345412404 ; 18.257450812070751 ];

%-- Skew coefficient uncertainty:
alpha_c_error = 0.000000000000000;

%-- Distortion coefficients uncertainty:
kc_error = [ 0.043019791882661 ; 1.351236253572859 ; 0.001517942498355 ; 0.001585101714976 ; 0.000000000000000 ];

%-- Image size:
nx = 4608;
ny = 3072;


%-- Various other variables (may be ignored if you do not use the Matlab Calibration Toolbox):
%-- Those variables are used to control which intrinsic parameters should be optimized

n_ima = 11;						% Number of calibration images
est_fc = [ 1 ; 1 ];					% Estimation indicator of the two focal variables
est_aspect_ratio = 1;				% Estimation indicator of the aspect ratio fc(2)/fc(1)
center_optim = 1;					% Estimation indicator of the principal point
est_alpha = 0;						% Estimation indicator of the skew coefficient
est_dist = [ 1 ; 1 ; 1 ; 1 ; 0 ];	% Estimation indicator of the distortion coefficients


%-- Extrinsic parameters:
%-- The rotation (omc_kk) and the translation (Tc_kk) vectors for every calibration image and their uncertainties

%-- Image #1:
omc_1 = [ -2.141497e+00 ; -2.103941e+00 ; -2.196965e-01 ];
Tc_1  = [ -3.965997e+01 ; -5.495150e+01 ; 4.691980e+02 ];
omc_error_1 = [ 3.872963e-03 ; 4.553486e-03 ; 8.590538e-03 ];
Tc_error_1  = [ 2.598780e+00 ; 2.347275e+00 ; 1.624192e+00 ];

%-- Image #2:
omc_2 = [ -1.913370e+00 ; -1.893103e+00 ; -6.958395e-01 ];
Tc_2  = [ -4.325655e+01 ; -3.381377e+01 ; 5.711506e+02 ];
omc_error_2 = [ 3.074575e-03 ; 4.936326e-03 ; 7.433834e-03 ];
Tc_error_2  = [ 3.153808e+00 ; 2.851606e+00 ; 2.034721e+00 ];

%-- Image #3:
omc_3 = [ -2.133022e+00 ; -1.870313e+00 ; -1.209984e+00 ];
Tc_3  = [ -4.112422e+01 ; -1.815799e+01 ; 5.238086e+02 ];
omc_error_3 = [ 2.860844e-03 ; 5.558401e-03 ; 7.985511e-03 ];
Tc_error_3  = [ 2.892554e+00 ; 2.614881e+00 ; 1.912666e+00 ];

%-- Image #4:
omc_4 = [ -1.364457e+00 ; -1.761770e+00 ; -2.072390e-02 ];
Tc_4  = [ -4.220510e+01 ; -6.004250e+01 ; 5.084794e+02 ];
omc_error_4 = [ 3.817327e-03 ; 4.778353e-03 ; 5.761719e-03 ];
Tc_error_4  = [ 2.812102e+00 ; 2.541405e+00 ; 1.690111e+00 ];

%-- Image #5:
omc_5 = [ NaN ; NaN ; NaN ];
Tc_5  = [ NaN ; NaN ; NaN ];
omc_error_5 = [ NaN ; NaN ; NaN ];
Tc_error_5  = [ NaN ; NaN ; NaN ];

%-- Image #6:
omc_6 = [ -1.866827e+00 ; -1.865635e+00 ; 5.167352e-01 ];
Tc_6  = [ -8.531980e+01 ; -4.802462e+01 ; 5.533624e+02 ];
omc_error_6 = [ 5.063010e-03 ; 3.818053e-03 ; 7.061012e-03 ];
Tc_error_6  = [ 3.074554e+00 ; 2.777121e+00 ; 1.763766e+00 ];

%-- Image #7:
omc_7 = [ -2.136026e+00 ; -2.029449e+00 ; 3.552896e-01 ];
Tc_7  = [ -7.758113e+01 ; -5.846960e+01 ; 6.030369e+02 ];
omc_error_7 = [ 5.197278e-03 ; 3.700022e-03 ; 8.236143e-03 ];
Tc_error_7  = [ 3.343945e+00 ; 3.019066e+00 ; 1.975924e+00 ];

%-- Image #8:
omc_8 = [ 2.117610e+00 ; 2.104270e+00 ; -6.872361e-02 ];
Tc_8  = [ -5.104568e+01 ; -5.157120e+01 ; 6.002305e+02 ];
omc_error_8 = [ 4.194853e-03 ; 4.503977e-03 ; 9.490474e-03 ];
Tc_error_8  = [ 3.318983e+00 ; 2.997888e+00 ; 2.016717e+00 ];

%-- Image #9:
omc_9 = [ 1.838717e+00 ; 1.855862e+00 ; 3.814585e-01 ];
Tc_9  = [ -3.208942e+01 ; -5.559921e+01 ; 4.944331e+02 ];
omc_error_9 = [ 4.462815e-03 ; 3.860315e-03 ; 7.034996e-03 ];
Tc_error_9  = [ 2.735541e+00 ; 2.467150e+00 ; 1.704923e+00 ];

%-- Image #10:
omc_10 = [ 1.888304e+00 ; 1.819402e+00 ; 1.036558e+00 ];
Tc_10  = [ -2.784920e+01 ; -4.023422e+01 ; 4.310911e+02 ];
omc_error_10 = [ 5.550991e-03 ; 3.267452e-03 ; 6.930723e-03 ];
Tc_error_10  = [ 2.384834e+00 ; 2.151330e+00 ; 1.571715e+00 ];

%-- Image #11:
omc_11 = [ 2.120255e+00 ; 2.003399e+00 ; 9.878376e-01 ];
Tc_11  = [ -3.817294e+01 ; -4.149677e+01 ; 4.898586e+02 ];
omc_error_11 = [ 5.687609e-03 ; 2.723575e-03 ; 7.746430e-03 ];
Tc_error_11  = [ 2.709766e+00 ; 2.445861e+00 ; 1.763220e+00 ];

