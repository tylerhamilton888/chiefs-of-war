"""Prepare generated complete-body sprite sheets without synthesizing body parts."""
import json
from pathlib import Path
import numpy as np
from PIL import Image
from scipy import ndimage
root=Path(__file__).resolve().parents[1]
assets=root/'assets/frontier'
resources=root/'resources/frontier'
# Isolate the eight already-drawn poses before packing; their bounding boxes overlap.
im=Image.open(assets/'source/devour.png').convert('RGBA')
a=np.asarray(im)
labels,n=ndimage.label(a[:,:,3]>100)
main=[]
for k,sl in enumerate(ndimage.find_objects(labels),1):
    if sl and np.count_nonzero(labels[sl]==k)>1000:
        y,x=sl;main.append((k,x.start,y.start,x.stop,y.stop))
assert len(main)==8, main
main.sort(key=lambda b:b[2]+b[4]);main=sorted(main[:4],key=lambda b:b[1])+sorted(main[4:],key=lambda b:b[1])
core=np.isin(labels,[b[0] for b in main])
_,inds=ndimage.distance_transform_edt(~core,return_indices=True)
nearest=labels[inds[0],inds[1]]
canvas=np.zeros((1200,2560,4),dtype=np.uint8)
anchors=[(150,446),(575,445),(930,447),(1255,451),(150,953),(575,958),(925,958),(1255,958)]
for i,(k,x0,y0,x1,y1) in enumerate(main):
    mask=(nearest==k)&(a[:,:,3]>=8)
    yy,xx=np.nonzero(mask)
    sx0=max(0,xx.min()-2); sx1=min(im.width,xx.max()+3)
    sy0=max(0,yy.min()-2); sy1=min(im.height,yy.max()+3)
    part=a[sy0:sy1,sx0:sx1].copy();part[~mask[sy0:sy1,sx0:sx1]]=0
    ax,ay=anchors[i];dx=(i%4)*640+230+sx0-ax;dy=(i//4)*600+550+sy0-ay
    assert dx>=(i%4)*640 and dx+part.shape[1]<=(i%4+1)*640,(i,dx,part.shape)
    assert dy>=(i//4)*600 and dy+part.shape[0]<=(i//4+1)*600,(i,dy,part.shape)
    canvas[dy:dy+part.shape[0],dx:dx+part.shape[1]]=part
Image.fromarray(canvas,'RGBA').save(assets/'devour.png',optimize=True)
(resources/'devour.json').write_text(json.dumps({'height':400,'frames':[[i%4*640,i//4*600,640,600,230,550] for i in range(8)]},indent=2)+'\n')
# Log frames already have clear gutters. Keep their original pixels intact.
import shutil
shutil.copyfile(assets/'source/log_attack.png',assets/'log_attack.png')
logbounds=[(38,13,249,387),(369,114,621,387),(642,102,955,389),(970,114,1243,389),(39,412,265,796),(341,452,622,795),(630,507,980,795),(994,506,1230,797),(33,808,259,1184),(340,885,600,1186),(641,905,966,1194),(994,900,1236,1186)]
loganchors=[(145,383),(470,383),(770,385),(1095,385),(150,792),(468,792),(767,792),(1105,793),(145,1180),(470,1182),(767,1187),(1105,1182)]
frames=[]
for (x0,y0,x1,y1),(ax,ay) in zip(logbounds,loganchors):
    x0=max(0,x0-2);y0=max(0,y0-2);x1=min(1254,x1+2);y1=min(1254,y1+2)
    frames.append([x0,y0,x1-x0,y1-y0,ax-x0,ay-y0])
(resources/'log_attack.json').write_text(json.dumps({'height':315,'frames':frames},indent=2)+'\n')
print('Prepared 12 log and 8 feeding whole-body frames')
