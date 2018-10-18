
#include "mex.h"
#include <math.h>

#ifndef NOMINMAX
#ifndef max
#define max(a,b) (((a) > (b)) ? (a) : (b))
#endif
#ifndef min
#define min(a,b) (((a) < (b)) ? (a) : (b))
#endif
#endif 

#define LARGE 1e12

void computeBary2d(float x0,float y0,float x1,float y1,float x2,float y2,float xx,float yy,float &alpha,float &beta)
{

	float A = x0-x2;
	float B = x1-x2;
	float D = y0-y2;
	float E = y1-y2;
	float C =x2-xx;
	float F =y2-yy;
	alpha = (B*(F)-C*(E))/(A*(E)-B*(D));
	beta  = (A*(F)-C*(D))/(B*(D)-A*(E));
}


void computeBary3d(float &a, float &b, float x, float y, float z, float *p0, float *p1, float *p2)
{

	float p0x = p0[0];
	float p0y= p0[1];
	float p0z= p0[2];
	float p1x= p1[0];
	float p1y= p1[1];
	float p1z= p1[2];
	float p2x= p2[0];
	float p2y= p2[1];
	float p2z= p2[2];
	a = (p1y*p2z*x - p2y*p1z*x - p1x*p2z*y + p2x*p1z*y + p1x*p2y*z - p2x*p1y*z)/(p0x*p1y*p2z - p0x*p2y*p1z - p1x*p0y*p2z + p1x*p2y*p0z + p2x*p0y*p1z - p2x*p1y*p0z);
	b = -(p0y*p2z*x - p2y*p0z*x - p0x*p2z*y + p2x*p0z*y + p0x*p2y*z - p2x*p0y*z)/(p0x*p1y*p2z - p0x*p2y*p1z - p1x*p0y*p2z + p1x*p2y*p0z + p2x*p0y*p1z - p2x*p1y*p0z);
}






