#!/usr/bin/env python3
"""Generates Porto Sereno's painted textures (story-008): building palettes recoloured from the
Kenney City Kit Suburban colormap, tiled ground textures, and cumulus clouds.

Usage (from the project root):  python3 tools/generate_city_art.py
Needs numpy and Pillow. Output goes to assets/textures/. Deterministic (fixed seeds).
"""
import os
import numpy as np
from PIL import Image, ImageFilter
src,out='assets/models/suburban/Textures/colormap.png','assets/textures'
os.makedirs(out,exist_ok=True)
base=np.array(Image.open(src).convert('RGB')).astype(float)
ROOF=(0,128,64,256); WALL=(192,256,256,384); TRIM=(0,256,64,384)
def hexc(h): return np.array([int(h[i:i+2],16) for i in (0,2,4)],float)
def paint(a,cell,color):
    x0,y0,x1,y1=cell
    r=a[y0:y1,x0:x1]; lum=r.mean(axis=2); lum=lum/lum.mean()
    lum=1+(lum-1)*.3
    a[y0:y1,x0:x1]=np.clip(lum[...,None]*color,0,255)
pal=[('f5e7cc','c9674a','8a7a70'),('fbf6ea','4f93a6','7f8c94'),('f3d58f','b8553f','8c7762'),
     ('f2b9a0','9c5240','8a6a60'),('dfe9e2','6f9a78','76877e'),('fbf1dc','e08a4f','8f7f6f')]
for i,(w,rf,t) in enumerate(pal):
    a=base.copy(); paint(a,WALL,hexc(w)); paint(a,ROOF,hexc(rf)); paint(a,TRIM,hexc(t))
    Image.fromarray(a.astype('uint8')).resize((256,256),Image.BILINEAR).save(f'{out}/palette_{i}.png')
# clouds: fbm-warped blobs, flat painted white top, lilac base
rng=np.random.default_rng(7)
def fbm(h,w):
    t=np.zeros((h,w))
    for o in range(5):
        n=2**(o+2); g=rng.random((n,n*2))
        t+=np.array(Image.fromarray((g*255).astype('uint8')).resize((w,h),Image.BICUBIC))/255/2**o
    return t/t.max()
for c in range(3):
    h,w=256,512; yy,xx=np.mgrid[0:h,0:w]; f=np.zeros((h,w))
    for _ in range(14):
        cx=rng.uniform(.18,.82)*w; d=abs(cx-w/2)/(w/2); cy=h*.68-rng.uniform(0,.38)*h*(1-d); r=rng.uniform(.09,.2)*h*(1.5-d)
        f=np.maximum(f,1-np.hypot(xx-cx,(yy-cy)*1.05)/r/1.0)
    base_cut=np.clip((h*.72-yy)/8,0,1)
    n=fbm(h,w); body=np.clip(f*5,0,1)  # noise only frays the blobs: the rest of the quad stays clear
    mask=np.clip((f+(n-.5)*.35*body-.02)*14,0,1)*base_cut*(f>0)
    shade=np.clip((yy/h-.28+(n-.5)*.5-f*.25)*3.2,0,1)[...,None]
    top=np.array([255,252,244.]);low=np.array([196,208,232.])
    rgb=top*(1-shade)+low*shade
    img=np.dstack([rgb,mask*255]).astype('uint8')
    Image.fromarray(img,'RGBA').filter(ImageFilter.GaussianBlur(.8)).save(f'{out}/cloud_{c}.png')
# tileable painted ground textures
def wrapnoise(n,cells,seed):
    r=np.random.default_rng(seed);g=r.random((cells,cells))
    yy,xx=np.mgrid[0:n,0:n]/n*cells
    x0=xx.astype(int);y0=yy.astype(int);fx=xx-x0;fy=yy-y0
    fx=fx*fx*(3-2*fx);fy=fy*fy*(3-2*fy)
    x1=(x0+1)%cells;y1=(y0+1)%cells
    return (g[y0,x0]*(1-fx)+g[y0,x1]*fx)*(1-fy)+(g[y1,x0]*(1-fx)+g[y1,x1]*fx)*fy
def fbmw(n,seed,base=4,oct=5):
    t=sum(wrapnoise(n,base*2**o,seed+o)/2**o for o in range(oct));return (t-t.min())/(t.max()-t.min())
def cobble(n,cells,seed,jit,tone,mortar):
    r=np.random.default_rng(seed);ids=[];pts=[]
    for j in range(cells):
        for i in range(cells):
            ox=.5*(j%2)
            pts.append(((i+ox+.5+r.uniform(-jit,jit))/cells*n,(j+.5+r.uniform(-jit,jit))/cells*n))
    pts=np.array(pts);bright=1-r.random(len(pts))*tone
    yy,xx=np.mgrid[0:n,0:n];d=[]
    for sx in (-n,0,n):
        for sy in (-n,0,n):
            d.append(np.hypot(xx[...,None]-(pts[:,0]+sx),yy[...,None]-(pts[:,1]+sy)))
    d=np.concatenate(d,axis=2);idx=np.argpartition(d,1,axis=2)[...,:2]
    a=np.take_along_axis(d,idx,2);a.sort(axis=2);nearest=d.argmin(axis=2)%len(pts)
    edge=np.clip((a[...,1]-a[...,0])/(n/cells*.14),0,1)
    v=bright[nearest]*(mortar+(1-mortar)*edge)*(.93+.07*fbmw(n,seed+9))
    return v
def saveg(v,tint,name):
    img=np.clip(v[...,None]*np.array(tint)*255,0,255).astype('uint8');Image.fromarray(img).save(f'{out}/{name}.png')
saveg(cobble(256,9,3,.16,.09,.8),(1,.985,.96),'cobble')
saveg(cobble(256,5,4,.05,.05,.86),(1,.99,.97),'paving')
g=fbmw(256,20,3)*.6+fbmw(256,40,16,3)*.4
saveg(.84+.16*g,(.97,1,.93),'grass')
