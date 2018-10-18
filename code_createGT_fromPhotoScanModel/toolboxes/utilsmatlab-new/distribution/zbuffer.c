
#include <mex.h>
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


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	/*mex function to perform zbuffering. This is called by the matlab function z_bufferMesh.m. It is not advisable to call this function without wrapping it with
	//z_bufferMesh.m because this is research code and does not do important things like error checking (e.g. ensuring the arguments are correct etc.)
	//Proper documentation will come shortly.
	//Toby Collins 2010
	//toby.collins@gmail.com*/
	double *x, *y;
	mwSize noTris, noTestPoints, noVerts;
	int *ptriInds1,*ptriInds2,*ptriInds3;
	int *pBaryTriInds;
	double *pVertsX, *pVertsY,*pPointsX,*pPointsY, *pBaryA,*pBaryB,*pBaryC,*pVertsDepth,*pzDepth;
	double A,B,C,D,E,F,alpha,beta,dv1,dv2,dv3,dd,maxDepth;
	double  xmin, ymin, xmax, ymax;
	int xminI, yminI, xmaxI, ymaxI;
	/*double B;*/
	mxArray *mexBaryTriInds, *mexBaryA, *mexBaryB,*mexBaryC;

	long i,j;
	bool cond1,cond2,cond3,cond4,useDepth;

	double ptx,pty;
	int xx,yy;
	int colLen;

	double *withTexMapMask;
	bool withtMapMsh;
	mxArray *tmapMask;
	double *tmapMask_data;
	double *texvertX,*texvertY;
	double tmapx,tmapy;
	int tmapH,tmapW;
	double Height_tmap;
	const mwSize *dims_tmap;
    
    int ndim;


	noTris = mxGetM(prhs[4]);
	noVerts = mxGetM(prhs[2]);
	ndim = mxGetNumberOfDimensions(prhs[0]);
	int dims = mxGetDimensions(prhs[0]);


	int Height = (mxGetPr(prhs[0]))[0];
	int Width = (mxGetPr(prhs[1]))[0];
	colLen=Height;
	plhs[0] = mxCreateNumericMatrix(Height, Width, mxINT32_CLASS, mxREAL);
	plhs[1] = mxCreateDoubleMatrix(Height, Width,mxREAL);
	if (nlhs > 2)
	{	
		plhs[2] = mxCreateDoubleMatrix(Height, Width, mxREAL);
		plhs[3] = mxCreateDoubleMatrix(Height, Width, mxREAL);
		plhs[4] = mxCreateDoubleMatrix(Height, Width, mxREAL); /*depth*/
	}
	pVertsX = mxGetPr(prhs[2]);
	pVertsY = mxGetPr(prhs[3]);
	pVertsDepth = mxGetPr(prhs[7]);
	withTexMapMask = (double *)mxGetPr(prhs[8]);
	withtMapMsh = withTexMapMask[0]>0;
	if (withtMapMsh)
	{
		dims_tmap = mxGetDimensions(prhs[9]);
		tmapH = (int)dims_tmap[0];
		tmapW = (int)dims_tmap[1];
		tmapMask = mxGetPr(prhs[9]);
		tmapMask_data = (double *) mxGetPr(prhs[9]);
		texvertX=(double *) mxGetPr(prhs[10]);
		texvertY=(double *) mxGetPr(prhs[11]);
	}
	ptriInds1=(int *) mxGetPr(prhs[4]);
	ptriInds2=(int *) mxGetPr(prhs[5]);
	ptriInds3=(int *) mxGetPr(prhs[6]);
	pBaryTriInds =(int *) mxGetPr(plhs[0]);
	pzDepth = (double *)mxGetPr(plhs[1]);
	if (nlhs > 2)
	{
		pBaryA = (double *)mxGetPr(plhs[2]);
		pBaryB = (double *)mxGetPr(plhs[3]);
		pBaryC = (double *)mxGetPr(plhs[4]);
	}
	maxDepth = -LARGE;
	for(i = 0; i < noVerts; i++)
	{
		if (pVertsDepth[i]> maxDepth)
		{
			maxDepth=pVertsDepth[i];
		}
	}
	maxDepth=maxDepth+1;
	for(i = 0; i < Height*Width; i++)
	{
		pzDepth[i]=maxDepth;
	}
	if (maxDepth==0)
	{
		useDepth=false;
	}
	else
	{
		useDepth=true;
	}
	for(j = 0; j < noTris; j++)
	{
		A = pVertsX[ptriInds1[j]-1]-pVertsX[ptriInds3[j]-1];
		B =pVertsX[ptriInds2[j]-1]-pVertsX[ptriInds3[j]-1];
		D =pVertsY[ptriInds1[j]-1]-pVertsY[ptriInds3[j]-1];
		E =pVertsY[ptriInds2[j]-1]-pVertsY[ptriInds3[j]-1];
		dv1 =                pVertsDepth[ptriInds1[j]-1];
		dv2 =                pVertsDepth[ptriInds2[j]-1];
		dv3 =                pVertsDepth[ptriInds3[j]-1];
		xmin = (min(min(pVertsX[ptriInds1[j]-1],pVertsX[ptriInds2[j]-1]),pVertsX[ptriInds3[j]-1]));
		ymin = (min(min(pVertsY[ptriInds1[j]-1],pVertsY[ptriInds2[j]-1]),pVertsY[ptriInds3[j]-1]));
		xmax = (max(max(pVertsX[ptriInds1[j]-1],pVertsX[ptriInds2[j]-1]),pVertsX[ptriInds3[j]-1]));
		ymax = (max(max(pVertsY[ptriInds1[j]-1],pVertsY[ptriInds2[j]-1]),pVertsY[ptriInds3[j]-1]));
		xminI = max(1,floor(xmin)-1);
		yminI = max(1,floor(ymin)-1);
		xmaxI = min(ceil(xmax)+1,Width);
		ymaxI = min(ceil(ymax)+1,Height);
		for(xx = xminI-1; xx < xmaxI-1; xx++)
		{
			for(yy = yminI-1; yy < ymaxI-1; yy++)
			{
				ptx = xx+0.5;
				pty = yy+0.5;
				C =pVertsX[ptriInds3[j]-1]-ptx;
				F =pVertsY[ptriInds3[j]-1]-pty;
				alpha = (B*(F)-C*(E))/(A*(E)-B*(D));
				beta  = (A*(F)-C*(D))/(B*(D)-A*(E));
				if (alpha>=0&&beta>=0&&alpha+beta<=1)
				{
					if (withtMapMsh)
					{
						tmapx = texvertX[ptriInds1[j]-1]*alpha+texvertX[ptriInds2[j]-1]*beta+(1-alpha-beta)*texvertX[ptriInds3[j]-1];
						tmapy = texvertY[ptriInds1[j]-1]*alpha+texvertY[ptriInds2[j]-1]*beta+(1-alpha-beta)*texvertY[ptriInds3[j]-1];
						tmapx=tmapx-1;
						tmapy=tmapy-1;
						tmapx = max(0,floor(tmapx)-1);
						tmapx = min(tmapW-1,ceil(tmapx));
						tmapy = max(0,floor(tmapy)-1);
						tmapy = min(tmapH-1,ceil(tmapy));
						if (tmapMask_data[((int)tmapx*tmapH)+(int)tmapy]<=0)
						{
							continue;
						}
					}
					/*work out depth*/
					dd=dv1*alpha+dv2*beta+dv3*(1-alpha-beta);              
					if (dd<(pzDepth[(xx*colLen)+yy] ))
					{
						pBaryTriInds[(xx*colLen)+yy] =j+1;
						pzDepth[(xx*colLen)+yy] =dd;
						if (nlhs > 2)
						{
							pBaryA[(xx*colLen)+yy] =alpha;
							pBaryB[(xx*colLen)+yy] =beta;
							pBaryC[(xx*colLen)+yy] =1-alpha-beta;
						}

					}
				}        
			}

		}
	}
}
