% Intrinsic and Extrinsic Camera Parameters
%
% This script file can be directly excecuted under Matlab to recover the camera intrinsic and extrinsic parameters.
% IMPORTANT: This file contains neither the structure of the calibration objects nor the image coordinates of the calibration points.
%            All those complementary variables are saved in the complete matlab data file Calib_Results.mat.
% For more information regarding the calibration model visit http://www.vision.caltech.edu/bouguetj/calib_doc/


%-- Focal length:
fc = [ 3982.776989125465200 ; 3995.224265962334400 ];

%-- Principal point:
cc = [ 1112.443740622045200 ; 800.871962066576770 ];

%-- Skew coefficient:
alpha_c = 0.000000000000000;

%-- Distortion coefficients:
kc = [ 0.037086551319806 ; -0.700280181382670 ; -0.000464680354597 ; -0.009510801148485 ; 0.000000000000000 ];

%-- Focal length uncertainty:
fc_error = [ 6.979835144445035 ; 6.836474324824048 ];

%-- Principal point uncertainty:
cc_error = [ 8.988985900237292 ; 8.569312163272512 ];

%-- Skew coefficient uncertainty:
alpha_c_error = 0.000000000000000;

%-- Distortion coefficients uncertainty:
kc_error = [ 0.024847584972210 ; 0.749233198041976 ; 0.000812904820625 ; 0.000874004472390 ; 0.000000000000000 ];

%-- Image size:
nx = 2400;
ny = 1600;


%-- Various other variables (may be ignored if you do not use the Matlab Calibration Toolbox):
%-- Those variables are used to control which intrinsic parameters should be optimized

n_ima = 21;						% Number of calibration images
est_fc = [ 1 ; 1 ];					% Estimation indicator of the two focal variables
est_aspect_ratio = 1;				% Estimation indicator of the aspect ratio fc(2)/fc(1)
center_optim = 1;					% Estimation indicator of the principal point
est_alpha = 0;						% Estimation indicator of the skew coefficient
est_dist = [ 1 ; 1 ; 1 ; 1 ; 0 ];	% Estimation indicator of the distortion coefficients


%-- Extrinsic parameters:
%-- The rotation (omc_kk) and the translation (Tc_kk) vectors for every calibration image and their uncertainties

%-- Image #1:
omc_1 = [ -2.114782e+00 ; -2.124332e+00 ; -1.570687e-01 ];
Tc_1  = [ -9.512001e-03 ; -9.600605e-03 ; 7.365139e-02 ];
omc_error_1 = [ 1.487041e-03 ; 1.734586e-03 ; 3.737184e-03 ];
Tc_error_1  = [ 1.668564e-04 ; 1.587496e-04 ; 1.314039e-04 ];

%-- Image #2:
omc_2 = [ NaN ; NaN ; NaN ];
Tc_2  = [ NaN ; NaN ; NaN ];
omc_error_2 = [ NaN ; NaN ; NaN ];
Tc_error_2  = [ NaN ; NaN ; NaN ];

%-- Image #3:
omc_3 = [ -1.834563e+00 ; -2.018923e+00 ; 2.022613e-01 ];
Tc_3  = [ -9.482196e-03 ; -1.050544e-02 ; 7.813146e-02 ];
omc_error_3 = [ 1.679979e-03 ; 1.648057e-03 ; 2.932084e-03 ];
Tc_error_3  = [ 1.767996e-04 ; 1.679779e-04 ; 1.314489e-04 ];

%-- Image #4:
omc_4 = [ -1.637218e+00 ; -1.974407e+00 ; 3.757882e-01 ];
Tc_4  = [ -8.123961e-03 ; -1.257752e-02 ; 8.259742e-02 ];
omc_error_4 = [ 1.797228e-03 ; 1.688909e-03 ; 2.703681e-03 ];
Tc_error_4  = [ 1.871672e-04 ; 1.773726e-04 ; 1.355409e-04 ];

%-- Image #5:
omc_5 = [ NaN ; NaN ; NaN ];
Tc_5  = [ NaN ; NaN ; NaN ];
omc_error_5 = [ NaN ; NaN ; NaN ];
Tc_error_5  = [ NaN ; NaN ; NaN ];

%-- Image #6:
omc_6 = [ NaN ; NaN ; NaN ];
Tc_6  = [ NaN ; NaN ; NaN ];
omc_error_6 = [ NaN ; NaN ; NaN ];
Tc_error_6  = [ NaN ; NaN ; NaN ];

%-- Image #7:
omc_7 = [ -1.315830e+00 ; -1.855006e+00 ; 6.301214e-01 ];
Tc_7  = [ -4.964856e-03 ; -1.388366e-02 ; 8.785380e-02 ];
omc_error_7 = [ 1.921917e-03 ; 1.818551e-03 ; 2.398155e-03 ];
Tc_error_7  = [ 1.990970e-04 ; 1.883814e-04 ; 1.398035e-04 ];