void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
	const mxArray *prhs[])
{
	//mex function to perform zbuffering. This is called by the matlab function z_bufferMesh.m. It is not advisable to call this function without wrapping it with
	//z_bufferMesh.m because this is research code and does not do important things like error checking (e.g. ensuring the arguments are correct etc.)
	//Proper documentation will come shortly.
	//Toby Collins 2012
	//toby.collins@gmail.com

	const mwSize *rendDims = mxGetDimensions(prhs[0]);
	int rendH = (int)rendDims[0];
	int rendW = (int)rendDims[1];
	int numCol = (int)rendDims[2];

	const mwSize *vertexDims = mxGetDimensions(prhs[4]);
	int numVerts = (int)vertexDims[1];

	const mwSize *faceDims = mxGetDimensions(prhs[6]);
	int numFaces = (int)faceDims[1];


	const mwSize *tMapDims = mxGetDimensions(prhs[8]);
	int tmapH = (int)tMapDims[0];
	int tmapW = (int)tMapDims[1];
	int tmapNumCol = (int)tMapDims[2];
	bool hasTextureMap;


	/*0 rend
	1 rendMask
	2 dMap
	3 baryMap
	4 vs
	5 vsTexture
	6 T
	7 TTexture
	8 TmapImg
	9 vertexPosCam3d
	10 K third row must be 0 0 1
	*/



	float * rend_data;
	bool * rendMask_data;
	float * dMap_data;
	float * baryMap_data;
	float * vs_data;
	float * vsTexture_data;
	unsigned int * T_data;
	unsigned int * TTexture_data;

	float * TmapImg_data;
	float * v3dCam_data;
	float * faceNormals_data;
	float * Kinv_data;


	rend_data = (float *) mxGetPr(prhs[0]);
	rendMask_data = (bool *) mxGetPr(prhs[1]);
	dMap_data = (float *) mxGetPr(prhs[2]);
	baryMap_data = (float *) mxGetPr(prhs[3]);
	vs_data = (float *) mxGetPr(prhs[4]);
	vsTexture_data = (float *) mxGetPr(prhs[5]);
	T_data = (unsigned int *) mxGetPr(prhs[6]);
	TTexture_data = (unsigned int *) mxGetPr(prhs[7]);
	TmapImg_data = (float *) mxGetPr(prhs[8]);
	v3dCam_data = (float *) mxGetPr(prhs[9]);
	faceNormals_data = (float *) mxGetPr(prhs[10]);
	Kinv_data = (float *) mxGetPr(prhs[11]);

	 unsigned int mode  = ((unsigned int *) mxGetPr(prhs[12]))[0];
	 hasTextureMap =  ((bool *) mxGetPr(prhs[13]))[0];


	float x0, y0, x1, y1,x2, y2, A, B, C, D, E, F;
	float x0t, y0t, x1t, y1t,x2t, y2t;

	float dv0, dv1, dv2;
	float dd;
	unsigned int  v0, v1, v2;
	unsigned int  v0t, v1t, v2t;

	float xmin,ymin,xmax,ymax,alpha,beta;
	int xminI,yminI,xmaxI,ymaxI;
	float minDFace;
	float tmapu;
	float tmapv;

	float tmapx;
	float tmapy;

	float rx, ry, rz;
	float fnx, fny, fnz;
	float p0x, p0y, p0z;

	for(int j = 0; j < numFaces; j++)
	{
		v0 = T_data[j*3+0];
		v1 = T_data[j*3+1];
		v2 = T_data[j*3+2];

		x0 = vs_data[v0*2+0];
		y0 = vs_data[v0*2+1];

		x1 = vs_data[v1*2+0];
		y1 = vs_data[v1*2+1];

		x2 = vs_data[v2*2+0];
		y2 = vs_data[v2*2+1];

		fnx = faceNormals_data[j*3+0];
		fny = faceNormals_data[j*3+1];
		fnz = faceNormals_data[j*3+2];

		p0x =  v3dCam_data[3*v0];
		p0y =  v3dCam_data[3*v0+1];
		p0z =  v3dCam_data[3*v0+2];

		A = x0-x2;
		B = x1-x2;
		D = y0-y2;
		E = y1-y2;
		dv0 =                v3dCam_data[3*v0+2];
		dv1 =                v3dCam_data[3*v1+2];
		dv2 =                v3dCam_data[3*v2+2];

		if (dv0<0|dv1<0|dv2<0)
		{continue;
		}
		xmin = min(min(x0,x1),x2);
		ymin = min(min(y0,y1),y2);
		xmax = max(max(x0,x1),x2);
		ymax = max(max(y0,y1),y2);

		xminI = max(1,floor(xmin)-1);
		yminI = max(1,floor(ymin)-1);
		xmaxI = min(ceil(xmax)+1,rendW-1);
		ymaxI = min(ceil(ymax)+1,rendH-1);

		minDFace = min(min(dv0,dv1),dv2);
		for(int xx = xminI-1; xx < xmaxI+1; xx++)
		{
			for(int yy = yminI-1; yy < ymaxI+1; yy++)
			{
				if (minDFace>dMap_data[(xx*rendH)+yy])
				{
					continue;

				}
				//ptx = xx+0.5;
				//pty = yy+0.5;
				C =x2-xx;
				F =y2-yy;
				alpha = (B*(F)-C*(E))/(A*(E)-B*(D));
				beta  = (A*(F)-C*(D))/(B*(D)-A*(E));
				if (!(alpha>=0&&beta>=0&&alpha+beta<=1))
				{
					continue;
				}


				dd = p0x*fnx+ p0y*fny+p0z*fnz;


				rx = Kinv_data[0]*xx+Kinv_data[3]*yy+Kinv_data[6];
				ry = Kinv_data[1]*xx+Kinv_data[4]*yy+Kinv_data[7];
				rz = Kinv_data[2]*xx+Kinv_data[5]*yy+Kinv_data[8];

				dd = dd/(rx*fnx+ ry*fny+rz*fnz);
				if (dd<=0)
				{
					continue;
				}
				//dd=  dd*rz;

				computeBary3d(alpha,beta,rx*dd,ry*dd,dd,v3dCam_data+3*v0,v3dCam_data+3*v1,v3dCam_data+3*v2);



				//work out depth
				//dd=dv0*alpha+dv1*beta+dv2*(1-alpha-beta);       
				if (dd>(dMap_data[(xx*rendH)+yy] ))
				{
					continue;
				}
				if (hasTextureMap)
				{
				//do texture mapping
				v0t = TTexture_data[j*3+0];
				v1t = TTexture_data[j*3+1];
				v2t = TTexture_data[j*3+2];


				x0t = vsTexture_data[v0t*2+0];
				y0t = vsTexture_data[v0t*2+1];

				x1t = vsTexture_data[v1t*2+0];
				y1t = vsTexture_data[v1t*2+1];

				x2t = vsTexture_data[v2t*2+0];

				y2t = vsTexture_data[v2t*2+1];

				tmapu = x0t*alpha+x1t*beta+(1-alpha-beta)*x2t;
				tmapv = y0t*alpha+y1t*beta+(1-alpha-beta)*y2t;


				tmapx = tmapu*tmapW;
				tmapy = tmapH-tmapv*tmapH;

				tmapx = max(0,floor(tmapx)-1);
				tmapx = min(tmapW-1,ceil(tmapx));
				tmapy = max(0,floor(tmapy)-1);
				tmapy = min(tmapH-1,ceil(tmapy));
				
				rend_data[(xx*rendH)+yy] = TmapImg_data[((int)tmapx*tmapH)+(int)tmapy];
				rend_data[rendH*rendW+(xx*rendH)+yy] = TmapImg_data[tmapH*tmapW+((int)tmapx*tmapH)+(int)tmapy];
				rend_data[2*rendH*rendW+(xx*rendH)+yy] = TmapImg_data[2*tmapH*tmapW+((int)tmapx*tmapH)+(int)tmapy];
				}
				else
				{

				
				}

				//tmapx=tmapx-1;
				//tmapy=tmapy-1;



				//tmapx = max(0,floor(tmapx)-1);
				//tmapx = min(tmapW-1,ceil(tmapx));
				//tmapy = max(0,floor(tmapy)-1);
				//tmapy = min(tmapH-1,ceil(tmapy));
				//if (TmapImg_data[tmapH*tmapW*3+((int)tmapx*tmapH)+(int)tmapy]<=0)
				//{
				//		continue;
				//}
				dMap_data[(xx*rendH)+yy] = dd;
				if (mode==0)
				{continue;}

				baryMap_data[(xx*rendH)+yy] =j;
				baryMap_data[rendH*rendW+(xx*rendH)+yy] =alpha;
				baryMap_data[2*rendH*rendW+(xx*rendH)+yy] =beta;
				baryMap_data[3*rendH*rendW+(xx*rendH)+yy] =1-alpha-beta;
				rendMask_data[(xx*rendH)+yy] = 1;


			}

		}
	}
}
