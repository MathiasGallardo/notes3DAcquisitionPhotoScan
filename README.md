# Notes on Creating Real Data for Testing and Validating 3D Reconstruction Methods from Agisoft Photoscan

## Description

Most of methods developed in EnCoV deal with 3D reconstruction and require ground-truth 3D shape to test and validate them.
We propose in this document one pipeline using the Structure-from-Motion (SfM) technique of PhotoScan Agisoft and the camera calibration of Agisoft Lens to reconstruct 3D textured shapes, i.e a digital 3D model with its texture, from a set of RGB images.

Note that other methods such as structured-light system can be used to acquire ground-truth 3D shapes.