%-- Image #8:
omc_8 = [ NaN ; NaN ; NaN ];
Tc_8  = [ NaN ; NaN ; NaN ];
omc_error_8 = [ NaN ; NaN ; NaN ];
Tc_error_8  = [ NaN ; NaN ; NaN ];

%-- Image #9:
omc_9 = [ -2.245600e+00 ; -2.152043e+00 ; -3.661529e-01 ];
Tc_9  = [ -9.385048e-03 ; -8.931857e-03 ; 7.660741e-02 ];
omc_error_9 = [ 1.527359e-03 ; 1.935423e-03 ; 3.874516e-03 ];
Tc_error_9  = [ 1.736076e-04 ; 1.642738e-04 ; 1.366763e-04 ];

%-- Image #10:
omc_10 = [ NaN ; NaN ; NaN ];
Tc_10  = [ NaN ; NaN ; NaN ];
omc_error_10 = [ NaN ; NaN ; NaN ];
Tc_error_10  = [ NaN ; NaN ; NaN ];

%-- Image #11:
omc_11 = [ NaN ; NaN ; NaN ];
Tc_11  = [ NaN ; NaN ; NaN ];
omc_error_11 = [ NaN ; NaN ; NaN ];
Tc_error_11  = [ NaN ; NaN ; NaN ];

%-- Image #12:
omc_12 = [ NaN ; NaN ; NaN ];
Tc_12  = [ NaN ; NaN ; NaN ];
omc_error_12 = [ NaN ; NaN ; NaN ];
Tc_error_12  = [ NaN ; NaN ; NaN ];

%-- Image #13:
omc_13 = [ 2.023276e+00 ; 1.558809e+00 ; 9.375587e-01 ];
Tc_13  = [ -5.804320e-03 ; -7.566125e-03 ; 7.618110e-02 ];
omc_error_13 = [ 2.311123e-03 ; 1.302097e-03 ; 2.930027e-03 ];
Tc_error_13  = [ 1.724521e-04 ; 1.630792e-04 ; 1.448683e-04 ];

%-- Image #14:
omc_14 = [ NaN ; NaN ; NaN ];
Tc_14  = [ NaN ; NaN ; NaN ];
omc_error_14 = [ NaN ; NaN ; NaN ];
Tc_error_14  = [ NaN ; NaN ; NaN ];

%-- Image #15:
omc_15 = [ NaN ; NaN ; NaN ];
Tc_15  = [ NaN ; NaN ; NaN ];
omc_error_15 = [ NaN ; NaN ; NaN ];
Tc_error_15  = [ NaN ; NaN ; NaN ];

%-- Image #16:
omc_16 = [ 2.053386e+00 ; 2.049400e+00 ; -3.207728e-01 ];
Tc_16  = [ -8.368290e-03 ; -9.933984e-03 ; 8.927782e-02 ];
omc_error_16 = [ 1.659751e-03 ; 2.002560e-03 ; 3.386423e-03 ];
Tc_error_16  = [ 2.018746e-04 ; 1.915689e-04 ; 1.489395e-04 ];

%-- Image #17:
omc_17 = [ NaN ; NaN ; NaN ];
Tc_17  = [ NaN ; NaN ; NaN ];
omc_error_17 = [ NaN ; NaN ; NaN ];
Tc_error_17  = [ NaN ; NaN ; NaN ];

%-- Image #18:
omc_18 = [ -2.039859e+00 ; -2.092567e+00 ; -2.068978e-01 ];
Tc_18  = [ -9.862552e-03 ; -1.003731e-02 ; 7.972819e-02 ];
omc_error_18 = [ 1.409791e-03 ; 1.743840e-03 ; 3.535818e-03 ];
Tc_error_18  = [ 1.805304e-04 ; 1.718611e-04 ; 1.428365e-04 ];

%-- Image #19:
omc_19 = [ NaN ; NaN ; NaN ];
Tc_19  = [ NaN ; NaN ; NaN ];
omc_error_19 = [ NaN ; NaN ; NaN ];
Tc_error_19  = [ NaN ; NaN ; NaN ];

%-- Image #20:
omc_20 = [ NaN ; NaN ; NaN ];
Tc_20  = [ NaN ; NaN ; NaN ];
omc_error_20 = [ NaN ; NaN ; NaN ];
Tc_error_20  = [ NaN ; NaN ; NaN ];

%-- Image #21:
omc_21 = [ -1.876402e+00 ; -1.903264e+00 ; -4.081928e-01 ];
Tc_21  = [ -8.767960e-03 ; -9.644413e-03 ; 9.091249e-02 ];
omc_error_21 = [ 1.346875e-03 ; 1.876414e-03 ; 3.038305e-03 ];
Tc_error_21  = [ 2.056595e-04 ; 1.955968e-04 ; 1.642569e-04 ];

